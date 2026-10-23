# 🤖 Manual de Operaciones para Agentes IA — Raspberry Pi (`raspiluis`)

> **Instrucciones para Agentes:** Este archivo describe cómo conectarse, ejecutar tareas, gestionar servicios y desarrollar proyectos en la Raspberry Pi 4 B de Luis.

---

## 🚀 1. Conexión Remota y Shell

La máquina de desarrollo (este portátil con Windows) tiene configurada autenticación por clave SSH pública (`~/.ssh/id_ed25519`).
- **Comando base:** `ssh -o StrictHostKeyChecking=no luis@192.168.1.119 "<comando>"`
- **IP alternativa (Wi-Fi):** `192.168.1.78`
- **Sudo:** El usuario `luis` tiene `NOPASSWD: ALL`. Cualquier comando con privilegios se ejecuta anteponiendo `sudo` sin interacción de contraseña.

---

## 📁 2. Convención de Proyectos

1. **Ubicación en la Raspberry Pi:** Todo proyecto reside en `/home/luis/projects/<nombre-proyecto>`.
2. **Entornos Virtuales:** Usar `venv` en cada proyecto:
   ```bash
   python3 -m venv /home/luis/projects/<nombre-proyecto>/venv
   /home/luis/projects/<nombre-proyecto>/venv/bin/pip install -r requirements.txt
   ```
3. **Servicios de fondo:** Se gestionan como servicios de `systemd` bajo `/etc/systemd/system/<nombre>.service`.

---

## 📋 3. Catálogo de Servicios y Proyectos Activos

| Proyecto | Ruta en Pi | Servicio Systemd | Puerto | Descripción |
| :--- | :--- | :--- | :--- | :--- |
| **MusiKa** | `/home/luis/projects/musika` | `musika.service` | 8080 (local) | Bot de música de Discord residencial |
| **Raspi Dashboard** | `/home/luis/projects/dashboard` | `dashboard.service` | 3000 | Panel web de telemetría y control |

---

## 🔄 4. Ciclo de Despliegue Estándar para Agentes

Al actualizar o crear un proyecto:
1. Escribir/probar el código localmente o transferirlo vía `scp` / `git`.
2. Si el proyecto se sube a GitHub:
   ```bash
   ssh luis@192.168.1.119 "cd /home/luis/projects/<proyecto> && git pull"
   ```
3. Si requiere reinicio de servicio:
   ```bash
   ssh luis@192.168.1.119 "sudo systemctl restart <nombre>.service"
   ```
4. Verificar estado y logs:
   ```bash
   ssh luis@192.168.1.119 "systemctl status <nombre>.service --no-pager"
   ```

---
*Mantenido en el repositorio central `luisprada96-cloud/raspiluis`.*
