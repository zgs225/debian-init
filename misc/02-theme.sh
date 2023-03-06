#!/bin/bash

. ./utils.sh

# Setup gnome terminal theme to gruvbox-material
function setup_gnome_terminal_theme() {
    # If gnome terminal is not installed, exit
    if ! command -v gnome-terminal &> /dev/null; then
        l_error "Gnome terminal is not installed"
        return
    fi

    if [ -d "$HOME/.gogh" ]; then
        l_skip "Gnome terminal theme is already installed"
        return
    fi

    # Install gnome terminal theme
    git clone https://github.com/Gogh-Co/Gogh.git "$HOME/.gogh"
    bash "$HOME/.gogh/themes/gruvbox-material.sh"
    l_success "Gnome terminal theme installed"
}
