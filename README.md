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

# 5. Instalamos Flatpak para algunos programas con esta compatibilad

sudo apt install flatpak

sudo apt install gnome-software-plugin-flatpak

sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

