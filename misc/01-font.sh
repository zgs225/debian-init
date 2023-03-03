#!/bin/bash

. ./utils.sh

# Install NERD font
FONT="Sauce Code Pro"
DOWNLOAD_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/SourceCodePro.zip"

# Check if $FONT is already installed
fc-list | grep -i "$FONT" > /dev/null

if [ $? == 0 ]; then
    l_skip "font $FONT is already installed."
else
    l_info "downloading font $FONT..."
    http --download $DOWNLOAD_URL -o SourceCodePro.zip

    l_info "installing font $FONT..."
    unzip SourceCodePro.zip -d SourceCodePro

    sys_font_dir=/usr/local/share/fonts
    font_dir="$sys_font_dir/NerdFonts"
    sudo mkdir -p $font_dir
    find ./SourceCodePro \( -name '*.ttf' -and -not -name '*Windows*' \) -exec sudo cp -f {} "$font_dir" \;

    fc-cache -f
    fc-list | grep -i "$FONT"

    l_info "cleanning files..."
    rm -f SourceCodePro.zip
    rm -rf SourceCodePro

    l_success "font ${FONT} installed."
fi
