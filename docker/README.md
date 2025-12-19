# Docker dev container (starter)

This folder contains everything needed to run a Linux development environment using Docker.

If you have never used Docker before, this guide explains:
- What Docker is (in plain language)
- What each file in `docker/` does
- Exactly which commands to run (from the repo root)

## Quick start (from repo root)
1) Create your local env file (not committed):
   `cp docker/.env.example docker/.env`

2) Build + start the dev container:
   `docker compose -f docker/compose.yml --env-file docker/.env up -d --build`

3) Open a shell inside the container:
   `docker compose -f docker/compose.yml exec dev bash`

4) Stop everything:
   `docker compose -f docker/compose.yml down`

### What those commands mean
- `docker compose`: runs Docker Compose (multiple containers/services).
- `-f docker/compose.yml`: points Compose at this repo’s config file (which lives in `docker/`).
- `--env-file docker/.env`: loads environment variables from your local `docker/.env`.
- `up`: creates/starts the services.
- `-d`: runs in the background (“detached”).
- `--build`: rebuilds the image if needed (use this after editing `docker/Dockerfile`).
- `exec dev bash`: opens an interactive Bash shell inside the running `dev` container.
- `down`: stops and removes the containers created by `up`.

## What Docker is (in 60 seconds)
- **Image**: a packaged filesystem + instructions (like a template). Built from a `Dockerfile`.
- **Container**: a running instance of an image (like “a process with its own filesystem”).
- **Dockerfile**: a recipe to build an image (install tools, create a user, set defaults).
- **Docker Compose**: a tool to run one or more containers together from a `compose.yml`.
- **Volume mount**: maps a folder from your machine into the container. Here we mount the repo
  so edits in your editor appear immediately inside the container.

## What you get
This setup creates a container that:
- Runs Linux (even if your laptop is macOS/Windows)
- Mounts the repo root into `/work` inside the container
- Uses a non-root user by default (`dev`)
- Stays running (`sleep infinity`) so you can repeatedly `exec` into it

## Prerequisites
You need Docker installed:
- macOS/Windows: install Docker Desktop
- Linux: install Docker Engine + Docker Compose v2

Verify installation:
- `docker --version`
- `docker compose version`

## Directory tour: what each file does
### `docker/compose.yml`
Defines the runnable “services” (containers) for this repo:
- `dev`: a general-purpose dev container (default)
- `swift`: an optional container for server-side Swift experiments (disabled unless you enable the `swift` profile)

Important details:
- The file lives in `docker/`, so **relative paths are relative to `docker/`**.
- The repo is mounted with `../:/work` (repo root → container `/work`).
- Build context is `.` (the `docker/` folder). Only files in `docker/` are sent to the build.

### `docker/Dockerfile`
The “recipe” used by Compose to build the image for both services:
- Starts from a configurable base image (`BASE_IMAGE`)
- Installs a small set of common CLI tools via `apt-get`
- Creates a user (`USERNAME`, `USER_UID`, `USER_GID`) so files created in the mounted repo aren’t owned by root
- Uses `tini` as PID 1 (helps handle signals properly in containers)
- Defaults to `sleep infinity` (keeps the container running for interactive use)

### `docker/.env.example` (committed)
Example environment variables. Copy it to `docker/.env` (which is local-only).

This is where you customize:
- Timezone (`TZ`)
- App environment (`APP_ENV`)
- Base image (`BASE_IMAGE`) and Swift image (`SWIFT_IMAGE`)
- User mapping (`USERNAME`, `USER_UID`, `USER_GID`)

### `docker/.env` (not committed)
Your local settings. This file is intentionally not committed (so you don’t accidentally commit secrets).

### `docker/.gitignore`
Ensures `docker/.env` stays untracked even if someone runs `git add -A`.

### `docker/.dockerignore`
Controls what files are sent to Docker during `docker build`.

In this repo, the build context is `docker/`, so `.dockerignore` mostly protects against accidentally
including local env files and editor/system junk.

## Optional: Swift service (server-side Swift experiments)
The `swift` service is disabled by default.

Start it by enabling the `swift` profile:
- `docker compose -f docker/compose.yml --env-file docker/.env --profile swift up -d --build`

Open a shell:
- `docker compose -f docker/compose.yml exec swift bash`

Change the Swift image tag in `docker/.env`:
- `SWIFT_IMAGE=swift:5.10-jammy`

## Common commands (cheat sheet)
- Start / rebuild: `docker compose -f docker/compose.yml --env-file docker/.env up -d --build`
- Shell: `docker compose -f docker/compose.yml exec dev bash`
- Logs: `docker compose -f docker/compose.yml logs -f dev`
- Stop: `docker compose -f docker/compose.yml down`
- Stop + remove volumes: `docker compose -f docker/compose.yml down -v`

## Customization
### Install more tools
Edit `docker/Dockerfile` and add packages to the `apt-get install` list, then rebuild:
- `docker compose -f docker/compose.yml --env-file docker/.env up -d --build`

### Change the base Linux distro/image
Set `BASE_IMAGE` in `docker/.env`. Examples (must be `apt-get` compatible with this Dockerfile):
- `BASE_IMAGE=ubuntu:24.04`
- `BASE_IMAGE=debian:bookworm-slim`

If you want Alpine/Fedora/etc., the Dockerfile needs to be adapted (different package manager).

## Troubleshooting
### “command not found: docker”
Docker isn’t installed, or the Docker daemon isn’t running. Install/start Docker and retry.

### “permission denied” or files owned by root
On Linux hosts, set your UID/GID in `docker/.env` (run `id -u` and `id -g` on your host):
- `USER_UID=...`
- `USER_GID=...`

### “no such file or directory” for paths
Remember: `docker/compose.yml` is inside `docker/`, so paths like `../:/work` are relative to `docker/`.
