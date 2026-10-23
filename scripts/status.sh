#!/usr/bin/env bash
# ==============================================================================
#  🍓 RaspiLuis System Diagnostics & Status
# ==============================================================================

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}================================================================${NC}"
echo -e "${CYAN}          🍓 RaspiLuis - Diagnóstico del Sistema               ${NC}"
echo -e "${CYAN}================================================================${NC}"

# Hostname e IP
HOST=$(hostname)
LOCAL_IP=$(hostname -I | awk '{print $1}')
UPTIME=$(uptime -p)
echo -e "🖥️  ${YELLOW}Host:${NC} $HOST ($LOCAL_IP)"
echo -e "⏱️  ${YELLOW}Uptime:${NC} $UPTIME"

# Temperatura de CPU
if command -v vcgencmd &> /dev/null; then
    TEMP=$(vcgencmd measure_temp | cut -d "=" -f2)
    echo -e "🌡️  ${YELLOW}Temp CPU:${NC} $TEMP"
elif [ -f /sys/class/thermal/thermal_zone0/temp ]; then
    TEMP_RAW=$(cat /sys/class/thermal/thermal_zone0/temp)
    TEMP_C=$(awk "BEGIN {print $TEMP_RAW / 1000}")
    echo -e "🌡️  ${YELLOW}Temp CPU:${NC} ${TEMP_C}°C"
fi

# Uso de Memoria RAM
echo ""
echo -e "${GREEN}📊 Memoria RAM:${NC}"
free -h | awk 'NR==1{print "  " $0} NR==2{print "  " $0} NR==3{print "  " $0}'

# Espacio en Disco
echo ""
echo -e "${GREEN}💾 Espacio en Disco:${NC}"
df -h / | awk 'NR==1{print "  " $0} NR==2{print "  " $0}'

# Estado de Servicios de Mini-Proyectos
echo ""
echo -e "${GREEN}🤖 Servicios Systemd:${NC}"
for s in musika docker tailscaled; do
    if systemctl is-active --quiet "$s" 2>/dev/null; then
        echo -e "  ✅ $s: ${GREEN}ACTIVO (Running)${NC}"
    else
        echo -e "  ⚪ $s: ${YELLOW}Inactivo o no instalado${NC}"
    fi
done

# Contenedores Docker activos
if command -v docker &> /dev/null; then
    echo ""
    echo -e "${GREEN}🐳 Contenedores Docker Activos:${NC}"
    DOCKER_COUNT=$(docker ps -q | wc -l)
    if [ "$DOCKER_COUNT" -gt 0 ]; then
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | sed 's/^/  /'
    else
        echo "  (No hay contenedores en ejecución)"
    fi
fi

echo -e "${CYAN}================================================================${NC}"
