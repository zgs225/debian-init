#!/bin/bash

ROOT_DIR=$(pwd)
SH=/bin/bash

function l_skip() {
	echo "[SKIP] " $@
}

function l_info() {
	echo "[INFO] " $@
}

function run_scripts_in_dir() {
	DIR=$1
	FILES=$(find "$ROOT_DIR/$DIR" -name '*.sh' | sort)
	for FILE in $FILES; do
		l_info "Run $FILE"
		$SH $FILE
	done
}

function install_via_apt() {
	if [ $# == 1 ]; then
		CMD=$1
		PACKAGE=$1
	else
		CMD=$1
		PACKAGE=$2
	fi

	command -v $CMD > /dev/null

	if [ $? != 0 ]; then
		l_info "Installing $PACKAGE"
		apt install -y $PACKAGE
	else
		l_skip "package $PACKAGE already installed."
	fi
}