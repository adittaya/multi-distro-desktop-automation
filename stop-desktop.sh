#!/bin/bash
# Stop desktop environment and audio services
set -euo pipefail

echo "[INFO] Stopping desktop environment..."

# Stop display manager
if command -v systemctl >/dev/null 2>&1; then
    sudo systemctl stop lightdm 2>/dev/null || true
elif command -v rc-service >/dev/null 2>&1; then
    # For OpenRC systems
    sudo rc-service lightdm stop 2>/dev/null || true
fi

# Stop PulseAudio
echo "[INFO] Stopping PulseAudio..."
pulseaudio --kill 2>/dev/null || true

echo "[SUCCESS] Desktop environment and audio services stopped."
