#!/usr/bin/env bash
# =============================================================
#  Smart Hospital — Quick-Start Setup Script
#  Tested on: Ubuntu Server 22.04 / Debian 12
# =============================================================
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ---------------------------------------------------------------
# 1. Check OS
# ---------------------------------------------------------------
if [[ "$(uname -s)" != "Linux" ]]; then
  error "This script is designed for Linux (Ubuntu/Debian). Run it inside the VM."
fi

info "Starting Smart Hospital setup on $(lsb_release -ds 2>/dev/null || uname -a)"

# ---------------------------------------------------------------
# 2. Install Docker if not present
# ---------------------------------------------------------------
if ! command -v docker &>/dev/null; then
  info "Installing Docker..."
  sudo apt-get update -qq
  sudo apt-get install -y ca-certificates curl gnupg lsb-release
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update -qq
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin
  sudo usermod -aG docker "$USER"
  info "Docker installed successfully."
else
  info "Docker already installed: $(docker --version)"
fi

# ---------------------------------------------------------------
# 3. Install Docker Compose plugin if missing
# ---------------------------------------------------------------
if ! docker compose version &>/dev/null; then
  info "Installing docker-compose-plugin..."
  sudo apt-get install -y docker-compose-plugin
fi

# ---------------------------------------------------------------
# 4. Start the stack
# ---------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

info "Starting containers from $PROJECT_ROOT ..."
cd "$PROJECT_ROOT"

# Use `docker compose` (v2 plugin) with fallback to `docker-compose` (v1)
if docker compose version &>/dev/null; then
  COMPOSE_CMD="docker compose"
else
  COMPOSE_CMD="docker-compose"
fi

$COMPOSE_CMD up -d

# ---------------------------------------------------------------
# 5. Wait for MySQL to be ready
# ---------------------------------------------------------------
info "Waiting for MySQL to accept connections (max 120 s)..."
for i in $(seq 1 24); do
  if $COMPOSE_CMD exec -T mysql mysqladmin ping -h localhost \
       -u root -phospital_root_2024 --silent 2>/dev/null; then
    info "MySQL is ready."
    break
  fi
  sleep 5
  if [[ $i -eq 24 ]]; then
    error "MySQL did not start in time. Run: $COMPOSE_CMD logs mysql"
  fi
done

# ---------------------------------------------------------------
# 6. Print access information
# ---------------------------------------------------------------
HOST_IP=$(hostname -I | awk '{print $1}')

echo ""
echo -e "${GREEN}=============================================================${NC}"
echo -e "${GREEN}  Smart Hospital is UP and RUNNING${NC}"
echo -e "${GREEN}=============================================================${NC}"
echo ""
echo "  Grafana Dashboard : http://${HOST_IP}:3000"
echo "  Grafana login     : admin / hospital_admin_2024"
echo ""
echo "  MySQL host        : ${HOST_IP}:3306"
echo "  MySQL database    : smart_hospital"
echo "  MySQL user        : hospital_user"
echo "  MySQL password    : hospital_pass_2024"
echo ""
echo "  Useful commands:"
echo "    View logs        : $COMPOSE_CMD logs -f"
echo "    Stop stack       : $COMPOSE_CMD down"
echo "    Restart stack    : $COMPOSE_CMD restart"
echo "    MySQL shell      : $COMPOSE_CMD exec mysql mysql -u root -phospital_root_2024 smart_hospital"
echo ""
echo -e "${YELLOW}NOTE: If you just added your user to the 'docker' group, log out${NC}"
echo -e "${YELLOW}      and log in again, or run: newgrp docker${NC}"
echo ""
