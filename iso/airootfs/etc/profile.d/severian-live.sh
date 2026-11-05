# shellcheck shell=sh
# SeverianOS live medium: start the desktop on tty1
if [ "$USER" = "live" ] && [ "$(tty)" = "/dev/tty1" ] && [ -z "$WAYLAND_DISPLAY" ]; then
    exec severian-session
fi
