# syntax=docker/dockerfile:1
# This Dockerfile builds a general-purpose Linux dev image.
# It intentionally stays small and easy to customize.

# Base image is configurable so you can try different Linux distros/images.
# NOTE: This Dockerfile uses `apt-get`, so the base image must be Debian/Ubuntu-family.
ARG BASE_IMAGE=ubuntu:24.04
FROM ${BASE_IMAGE}

# A non-root user is created so files written into the mounted repo aren’t owned by root.
ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=1000

ENV DEBIAN_FRONTEND=noninteractive

# Install a minimal set of common tools.
# - `tini` acts as a tiny init process (PID 1) that handles signals correctly.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      bash \
      bash-completion \
      ca-certificates \
      curl \
      git \
      sudo \
      tini \
      tzdata \
 && rm -rf /var/lib/apt/lists/*

# Create the dev user and give it passwordless sudo for convenience in a dev container.
RUN set -eux; \
    if ! getent group "${USERNAME}" >/dev/null; then \
      groupadd --gid "${USER_GID}" "${USERNAME}" || groupadd "${USERNAME}"; \
    fi; \
    if ! id -u "${USERNAME}" >/dev/null 2>&1; then \
      useradd --uid "${USER_UID}" --gid "${USERNAME}" -m "${USERNAME}" || useradd --gid "${USERNAME}" -m "${USERNAME}"; \
    fi; \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/"${USERNAME}"; \
    chmod 0440 /etc/sudoers.d/"${USERNAME}"

# This is where the repo will be mounted inside the container (see compose.yml).
WORKDIR /work

# `tini` is the entrypoint. `sleep infinity` keeps the container alive for interactive use.
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["sleep", "infinity"]

# Drop privileges for day-to-day work.
USER ${USERNAME}
