# 🍓 RaspiLuis - Centro de Mini-Proyectos y Servidor Doméstico

Guía completa y automatización para convertir una **Raspberry Pi** en un servidor doméstico 24/7 de alto rendimiento para mini-proyectos (como el bot de música **MusiKa** para Discord, contenedores Docker, proxies, APIs y túneles).

---

## 📑 Índice

1. [Flasheo Headless con Raspberry Pi Imager](#1-flasheo-headless-con-raspberry-pi-imager)
2. [Primer Arranque y Conexión SSH](#2-primer-arranque-y-conexión-ssh)
3. [Instalación Automática (One-Line Bootstrap)](#3-instalación-automática-one-line-bootstrap)
4. [Montar MusiKa (Bot de Discord 24/7)](#4-montar-musika-bot-de-discord-247)
5. [Herramientas y Mini-Proyectos incluidos](#5-herramientas-y-mini-proyectos-incluidos)
6. [Acceso Remoto con Tailscale (Sin abrir puertos)](#6-acceso-remoto-con-tailscale-sin-abrir-puertos)
7. [Comandos de Mantenimiento](#7-comandos-de-mantenimiento)

---

## 1. Flasheo Headless con Raspberry Pi Imager

> [!NOTE]
> **Modo Headless**: No necesitas conectar monitor, TV, teclado ni ratón a la Raspberry Pi. Todo el sistema operativo y el acceso remoto quedan pre-configurados en la microSD desde tu portátil/PC.

1. Descarga e instala [Raspberry Pi Imager](https://www.raspberrypi.com/software/).
2. Inserta tu tarjeta microSD en el portátil/lector.
3. Abre Raspberry Pi Imager y configura las tres opciones:
   - **Dispositivo**: Elige tu modelo (Raspberry Pi 4, 3, o 5).
   - **Sistema Operativo**: Ve a **`Raspberry Pi OS (other)`** ➔ elige **`Raspberry Pi OS Lite (64-bit)`** *(sin interfaz gráfica de escritorio: consume ~50MB de RAM, arranca en segundos y es ultra estable)*.
   - **Almacenamiento**: Selecciona tu tarjeta microSD.
4. Pulsa **Siguiente**. Cuando te pregunte: *"¿Deseas aplicar los ajustes de personalización del SO?"*, pulsa **EDITAR AJUSTES** (o el icono de engranaje):
   - **General**:
     - *Nombre del equipo (Hostname)*: `raspiluis` (o `raspberrypi`).
     - *Nombre de usuario*: `luis` (o el que prefieras).
     - *Contraseña*: Tu contraseña elegida.
     - *(Opcional)* *Configurar red inalámbrica*: Pon el nombre (SSID) y contraseña de tu Wi-Fi si no vas a conectarla por cable Ethernet.
   - **Servicios**:
     - Marca **`Activar SSH`**.
     - Selecciona **`Usar autenticación por contraseña`**.
5. Guarda los ajustes y dale a **SÍ / Escribir**.
6. Espera a que termine el proceso de escritura y verificación.

---

## 2. Primer Arranque y Conexión SSH

1. Extrae la microSD del portátil e insértala en la ranura de la Raspberry Pi.
2. Conecta el cable de red Ethernet al router (si no usas Wi-Fi) y el cable de alimentación USB-C / micro-USB.
3. Espera unos **90 segundos** a que complete su primer booteo y redimensionamiento de partición.
4. Desde tu terminal (PowerShell en Windows, Terminal en macOS/Linux):

```bash
# Conectarse por nombre de host
ssh luis@raspiluis.local

# O conectarse por su IP local (si tu router la asignó)
ssh luis@192.168.1.78
```

Introduce la contraseña que configuraste en Raspberry Pi Imager. ¡Ya estás dentro de tu servidor!

---

## 3. Instalación Automática (One-Line Bootstrap)

Para no perder tiempo instalando paquetes uno a uno, este repositorio incluye un script automatizado que prepara todo el entorno:

Ejecuta este único comando en tu Raspberry Pi:

```bash
curl -sSL https://raw.githubusercontent.com/luisprada96-cloud/raspiluis/main/bootstrap.sh | bash
```

### ¿Qué instala y configura automáticamente?
* ✅ **Actualización completa del sistema**: `apt update && apt upgrade`
* ✅ **Herramientas esenciales**: `git`, `curl`, `wget`, `htop`, `tmux`, `jq`, `unzip`, `build-essential`
* ✅ **Seguridad y Firewall**: `ufw` (abriendo solo puerto SSH 22) y `fail2ban` (protección contra fuerza bruta)
* ✅ **Python 3 moderno**: `python3`, `python3-pip`, `python3-venv` y **`ffmpeg`** (imprescindible para streaming de audio)
* ✅ **uv (Python Package Manager ultra rápido)**: Instalador oficial de Astral
* ✅ **Docker & Docker Compose**: Motor oficial para levantar cualquier contenedor o mini-proyecto
* ✅ **Node.js LTS**: Preparado para bots y APIs en JavaScript / TypeScript
* ✅ **Estructura de carpetas limpia**: Crea `~/projects/` y scripts de diagnóstico

---

## 4. Montar MusiKa (Bot de Discord 24/7)

Con la Raspberry lista, tu bot de música reproducirá audio de YouTube desde tu **IP residencial** (sin bloqueos de centros de datos de YouTube) y gastando **0 horas** en Render.

### Paso 1: Clonar el bot
```bash
cd ~/projects
git clone https://github.com/luisprada96-cloud/musika-discord-bot.git musika
cd musika
```

### Paso 2: Crear el entorno virtual e instalar dependencias
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Paso 3: Configurar variables de entorno (.env)
Crea tu archivo `.env`:
```bash
nano .env
```
Pega tus credenciales:
```env
DISCORD_TOKEN=tu_token_de_discord
CLOUDFLARE_WORKER_URL=https://musika.luisjourney.xyz
WORKER_AUTH_KEY=tu_worker_auth_key
BOT_INSTANCE_NAME=raspiluis
```
*(Guarda con `Ctrl+O` y sal con `Ctrl+X`)*.

### Paso 4: Servicio automático 24/7 (systemd)
Para que el bot arranque solo al encender la Raspberry y se reinicie automáticamente si falla:

```bash
# Copiar el archivo de servicio desde este repositorio
sudo cp ~/projects/raspiluis/services/musika.service /etc/systemd/system/

# Recargar servicios y activar
sudo systemctl daemon-reload
sudo systemctl enable musika
sudo systemctl start musika

# Ver estado en tiempo real
sudo systemctl status musika

# Ver logs en vivo
journalctl -u musika -f
```

---

## 5. Herramientas y Mini-Proyectos incluidos

Dentro de `~/projects/raspiluis/`:

### Diagnóstico Rápido de la Pi (`status.sh`)
```bash
~/projects/raspiluis/scripts/status.sh
```
Muestra:
- Temperatura actual de la CPU
- Uso de memoria RAM y Swap
- Espacio disponible en disco
- IP local y estado de la red
- Estado de los servicios de mini-proyectos

### Actualizador Total (`update-all.sh`)
```bash
~/projects/raspiluis/scripts/update-all.sh
```
Actualiza en un solo comando:
- Paquetes de Debian / Raspberry Pi OS (`apt`)
- Contenedores Docker activos
- Repositorios Git en `~/projects`

---

## 6. Acceso Remoto con Tailscale (Sin abrir puertos)

Para poder conectarte a tu Raspberry Pi desde el portátil fuera de casa, desde el móvil o desde cualquier red sin tocar el router:

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```
Abre el enlace que te mostrará en pantalla para vincularlo a tu cuenta de Tailscale. A partir de ese momento, podrás hacer `ssh luis@raspiluis` desde cualquier parte del mundo de forma 100% cifrada.

---

## 7. Comandos de Mantenimiento

| Acción | Comando |
|---|---|
| Ver uso de recursos (CPU / RAM) | `htop` |
| Ver temperatura de la CPU | `vcgencmd measure_temp` |
| Reiniciar la Raspberry Pi | `sudo reboot` |
| Apagar con seguridad | `sudo shutdown -h now` |
| Reiniciar el bot MusiKa | `sudo systemctl restart musika` |
| Ver logs del bot en vivo | `journalctl -u musika -f` |

---
Creado con ❤️ para el ecosistema domótico y de bots de Luis.
