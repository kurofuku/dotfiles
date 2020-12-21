#!/bin/bash

CHROMEBOOK=0
RASPBERRYPI=0

if [ $# -ne 1 ]; then
	echo "You need to specify chromebook or raspi" 1>&2
	exit 1
fi

if [ "chromebook" == $1 ]; then
	CHROMEBOOK=1
elif  [ "raspi" == $1 ]; then
	RASPBERRYPI=1
else
	echo "You need to specify chromebook or raspi" 1>&2
	exit 1
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

if [ 1 == ${CHROMEBOOK} ] ; then
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
	
	VSCODE_EXTENSIONS="	ms-vscode.cpptools \
				hars.cppsnippets \
				austin.code-gnu-global \
				oderwat.indent-rainbow \
				SolarLiner.linux-themes \
				alefragnani.project-manager \
				jtanx.ctagsx \
				donjayamanne.python-extension-pack \
				tht13.python \
				gerane.theme-dracula \
				pkief.material-icon-theme \
				coenraads.bracket-pair-colorizer \
				formulahendry.auto-close-tag \
				ms-vscode-remote.vscode-remote-extensionpack \
				"
	for extension in ${VSCODE_EXTENSIONS[@]}; do
		code --install-extension ${extension}
	done
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
