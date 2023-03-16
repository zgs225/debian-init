#!/bin/bash

# utities

AUTHOR="yuez"
EMAIL="i@yuez.me"

ROOT_DIR=$(pwd)
SH=/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
GRAY='\033[0;37m'
CLEAR='\033[0m'

PREBUILT_PACKAGE_DIR="/opt/apps"

function print_logo() {
    echo "██████╗ ███████╗██████╗ ██╗ █████╗ ███╗   ██╗      ██╗███╗   ██╗██╗████████╗";
    echo "██╔══██╗██╔════╝██╔══██╗██║██╔══██╗████╗  ██║      ██║████╗  ██║██║╚══██╔══╝";
    echo "██║  ██║█████╗  ██████╔╝██║███████║██╔██╗ ██║█████╗██║██╔██╗ ██║██║   ██║   ";
    echo "██║  ██║██╔══╝  ██╔══██╗██║██╔══██║██║╚██╗██║╚════╝██║██║╚██╗██║██║   ██║   ";
    echo "██████╔╝███████╗██████╔╝██║██║  ██║██║ ╚████║      ██║██║ ╚████║██║   ██║   ";
    echo "╚═════╝ ╚══════╝╚═════╝ ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝      ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝   ";
    echo "                                                                            ";
}

function l_skip() {
    printf "${GRAY}[SKIP] ${@}${CLEAR}\n"
}

function l_info() {
    echo "[INFO]" $@
}

function l_error() {
    printf "${RED}[ERRO] ${@}${CLEAR}\n"
}

function l_success() {
    printf "${GREEN}[SUCC] ${@}${CLEAR}\n"
}

function l_warn() {
    printf "${YELLOW}[WARN] ${@}${CLEAR}\n"
}

function run_scripts_in_dir() {
    DIR=$1
    FILES=$(find "$ROOT_DIR/$DIR" -name '*.sh' | sort)
    for FILE in $FILES; do
        l_warn "run $FILE"
        $SH $FILE
    done
}

function install_via_apt() {
    PACKAGE=$1

    sudo dpkg -L "$PACKAGE" > /dev/null 2>&1

    if [ $? != 0 ]; then
        l_warn "installing $PACKAGE"
        sudo apt install -y $PACKAGE
        l_success "package ${PACKAGE} installed."
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
        sudo dpkg -s "$PACKAGE" &> /dev/null
        if [ $? == 0 ]; then
            l_skip "package $PACKAGE already installed."
            return
        fi
    fi

    l_warn "installing $PACKAGE"

    FILE_NAME=$(basename $URL)
    http --download $URL -o "${FILE_NAME}"
    sudo dpkg -i "./${FILE_NAME}"

    rm $FILE_NAME

    l_success "deb package ${PACKAGE} installed."
}

function install_via_flatpak() {
    PACKAGE=$1
    HUB="flathub"

    flatpak info "$PACKAGE" &> /dev/null
    if [ $? != 0 ]; then
        l_warn "installing $PACKAGE"
        flatpak install -y "${HUB}"  "${PACKAGE}"
        l_success "package ${PACKAGE} installed."
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
        l_warn "installing go package ${PACKAGE}"
        go install "${PACKAGE}"
        l_success "go package ${PACKAGE} installed."
    fi
}

function install_prebuilt_bin() {
    CMD=$1
    URL=$2
    BIN_DIR=/usr/bin

    if [ -f "${BIN_DIR}/${CMD}" ]; then
        l_skip "${CMD} already installed."
    else
        l_warn "installing ${CMD}"
        http --download "${URL}" -o "${CMD}"
        chmod a+x "${CMD}"
        sudo mv "${CMD}" "${BIN_DIR}/${CMD}"
        l_success "${CMD} installed."
    fi
}

function install_prebuilt_zipbin() {
    CMD=$1
    URL=$2
    BIN_DIR=/usr/bin

    if [ -f "${BIN_DIR}/${CMD}" ]; then
        l_skip "${CMD} already installed."
    else
        l_warn "installing ${CMD}"
        http --download "${URL}" -o "${CMD}.zip"
        unzip "${CMD}.zip"
        chmod a+x "${CMD}"
        sudo mv "${CMD}" "${BIN_DIR}/${CMD}"
        rm "${CMD}.zip"
        l_success "${CMD} installed."
    fi
}

function install_prebuilt_package() {
    URL=$1
    FILENAME=$(basename ${URL})
    DOWNLOAD_FILE="${FILENAME}.download"
    INSTALLED_DIR="${PREBUILT_PACKAGE_DIR}/${FILENAME%%.*}"

    if [ -d "${INSTALLED_DIR}" ]; then
        l_skip "prebuilt package ${FILENAME} already installed."
    else
        l_warn "installing prebuilt package ${FILENAME}"
        http -dco "${DOWNLOAD_FILE}" "${URL}"
        mv "${DOWNLOAD_FILE}" "${FILENAME}"

        sudo mkdir -p "${INSTALLED_DIR}"

        if [ "${FILENAME}" == *".tar.gz" ]; then
            l_info "extracting ${FILENAME}..."
            sudo tar -C "${INSTALLED_DIR}" -xzf "${FILENAME}" --strip-components 1
            if [ $? != 0 ]; then
                l_error "failed to install prebuilt package ${FILENAME}"
                return 1
            fi
        fi

        if [ "${FILENAME}" == *".zip" ]; then
            l_info "extracting ${FILENAME}..."
            sudo unzip -d "${INSTALLED_DIR}" "${FILENAME}"
            if [ $? != 0 ]; then
                l_error "failed to install prebuilt package ${FILENAME}"
                return 1
            fi
        fi

        rm "${FILENAME}"

        l_success "${FILENAME} installed."
    fi
}

function install_via_pip() {
    PACKAGE=$1

    command -v pip &> /dev/null
    if [ $? != 0 ]; then
        l_error "command pip not found."
        return 1
    fi

    pip show "${PACKAGE}" &> /dev/null
    if [ $? != 0 ]; then
        l_warn "installing python ${PACKAGE}"
        pip install "${PACKAGE}"
        if [ $? != 0 ]; then
            l_error "failed to install ${PACKAGE}"
            return 1
        fi
    else
        l_skip "${PACKAGE} already installed."
    fi
}

function set_go_env() {
    KEY=$1
    VAL=$2

    command -v go &> /dev/null

    if [ $? != 0 ]; then
        l_error "can't set go env caused by command go not found."
        return 1
    fi

    OLDVAL=$(go env "${KEY}")

    if [ ! -z "${OLDVAL}" ]; then
        if [[ ",${VAL}," = *",${OLDVAL},"* ]]; then
            l_skip "go env ${KEY}=${VAL} already configured."
            return
        fi
        VAL="${OLDVAL},${VAL}"
    fi

    go env -w "${KEY}=${VAL}"

    l_success "go env ${KEY}=${VAL}"
}

function ctrl_c() {
    l_error "user interrupt"
    exit 1
}

function get_distrib_codename() {
    if [ -f /etc/upstream-release/lsb-release ]; then
        . /etc/upstream-release/lsb-release
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
    fi
    if [ -z "${DISTRIB_CODENAME}" ]; then
        DISTRIB_CODENAME=$(lsb_release -cs)
    fi
    echo "${DISTRIB_CODENAME}"
}
