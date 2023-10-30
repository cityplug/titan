#!/bin/bash

# Debian (titan.estate.cityplug.local) setup script.

# apt update && apt install git -y && cd /opt && git clone https://github.com/cityplug/titan && apt full-upgrade -y && chmod +x /opt/titan/.scripts/* && reboot
# cd /opt/titan/.scripts && ./start.sh
# cd /opt/titan/.scripts && ./finish.sh

# --- Initialzing libraries
hostnamectl set-hostname titan.estate.cityplug.local
echo "deb http://deb.debian.org/debian bookworm-backports main contrib" >> /etc/apt/sources.list

# --- Change root password
echo "#  ---  Change root password  ---  #"
passwd root
echo "#  ---  Root password changed  ---  #" 

# --- Disable Bluetooth/WIFI & Splash
echo "
disable_splash=1
dtoverlay=disable-wifi
dtoverlay=disable-bt" >> /boot/config.txt

# --- Install Packages
echo "#  ---  Installing New Packages  ---  #"
apt update -y
apt install apt-transport-https ca-certificates software-properties-common gnupg ufw -y
apt full-upgrade -y
apt autoremove && apt autoclean -y

# --- Install Tailscale
curl -fsSL https://pkgs.tailscale.com/stable/raspbian/bookworm.gpg | apt-key add -
curl -fsSL https://pkgs.tailscale.com/stable/raspbian/bookworm.list | tee /etc/apt/sources.list.d/tailscale.list && apt update -y
apt install tailscale -y

# --- Install CockPit
apt install -t bookworm-backports cockpit --no-install-recommends
rm /etc/cockpit/disallowed-users && touch /etc/cockpit/disallowed-users

# --- Install Docker
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update && apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# --- Install Docker-Compose
wget https://github.com/docker/compose/releases/download/v2.15.1/docker-compose-linux-aarch64 -O /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose && apt install docker-compose -y

# --- Create and allocate swap
echo "#  ---  Creating 2GB swap file  ---  #"
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile && swapon /swapfile
# --- Add swap to the /fstab file & Verify command
sh -c 'echo "/swapfile none swap sw 0 0" >> /etc/fstab' && cat /etc/fstab
echo "#  ---  2GB swap file created ---  #"

# --- Addons
rm -rf /etc/update-motd.d/* && rm -rf /etc/motd && rm /etc/motd.d/cockpit
mv /opt/titan/10-uname /etc/update-motd.d/ && chmod +x /etc/update-motd.d/10-uname
mv /opt/titan/.scripts/npm/npm_config.json /opt/titan/.scripts/npm/config.json

echo "
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1" >> /etc/sysctl.conf
sysctl -p

# --- Security Addons
groupadd ssh-users
groupadd titans
usermod -aG ssh-users,titans focal
sed -i '15i\AllowGroups ssh-users\n' /etc/ssh/sshd_config

# -- Parent Folder
mkdir -p /titan/appdata/ 
mkdir /titan_/libraries/
mkdir /titan/libraries/baari && mkdir /titan/libraries/shanice

chown -R focal:titans /titan/*
chmod -R 777 /titan/ && chown -R focal:titans /titan
chmod -R 777 /titan/* && chown -R nobody:nogroup /titan/*

# --- Mount USB
echo "UUID=15b585b7-6eb4-42ce-9bfc-60398e975c74 /titan/  auto   defaults,user,nofail  0   0" >> /etc/fstab
mount -a

# --- Firewall Rules 
ufw deny 22
ufw allow 4792
ufw allow from 192.168.7.0/24 to any port 9090 #cockpit
ufw allow from 10.0.0.0/24 to any port 9090 #cockpit
ufw allow from 192.168.10.0/24 to any port 9090 #cockpit
ufw allow 53 #pihole
ufw allow 85 #homer
ufw logging on
ufw status
#ufw enable

#--
systemctl enable docker && usermod -aG docker focal
docker-compose --version && docker --version


tailscale up --advertise-routes=192.168.7.0/24

echo "#  ---  SYSTEM REBOOT  ---  #"
# ----> Next Script | more.sh
reboot
------------------------------------------------------------------------------

# --- ArgonOne Fan Control
curl https://download.argon40.com/argonfanhat.sh | bash
rm /etc/argononed.conf
echo "
65=10
70=45
75=100" >> /etc/argononed.conf

# --- Install casaos
curl -fsSL https://get.casaos.io | sudo bash
rm /etc/casaos/gateway.ini && mv /opt/titan/.scripts/gateway.ini /etc/casaos