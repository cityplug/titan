#!/bin/bash

# --- Docker Services
docker run -d -p 9000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /env/appdata/portainer:/data portainer/portainer-ce:latest
docker-compose up -d
docker ps
mv /opt/titan/.scripts/npm/npm_config.json /env/appdata/npm/config.json

# --- Build Homepage
docker stop homepage
rm -rf /env/appdata/homepage/
mv /opt/titan/.scripts/homepage /env/appdata/
docker start homepage

echo "#  ---  COMPLETED | REBOOTING SYSTEM  ---  #"
reboot
#------------------------------------------------------------------------------

#docker run -d --name pihole --restart always -p 53:53/tcp -p 53:53/udp -p 80:80/tcp -p 443:443/tcp -e TZ=Europe/London -e WEBPASSWORD= -e WEBTHEME=default-dark -e PIHOLE_DOMAIN=titan.estate.cityplug.local --hostname pihole.titan -v /titan/appdata/pihole:/etc/pihole/ -v /titan/appdata/pihole/dnsmasq:/etc/dnsmasq.d/ --cap-add NET_ADMIN pihole/pihole:latest
#docker run -d --name watchtower --restart unless-stopped -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower:latest --interval 3600 --cleanup