{ config, lib, pkgs, ... }:
let
  # Get secrets from SOPS configuration
  db_password = config.sops.secrets."DB_PASSWORD";
in
{
  virtualisation.docker.containers = {

    # Honcho API Service
    honcho-api = {
      image = "ghcr.io/nousresearch/honcho:latest";
      environmentFiles = [ config.sops.secrets."honcho/env".path ];
      ports = [
        "127.0.0.1:8000:8000"
      ];
      healthCheck = {
        test = "${pkgs.python3}/bin/python -c 'import urllib.request; urllib.request.urlopen(\"http://localhost:8000/health\", timeout=2).read()'";
        interval = "5s";
        timeout = "5s";
        retries = 5;
        startPeriod = "10s";
      };
      dependsOn = [
        {
          name = "honcho-postgres";
          condition = "service_healthy";
        }
        {
          name = "honcho-redis";
          condition = "service_healthy";
        }
      ];
    };

    # Honcho Deriver Service
    honcho-deriver = {
      image = "ghcr.io/nousresearch/honcho:latest";
      command = "/app/.venv/bin/python -m src.deriver";
      environmentFiles = [ config.sops.secrets."honcho/env".path ];
      dependsOn = [
        {
          name = "honcho-api";
          condition = "service_healthy";
        }
        {
          name = "honcho-postgres";
          condition = "service_healthy";
        }
        {
          name = "honcho-redis";
          condition = "service_healthy";
        }
      ];
    };

    # PostgreSQL with pgvector
    honcho-postgres = {
      image = "pgvector/pgvector:pg15";
      environment = {
        POSTGRES_DB = "postgres";
        POSTGRES_USER = "postgres";
        POSTGRES_PASSWORD = db_password.text;
      };
      ports = [
        "127.0.0.1:5432:5432"
      ];
      volumes = [
        "./database/init.sql:/docker-entrypoint-initdb.d/init.sql",
        "/etc/postgresql/honcho:/var/lib/postgresql/data"
      ];
      healthCheck = {
        test = ["CMD-SHELL", "pg_isready -U postgres -d postgres"];
        interval = "5s";
        timeout = "5s";
        retries = 5;
      };
    };

    # Redis
    honcho-redis = {
      image = "redis:8.2";
      ports = [
        "127.0.0.1:6379:6379"
      ];
      volumes = [
        "/etc/redis/honcho:/data"
      ];
      healthCheck = {
        test = ["CMD-SHELL", "redis-cli ping"];
        interval = "5s";
        timeout = "5s";
        retries = 5;
      };
    };
  };

  # PostgreSQL service configuration
  services.postgresql = {
    enable = true;
    environment = {
        POSTGRES_PASSWORD = db_password.text;
      };
    package = pkgs.postgresql_16;
    ensureDatabases = ["postgres"];
    ensureUsers = [ "postgres" ];
    settings = {
      max_connections = 200;
    };
  };
}