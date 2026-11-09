#!/bin/bash
docker compose --env-file .env --env-file .env.gemma -f docker-compose.gemma-4-31b-fp8-dynamic.yml up -d
