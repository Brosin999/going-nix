#!/usr/bin/env bash

# Toggle waybar visibility for true fullscreen

if systemctl --user is-active --quiet waybar.service; then
    # Waybar is running, stop it
    systemctl --user stop waybar.service
    echo "Waybar hidden"
else
    # Waybar is stopped, start it
    systemctl --user start waybar.service
    echo "Waybar shown"
fi