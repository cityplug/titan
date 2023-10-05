#!/bin/bash

# --- Docker Services
docker-compose up -d
#docker run -d --name pihole --restart always -p 53:53/tcp -p 53:53/udp -p 80:80/tcp -p 443:443/tcp -e TZ=Europe/London -e WEBPASSWORD= -e WEBTHEME=default-dark -e PIHOLE_DOMAIN=titan.estate.cityplug.local --hostname pihole.titan -v /titan/appdata/pihole:/etc/pihole/ -v /titan/appdata/pihole/dnsmasq:/etc/dnsmasq.d/ --cap-add NET_ADMIN pihole/pihole:latest
docker run -d --name homer --restart always -p 85:8080 -v /titan/appdata/homer/assets:/www/assets b4bz/homer:latest
docker run -d --name watchtower --restart unless-stopped -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower:latest --interval 3600 --cleanup
docker run -d --name scrypted --restart unless-stopped --network host -v ~/.scrypted:/server/volume koush/scrypted:latest
docker run -d --name nxfilter -p 53:53/udp -p 19004:19004/udp -p 80:80 -p 443:443 -p 19002-19004:19002-19004 -e TZ=Europe/London -v /titan/appdata/nxfilter:/nxfilter/conf -v /titan/appdata/nxfilter/db:/nxfilter/db -v /titan/appdata/nxfilter/log:/nxfilter/log deepwoods/nxfilter:latest
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

# ---
echo "# --- Enter pihole user password --- #"
docker exec -it pihole pihole -a -p
echo "#  ---  COMPLETED | REBOOT SYSTEM  ---  #"
reboot
#------------------------------------------------------------------------------
