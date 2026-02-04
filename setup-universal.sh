#!/bin/bash
# Universal Linux desktop setup with audio support
set -euo pipefail

echo "[INFO] Detecting Linux distribution..."

# Detect distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
    DISTRO_VERSION=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    DISTRO=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
else
    echo "[ERROR] Cannot detect Linux distribution"
    exit 1
fi

echo "[INFO] Detected distribution: $DISTRO"

# Install desktop environment based on distribution
case $DISTRO in
    ubuntu|debian|raspbian)
        echo "[INFO] Installing XFCE4 on Debian-based system..."
        sudo apt update
        sudo apt install -y xfce4 xfce4-goodies pulseaudio pavucontrol alsa-utils lightdm
        ;;
    fedora|centos|rhel|rocky|almalinux)
        echo "[INFO] Installing XFCE4 on Red Hat-based system..."
        sudo dnf install -y xfce4-session xfce4-panel xfce4-desktop xfce4-appfinder xfce4-power-manager xfce4-screenshooter xfce4-settings xfce4-taskmanager xfce4-terminal xfce4-volumed-pulse pavucontrol pulseaudio pulseaudio-utils alsa-utils lightdm
        ;;
    arch|manjaro)
        echo "[INFO] Installing XFCE4 on Arch-based system..."
        sudo pacman -Sy --noconfirm xfce4 xfce4-goodies pavucontrol pulseaudio pulseaudio-alsa alsa-utils lightdm
        ;;
    opensuse-leap|opensuse-tumbleweed)
        echo "[INFO] Installing XFCE4 on openSUSE..."
        sudo zypper install -y xfce4 pavucontrol pulseaudio pulseaudio-utils alsa-utils lightdm
        ;;
    alpine)
        echo "[INFO] Installing XFCE4 on Alpine Linux..."
        sudo apk add xfce4 lightdm pavucontrol pulseaudio pulseaudio-utils alsa-utils
        ;;
    *)
        echo "[ERROR] Unsupported distribution: $DISTRO"
        exit 1
        ;;
esac

# Configure PulseAudio
echo "[INFO] Configuring PulseAudio..."
pulseaudio --kill 2>/dev/null || true

# Create PulseAudio configuration
mkdir -p ~/.config/pulse
cat > ~/.config/pulse/client.conf << 'EOF'
# Configuration for PulseAudio client
tcp-server=127.0.0.1
auth-anonymous=1
autospawn=no
EOF

# Start PulseAudio server
pulseaudio --start \
  --exit-idle-time=-1 \
  --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1"

# Wait for PulseAudio to start
sleep 2

# Enable LightDM display manager
if command -v systemctl >/dev/null 2>&1; then
    sudo systemctl enable lightdm
    sudo systemctl start lightdm
elif command -v rc-update >/dev/null 2>&1; then
    # For OpenRC systems (Alpine, etc.)
    sudo rc-update add lightdm default
    sudo rc-service lightdm start
fi

echo "[SUCCESS] Desktop environment installed with audio support!"
echo "[INFO] You can now start the desktop with './start-desktop.sh'"
