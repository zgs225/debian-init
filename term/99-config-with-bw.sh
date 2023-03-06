#!/bin/bash

# Config with bitwarden

. ./utils.sh

# Login into bitwarden
if ! bw login --check > /dev/null; then
    bw login --raw
    l_success "bitwarden login."
else
    l_skip "bitwarden is already logged in."
fi

# Sync bitwarden
bw sync > /dev/null
l_info "bitwarden sync."

# Configure netrc file with bitwarden
if [ ! -f "${HOME}/.netrc" ]; then
    USERNAME="zhaigs5"
    PASSWORD=$(bw get item 10.126.138.28 | jq -c '.fields[] | select (.name == "API Key") | .value' | tr -d '"')
	cat <<-EOF > "${HOME}/.netrc"
	machine 10.126.138.28 login ${USERNAME} password ${PASSWORD}
EOF
	chmod 0600 "${HOME}/.netrc"
	l_success "netrc file confiigured."
else
	l_skip "netrc file is already exists."
fi

set_go_env GOPRIVATE  172.16.21.59
set_go_env GOINSECURE 172.16.21.59

# Wireguard configuration with bitwarden
WIREGUARD_CLIENT_CONF="/etc/wireguard/wg0.conf"
if sudo test -f "${WIREGUARD_CLIENT_CONF}"; then
    l_skip "wireguard client configuration file is already exists."
else
    l_info "get wireguard client configuration file from bitwarden."
    ITEM=$(bw get item "WireGuard Client LinuxMint")
    PRIVATE_KEY=$(echo "${ITEM}" | jq -c '.login.password' | tr -d '"')
    ENDPOINT=$(echo "${ITEM}" | jq -c '.fields[] | select (.name == "Endpoint") | .value' | tr -d '"')

    TMPFILE=$(mktemp)
    cat <<-EOF > "${TMPFILE}"
    [Interface]
    Address = 10.247.113.13/24, fd54:5612:3279:4624::13/64
    DNS = 1.1.1.1, 2606:4700:4700::1111
    PrivateKey = ${PRIVATE_KEY}
    MTU = 1280

    [Peer]
    PublicKey = zWsKalVtEi5sMQdCjy6Y47M9wB48FnuXBCd8tfIMHWU=
    PresharedKey = EzOpd0EAxVgiKRxDp1rHNC33Dj9vzlIpd2xmLYh7pNg=
    AllowedIPs = 0.0.0.0/0, ::/0
    Endpoint = ${ENDPOINT}
    PersistentKeepalive = 25
EOF
    sudo mv "${TMPFILE}" "${WIREGUARD_CLIENT_CONF}"
    sudo chmod 0600 "${WIREGUARD_CLIENT_CONF}"

    sudo systemctl enable wg-quick@wg0
    sudo systemctl start wg-quick@wg0

    l_success "wireguard client configuration file is configured."
fi
