# Debian-Trixie 13
Instalar debian trixie Guia

# 1. Entrar como root
su

Eleccion Mostrar asteriscos al introducir contraseña
direccion

nano /etc/sudoers

al lado ponemos de env_reset,pwfeedback a eleccion

# 2. Poner al usuario normal acceso sudo

nano /etc/sudoers.d/tu_usuario

agregar en el texto

tu_usuario ALL=(ALL:ALL) ALL

# 3. Cambiar los repositorios debian trixie

en sources.list

nano /etc/apt/sources.list 

cambiamos todo la lista eliminando el actual.

deb http://deb.debian.org/debian/ trixie main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ trixie main contrib non-free non-free-firmware

deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
deb-src http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware

deb http://deb.debian.org/debian/ trixie-updates main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ trixie-updates main contrib non-free non-free-firmware

guardamos 

hacemos un apt update 

# 4. Instalamos Packetes

sudo apt update && sudo apt dist-upgrade -y

sudo apt install curl git wget

sudo apt install fastfetch

sudo apt install exfat-fuse hfsplus ntfs-3g

sudo apt install gdebi gdebi-core synaptic

sudo apt install p7zip-full p7zip-rar rar unrar

sudo apt install ffmpeg libavcodec-extra gstreamer1.0-libav gstreamer1.0-plugins-ugly gstreamer1.0-plugins-bad gstreamer1.0-pulseaudio vorbis-tools

sudo apt-get install fonts-freefont-ttf fonts-freefont-otf

sudo apt-get install ttf-mscorefonts-installer

sudo apt install fonts-ubuntu

# 5. Instalamos Flatpak para algunos programas con esta compatibilad

sudo apt install flatpak

sudo apt install gnome-software-plugin-flatpak

sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

## 🚀 Instalación de Ptyxis solo debian no Flatpak

Para instalar el script y configurar Ptyxis correctamente, sigue estos pasos en tu terminal:

1. **Dale permisos de ejecución al archivo:**

   chmod +x ptyxis.sh
   
2. **Ejecuta el instalador con privilegios de root:**
   
   sudo ./ptyxis.sh
   
3. ## 🛠️ Solución al problema de la Ruta (Ruta actual vs Home)

Por defecto, en Debian 13, algunas extensiones de Nautilus abren la terminal en la carpeta personal (`/home`) y no donde estás parado.

### La solución aplicada:
Para que **Ptyxis** reconozca la ubicación de la carpeta desde los archivos de Nautilus, se deben forzar los argumentos de GTK4 mediante GSettings. El script ejecuta:

# Fuerza a la extensión a pasar la ruta actual como argumento

gsettings set com.github.stunkymonkey.nautilus-open-any-terminal use-all-terminal-args true

# Define explícitamente el binario de Ptyxis

gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal ptyxis

