#!/bin/bash
PUBLIC_IP=$(curl -s 'http://ipv4.icanhazip.com/')
sed -i 's|host = manuka|host ='${PUBLIC_IP}'|' /opt/splunk-honeypot/docker/splunk/opt/splunk/etc/apps/cowrie-splunk-app-main/local/inputs.conf