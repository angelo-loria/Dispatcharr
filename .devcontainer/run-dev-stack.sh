#!/usr/bin/env bash
# Helper to run the full dev stack inside a Codespace or devcontainer
# Usage:
#   ./run-dev-stack.sh start   - start stack (foreground)
#   ./run-dev-stack.sh start -d - start stack (detached)
#   ./run-dev-stack.sh stop    - stop and remove stack
#   ./run-dev-stack.sh logs    - follow logs
#   ./run-dev-stack.sh status  - show compose status
# This script expects to be run from the repository root or will cd to it.

set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
COMPOSE_FILE="$ROOT_DIR/docker/docker-compose.dev.yml"

function die() {
  echo "ERROR: $*" >&2
  exit 1
}

cd "$ROOT_DIR"

if ! command -v docker >/dev/null 2>&1; then
  die "docker is not installed or not available inside this container. In Codespaces enable Docker-in-Codespaces or connect to a remote Docker host."
fi

if ! docker info >/dev/null 2>&1; then
  echo "Warning: docker daemon not available or you don't have access."
  echo "If you want to use docker-compose here, enable the Docker CLI in the devcontainer or attach to a remote Docker host."
fi

ACTION="${1:-}" || true
shift || true
DETACHED=false

# simple arg parsing
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -d|--detached)
      DETACHED=true; shift;;
    *)
      POSITIONAL_ARGS+=("$1"); shift;;
  esac
done

# Allow calling without args to show help
case "$ACTION" in
  start)
    if [[ "$DETACHED" == true ]]; then
      docker compose -f "$COMPOSE_FILE" up --build -d
    else
      docker compose -f "$COMPOSE_FILE" up --build
    fi
    ;;
  stop)
    docker compose -f "$COMPOSE_FILE" down --volumes --remove-orphans
    ;;
  logs)
    docker compose -f "$COMPOSE_FILE" logs -f --no-color
    ;;
  status)
    docker compose -f "$COMPOSE_FILE" ps
    ;;
  help|--help|-h|"")
    cat <<'EOF'
run-dev-stack.sh - helper to run the Dispatcharr dev compose stack

Usage:
  ./run-dev-stack.sh start       # start stack (foreground)
  ./run-dev-stack.sh start -d    # start stack detached
  ./run-dev-stack.sh stop        # stop stack and remove volumes/orphans
  ./run-dev-stack.sh logs        # follow logs
  ./run-dev-stack.sh status      # show compose status

Notes:
- This script expects Docker to be available in the Codespace/devcontainer.
- On Codespaces you may need to enable Docker-in-Codespaces or configure a remote Docker host.
EOF
    ;;
  *)
    echo "Unknown action: ${ACTION:-<none>}"
    exit 2
    ;;
esac
