#!/bin/bash

. ./utils.sh

install_remote_deb "https://github.com/TheAssassin/AppImageLauncher/releases/download/v2.2.0/appimagelauncher_2.2.0-travis995.0f91801.bionic_amd64.deb" appimagelauncher
install_remote_deb "https://dtapp-pub.dingtalk.com/dingtalk-desktop/xc_dingtalk_update/linux_deb/Release/com.alibabainc.dingtalk_1.4.0.20425_amd64.deb" com.alibabainc.dingtalk

CLASH_VERGE_DOWNLOAD_URL="https://jupyter.yuez.me:12388/clash/clients/clash-verge_1.2.3_amd64.deb"
CLASH_VERGE_PACKAGE="clash-verge"
install_remote_deb $CLASH_VERGE_DOWNLOAD_URL $CLASH_VERGE_PACKAGE

# Install vscode from deb package
install_remote_deb "https://az764295.vo.msecnd.net/stable/92da9481c0904c6adfe372c12da3b7748d74bdcb/code_1.76.0-1677667493_amd64.deb" code

install_via_flatpak com.google.Chrome
install_via_flatpak io.dbeaver.DBeaverCommunity
install_via_flatpak com.bitwarden.desktop
install_via_flatpak com.tencent.wemeet
install_via_flatpak com.jetbrains.CLion
install_via_flatpak com.jetbrains.IntelliJ-IDEA-Ultimate
install_via_flatpak org.remmina.Remmina
install_via_flatpak com.wps.Office
install_via_flatpak rest.insomnia.Insomnia
install_via_flatpak org.wireshark.Wireshark
install_via_flatpak net.xmind.XMind8
install_via_flatpak dev.k8slens.OpenLens
install_via_flatpak org.telegram.desktop


install_prebuilt_package "https://download-cdn.jetbrains.com/go/goland-2022.3.2.tar.gz"
