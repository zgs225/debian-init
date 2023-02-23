#!/bin/bash

. ./utils.sh

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

# Install clash-verge from remote
CLASH_VERGE_DOWNLOAD_URL="https://jupyter.yuez.me:12388/clash/clients/clash-verge_1.2.3_amd64.deb"
CLASH_VERGE_PACKAGE="clash-verge"
install_remote_deb $CLASH_VERGE_DOWNLOAD_URL $CLASH_VERGE_PACKAGE