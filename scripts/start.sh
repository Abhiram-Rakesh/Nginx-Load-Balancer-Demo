#!/usr/bin/env bash
# Starts the docker-compose stack for the project (auto-detects project root and compose binary).
#
# Usage:
#   sudo ./scripts/start.sh
#   (or run as the user in docker group)

set -o errexit
set -o nounset
set -o pipefail

echo -e "\n\033[1;32m=============================================\033[0m"
echo -e "\033[1;32m      Starting NGINX Load Balancer Stack      \033[0m"
echo -e "\033[1;32m      (web1 + web2 + web3 + lb)               \033[0m"
echo -e "\033[1;32m      Created by Abhiram                      \033[0m"
echo -e "\033[1;32m=============================================\033[0m\n"

echoinfo() { echo -e "\033[1;34m[INFO]\033[0m  $*"; }
echowarn() { echo -e "\033[1;33m[WARN]\033[0m  $*"; }
echoerr() { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; }

# Resolve locations
SCRIPT_PATH="$(realpath "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
if [[ "$(basename "$SCRIPT_DIR")" == "scripts" ]]; then
    PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
else
    PROJECT_DIR="$SCRIPT_DIR"
fi

echoinfo "Project root: $PROJECT_DIR"
cd "$PROJECT_DIR"

# Detect compose command
if docker compose version >/dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
    COMPOSE_CMD="docker-compose"
else
    echoerr "No docker-compose found. Please install Docker Compose."
    exit 1
fi

echoinfo "Using compose command: $COMPOSE_CMD"

echoinfo "Bringing up stack (detached)..."
$COMPOSE_CMD up -d

sleep 2
echoinfo "Containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echoinfo "Testing local LB (curl http://localhost/)..."
if curl -sS http://localhost/ >/dev/null 2>&1; then
    echoinfo "Local LB responded."
else
    echowarn "Local LB did not respond. Check 'docker logs lb'."
fi

echoinfo "Start complete."
exit 0
