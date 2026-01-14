#!/usr/bin/env bash
set -euo pipefail

# Mask systemd targets to permanently prevent sleep
# This is the standard solution for servers/headless systems
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target