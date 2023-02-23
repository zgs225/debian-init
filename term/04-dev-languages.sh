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