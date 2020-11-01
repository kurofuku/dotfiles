#!/bin/sh

PIXELBOOK=0
RASPBERRYPI=0

if [ $# -ne 1 ]; then
	echo "You need to specify pixelbook or raspi" 1>&2
	exit 1
fi

if [ "pixelbook" == $1 ]; then
	PIXELBOOK=1
elif  [ "raspi" == $1 ]; then
	RASPBERRYPI=1
fi
# update/upgrade
sudo apt-get -y update
sudo apt-get -y upgrade

# install utility
sudo apt-get -y install neovim git tmux software-properties-common python-pip python3 python3 python3-pip
sudo pip install --upgrade pip
sudo pip3 install --upgrade pip
sudo pip3 install neovim
sudo pip3 install --upgrade neovim
sudo pip3 install Pygments

if [ 1 == ${PIXELBOOK} ] ; then
	sudo apt-get -y install gdebi

	# install code
	curlSucceed=1
	while [ 0 != $curlSucceed ]
	do
		curl -L -C - -o /tmp/code.deb https://go.microsoft.com/fwlink/?LinkID=760868
		curlSucceed=$?
	done
	sudo gdebi -o APT::Get::force-yes=true -o APT::Get::Assume-Yes=true -n /tmp/code.deb
	rm /tmp/code.deb

	code --install-extension ms-vscode.cpptools
	code --install-extension hars.cppsnippets
	code --install-extension austin.code-gnu-global
	code --install-extension oderwat.indent-rainbow
	code --install-extension SolarLiner.linux-themes
	code --install-extension alefragnani.project-manager
	code --install-extension jtanx.ctagsx
	code --install-extension donjayamanne.python-extension-pack
	code --install-extension tht13.python
	code --install-extension MS-CEINTL.vscode-language-pack-ja
	code --install-extension gerane.theme-dracula
	code --install-extension gerane.theme-dark-dracula
	code --install-extension pkief.material-icon-theme
	code --install-extension coenraads.bracket-pair-colorizer
	code --install-extension formulahendry.auto-close-tag
	code --install-extension ms-vscode-remote.vscode-remote-extensionpack
fi

git clone https://github.com/kurofuku/dotfiles
cp dotfiles/.tmux.conf .
cp dotfiles/.globalrc .
mkdir -p .config/nvim
cp dotfiles/init.vim .config/nvim
cp dotfiles/dein.toml .config/nvim
cp dotfiles/dein_lazy.toml .config/nvim
rm -rf dotfiles

sync

echo "You need to do this command to install plugins correctly."
echo "	nvim"
echo "In nvim console, run this command."
echo "	:UpdateRemotePlugins"
