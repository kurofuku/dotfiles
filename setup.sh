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
sudo apt-get -y install neovim git tmux software-properties-common python3 python3-pip
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

if [ 1 == ${RASPBERRYPI} ] ; then
	# Install clamav with my customization
	cd ${HOME}
	sudo apt-get -y install	cmake gcc make pkg-config python3 python3-pip python3-pytest valgrind \
				check libbz2-dev libcurl4-openssl-dev libjson-c-dev libmilter-dev \
				libncurses5-dev libpcre2-dev libssl-dev libxml2-dev zlib1g-dev \
				netcat
	sudo groupadd clamav
	sudo useradd -g clamav -s /bin/false -c "Clam Antivirus" clamav
	wget https://github.com/Cisco-Talos/clamav/archive/refs/tags/clamav-0.104.0.tar.gz
	tar zxf clamav-0.104.0.tar.gz
	wget https://raw.githubusercontent.com/kurofuku/dotfiles/master/clamav/change_fanotify_mask.diff
	wget https://raw.githubusercontent.com/kurofuku/dotfiles/master/clamav/add_OnAccessVirusEvent_functionalty.diff
	patch -p0 < change_fanotify_mask.diff
	patch -p0 < add_OnAccessVirusEvent_functionalty.diff
	cd clamav-clamav-0.104.0
	mkdir build && cd build
	cmake ..
	cmake --build .
	ctest
	sudo cmake --build . --target install
	sed -e 's/^Example/#Example/' /usr/local/etc/clamd.conf.sample | \
		sed -e 's/^#FixStaleSocket yes/FixStaleSocket yes/' | \
		sed -e 's/^#TCPSocket 3310/TCPSocket 3310/' | \
		sed -e 's/^#TCPAddr localhost/TCPAddr localhost/' | sudo tee /usr/local/etc/clamd.conf > /dev/null
	sed -e 's/^Example/#Example/' /usr/local/etc/freshclam.conf.sample | sudo tee /usr/local/etc/freshclam.conf > /dev/null
	wget https://raw.githubusercontent.com/kurofuku/dotfiles/master/clamav/freshclam.service
	wget https://raw.githubusercontent.com/kurofuku/dotfiles/master/clamav/clamd.service
	wget https://raw.githubusercontent.com/kurofuku/dotfiles/master/clamav/clamonacc.service
	wget https://raw.githubusercontent.com/kurofuku/dotfiles/master/clamav/start_clamonacc.sh
	wget https://raw.githubusercontent.com/kurofuku/dotfiles/master/clamav/mysendmail
	sudo cp freshclam.service /etc/systemd/system/
	sudo cp clamd.service /etc/systemd/system/
	sudo cp clamonacc.service /etc/systemd/system/
	sudo cp start_clamonacc.sh /usr/local/bin/
	sudo chmod +x /usr/local/bin/start_clamonacc.sh
	sudo cp mysendmail /usr/local/bin/
	sudo chmod +x /usr/local/bin/mysendmail
	echo "OnAccessVirusEvent /usr/local/bin/mysendmail" | sudo tee -a /usr/local/etc/clamd.conf > /dev/null
	echo "OnAccessIncludePath ${HOME}" | sudo tee -a /usr/local/etc/clamd.conf > /dev/null
	echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
	sudo service freshclam start
	sudo service clamd start
	sudo service clamonacc start
	cd ${HOME}
	rm -f clamav-0.104.0.tar.gz
	rm -rf clamav-clamav-0.104.0
	rm -rf *.diff
fi

cd ${HOME}
git clone https://github.com/kurofuku/dotfiles
cp dotfiles/.tmux.conf ${HOME}
cp dotfiles/.globalrc ${HOME}
mkdir -p ${HOME}/.config/nvim
cp dotfiles/init.vim ${HOME}/.config/nvim
cp dotfiles/dein.toml ${HOME}/.config/nvim
cp dotfiles/dein_lazy.toml ${HOME}/.config/nvim
rm -rf dotfiles

sync

echo "You need to do this command to install plugins correctly."
echo "	nvim"
echo "In nvim console, run this command."
echo "	:UpdateRemotePlugins"
echo ""
echo "Also if you want to run clamav relevant daemon, please activate by below commands."
echo "	sudo systemctl enable freshclam"
echo "	sudo systemctl enable clamd"
echo "	sudo systemctl enable clamonacc"
echo "If you want to immediately start these clamav relevant daemon, please run these commands."
echo "	sudo systemctl start freshclam"
echo "	sudo systemctl start clamd"
echo "	sudo systemctl start clamonacc"
