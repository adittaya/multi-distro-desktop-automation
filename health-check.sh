#!/bin/bash
# Health check for desktop environment setup
set -euo pipefail

echo "=== Multi-Distro Desktop Health Check ==="

# Check distribution detection
echo ""
echo "1. Distribution Detection:"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "   ✓ Distribution: $NAME ($VERSION)"
else
    echo "   ✗ Could not detect distribution"
fi

# Check desktop environment
echo ""
echo "2. Desktop Environment:"
if command -v startxfce4 >/dev/null 2>&1; then
    echo "   ✓ XFCE4 available"
else
    echo "   ✗ XFCE4 not found"
fi

# Check display manager
echo ""
echo "3. Display Manager:"
if pgrep -x "lightdm" > /dev/null; then
    echo "   ✓ LightDM running"
else
    echo "   ⚠ LightDM not running"
fi

# Check PulseAudio
echo ""
echo "4. PulseAudio Status:"
if pgrep -x "pulseaudio" > /dev/null; then
    echo "   ✓ PulseAudio daemon running"
    # Check if TCP module is loaded
    if pactl list modules short | grep -q "module-native-protocol-tcp"; then
        echo "   ✓ TCP protocol module loaded"
    else
        echo "   ⚠ TCP protocol module not loaded"
    fi
else
    echo "   ✗ PulseAudio daemon not running"
fi

# Check audio devices
echo ""
echo "5. Audio Devices:"
if command -v pactl >/dev/null 2>&1; then
    sink_count=$(pactl list sinks short | wc -l)
    source_count=$(pactl list sources short | wc -l)
    echo "   ✓ Sinks: $sink_count, Sources: $source_count"
else
    echo "   ⚠ pactl not available"
fi

# Check configuration files
echo ""
echo "6. Configuration Files:"
if [ -f ~/.config/pulse/client.conf ]; then
    echo "   ✓ PulseAudio client config exists"
else
    echo "   ⚠ PulseAudio client config missing"
fi

echo ""
echo "=== Health Check Complete ==="
