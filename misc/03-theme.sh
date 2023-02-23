#!/bin/bash

. ./utils.sh

# Install NERD font
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
	sudo mkdir -p $font_dir
	find ./SourceCodePro \( -name '*.ttf' -and -not -name '*Windows*' \) -exec sudo cp -f {} "$font_dir" \;

	fc-cache -f
	fc-list | grep -i "$FONT"

	l_info "Cleanning files..."
	rm -f SourceCodePro.zip
	rm -rf SourceCodePro
fi

# Setup terminal theme
THEME=gruvbox-dark

install_via_apt dconf-cli
install_via_apt uuid-runtime

http --download https://codeload.github.com/Gogh-Co/Gogh/zip/refs/tags/v242 -o gogh.zip
unzip -q gogh.zip
cd Gogh-242/themes
export TERMINAL=gnome-terminal
${SH} ${THEME}.sh

cd ../..
rm -rf Gogh-242 gogh.zip
