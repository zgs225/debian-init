#!/bin/bash

. ./utils.sh

PROFILE_FILE="${HOME}/.profile"

source $PROFILE_FILE

# Install golang
command -v go > /dev/null
if [ $? != 0 ]; then
	l_info "installing golang..."
	http --download https://go.dev/dl/go1.20.1.linux-amd64.tar.gz -o go.tar.gz
	sudo tar -C /usr/local -xzf go.tar.gz
	sudo chmod a+x /usr/local/go/bin/go
	echo 'export PATH=$PATH:/usr/local/go/bin' >> "${PROFILE_FILE}"
	source "${PROFILE_FILE}"
	l_info "golang $(go version) installed."
	rm -f go.tar.gz
else
	l_skip "golang $(go version) already installed"
fi

# Install nvm and nodejs
if [ -z "$NVM_DIR" ]; then
	l_info "installing nvm"
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
	source "${PROFILE_FILE}"
	nvm --version
else
	. ${NVM_DIR}/nvm.sh
	l_skip "nvm $(nvm --version) already installed."
fi

# Install lastest Node.js
command -v node &> /dev/null 
if [ $? != 0 ]; then
	nvm install --lts --default
	l_info "$(node --version)"
	corepack enable
else
	l_skip "node $(node --version) already installed."
fi

# Install pyenv
command -v pyenv &> /dev/null
if [ $? != 0 ]; then
	curl https://pyenv.run | bash

	cat <<-EOF >> $PROFILE_FILE
	export PYENV_ROOT="\$HOME/.pyenv"
	command -v pyenv >/dev/null || export PATH="\$PYENV_ROOT/bin:\$PATH"
	eval "\$(pyenv init -)"
EOF
	source $PROFILE_FILE
	l_info "$(pyenv --version) installed."
else
	l_skip "$(pyenv --version) already installed."
fi

# Install python via pyenv
command -v python &> /dev/null
if [ $? != 0 ]; then
	PYTHON_VESION=3.11.2
	pyenv install "${PYTHON_VESION}"
	pyenv rehash
	pyenv global "${PYTHON_VESION}"
	l_info "$(python --version) installed."
else
	l_skip "$(python --version) already installed."
fi

# Install rust
command -v rustc &> /dev/null
if [ $? != 0 ]; then
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
	l_info "$(rustc --version) installed."
else
	l_skip "$(rustc --version) already installed."
fi

# Install protobuf compiler and its tools
TRIPLE_GATEWAY_VERSION=e316e53ee241c94282ad37d0b12e9af61eb50bfb

install_via_apt protobuf-compiler
install_via_go google.golang.org/protobuf/cmd/protoc-gen-go@v1.28
install_via_go google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2
install_via_go github.com/dubbogo/tools/cmd/protoc-gen-go-triple@v1.0.9
install_via_go "github.com/zgs225/dubbo-go-gateway/protoc-gen-triple-gateway@${TRIPLE_GATEWAY_VERSION}"
install_via_go "github.com/zgs225/dubbo-go-gateway/protoc-gen-openapiv2@${TRIPLE_GATEWAY_VERSION}"
install_via_go github.com/zgs225/protoc-gen-go-gorm@latest

# Install other golang packages
install_via_go github.com/zgs225/simple-server@v1.0.0