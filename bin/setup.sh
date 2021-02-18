#!/bin/bash
# variables
composeVerision="1.27.2"
sshConfig="/etc/ssh/sshd_config"
sshSplunkHoneypot="50220"
installer=$1
# functions
function checkRoot {
if [[ "$(whoami)" != "root" ]]; then
    echo "Please run as root."
    echo "e.g. sudo $0"
    exit
fi
}
function installDependencies {
apt-get update && \
apt-get upgrade -y && \
apt-get install -y \
    -o APT::Install-Suggests=false \
    -o APT::Install-Recommends=false \
  apache2-utils \
  curl \
  fail2ban \
  openssh-server \
  pigz
}
function installDocker {
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh
echo "docker installed"
}
function userGroup {
usermod -aG docker $USER
newgrp docker
}
function installCompose {
curl -L "https://github.com/docker/compose/releases/download/$composeVerision/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
}
function setSSH {
# check port
if grep -q 'Port '$sshSplunkHoneypot'' $sshConfig; then
  echo "port is already set to $sshSplunkHoneypot"
  exit
fi
# set port
if grep -q '#Port 22' $sshConfig; then
  if sed -i 's|#Port 22|Port '$sshSplunkHoneypot'|' $sshConfig; then
    changed=1
  fi
elif grep -q 'Port 22' $sshConfig; then
  if sed -i 's|Port 22|Port '$sshSplunkHoneypot'|' $sshConfig; then
    changed=1
  fi
else echo "failed to set ssh port, please set manualy to $sshSplunkHoneypot"
fi
# restart ssh
if [[ $changed = 1 ]]; then
  echo "ssh port changed from 22 to $sshSplunkHoneypot, restarting ssh..."
  if systemctl restart sshd; then
    echo "ssh restarted"
  fi
fi
}
function backupConfig {
if [ -f $1 ]; then
  echo $1 "exists, backing up..."
  if mv -f $1 $2; then
    echo "$1 config backed up to $2"
    fi
fi
}
function restoreConfig {
if [ -f $1 ]; then
  echo $1 "exists, restoring config..."
  if mv -f $1 $2; then
    echo "$1 config restored to $2"
  fi
fi
}
function installSplunkHoneypot {
# backup configs
backupConfig "/opt/splunk-honeypot/docker/traefik/etc/conf/traefik.htpasswd" "./traefik.htpasswd.bak"
backupConfig "/opt/splunk-honeypot/docker/traefik/etc/conf/splunk.htpasswd" "./splunk.htpasswd.bak"
# copy opt
cp -r ./opt/splunk-honeypot /opt
echo "copied manuka to /opt"
# restore configs
restoreConfig "./traefik.htpasswd.bak" "/opt/splunk-honeypot/docker/traefik/etc/conf/traefik.htpasswd"
restoreConfig "./splunk.htpasswd.bak" "/opt/splunk-honeypot/docker/traefik/etc/conf/splunk.htpasswd"
# touch logs
touch /opt/splunk-honeypot/mnt/var/log/traefik/traefik.json
touch /opt/splunk-honeypot/mnt/var/log/traefik/access.log
touch /opt/splunk-honeypot/mnt/var/log/honeypot/cowrie/cowrie.json
# set permissions
chown -R 1000:1000 /opt/splunk-honeypot
# setup passwords
if [[ $installer != "auto" ]]; then
  ## set passwords
  /opt/splunk-honeypot/bin/set-passwords.sh "/opt/splunk-honeypot/docker/traefik/etc/conf"
  ## set geoip
  /opt/splunk-honeypot/bin/set-geoipdb.sh "/opt/splunk-honeypot/docker/elastic/logstash/share/pipeline/2_filter_geoip.conf"
fi
}
function installServices {
if [ -f "/etc/fail2ban/jail.d/defaults-debian.conf" ]; then
  rm /etc/fail2ban/jail.d/defaults-debian.conf
fi
cp -r ./etc/fail2ban/ /etc
fail2ban-client reload
## logrotate ##
cp ./etc/logrotate.d/splunk-honeypot /etc/logrotate.d/
## systemd service ##
cp ./etc/systemd/system/splunk-honeypot.service /etc/systemd/system/
chmod 644 /etc/systemd/system/splunk-honeypot.service
systemctl daemon-reload
systemctl enable manuka
systemctl start manuka
}
### Main ###
checkRoot
installDependencies
installDocker
userGroup
installCompose
setSSH
installSplunkHoneypot
installServices
if [[ $installer != "auto" ]]; then
  echo "Installation complete, now restarting..."
  shutdown -r now
fi