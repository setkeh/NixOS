{ config, lib, pkgs, ... }:
let
  # Get secrets from SOPS configuration
  db_password = (config.sops.secrets."DB_PASSWORD").decryptedValue;
in
{
  virtualisation.oci-containers = {
    backend = "docker";

    containers = {
      # Honcho API Service
      honcho-api = {
        image = "ghcr.io/nousresearch/honcho:latest";
        environmentFiles = [ config.sops.secrets."honcho/env".path ];
        ports = [
          "127.0.0.1:8000:8000"
        ];
      };

      # Honcho Deriver Service
      honcho-deriver = {
        image = "ghcr.io/nousresearch/honcho:latest";
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