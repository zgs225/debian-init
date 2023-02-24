#!/bin/bash

set -e

. ./utils.sh

run_scripts_in_dir term
run_scripts_in_dir apps

l_success "done."
