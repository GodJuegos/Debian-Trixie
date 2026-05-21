#!/bin/bash
# ============================================================
# Script: instalar-blackbox.sh
# Descripcion: Instala BlackBox Terminal y lo configura como
#              terminal predeterminado en Nautilus (Debian).
#
# Uso: sudo bash instalar-blackbox.sh
# ============================================================

set -e

# Verificar que se ejecuta como root
if [[ $EUID -ne 0 ]]; then
   echo "ERROR: Este script debe ejecutarse como root"
   echo "Uso: sudo bash instalar-blackbox.sh"
   exit 1
fi

USUARIO="${SUDO_USER:-$(whoami)}"
HOME_DIR="/home/${USUARIO}"

if [ ! -d "${HOME_DIR}" ]; then
    HOME_DIR=$(eval echo "~${USUARIO}")
fi

echo "=========================================="
echo "  Instalacion de BlackBox Terminal"
echo "=========================================="
echo "Usuario: ${USUARIO}"
echo "Home: ${HOME_DIR}"
echo ""

# ============================================================
# 1. Actualizar repositorios e instalar dependencias
# ============================================================
echo "[1/6] Actualizando repositorios e instalando dependencias..."

apt update -qq
apt install -y flatpak git wget make python3-nautilus gir1.2-gtk-4.0 gettext build-essential bash-completion command-not-found

# Agregar Flathub si no existe
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# ============================================================
# 2. Instalar BlackBox desde Flathub
# ============================================================
echo ""
echo "[2/6] Instalando BlackBox Terminal desde Flathub..."

flatpak install -y flathub com.raggesilver.BlackBox

# ============================================================
# 3. Compilar e instalar nautilus-open-any-terminal
# ============================================================
echo ""
echo "[3/6] Compilando extension nautilus-open-any-terminal..."

cd /tmp
rm -rf nautilus-open-any-terminal 2>/dev/null || true
git clone https://github.com/Stunkymonkey/nautilus-open-any-terminal.git

cd nautilus-open-any-terminal
make
make install schema
glib-compile-schemas /usr/share/glib-2.0/schemas

# ============================================================
# 4. Configurar BlackBox como terminal predeterminado
# ============================================================
echo ""
echo "[4/6] Configurando BlackBox como terminal predeterminado..."

runuser -l "${USUARIO}" -c "gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal 'custom'"
runuser -l "${USUARIO}" -c "gsettings set com.github.stunkymonkey.nautilus-open-any-terminal custom-local-command 'flatpak run com.raggesilver.BlackBox --working-directory %s'"
runuser -l "${USUARIO}" -c "gsettings set com.github.stunkymonkey.nautilus-open-any-terminal flatpak 'system'"
runuser -l "${USUARIO}" -c "gsettings set com.github.stunkymonkey.nautilus-open-any-terminal use-generic-terminal-name true"

# Configurar terminal predeterminado de GNOME
runuser -l "${USUARIO}" -c "gsettings set org.gnome.desktop.default-applications.terminal exec 'flatpak run com.raggesilver.BlackBox'"
runuser -l "${USUARIO}" -c "gsettings set org.gnome.desktop.default-applications.terminal exec-arg ''"

# ============================================================
# 5. Configurar autocompletado y deteccion de errores
# ============================================================
echo ""
echo "[5/6] Configurando autocompletado y deteccion de errores..."

BASHRC="${HOME_DIR}/.bashrc"

# Backup del .bashrc original
if [ -f "${BASHRC}" ]; then
    cp "${BASHRC}" "${BASHRC}.bak.blackbox" 2>/dev/null || true
fi

# Verificar si ya esta configurado para no duplicar
if grep -q "Configuracion de BlackBox" "${BASHRC}" 2>/dev/null; then
    echo "   Configuracion de BlackBox ya existe en .bashrc, omitiendo..."
else
    cat >> "${BASHRC}" << 'BASHRC_ADD'

# ============================================================
# Configuracion de BlackBox - Autocompletado y Mejoras
# ============================================================

# Habilitar bash-completion
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# Autocompletado mejorado
bind 'set show-all-if-ambiguous on'
bind 'set menu-complete-display-prefix on'
bind 'set completion-ignore-case on'
bind 'set mark-directories on'
bind 'set mark-symlinked-directories on'
bind 'set skip-completed-text on'
bind 'set colored-stats on'
bind 'set show-all-if-unmodified on'
bind 'set page-completions off'
bind 'set colored-completion-prefix on'

# Historial mejorado
shopt -s histappend
export HISTCONTROL=ignoreboth:erasedups
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTTIMEFORMAT="%F %T "

# Alias utiles
alias ll='ls -la --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'

# Deteccion de errores y prompt mejorado
_bb_error_handler() {
    local exit_code=$?
    if [ "$exit_code" -ne 0 ] 2>/dev/null; then
        echo -e "\033[0;31m[ERROR] Comando fallo con codigo: $exit_code\033[0m"
        case $exit_code in
            127) echo -e "\033[0;33m[INFO] Comando no encontrado. Verifica el nombre o instala el paquete.\033[0m" ;;
            126) echo -e "\033[0;33m[INFO] Comando no ejecutable. Verifica permisos con chmod +x\033[0m" ;;
            1)   echo -e "\033[0;33m[INFO] Error general. Verifica la sintaxis del comando.\033[0m" ;;
            2)   echo -e "\033[0;33m[INFO] Uso incorrecto del comando. Usa --help para ayuda.\033[0m" ;;
            130) echo -e "\033[0;33m[INFO] Comando interrumpido por Ctrl+C\033[0m" ;;
            137) echo -e "\033[0;33m[INFO] Proceso terminado (OOM o kill -9)\033[0m" ;;
        esac
        PS1="\[\033[0;31m\][${exit_code}]\[\033[0m\] \[\033[1;32m\]\u@\h\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\]\$ "
    else
        PS1="\[\033[1;32m\]\u@\h\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\]\$ "
    fi
}
PROMPT_COMMAND=_bb_error_handler
BASHRC_ADD
fi

chown "${USUARIO}:${USUARIO}" "${BASHRC}" 2>/dev/null || true

# Configurar .bash_profile si existe
BASH_PROFILE="${HOME_DIR}/.bash_profile"
if [ -f "${BASH_PROFILE}" ]; then
    if ! grep -q "bashrc" "${BASH_PROFILE}" 2>/dev/null; then
        echo '[ -f ~/.bashrc ] && . ~/.bashrc' >> "${BASH_PROFILE}"
    fi
fi

# ============================================================
# 6. Reiniciar Nautilus y limpiar
# ============================================================
echo ""
echo "[6/6] Reiniciando Nautilus y limpiando archivos temporales..."

runuser -l "${USUARIO}" -c 'nautilus -q' 2>/dev/null || true

cd /
rm -rf /tmp/nautilus-open-any-terminal

# ============================================================
# Finalizar
# ============================================================
echo ""
echo "=========================================="
echo "  ¡Instalacion completada exitosamente!"
echo "=========================================="
echo ""
echo "Resumen de cambios realizados:"
echo "  [OK] BlackBox Terminal instalado via Flatpak"
echo "  [OK] Extension nautilus-open-any-terminal compilada e instalada"
echo "  [OK] BlackBox configurado como terminal predeterminado"
echo "  [OK] Click derecho en Nautilus -> Abrir en Terminal (abre en la ruta actual)"
echo "  [OK] Autocompletado mejorado activado"
echo "  [OK] Deteccion de errores configurada"
echo ""
echo "Para aplicar los cambios:"
echo "  - Abre una nueva terminal o ejecuta: source ~/.bashrc"
echo "  - Si el menu contextual no aparece, cierra todas las ventanas de Nautilus"
echo "    y ejecuta: nautilus -q"
echo ""
echo "=========================================="
