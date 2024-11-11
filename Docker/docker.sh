# Create Dev DB image
docker build -t anuchitorigin/caige-db .
# Create BA_MAIN image
docker build -t anuchitorigin/caige-ba_main .
# Create BA_AUTH image
docker build -t anuchitorigin/caige-ba_auth .
# Create Frontend image
docker build -t anuchitorigin/caige-frontend .
# Prepare environment for multi-architecture image
# For more information: https://developer.arm.com/documentation/102475/0100/Multi-architecture-images
# Note: Use once before using command 'docker buildx build ...'
docker buildx create --name thebuilder
docker buildx use thebuilder
# Create and Push DB image
docker buildx build --platform linux/arm64,linux/amd64 -t anuchitorigin/caige-db --push .
# Create and Push BA_MAIN image
docker buildx build --platform linux/arm64,linux/amd64 -t anuchitorigin/caige-ba_main --push .
# Create and Push BA_AUTH image
docker buildx build --platform linux/arm64,linux/amd64 -t anuchitorigin/caige-ba_auth --push .
# Create and Push BA_DATA image
docker buildx build --platform linux/arm64,linux/amd64 -t anuchitorigin/caige-ba_data --push .
# Create and Push Frontend image
docker buildx build --platform linux/arm64,linux/amd64 -t anuchitorigin/caige-frontend --push .

# Create New DB container
docker compose -f compose.db.yml up -d
# Create Container with custom project name
docker compose -p caige-dev up -d
# Create Container
docker compose up -d
# Destroy Container
docker compose down

# MySQL Dump
docker exec caige-dev-db-1 mariadb-dump -u root -pcai9ameEng1ne5 -A -R > _init.sql

# .env
# FR_MAIN_PORT = 57000
# BA_MAIN_PORT = 57100
# BA_AUTH_PORT = 57101
# BA_DATA_PORT = 57102
# MARIADB_ROOT_PASSWORD = cai9ameEng1ne5