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
