Setting up of container for frontend, backend and development database:
docker-compose -f docker-compose.yml up -d --build

Setting up of container for backend, backend tests and testing database:
docker-compose -f docker-compose-backendtest.yml up -d --build
