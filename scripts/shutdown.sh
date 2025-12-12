#!/usr/bin/env bash
# Stops and removes the docker-compose stack from the project (auto-detects project root).
#
# Usage:
#   sudo ./scripts/shutdown.sh
#   (or run as the user in docker group)

set -o errexit
set -o nounset
set -o pipefail

echo -e "\n\033[1;31m=============================================\033[0m"
echo -e "\033[1;31m     Stopping NGINX Load Balancer Stack       \033[0m"
echo -e "\033[1;31m     (Gracefully shutting down services)       \033[0m"
echo -e "\033[1;31m     Created by Abhiram                       \033[0m"
echo -e "\033[1;31m=============================================\033[0m\n"

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

echoinfo "Stopping and removing stack..."
# By default this will remove containers, networks, and anonymous volumes created by compose
$COMPOSE_CMD down

echoinfo "Current containers (post-stop):"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echoinfo "Stop complete."
exit 0
