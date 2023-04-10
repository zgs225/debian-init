#!/bin/bash

. ./utils.sh

OS=$(uname | tr '[:upper:]' '[:lower:]')
ARCH=$(dpkg --print-architecture)

KUBECTL_URL="https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/${OS}/${ARCH}/kubectl"
install_prebuilt_bin kubectl "${KUBECTL_URL}"

KIND_URL="https://kind.sigs.k8s.io/dl/v0.17.0/kind-${OS}-${ARCH}"
install_prebuilt_bin kind "${KIND_URL}"

if [ command -v helm &> /dev/null ]; then
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
    rm get_helm.sh
    l_success "helm installed"

    helm repo add bitnami https://charts.bitnami.com/bitnami
    l_success "bitnami repo added"
else
    l_skip "helm already installed"
fi
