#!/bin/bash

. utils.sh

# Add i386 architecture if not already present
if ! dpkg --print-foreign-architectures | grep -q "i386"; then
    sudo dpkg --add-architecture i386
    l_success "Added i386 architecture"
else
    l_skip "i386 architecture already present"
fi

# Remove deprecated winehq key
sudo apt-key del 818A435C5FCBF54A 2>/dev/null
l_info "Removed deprecated winehq key"

keyrings_dir="/usr/share/keyrings"

if [ ! -d "$keyrings_dir" ]; then
    sudo mkdir -p "$keyrings_dir"
fi

winehq_key="winehq-key.gpg"

if [ ! -f "${keyrings_dir}/${winehq_key}" ]; then
    tmpfile=$(mktemp)
    wget -O ${tmpfile} https://dl.winehq.org/wine-builds/winehq.key
    sudo gpg -o "${keyrings_dir}/${winehq_key}" --dearmor ${tmpfile}
    l_success "Added winehq key"
else
    l_skip "winehq key already present"
fi

distro=$(get_distrib_codename)
if [ -z "$distro" ]; then
    l_error "Could not determine distribution codename"
    exit 1
fi

# Add winehq repository if not already present
if ! grep -q "winehq" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
    sudo add-apt-repository -y "deb [arch=amd64 signed-by=${keyrings_dir}/${winehq_key}] https://dl.winehq.org/wine-builds/ubuntu/ ${distro} main"
    sudo apt update
    l_success "Added winehq repository"
else
    l_skip "winehq repository already present"
fi
