#!/bin/bash

. ./utils.sh

install_via_apt zsh

chsh -s $(which zsh)
l_info "set zsh as default."