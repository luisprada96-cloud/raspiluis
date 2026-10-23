# 🔐 Guía de Conexión SSH y Credenciales — Raspberry Pi 4 B (`raspiluis`)

Este documento contiene los datos de acceso, credenciales y métodos de conexión a la Raspberry Pi para desarrolladores, usuarios y agentes IA.

---

## 📡 Datos de Red y Acceso

| Parámetro | Valor | Notas |
| :--- | :--- | :--- |
| **Hostname** | `raspiluis` / `raspiluis.local` | Resolución mDNS en la red local |
| **IP Primaria (Ethernet)** | `192.168.1.119` | Conexión cableada Gigabit (recomendada) |
| **IP Secundaria (Wi-Fi)** | `192.168.1.78` | Red 5GHz `MOVISTAR_PLUS_5DDB` (failover automático) |
| **Puerto SSH** | `22` | Estándar SSH |
| **Usuario** | `luis` | Usuario administrador |
| **Permisos Sudo** | `NOPASSWD: ALL` | Puede ejecutar cualquier `sudo` sin pedir contraseña |

---

## 🔑 Métodos de Conexión

### 1. Desde este portátil (Conexión de Agentes y Terminal — SIN contraseña)
La clave SSH pública de este portátil (`~/.ssh/id_ed25519.pub`) ya está instalada en `/home/luis/.ssh/authorized_keys`.
Por tanto, **no requiere contraseña**.

Comando directo desde PowerShell o CMD:
```powershell
ssh luis@192.168.1.119
# o si estás conectado solo por Wi-Fi:
ssh luis@192.168.1.78
# o por nombre de host:
ssh luis@raspiluis.local
```

### 2. Desde otro ordenador, móvil o tablet (Con contraseña)
Si te conectas desde un dispositivo que no tiene la clave SSH (como un móvil con Termius, una tablet u otro PC):
```bash
ssh luis@192.168.1.119
```
- Introduce la contraseña del usuario `luis` que configuraste al grabar la microSD en Raspberry Pi Imager.

> 💡 **¿Has olvidado la contraseña del usuario `luis`?**
> Como el usuario `luis` tiene `sudo` sin contraseña configurado para las claves SSH, desde este portátil un agente o tú mismo podéis cambiar la contraseña en 2 segundos ejecutando:
> ```powershell
> ssh luis@192.168.1.119 "sudo passwd luis"
> ```

---

## ⚙️ Configuración SSH en Windows (`~/.ssh/config`)

Para conectarte cómodamente escribiendo simplemente `ssh raspi` desde cualquier terminal:

Añade en `C:\Users\luisp\.ssh\config`:
```text
Host raspi
    HostName 192.168.1.119
    User luis
    IdentityFile ~/.ssh/id_ed25519
    StrictHostKeyChecking no

Host raspi-wifi
    HostName 192.168.1.78
    User luis
    IdentityFile ~/.ssh/id_ed25519
    StrictHostKeyChecking no
```

---

## 📂 Directorios de Proyectos en la Raspberry Pi

Todos los proyectos y servicios se organizan en:
```text
/home/luis/projects/
├── musika/          # Bot de música para Discord (servicio: musika.service)
└── dashboard/       # Panel web de telemetría y control (servicio: dashboard.service)
```

---

## 🛠️ Comandos Rápidos de Diagnóstico Remoto

```bash
# Ver temperatura del procesador
ssh luis@192.168.1.119 "vcgencmd measure_temp"

# Ver memoria RAM libre y usada
ssh luis@192.168.1.119 "free -h"

# Ver espacio en la tarjeta microSD
ssh luis@192.168.1.119 "df -h /"

# Ver estado del bot de Discord
ssh luis@192.168.1.119 "systemctl status musika --no-pager"
```
