#!/bin/bash

set -e

. ./utils.sh

run_scripts_in_dir term
run_scripts_in_dir misc

if [ -z "$DISPLAY" ]; then
    l_skip "not in desktop environment, skip desktop scripts."
else
    run_scripts_in_dir desktop
fi

l_success "done."

printf "\n\n"
print_logo
