Setting up of container for frontend, backend and development database:
docker-compose --env-file .env -f docker-compose.yml up -d --build

Setting up of container for backend, backend tests and testing database:
docker-compose --env-file .env -f docker-compose-backendtest.yml up -d --build
