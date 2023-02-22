#!/bin/bash

set -e

if [ "$(id -u)" != 0 ]; then
	echo "Must run as root."
	exit 1
fi

. ./utils.sh

run_scripts_in_dir term