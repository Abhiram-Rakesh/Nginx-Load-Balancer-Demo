#!/usr/bin/env bash
# install-nginx-lb-from-repo.sh
# Installs Docker + Docker Compose, auto-detects project root,
# validates required files, and starts the docker-compose stack.
#
# Usage:
#   sudo ./scripts/install-nginx-lb-from-repo.sh
#

set -o errexit
set -o nounset
set -o pipefail

COMPOSE_VERSION="v2.29.2"
DOCKER_COMPOSE_BIN="/usr/local/bin/docker-compose"

echo -e "\n\033[1;36m=============================================\033[0m"
echo -e "\033[1;36m   NGINX Load Balancer Demo – Installer       \033[0m"
echo -e "\033[1;36m   (Docker + Compose Setup on EC2)            \033[0m"
echo -e "\033[1;36m   Created by Abhiram                         \033[0m"
echo -e "\033[1;36m=============================================\033[0m\n"

# Colorized Logging Helpers

echoinfo() { echo -e "\033[1;34m[INFO]\033[0m  $*"; }
echoerr() { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; }
echowarn() { echo -e "\033[1;33m[WARN]\033[0m  $*"; }

# AUTO-DETECT PROJECT ROOT

SCRIPT_PATH="$(realpath "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"

# If script is inside "scripts/" → project root is parent folder
if [[ "$(basename "$SCRIPT_DIR")" == "scripts" ]]; then
    PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
else
    # Otherwise assume script is in project root
    PROJECT_DIR="$SCRIPT_DIR"
fi

echoinfo "Detected project root: $PROJECT_DIR"

# Validate required project files

REQUIRED_FILES=(
    "docker-compose.yml"
    "lb/nginx.conf"
)

MISSING=()
for f in "${REQUIRED_FILES[@]}"; do
    if [[ ! -f "$PROJECT_DIR/$f" ]]; then
        MISSING+=("$f")
    fi
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
    echoerr "Missing required files in project root:"
    for f in "${MISSING[@]}"; do echoerr " - $f"; done
    exit 1
fi

echoinfo "All required project files found."

# Install Docker (if missing)

if ! command -v docker >/dev/null 2>&1; then
    echoinfo "Docker not found. Installing..."

    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS_ID=${ID,,}

        case "$OS_ID" in
        amzn | amazon)
            yum update -y
            yum install -y docker
            ;;
        amzn2023)
            dnf update -y
            dnf install -y docker
            ;;
        ubuntu | debian)
            apt-get update -y
            apt-get install -y docker.io
            ;;
        centos | rhel)
            yum install -y docker
            ;;
        *)
            echoerr "Unsupported OS: $OS_ID"
            exit 1
            ;;
        esac
        systemctl enable docker --now
    fi

    echoinfo "Docker installed and started."
else
    echoinfo "Docker already installed: $(docker --version)"
fi

# Install Docker Compose

if docker compose version >/dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
    echoinfo "Using Docker Compose plugin."
elif command -v docker-compose >/dev/null 2>&1; then
    COMPOSE_CMD="docker-compose"
    echoinfo "Using docker-compose binary."
else
    echoinfo "Installing docker-compose binary..."

    curl -fsSL \
        "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
        -o "$DOCKER_COMPOSE_BIN"

    chmod +x "$DOCKER_COMPOSE_BIN"

    COMPOSE_CMD="$DOCKER_COMPOSE_BIN"
    echoinfo "docker-compose installed."
fi

# Start docker-compose stack

echoinfo "Starting docker-compose stack..."
cd "$PROJECT_DIR"
$COMPOSE_CMD up -d

sleep 2

# Post-start checks

echoinfo "Containers running:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echoinfo "Testing local LB (curl localhost)..."

if curl -sS http://localhost/ >/tmp/lb_local_test.html; then
    echoinfo "Local LB responded:"
    head -n 5 /tmp/lb_local_test.html
else
    echoerr "Local LB failed. Check: docker logs lb"
fi

echoinfo "Testing LB → backend connectivity..."
docker exec lb curl -sS http://web1/ >/dev/null && echoinfo "web1 reachable" || echowarn "web1 unreachable"
docker exec lb curl -sS http://web2/ >/dev/null && echoinfo "web2 reachable" || echowarn "web2 unreachable"
docker exec lb curl -sS http://web3/ >/dev/null && echoinfo "web3 reachable" || echowarn "web3 unreachable"

# Completion

echoinfo "Setup complete!"
echo
echo "➡ If external access fails:"
echo "   - Ensure Security Group allows inbound TCP 80"
echo "   - Run: docker logs lb"
echo "   - Run: sudo ss -ltnp | grep ':80'"
echo

exit 0
