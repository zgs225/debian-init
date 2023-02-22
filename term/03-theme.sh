#!/bin/bash

. ./utils.sh

FONT="Sauce Code Pro"
DOWNLOAD_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/SourceCodePro.zip"

fc-list | grep -i "$FONT" > /dev/null

if [ $? == 0 ]; then
	l_skip "Font $FONT already installed."
else
	l_info "Downloading font $FONT..."
	http --download $DOWNLOAD_URL -o SourceCodePro.zip

	l_info "Installing font $FONT..."
	unzip SourceCodePro.zip -d SourceCodePro

	sys_font_dir=/usr/local/share/fonts
	font_dir="$sys_font_dir/NerdFonts"
	mkdir -p $font_dir
	find ./SourceCodePro \( -name '*.ttf' -and -not -name '*Windows*' \) -exec cp -f {} "$font_dir" \;

	fc-cache -f
	fc-list | grep -i "$FONT"

	l_info "Cleanning files..."
	rm -f SourceCodePro.zip
	rm -rf SourceCodePro
fi

