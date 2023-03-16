. ./utils.sh

foreignArch=$(sudo dpkg --print-foreign-architectures)
if [[ "$foreignArch" != *"i386"* ]]; then
    sudo dpkg --add-architecture i386
    sudo apt-get update
else
    l_skip "i386 architecture already added"
fi

# Add wine repository
if [ ! -f "/etc/apt/keyrings/winehq-archive.key" ]; then
    tmpKeyFile=$(mktemp)
    wget -O "${tmpKeyFile}" https://dl.winehq.org/wine-builds/winehq.key
    sudo mv "${tmpKeyFile}" /etc/apt/keyrings/winehq-archive.key
    l_warn "winehq-archive.key downloaded"

    DISTRIB_CODENAME=$(get_distrib_codename)

    if [ -z "$DISTRIB_CODENAME" ]; then
        l_error "DISTRIB_CODENAME is empty"
        exit 1
    fi

    tmpDir=$(mktemp -d)
    wget -NP "${tmpDir}" https://dl.winehq.org/wine-builds/ubuntu/dists/${DISTRIB_CODENAME}/winehq-${DISTRIB_CODENAME}.sources
    sudo mv "${tmpDir}/*" /etc/apt/sources.list.d/
    sudo apt update
fi

install_via_apt winehq-stable
install_via_apt winetricks

WINE_ROOT="${HOME}/.wine"
WINE_WECHAT_PREFIX="${WINE_ROOT}/wechat"
WINE_WECHAT_ARCH=win32

if [ ! -d "$WINE_WECHAT_PREFIX" ]; then
    mkdir -p "$WINE_WECHAT_PREFIX"
fi

# install wine wechat
if [ ! -f "$WINE_WECHAT_PREFIX/drive_c/Program Files (x86)/Tencent/WeChat/WeChat.exe" ]; then
    l_info "installing wine wechat"
    WINEPREFIX="$WINE_WECHAT_PREFIX" WINEARCH="${WINE_WECHAT_ARCH}" winetricks -q win7
    WINEPREFIX="$WINE_WECHAT_PREFIX" WINEARCH="${WINE_WECHAT_ARCH}" winetricks -q riched20
    WINEPREFIX="$WINE_WECHAT_PREFIX" WINEARCH="${WINE_WECHAT_ARCH}" winetricks -q corefonts
    wget -O /tmp/wechat.exe https://dldir1.qq.com/weixin/Windows/WeChatSetup.exe
    WINEPREFIX="$WINE_WECHAT_PREFIX" WINEARCH="${WINE_WECHAT_ARCH}" wine /tmp/wechat.exe
    rm /tmp/wechat.exe
    l_success "wine wechat installed"
else
    l_skip "wine wechat already installed"
fi
