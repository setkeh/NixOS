{ config, lib, pkgs, ... }:
let
  # Get secrets from SOPS configuration
  db_password = (config.sops.secrets."DB_PASSWORD").decryptedValue;

  # Turbopuffer (Standard PyPI Source Build)
  turbopuffer = pkgs.python311Packages.buildPythonPackage rec {
    pname = "turbopuffer";
    version = "0.1.8"; # Replace with the version in your uv.lock
    format = "setuptools";
    
    src = pkgs.python311Packages.fetchPypi {
      inherit pname version;
      # Run `nix run nixpkgs#nix-prefetch-github` or similar, 
      # or just leave it empty to let Nix error out and give you the correct hash
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Replace with actual SRI hash
    };
    
    doCheck = false; # Skip tests to speed up the build
    dependencies = with pkgs.python311Packages; [ requests ]; # Add its dependencies here
  };

  # 1. Fetch Honcho source directly from GitHub
  honchoSrc = pkgs.fetchFromGitHub {
    owner = "plastic-labs";
    repo = "honcho";
    rev = "main"; # Recommend pinning this to a specific commit or release tag
    hash = "sha256-FI9JO436dJD83tmyLTYSWNLSUkeErgGwId3ewI9j9ig="; # Replace with actual SRI hash
  };

  # 2. Package the Python Environment
  # Because Nix builds are sandboxed, you must define the dependencies here 
  # rather than relying on `uv sync` during the build phase.
  pythonEnv = pkgs.python313.withPackages (ps: with ps; [
    fastapi
    uvicorn
    sqlalchemy
    python-dotenv
    fastapi-pagination
    pgvector
    sentry-sdk
    greenlet
    psycopg
    httpx
    rich
    nanoid
    alembic
    pyjwt
    tenacity
    tiktoken
    langfuse
    openai
    pydantic
    pydantic-settings
    google-genai
    pdfplumber
    typing-extensions
    json-repair
    pyarrow
    redis
    cashews
    scikit-learn
    prometheus-client
    cloudevents
    lancedb
    turbopuffer
  ]);

  # 3. Build the Docker image purely in Nix
  honchoImage = pkgs.dockerTools.buildLayeredImage {
    name = "honcho-local";
    tag = "latest";
    created = "now";
    
    # Equivalent to the COPY commands in the Dockerfile
    contents = [
      pythonEnv
      pkgs.bashInteractive
      pkgs.coreutils
      # Replicate the WORKDIR /app structure and copy necessary source files
      (pkgs.runCommand "honcho-app-dir" {} ''
        mkdir -p $out/app
        cp -r ${honchoSrc}/src $out/app/
        cp -r ${honchoSrc}/migrations $out/app/
        cp -r ${honchoSrc}/scripts $out/app/
        cp -r ${honchoSrc}/alembic.ini $out/app/
      '')
    ];

    config = {
      Cmd = [ "${pythonEnv}/bin/fastapi" "run" "--host" "0.0.0.0" "/app/src/main.py" ];
      WorkingDir = "/app";
      ExposedPorts = {
        "8000/tcp" = {};
      };
      Env = [
        "PYTHONUNBUFFERED=1"
        "PYTHONDONTWRITEBYTECODE=1"
      ];
    };
  };
in
{
  virtualisation.oci-containers = {
    backend = "docker";

    # docker-honcho-api.service, docker-honcho-deriver.service, docker-honcho-postgres.service, docker-honcho-redis.service
    containers = {
      # Honcho API Service
      honcho-api = {
        image = "honcho-local:latest";
        imageFile = honchoImage;
        environmentFiles = [ config.sops.secrets."honcho/env".path ];
        ports = [
          "127.0.0.1:8000:8000"
        ];
      };

      # Honcho Deriver Service
      honcho-deriver = {
        image = "honcho-local:latest";
        imageFile = honchoImage;
        cmd = [ "/app/.venv/bin/python" "-m" "src.deriver" ];
        environmentFiles = [ config.sops.secrets."honcho/env".path ];
      };

      # PostgreSQL with pgvector
      honcho-postgres = {
        image = "pgvector/pgvector:pg15";
        environment = {
          POSTGRES_DB = "postgres";
          POSTGRES_USER = "postgres";
          POSTGRES_PASSWORD_FILE = "/run/secrets/db_password";
        };
        ports = [
          "127.0.0.1:5432:5432"
        ];
        volumes = [
          "/var/lib/sops/secrets/DB_PASSWORD:/run/secrets/db_password:ro"
          "./database/init.sql:/docker-entrypoint-initdb.d/init.sql"
          "/srv/2tb/postgresql/honcho:/var/lib/postgresql/data"
        ];
      };

      # Redis
      honcho-redis = {
        image = "redis:8.2";
        ports = [
          "127.0.0.1:6379:6379"
        ];
        volumes = [
          "/srv/ssd/redis/honcho:/data"
        ];
      };
    };
  };
}