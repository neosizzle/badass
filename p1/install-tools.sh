#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

#   _____             _             
#  |  __ \           | |            
#  | |  | | ___   ___| | _____ _ __ 
#  | |  | |/ _ \ / __| |/ / _ \ '__|
#  | |__| | (_) | (__|   <  __/ |   
#  |_____/ \___/ \___|_|\_\___|_|   
                                  
                                  
#Update existing list of packages
apt-get update -y

#Install pre-requisites
apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y

#Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

#Set up the stable Docker repository
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

#Update the apt package index
apt-get update -y

#Install Docker
apt-get install docker-ce docker-ce-cli containerd.io -y

#Verify that Docker Engine is installed correctly
docker ps

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Verify the installation
docker-compose --version

#    _____ _   _  _____ ____  
#   / ____| \ | |/ ____|___ \ 
#  | |  __|  \| | (___   __) |
#  | | |_ | . ` |\___ \ |__ < 
#  | |__| | |\  |____) |___) |
#   \_____|_| \_|_____/|____/ 
                            
apt install -y python3-pip python3-pyqt5 python3-pyqt5.qtsvg \
python3-pyqt5.qtwebsockets \
qemu qemu-kvm qemu-utils libvirt-clients libvirt-daemon-system virtinst \
wireshark xtightvncviewer apt-transport-https tshark \
ca-certificates curl gnupg2 software-properties-common cmake  libelf-dev libpcap0.8-dev -y

bash -c 'echo "deb http://ppa.launchpad.net/gns3/ppa/ubuntu bionic main" >> /etc/apt/sources.list'
bash -c 'echo "deb-src http://ppa.launchpad.net/gns3/ppa/ubuntu bionic main" >> /etc/apt/sources.list'
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F88F6D313016330404F710FC9A2FD067A2E3EF7B
apt-get update
apt install dynamips ubridge
/sbin/usermod -aG ubridge,libvirt,kvm,wireshark,docker $(whoami)


pip3 install gns3-server
pip3 install gns3-gui
