#!/bin/bash
# PulseAudio service manager
set -euo pipefail

ACTION=${1:-status}

case $ACTION in
    start)
        echo "[INFO] Starting PulseAudio server..."
        pulseaudio --kill 2>/dev/null || true
        pulseaudio --start \
          --exit-idle-time=-1 \
          --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1"
        sleep 2
        if pgrep -x "pulseaudio" > /dev/null; then
            echo "[SUCCESS] PulseAudio started successfully"
        else
            echo "[ERROR] Failed to start PulseAudio"
            exit 1
        fi
        ;;
    stop)
        echo "[INFO] Stopping PulseAudio server..."
        pulseaudio --kill 2>/dev/null || true
        echo "[SUCCESS] PulseAudio stopped"
        ;;
    restart)
        echo "[INFO] Restarting PulseAudio server..."
        ./pulseaudio-manager.sh stop
        sleep 2
        ./pulseaudio-manager.sh start
        ;;
    status)
        if pgrep -x "pulseaudio" > /dev/null; then
            echo "[STATUS] PulseAudio is running"
            # Show server info
            pactl info 2>/dev/null | head -10
        else
            echo "[STATUS] PulseAudio is not running"
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac
