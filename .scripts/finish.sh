#!/bin/bash

# --- Docker Services
echo
docker-compose up -d
docker run -d -p 53:53/tcp -p 53:53/udp -p 80:80/tcp -p 443:443/tcp --name pihole --restart always -e TZ=Europe/London -e WEBPASSWORD= -e WEBTHEME=default-dark -e PIHOLE_DOMAIN=titan.estate.cityplug.local --hostname pihole.titan -v /titan/appdata/pihole:/etc/pihole/ -v /titan/appdata/pihole/dnsmasq:/etc/dnsmasq.d/ --cap-add NET_ADMIN pihole/pihole:latest
docker run -d -p 85:8080 --name homer --restart always -v /titan/appdata/homer/assets:/www/assets b4bz/homer:latest
docker run -d --name watchtower --restart unless-stopped -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower:latest --interval 3600 --cleanup
docker run -d --name scrypted --network host --restart unless-stopped -v ~/.scrypted:/server/volume koush/scrypted:latest
docker ps

# --- Build Homer
docker stop homer
rm -rf /titan/appdata/homer/*
mv /opt/titan/.scripts/homer/assets /titan/appdata/homer/assets
docker start homer

# ---
wget https://github.com/45Drives/cockpit-identities/releases/download/v0.1.12/cockpit-identities_0.1.12-1focal_all.deb
wget https://github.com/45Drives/cockpit-navigator/releases/download/v0.5.10/cockpit-navigator_0.5.10-1focal_all.deb
wget https://github.com/45Drives/cockpit-file-sharing/releases/download/v3.3.4/cockpit-file-sharing_3.3.4-1focal_all.deb

apt install ./*.deb
rm *.deb

tailscale up

# ---
echo "# --- Enter pihole user password --- #"
docker exec -it pihole pihole -a -p
echo "#  ---  COMPLETED | REBOOT SYSTEM  ---  #"
reboot
#------------------------------------------------------------------------------
