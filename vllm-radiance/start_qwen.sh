#!/bin/bash
docker compose --env-file .env --env-file .env.qwen -f docker-compose.qwen3.8-27b-fp8.yml up -d
