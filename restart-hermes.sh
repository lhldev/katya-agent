#!/bin/bash
# restart_hermes.sh
# Hermes will be stoped once ever restart happends. issue 49502
#
# 1. Initialize the containerized topology
docker compose down --remove-orphans
docker compose up -d --build

# 2. Introduce a brief temporal delay to ensure the primary desktop processes are fully initialized
sleep 5

# 3. Inject the gateway process into the running container from the host
docker exec -d hermes-desktop su - lhl -c 'hermes gateway run'

echo "Hermes container and Telegram gateway have been successfully initialized."
