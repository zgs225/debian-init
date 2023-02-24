#!/bin/bash

. ./utils.sh

OS=$(uname | tr '[:upper:]' '[:lower:]')
ARCH=$(dpkg --print-architecture)

KUBECTL_URL="https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/${OS}/${ARCH}/kubectl"
install_prebuilt_bin kubectl "${KUBECTL_URL}"

KIND_URL="https://kind.sigs.k8s.io/dl/v0.17.0/kind-${OS}-${ARCH}"
install_prebuilt_bin kind "${KIND_URL}"

HELM_URL="https://get.helm.sh/helm-v3.11.1-${OS}-${ARCH}.tar.gz"
install_prebuilt_bin helm "${HELM_URL}"