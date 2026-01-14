#!/bin/bash
set -euo pipefail

DETECTED_PORT=$(ls /sys/class/drm | grep -E 'card[0-9]+-DP-[0-9]+' | head -n 1 | cut -d'-' -f2-)
PORT="${DETECTED_PORT:-DP-1}"

echo "Port detection: Found '$DETECTED_PORT', using '$PORT'"

EDID_FILE="edid/edid.bin"
TARGET_PATH="/usr/lib/firmware/$EDID_FILE"

if [ ! -f "$TARGET_PATH" ]; then
    echo "ERROR: Could not find EDID-file in $TARGET_PATH"
    exit 1
fi

CURRENT_KARGS=$(rpm-ostree kargs)
ARGS_TO_APPEND=""

REQUIRED_ARGS=(
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
    "video=$PORT:e"
    "drm.edid_firmware=$PORT:$EDID_FILE"
)

# Analyze existing boot-argument
for ARG in "${REQUIRED_ARGS[@]}"; do
    if [[ "$CURRENT_KARGS" != *"$ARG"* ]]; then
        echo "Missing arg: $ARG"
        ARGS_TO_APPEND="$ARGS_TO_APPEND --append=$ARG"
    fi
done

# Updates kernel arguments
if [ -n "$ARGS_TO_APPEND" ]; then
    echo "Applying kernel arguments..."
    rpm-ostree kargs $ARGS_TO_APPEND

    echo "Rebooting system to apply changes..."
    systemctl reboot
else
    echo "Configuration correct. No changes needed."
fi