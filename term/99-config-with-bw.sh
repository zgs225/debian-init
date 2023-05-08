#!/bin/bash

# Config with bitwarden

. ./utils.sh

# Login into bitwarden
if ! bw login --check > /dev/null; then
    l_info "login into bitwarden with email ${EMAIL}."
    bw login --raw "${EMAIL}" > "${HOME}/.bw_session"
    l_success "bitwarden login."
else
    l_skip "bitwarden is already logged in."
fi

BW_SESSION=$(cat "${HOME}/.bw_session")
if [ -z "${BW_SESSION}" ]; then
    l_error "bitwarden session is empty."
    exit 1
fi
export BW_SESSION="${BW_SESSION}"

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

# Config ssh private key with bitwarden
SSH_PRIVATE_KEY_FILE="${HOME}/.ssh/id_rsa"
if test -f "${SSH_PRIVATE_KEY_FILE}"; then
    l_skip "ssh private key file is already exists."
else
    l_info "get ssh private key file from bitwarden."
    SSH_PRIVATE_KEY=$(bw get item "SSH Private Key" | jq -c '.login.password' | tr -d '"')
    [ ! -d "${HOME}/.ssh" ] && mkdir -p "${HOME}/.ssh"
    echo "${SSH_PRIVATE_KEY}" | base64 -d > "${SSH_PRIVATE_KEY_FILE}"
    chmod 0600 "${SSH_PRIVATE_KEY_FILE}"
    l_success "ssh private key file is configured."
fi

# Config ssh public key with bitwarden
SSH_PUBLIC_KEY_FILE="${HOME}/.ssh/id_rsa.pub"
if test -f "${SSH_PUBLIC_KEY_FILE}"; then
    l_skip "ssh public key file is already exists."
else
    l_info "get ssh public key file from bitwarden."
    SSH_PUBLIC_KEY=$(bw get item "SSH Public Key" | jq -c '.login.password' | tr -d '"')
    [ ! -d "${HOME}/.ssh" ] && mkdir -p "${HOME}/.ssh"
    echo "${SSH_PUBLIC_KEY}" | base64 -d > "${SSH_PUBLIC_KEY_FILE}"
    chmod 0600 "${SSH_PUBLIC_KEY_FILE}"
    l_success "ssh public key file is configured."
fi

# Config LightsailDefaultKey-ap-southeast-1.pem with bitwarden
LIGHTSAIL_DEFAULT_KEY_FILE="${HOME}/.ssh/LightsailDefaultKey-ap-southeast-1.pem"
if test -f "${LIGHTSAIL_DEFAULT_KEY_FILE}"; then
    l_skip "LightsailDefaultKey-ap-southeast-1.pem file is already exists."
else
    l_info "get LightsailDefaultKey-ap-southeast-1.pem file from bitwarden."
    LIGHTSAIL_DEFAULT_KEY=$(bw get item "LightsailDefaultKey-ap-southeast-1.pem" | jq -c '.login.password' | tr -d '"')
    [ ! -d "${HOME}/.ssh" ] && mkdir -p "${HOME}/.ssh"
    echo "${LIGHTSAIL_DEFAULT_KEY}" | base64 -d > "${LIGHTSAIL_DEFAULT_KEY_FILE}"
    chmod 0600 "${LIGHTSAIL_DEFAULT_KEY_FILE}"
    l_success "LightsailDefaultKey-ap-southeast-1.pem file is configured."
fi

# AWS configuration with bitwarden
AWS_CONFIG_FILE="${HOME}/.aws/config"
if test -f "${AWS_CONFIG_FILE}"; then
    l_skip "aws configuration file is already exists."
else
    [ ! -d "${HOME}/.aws" ] && mkdir -p "${HOME}/.aws"

    l_info "get aws configuration from bitwarden."
    AWS_ACCESS_KEY_ID=$(bw get item "AWS Config" | jq -c '.login.username' | tr -d '"')
    AWS_SECRET_ACCESS_KEY=$(bw get item "AWS Config" | jq -c '.login.password' | tr -d '"')

    cat <<-EOF > "${AWS_CONFIG_FILE}"
    [default]
    aws_access_key_id = ${AWS_ACCESS_KEY_ID}
    aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
    region = ap-southeast-1
    output = json
EOF
    chmod 0600 "${AWS_CONFIG_FILE}"
    ARN=$(aws sts get-caller-identity | jq -c '.Arn' | tr -d '"')
    if [ -z "${ARN}" ]; then
        l_warn "get ARN error, please check your aws configuration or network."
    else
        l_success "aws configuration file is configured. ARN: ${ARN}"
    fi
fi

unset BW_SESSION
