#!/bin/bash
QT_QPA_PLATFORM=wayland flameshot gui --raw | wl-copy
