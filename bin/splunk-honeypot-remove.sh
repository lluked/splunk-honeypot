#!/bin/bash
## services
# systemd
systemctl disable splunk-honeypot
rm /etc/systemd/system/splunk-honeypot.service
systemctl daemon-reload
# logrotate
rm /etc/logrotate.d/splunk-honeypot
# fail2ban
rm /etc/fail2ban/filter.d/traefik-auth.conf
rm /etc/fail2ban/jail.d/traefik-auth.conf
printf "[sshd]\nenabled = true" > /etc/fail2ban/jail.d/defaults-debian.conf
fail2ban-client reload
# opt
rm -r /opt/splunk-honeypot
# ssh
sed -i 's|Port 50220|#Port 22|' "/etc/ssh/sshd_config"