#!/bin/bash
PUBLIC_IP=$(curl -s 'http://ipv4.icanhazip.com/')
if [[ $PUBLIC_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
  sed -i '/host = /c host = '${PUBLIC_IP}'' /home/dev/Projects/Docker/splunk-honeypot/opt/splunk-honeypot/docker/splunk/opt/splunk/etc/apps/cowrie-splunk-app-main/local/inputs.conf
fi