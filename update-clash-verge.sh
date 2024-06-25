#!/bin/bash

# 该脚本用于更新 clash verge 软件, 该脚本假设 clash verge 是通过 deb 包安装的

. utils.sh

APP_NAME=clash-verge
GITHUB_REPO=zzzgydi/clash-verge
GITHUB_RELEASE_URL=https://api.github.com/repos/$GITHUB_REPO/releases/latest

if [ "$EUID" -ne 0 ]
  then l_error "请使用 root 权限运行该脚本"
  exit
fi

l_info "正在更新 clash verge"

dpkg -s $APP_NAME &> /dev/null
if [ $? -ne 0 ]; then
  l_error "未通过 deb 包安装 clash verge"
  exit
fi

version=$(dpkg -s $APP_NAME | grep Version | awk '{print $2}')
l_info "当前版本: $version"

latest_release=$(curl -s $GITHUB_RELEASE_URL)
latest_version=$(echo "$latest_release" | grep tag_name | cut -d '"' -f 4 | tr -d 'v')
l_info "最新版本: $latest_version"

if [ "$version" == "$latest_version" ]; then
  l_info "当前版本已是最新版本"
  exit
fi

download_url=$(echo "$latest_release" | jq -r '.assets[] | select(.name | contains("amd64.deb")) | .browser_download_url')

if [ -z "$download_url" ]; then
  l_error "未找到 amd64.deb 文件"
  exit
fi

l_info "找到下载链接：${download_url}"

l_info "正在下载最新版本"

wget -q $download_url -O clash-verge.deb
dpkg -i clash-verge.deb
rm clash-verge.deb

# 给 clash 添加 net_admin 权限以支持 tun 模式
setcap CAP_NET_BIND_SERVICE,CAP_NET_ADMIN=+ep /usr/bin/clash
setcap CAP_NET_BIND_SERVICE,CAP_NET_ADMIN=+ep /usr/bin/clash-meta

l_success "更新完成, 请重启 clash verge"
