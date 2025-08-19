# Devcontainer Dockerfile for Dispatcharr
FROM mcr.microsoft.com/vscode/devcontainers/python:3.11-bullseye

# Install NodeJS, build tools, Docker CLI, and common deps
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
  && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    build-essential \
    libpq-dev \
    ffmpeg \
    redis-tools \
    jq \
    npm \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install latest Node via NodeSource (optional)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get install -y nodejs && npm install -g corepack

# Create a non-root user 'vscode' is already provided; ensure /workspace exists
RUN mkdir -p /workspace && chown vscode:vscode /workspace

USER vscode
WORKDIR /workspace

# Install Python & Node deps in postCreateCommand
