#!/bin/bash
# Purge traefik logs
read -r -p "Purge Traefik Logs? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    if rm -r -f ./var/log/traefik/*; then
        echo "Traefik logs purged"
    else
        echo "Purge failed"
    fi
else
    echo "Traefik logs not purged"
fi
# Purge cowrie logs
read -r -p "Purge Cowrie Logs? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    if rm -r -f ./var/log/cowrie/*; then
        echo "Cowrie logs purged"
    else
        echo "Purge failed"
    fi
else
    echo "Cowrie logs not purged"
fi