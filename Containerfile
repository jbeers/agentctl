ARG HERMES_BASE_IMAGE=docker.io/nousresearch/hermes-agent@sha256:acb739a1ba5fa8ac5cd1db188f4db11921528cea855791d30ced9c200c4c69b9
FROM ${HERMES_BASE_IMAGE}

USER root

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        gh \
        podman \
        podman-compose \
    && rm -rf /var/lib/apt/lists/*

ENV CONTAINER_HOST=unix:///run/podman/podman.sock \
    DOCKER_HOST=unix:///run/podman/podman.sock \
    GH_CONFIG_DIR=/opt/data/home/.config/gh

WORKDIR /workdir
USER hermes

LABEL org.opencontainers.image.title="Agentctl Hermes Runtime" \
      org.opencontainers.image.description="Hermes with GitHub and Podman Compose clients for a host rootless Podman socket"
