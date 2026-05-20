#!/bin/bash

# Script para instalar nautilus-open-any-terminal con ptyxis en Debian 13
# Ejecutar con: sudo bash install_nautilus_ptyxis.sh

set -e

echo "=========================================="
echo "Instalando nautilus-open-any-terminal para ptyxis"
echo "=========================================="

# Verificar que se ejecuta como root
if [[ $EUID -ne 0 ]]; then
   echo "Este script debe ejecutarse como root (sudo)" 
   exit 1
fi

echo "1. Actualizando repositorios..."
apt update

echo "2. Instalando dependencias necesarias..."
apt install -y git wget make python3-nautilus gir1.2-gtk-4.0 gettext build-essential

echo "3. Clonando repositorio nautilus-open-any-terminal..."
cd /tmp
rm -rf nautilus-open-any-terminal 2>/dev/null || true
git clone https://github.com/Stunkymonkey/nautilus-open-any-terminal.git

echo "4. Compilando e instalando..."
cd nautilus-open-any-terminal
make
make install schema

echo "5. Compilando esquemas de glib..."
glib-compile-schemas /usr/share/glib-2.0/schemas

echo "6. Configurando ptyxis como terminal predeterminado..."
# Configurar para todos los usuarios que ejecuten el comando
runuser -l $SUDO_USER -c 'gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal ptyxis'

echo "7. Saltando configuración de atajos de teclado..."
# No configuramos atajos para evitar conflictos con atajos globales del sistema

echo "8. Reiniciando Nautilus..."
runuser -l $SUDO_USER -c 'nautilus -q' 2>/dev/null || true

echo "9. Limpiando archivos temporales..."
cd /
rm -rf /tmp/nautilus-open-any-terminal

echo "=========================================="
echo "¡Instalación completada!"
echo "=========================================="
echo "Ahora deberías ver 'Open in Terminal' en el menú contextual de Nautilus."
echo ""
echo "Si no aparece, cierra todas las ventanas de carpetas y ejecuta: nautilus -q"
echo "=========================================="
