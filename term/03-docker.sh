#!/bin/bash

. ./utils.sh

DOCKER_KEY_FILE=/etc/apt/keyrings/docker.gpg
DOCKER_SOURCE_LIST_FILE=/etc/apt/sources.list.d/docker.list

if [ ! -s "${DOCKER_KEY_FILE}" ]; then
	l_info "installing gpg key..."
	sudo mkdir -m 0755 -p /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
else
	l_skip "docker key file already installed."
fi

if [ ! -s "${DOCKER_SOURCE_LIST_FILE}" ]; then
	l_info "installing docker repository source..."
	PACKAGE_BASE=$(awk -F= -v key="DISTRIB_CODENAME" '$1 == key {print $NF}' /etc/upstream-release/lsb-release)
	sudo echo \
	"deb [arch=$(dpkg --print-architecture) signed-by=${DOCKER_KEY_FILE}] https://download.docker.com/linux/ubuntu \
	${PACKAGE_BASE} stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt update
else
	l_skip "docker repsoitory source already installed."
fi

install_via_apt docker-ce
install_via_apt docker-ce-cli
install_via_apt containerd.io
install_via_apt docker-buildx-plugin
install_via_apt docker-compose-plugin

DOCKER_SERVICE_DIR=/etc/systemd/system/docker.service.d
DOCKER_SERVICE_FILE="${DOCKER_SERVICE_DIR}/http-proxy.conf"

if [ ! -d "${DOCKER_SERVICE_DIR}" ]; then
	sudo mkdir -p "${DOCKER_SERVICE_DIR}"
fi

if [ ! -s "${DOCKER_SERVICE_FILE}" ]; then
	sudo touch "${DOCKER_SERVICE_FILE}"
	sudo chown ${USER} "${DOCKER_SERVICE_FILE}"
	cat <<-EOF  > "${DOCKER_SERVICE_FILE}"
	[Service]
	Environment="HTTP_RPOXY=http://127.0.0.1:7890"
	Environment="HTTPS_RPOXY=http://127.0.0.1:7890"
	Environment="NO_PROXY=127.0.0.0/8,localhost,::1,.local"
EOF
	sudo chown root "${DOCKER_SERVICE_FILE}"
	sudo systemctl daemon-reload
	sudo systemctl restart docker

	l_info "docker engine use proxy configured"
fi