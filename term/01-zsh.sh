#!/bin/bash

. ./utils.sh

install_via_apt zsh

CURRENT_SHELL=$(awk -F: -v user="$(whoami)" '$1 == user {print $NF}' /etc/passwd)

if [ "$CURRENT_SHELL" == "$(which zsh)" ]; then
	l_skip "default shell of current user already set to zsh"
else
	chsh -s $(which zsh)
	l_success "set zsh as default."
fi
