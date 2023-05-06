. ./utils.sh

DISTRO=$(get_distrib_codename)

if [ -z "$DISTRO" ]; then
    l_error "Could not determine distro codename"
    exit 1
fi

if [ -f /usr/share/keyrings/tailscale-archive-keyring.gpg ]; then
    l_skip "tailscale keyring already installed"
else
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/${DISTRO}.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
    l_success "tailscale keyring installed"
fi

if [ -f /etc/apt/sources.list.d/tailscale.list ]; then
    l_skip "tailscale repo already added"
else
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/${DISTRO}.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
    sudo apt update
    l_success "tailscale repo added"
fi

install_via_apt tailscale

