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
sudo apt-key del 818A435C5FCBF54A &> /dev/null
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
    sudo tee "/etc/apt/sources.list.d/winehq.sources" <<EOF
Types: deb
URIs: https://dl.winehq.org/wine-builds/ubuntu
Suites: ${distro}
Components: main
Architectures: amd64 i386
Signed-By: ${keyrings_dir}/${winehq_key}
EOF
    sudo apt update
    l_success "Added winehq repository"
else
    l_skip "winehq repository already present"
fi

install_via_apt winehq-staging

# Install winetricks by script
if [ ! -f "/usr/local/bin/winetricks" ]; then
    l_warn "Installing winetricks"
    wget -O /tmp/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
    sudo mv /tmp/winetricks /usr/local/bin/winetricks
    sudo chmod +x /usr/local/bin/winetricks
    l_success "winetricks installed"

    # Install winetricks bash completion
    wget -O /tmp/winetricks-completion.bash https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks-completion.bash
    sudo mv /tmp/winetricks-completion.bash /usr/share/bash-completion/completions/winetricks
    l_success "winetricks bash completion installed"

    # Download latest man page
    wget -O /tmp/winetricks.1 https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks.1
    sudo mv /tmp/winetricks.1 /usr/share/man/man1/winetricks.1
else
    l_skip "winetricks already installed"
fi


# Install a shared wine mono at /usr/share/wine/mono/
if [ ! -d "/usr/share/wine/mono" ]; then
    l_warn "Installing shared wine mono"
    sudo mkdir -p /usr/share/wine/mono
    wget -O /tmp/mono.tar.xz https://dl.winehq.org/wine/wine-mono/7.4.0/wine-mono-7.4.0-x86.tar.xz
    sudo tar -xf /tmp/mono.tar.xz -C /usr/share/wine/mono
    rm /tmp/mono.tar.xz
    l_success "Shared wine mono installed"
else
    l_skip "Shared wine mono already installed"
fi


WINE_WECHAT_ROOT="${WINE_ROOT}/wechat/drive_c/Program Files (x86)/Tencent/WeChat"

if [ ! -d "${WINE_WECHAT_ROOT}" ]; then
    l_warn "preparing wine wechat"
    WINEPREFIX="${WINE_ROOT}/wechat" WINEARCH="${WINE_ARCH}" winetricks -q win7 riched20 corefonts vcrun2015 opensymbol
    WINEPREFIX="${WINE_ROOT}/wechat" wine reg add 'HKCU\Control Panel\Desktop' /v LogPixels /t REG_DWORD /d 192 /f
    l_info "downloading wechat"
    wget -O /tmp/wechat.exe https://dldir1.qq.com/weixin/Windows/WeChatSetup.exe
    WINEPREFIX="${WINE_ROOT}/wechat" WINEARCH="${WINE_ARCH}" wine /tmp/wechat.exe
    rm /tmp/wechat.exe

    l_success "wine wechat installed"
else
    l_skip "wine wechat already installed"
fi
