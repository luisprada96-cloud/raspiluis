#!/usr/bin/env bash
# ==============================================================================
#  🍓 RaspiLuis Update All
#  Actualiza paquetes de SO, contenedores Docker y repositorios en ~/projects.
# ==============================================================================

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== 1. Actualizando paquetes del Sistema Operativo (apt) ===${NC}"
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y

if command -v docker &> /dev/null; then
    echo ""
    echo -e "${BLUE}=== 2. Actualizando contenedores Docker activos ===${NC}"
    # Si hay docker-compose en ~/projects/raspiluis o similar
    if [ -f "$HOME/projects/raspiluis/docker-compose.yml" ]; then
        docker compose -f "$HOME/projects/raspiluis/docker-compose.yml" pull || true
        docker compose -f "$HOME/projects/raspiluis/docker-compose.yml" up -d --remove-orphans || true
    fi
fi

echo ""
echo -e "${BLUE}=== 3. Comprobando repositorios Git en ~/projects ===${NC}"
if [ -d "$HOME/projects" ]; then
    for dir in "$HOME/projects"/*/; do
        if [ -d "$dir/.git" ]; then
            echo "Actualizando $(basename "$dir")..."
            git -C "$dir" pull --ff-only || echo "  (Aviso: No se pudo hacer pull automático en $(basename "$dir"))"
        fi
    done
fi

echo ""
echo -e "${GREEN}✅ ¡Actualización de la Raspberry Pi finalizada!${NC}"
