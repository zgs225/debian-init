#!/bin/bash

ROOT_DIR=$(pwd)
SH=/bin/bash

function l_skip() {
	echo "[SKIP] " $@
}

function l_info() {
	echo "[INFO] " $@
}

function l_error() {
	echo "[ERRO] " $@
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
	PACKAGE=$1

	sudo dpkg --list "$PACKAGE" > /dev/null 2>&1

	if [ $? != 0 ]; then
		l_info "installing $PACKAGE"
		sudo apt install -y $PACKAGE
		l_info "package ${PACKAGE} installed."
	else
		l_skip "package $PACKAGE already installed."
	fi
}

function install_remote_deb() {
	URL=$1

	if [ $# == 2 ]; then
		PACKAGE=$2
	fi

	if [ -n "$PACKAGE" ]; then
		sudo dpkg --list "$PACKAGE" > /dev/null 2>&1
		if [ $? == 0 ]; then
			l_skip "package $PACKAGE already installed."
			return
		fi
	fi

	FILE_NAME=$(basename $URL)
	http --download $URL -o "${FILE_NAME}"
	sudo dpkg -i $FILE_NAME

	rm $FILE_NAME
}

function install_via_flatpak() {
	PACKAGE=$1
	HUB="flathub"

	flatpak info "$PACKAGE" &> /dev/null
	if [ $? != 0 ]; then
		l_info "installing $PACKAGE"
		flatpak install -y "${HUB}"  "${PACKAGE}"
		l_info "package ${PACKAGE} installed."
	else
		l_skip "${PACKAGE} already installed."
	fi
}

function install_via_go() {
	PACKAGE=$1
	REPO=$(echo "${PACKAGE}" | cut -d @ -f 1)

	if [ -z "${REPO}" ]; then
		l_error "go package ${PACKAGE} error"
		return 1
	fi

	command -v go &> /dev/null
	if [ $? != 0 ]; then
		l_error "command go not found."
		return 1
	fi

	BIN_PATH="$(go env GOPATH)/bin"
	CMD=$(basename "${REPO}")
	if [ -f "${BIN_PATH}/${CMD}" ]; then
		l_skip "go package ${PACKAGE} already installed."
	else
		go install "${PACKAGE}"
		l_info "go package ${PACKAGE} installed."
	fi
}