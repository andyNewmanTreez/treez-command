#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER andy WITH SUPERUSER;
    ALTER USER andy WITH SUPERUSER CREATEDB;
    CREATE DATABASE "product-api";
    GRANT ALL PRIVILEGES ON DATABASE "product-api" TO andy;
    CREATE USER goldentullis WITH SUPERUSER;
    ALTER USER goldentullis WITH SUPERUSER CREATEDB;
    GRANT ALL PRIVILEGES ON DATABASE "product-api" TO goldentullis;


EOSQL



#
#   psql -h localhost -U postgres product-api -c "CREATE USER andy WITH SUPERUSER"
#  547  psql -h localhost -U postgres product-api -c "ALTER USER andy WITH SUPERUSER CREATEDB"
#  548  psql -h localhost -U postgres -c "CREATE DATABASE \"product-api\";"\n
#  549  psql postgres -h localhost -U postgres  -d product-api < ~/Downloads/init-1-product-api-seed.sql \n
#  550  psql -c "CREATE EXTENSION IF NOT EXISTS pg_trgm;" product-api
#  551  psql postgres -h localhost -U postgres  product-api -c "CREATE EXTENSION IF NOT EXISTS pg_trgm;"\n
#  552  psql postgres -h localhost -U postgres  product-api -c "CREATE EXTENSION IF NOT EXISTS pg_trgm;" product-api;
#  553  psql postgres -h localhost -U postgres -d  product-api -c "CREATE EXTENSION IF NOT EXISTS pg_trgm;" product-api;
