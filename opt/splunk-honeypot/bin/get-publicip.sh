#!/bin/bash
PUBLIC_IP=$(curl -s 'http://ipv4.icanhazip.com/')
if [[ "$PUBLIC_IP" =~ ^(?:(?:2(?:[0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9])\.){3}(?:(?:2([0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9]))$ ]]; then
  sed -i '/host = /c host = '${PUBLIC_IP}'' /home/dev/Projects/Docker/splunk-honeypot/opt/splunk-honeypot/docker/splunk/opt/splunk/etc/apps/cowrie-splunk-app-main/local/inputs.conf
fi