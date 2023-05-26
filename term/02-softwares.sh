#!/bin/bash

. ./utils.sh

if [ ! -z "${HTTP_PROXY}" ]; then
    apt_proxy_file="/etc/apt/apt.conf.d/01proxy"
    if [ -f "$apt_proxy_file" ]; then
        l_skip "apt proxy already configured"
    else
        sudo tee "$apt_proxy_file" <<EOF
Acquire {
HTTP::proxy "${HTTP_PROXY}";
HTTPS::proxy "${HTTPS_PROXY}}";
}
EOF
        l_success "Configured apt proxy"
    fi
fi

install_via_apt git
install_via_apt neovim
install_via_apt curl
install_via_apt httpie
install_via_apt jq
install_via_apt build-essential
install_via_apt libssl-dev
install_via_apt zlib1g-dev
install_via_apt libbz2-dev
install_via_apt libreadline-dev
install_via_apt libsqlite3-dev curl
install_via_apt libncursesw5-dev
install_via_apt xz-utils
install_via_apt tk-dev
install_via_apt libxml2-dev
install_via_apt libxmlsec1-dev
install_via_apt libffi-dev
install_via_apt liblzma-dev
install_via_apt rcm
install_via_apt tmux
install_via_apt mysql-client-core-8.0
install_via_apt redis-tools
install_via_apt ca-certificates
install_via_apt gnupg
install_via_apt lsb-release
install_via_apt bat
install_via_apt ntfs-3g
install_via_apt clangd-15
install_via_apt ansible
install_via_apt tree
install_via_apt silversearcher-ag
install_via_apt universal-ctags
install_via_apt wireguard
install_via_apt wireguard-tools
install_via_apt resolvconf
install_via_apt rclone
install_via_apt awscli
install_via_apt tesseract-ocr
install_via_apt libtesseract-dev
install_via_apt tesseract-ocr-chi-sim
install_via_apt htop
install_via_apt lm-sensors
install_via_apt devscripts
install_via_apt socat
install_via_apt bear
install_via_apt cifs-utils

install_prebuilt_zipbin bw "https://vault.bitwarden.com/download/?app=cli&platform=linux"

install_remote_deb "https://github.com/ellie/atuin/releases/download/v14.0.1/atuin_14.0.1_amd64.deb" atuin
