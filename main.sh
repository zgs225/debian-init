#!/bin/bash

set -e

. ./utils.sh

run_scripts_in_dir term
run_scripts_in_dir desktop

l_success "done."

printf "\n\n"
print_logo
