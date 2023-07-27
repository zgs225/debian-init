#!/bin/bash

. ./utils.sh

# Install sdkman
if [ -z "${SDKMAN_DIR}" ] || [ ! -d "${SDKMAN_DIR}" ]; then
    l_info "Installing sdkman..."
    curl -s "https://get.sdkman.io" | bash
else
    l_skip "sdkman already installed"
fi

# 将 sdkman 的配置写入到 ~/.zsh/configs/sdkman.zsh 中
SDKMAN_CONFIG_FILE=~/.zsh/configs/sdkman.zsh
if [ -f "$SDKMAN_CONFIG_FILE" ]; then
    l_skip "sdkman config file already exists"
else
    l_info "Creating sdkman config file..."
    touch $SDKMAN_CONFIG_FILE
    echo "export SDKMAN_DIR=\"$HOME/.sdkman\"" >> $SDKMAN_CONFIG_FILE
    echo "[[ -s \"$HOME/.sdkman/bin/sdkman-init.sh\" ]] && source \"$HOME/.sdkman/bin/sdkman-init.sh\"" >> $SDKMAN_CONFIG_FILE
fi
source $SDKMAN_CONFIG_FILE

function isJDKInstalled() {
    local version=$1

    l_info "Checking jdk $version is installed..."

    local result=$(sdk list java | grep $version)

    # 判断 result 中是否包含 *, >, 如果包含则表示已经安装
    if [[ $result == *"*"* ]] || [[ $result == *">"* ]]; then
        return 0
    else
        return 1
    fi
}

# 安装 jdk 17.0.8-tem
if isJDKInstalled "17.0.8-tem"; then
    l_skip "jdk 17.0.8-tem already installed"
else
    l_info "Installing jdk 17.0.8-tem..."
    sdk install java 17.0.8-tem
    l_success "jdk 17.0.8-tem installed"
fi

l_info "Set jdk 17.0.8-tem as default"
sdk use java 17.0.8-tem
sdk default java 17.0.8-tem
