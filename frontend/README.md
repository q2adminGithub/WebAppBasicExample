Setting up of container for frontend, backend and dev portgres DB:
docker-compose -f docker-compose.yml --build

Setting up of container for backend, backendtests and testing database:
docker-compose -f docker-compose-backendtest.yml --build
