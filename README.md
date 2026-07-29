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

## Useful commands

Run these from the selected project directory:

```sh
docker compose config
docker compose ps
docker compose logs -f
```

