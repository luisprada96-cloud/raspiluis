#!/usr/bin/env bash
# ==============================================================================
#  🍓 RaspiLuis Bootstrap Script
#  Prepara una Raspberry Pi recién instalada para albergar mini-proyectos 24/7.
# ==============================================================================

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

echo -e "${GREEN}"
echo "  ██████╗  █████╗ ███████╗██████╗ ██╗██╗     ██╗   ██╗██╗███████╗"
echo "  ██╔══██╗██╔══██╗██╔════╝██╔══██╗██║██║     ██║   ██║██║██╔════╝"
echo "  ██████╔╝███████║███████╗██████╔╝██║██║     ██║   ██║██║███████╗"
echo "  ██╔══██╗██╔══██║╚════██║██╔═══╝ ██║██║     ██║   ██║██║╚════██║"
echo "  ██║  ██║██║  ██║███████║██║     ██║███████╗╚██████╔╝██║███████║"
echo "  ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝╚══════╝ ╚═════╝ ╚═╝╚══════╝"
echo -e "${NC}"
echo "Iniciando configuración optimizada para mini-proyectos..."

CURRENT_USER="${USER:-$(whoami)}"
USER_HOME="${HOME:-/home/$CURRENT_USER}"

# 1. Actualización del Sistema Operativo
log "1/7 Actualizando repositorios y paquetes de Raspberry Pi OS..."
sudo apt update && sudo apt upgrade -y
success "Sistema base actualizado."

# 2. Utilidades Esenciales y Compilación
log "2/7 Instalando herramientas esenciales del sistema..."
sudo apt install -y \
    curl \
    wget \
    git \
    htop \
    tmux \
    jq \
    unzip \
    zip \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    build-essential \
    ufw \
    fail2ban
success "Herramientas esenciales instaladas."

# 3. Python 3, venv, pip y ffmpeg (Crítico para bots de audio y streaming)
log "3/7 Instalando Python 3, venv, pip y FFmpeg..."
sudo apt install -y python3 python3-pip python3-venv ffmpeg

# Instalar uv (Gestor de paquetes de Python de altísima velocidad)
if ! command -v uv &> /dev/null; then
    log "Instalando uv (Fast Python Package Manager)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$USER_HOME/.cargo/bin:$PATH"
fi
success "Entorno Python 3 y FFmpeg configurados."

# 4. Docker y Docker Compose
log "4/7 Configurando Docker y Docker Compose..."
if ! command -v docker &> /dev/null; then
    log "Instalando Docker Engine oficial..."
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker "$CURRENT_USER"
    sudo systemctl enable docker
    sudo systemctl start docker
    success "Docker instalado y usuario '$CURRENT_USER' añadido al grupo docker."
else
    success "Docker ya estaba instalado."
fi

# 5. Node.js LTS
log "5/7 Instalando Node.js LTS..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt install -y nodejs
    success "Node.js $(node -v) y npm $(npm -v) instalados."
else
    success "Node.js ya estaba instalado."
fi

# 6. Configuración básica de Seguridad (Firewall UFW)
log "6/7 Asegurando la Raspberry Pi con UFW..."
sudo ufw allow 22/tcp comment 'SSH'
sudo ufw --force enable || true
success "Firewall UFW activado (Puerto 22 abierto)."

# 7. Estructura de Proyectos y Scripts
log "7/7 Creando estructura de carpetas ~/projects..."
mkdir -p "$USER_HOME/projects"
mkdir -p "$USER_HOME/logs"

# Clonar repo raspiluis localmente si no existe
if [ ! -d "$USER_HOME/projects/raspiluis" ]; then
    log "Descargando repositorio raspiluis en ~/projects..."
    git clone https://github.com/luisprada96-cloud/raspiluis.git "$USER_HOME/projects/raspiluis" || true
fi

# Dar permisos de ejecución a los scripts
if [ -d "$USER_HOME/projects/raspiluis/scripts" ]; then
    chmod +x "$USER_HOME/projects/raspiluis/scripts/"*.sh || true
fi

echo ""
echo -e "${GREEN}================================================================${NC}"
echo -e "${GREEN}  🎉 ¡Configuración completada con éxito!${NC}"
echo -e "${GREEN}================================================================${NC}"
echo ""
echo "Siguientes pasos recomendados:"
echo "1. Si vas a usar Docker sin sudo, cierra sesión y vuelve a entrar por SSH:"
echo "   exit"
echo "   ssh $CURRENT_USER@$(hostname -I | awk '{print $1}')"
echo ""
echo "2. Para montar el bot de música MusiKa, sigue las instrucciones en:"
echo "   https://github.com/luisprada96-cloud/raspiluis#4-montar-musika-bot-de-discord-247"
echo ""
echo "3. Para comprobar el estado del sistema en cualquier momento:"
echo "   ~/projects/raspiluis/scripts/status.sh"
echo ""
