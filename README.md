# Local vLLM stacks

This repository contains Docker Compose projects for locally hosting Hugging Face models with [vLLM](https://docs.vllm.ai/) and [Open WebUI](https://docs.openwebui.com/).

## Quick start: Granite with vLLM and Open WebUI

The currently working stack is `vllm-granite`. It runs Granite with tensor parallelism across two AMD GPUs and exposes an OpenAI-compatible API for Open WebUI.

### Prerequisites

- Docker Engine with the Compose plugin
- An AMD ROCm host with `/dev/kfd` and `/dev/dri` available
- The `video` and `render` groups available to the Docker container
- Hugging Face model cache directory at `/srv/huggingface`
- Host ports `8000` and `3000` available

Start the stack from its project directory:

```sh
cd vllm-granite
docker compose pull
docker compose up -d
```

Watch vLLM while the model loads:

```sh
docker compose logs -f vllm-granite
```

Once it is ready:

- Open WebUI: <http://localhost:3000>
- vLLM API from the host: <http://localhost:8000/v1>
- vLLM API from Open WebUI: `http://vllm-granite:8000/v1`

Open WebUI is configured with the vLLM endpoint in Compose. If you configure it manually, use the internal URL above and any placeholder API key; this vLLM service does not require an API key.

Check the vLLM model endpoint directly:

```sh
curl http://localhost:8000/v1/models
```

Stop the stack with:

```sh
docker compose down
```

The named `open-webui-data` volume preserves Open WebUI data. The host-mounted `/srv/huggingface` directory preserves downloaded model files.

## Dual Qwen planner and executor

`vllm-dual-qwen` runs two Qwen3.6 services across both AMD GPUs: the 27B
architect/planner on port 8000 and the 35B-A3B tool executor on port 8001.
Open WebUI is exposed on port 3000 and is preconfigured with both internal
OpenAI-compatible endpoints.

```sh
cd vllm-dual-qwen
docker compose pull
docker compose up -d
```

Open <http://localhost:3000> and select either `qwen-architect` or
`qwen-executor`. Use the architect for planning and the executor for tool
calls. The Open WebUI data is stored in the project's named
`open-webui-data` volume.

For normal upgrades or configuration changes, run the same command again:

```sh
docker compose up -d
```

This preserves the named volume. `docker compose up -d --force-recreate` also
preserves mounted named volumes; it only recreates containers. Do not run
`docker compose down -v` unless you intentionally want to permanently delete
Open WebUI data. Plain `docker compose down` is safe and preserves it.

## Adding more Compose projects

Keep each model deployment as an independent project directory. Give each project its own Compose file, environment file, host ports, and persistent volumes:

```text
.
├── README.md
├── vllm-granite/
│   └── docker-compose.yml
└── vllm-dual-model/
    ├── docker-compose.yml
    └── .env
```

Run Compose from the directory for the stack you want to operate. This keeps model settings and lifecycle commands separate. Avoid fixed `container_name` values so two projects can run without Docker name collisions.

For a stack serving two models, use one vLLM service per model when they need separate GPUs or independent resource limits. Assign each service a unique host port and `--served-model-name`, then add both OpenAI-compatible endpoints to Open WebUI. For example, Open WebUI could connect to `http://vllm-gpu0:8000/v1` and `http://vllm-gpu1:8000/v1` when those services expose those internal ports.

Open WebUI can also manage multiple OpenAI-compatible connections in its connection settings. This allows the WebUI to remain stable while the selected vLLM backend changes. See the [Open WebUI environment configuration](https://docs.openwebui.com/reference/env-configuration/) and [vLLM Docker documentation](https://docs.vllm.ai/en/latest/deployment/docker/) for the current configuration details.

## Switching stacks

The current stacks use the same host ports (notably 8000 and 3000), so run one
Open WebUI stack at a time. Stop the current stack without deleting volumes,
then start the next one:

```sh
cd vllm-granite
docker compose down
cd ../vllm-dual-qwen
docker compose up -d
```

The Hugging Face cache at `/srv/huggingface` is already shared, so downloaded
weights are reused. Each Compose project currently has its own Open WebUI
volume, so its chats and settings remain isolated. If you want one shared
Open WebUI history across all stacks, standardize the projects on one external
named volume and continue running only one Open WebUI container at a time.

## Useful commands

Run these from the selected project directory:

```sh
docker compose config
docker compose ps
docker compose logs -f
```
