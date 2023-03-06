#!/bin/bash

. ./utils.sh

DOTFILES_DIR="${HOME}/dotfiles"

if [ -d "$DOTFILES_DIR" ]; then
	l_skip "dotfiles already installed."
else
	l_info "configuring dotfiles..."
	git clone https://github.com/zgs225/dotfiles.git $DOTFILES_DIR
	env RCRC=$DOTFILES_DIR/rcrc rcup
	l_success "dotfiles configured."
fi

# Set server of bitwarden
BW_SERVER="https://bit.yuez.me"
bw config server "${BW_SERVER}" > /dev/null
l_success "bitwarden server configured to ${BW_SERVER}."
