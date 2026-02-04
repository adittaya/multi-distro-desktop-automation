#!/bin/bash
# Start desktop environment with audio support
set -euo pipefail

echo "[INFO] Starting desktop environment with audio..."

# Ensure PulseAudio is running
if ! pgrep -x "pulseaudio" > /dev/null; then
    echo "[INFO] Starting PulseAudio server..."
    pulseaudio --kill 2>/dev/null || true
    pulseaudio --start \
      --exit-idle-time=-1 \
      --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1"
    sleep 2
else
    echo "[INFO] PulseAudio already running"
fi

# Start display manager if not running
if ! pgrep -x "lightdm" > /dev/null && command -v systemctl >/dev/null 2>&1; then
    echo "[INFO] Starting LightDM display manager..."
    sudo systemctl start lightdm
elif ! pgrep -x "lightdm" > /dev/null && command -v rc-service >/dev/null 2>&1; then
    # For OpenRC systems
    sudo rc-service lightdm start
fi

# Check if we're in a container or chroot
if [ -f /.dockerenv ] || [ -n "$container" ] 2>/dev/null; then
    echo "[WARNING] Running in container - GUI may not be available"
    echo "[INFO] Use with X11 forwarding or VNC"
fi

echo "[SUCCESS] Desktop environment started with audio support!"
echo "[INFO] Check your display manager at the login screen"
