#!/bin/sh
set -e

if [ -z "$KENKU_IP" ]; then
    KENKU_IP=$(ip route | grep default | awk '{print $3}')
    echo "KENKU_IP nicht gesetzt, verwende Gateway-IP: $KENKU_IP"
    export KENKU_IP
fi

envsubst '${KENKU_IP}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf

exec nginx -g 'daemon off;'
