{ config, lib, pkgs, ... }:
let
  # Get secrets from SOPS configuration
  honchoSecrets = config.sops.secrets."honcho/env";
in
{
  virtualisation.docker.containers = {

    # Honcho API Service
    honcho-api = {
      image = "ghcr.io/nousresearch/honcho:latest";
      environment = {
        LOG_LEVEL = honchoSecrets.LOG_LEVEL.text;
        DB_CONNECTION_URI = "postgresql+psycopg://${config.services.postgresql.packages.psql.package.name}:${honchoSecrets.DB_PASSWORD.text}@honcho-postgres:5432/postgres";
        CACHE_URL = "redis://honcho-redis:6379/0?suppress=true";
        CACHE_ENABLED = "true";
        LLM_GEMINI_API_KEY = honchoSecrets.LLM_GEMINI_API_KEY.text;
        AUTH_USE = honchoSecrets.AUTH_USE.text;
        AUTH_JWT_SECRET = honchoSecrets.AUTH_JWT_SECRET.text;
        METRICS_ENABLED = honchoSecrets.METRICS_ENABLED.text;
        METRICS_NAMESPACE = honchoSecrets.METRICS_NAMESPACE.text;
        VECTOR_STORE_TYPE = honchoSecrets.VECTOR_STORE_TYPE.text;
        VECTOR_STORE_MIGRATED = honchoSecrets.VECTOR_STORE_MIGRATED.text;
      };
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
      environment = {
        DB_CONNECTION_URI = "postgresql+psycopg://${config.services.postgresql.packages.psql.package.name}:${honchoSecrets.DB_PASSWORD.text}@honcho-postgres:5432/postgres";
        CACHE_URL = "redis://honcho-redis:6379/0?suppress=true";
        CACHE_ENABLED = "true";
        LLM_GEMINI_API_KEY = honchoSecrets.LLM_GEMINI_API_KEY.text;
        AUTH_USE = honchoSecrets.AUTH_USE.text;
        AUTH_JWT_SECRET = honchoSecrets.AUTH_JWT_SECRET.text;
        METRICS_ENABLED = honchoSecrets.METRICS_ENABLED.text;
        METRICS_NAMESPACE = honchoSecrets.METRICS_NAMESPACE.text;
        VECTOR_STORE_TYPE = honchoSecrets.VECTOR_STORE_TYPE.text;
        VECTOR_STORE_MIGRATED = honchoSecrets.VECTOR_STORE_MIGRATED.text;
      };
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
        POSTGRES_PASSWORD = honchoSecrets.DB_PASSWORD.text;
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
        POSTGRES_PASSWORD = honchoSecrets.DB_PASSWORD.text;
      };
    package = pkgs.postgresql_16;
    ensureDatabases = ["postgres"];
    ensureUsers = [ "postgres" ];
    settings = {
      max_connections = 200;
    };
  };
}