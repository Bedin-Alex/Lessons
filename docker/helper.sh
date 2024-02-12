#!/bin/bash

client=$1

if [[ -z $1 ]];then
    echo "ERROR. Empty input argument"
    exit 1
else
    if [[ ! -d /config/peer_$client ]];then
        echo "ERROR. This client is absent. Check the dir /config/peer_$client"
        exit 1
    fi
fi

photo="/peer_$client-qr.png"
qrencode -t png -o ${photo} -r /config/peer_$client/peer_$client.conf

curl -F "chat_id=${SEND_TO}" \
     -F "photo=@${photo}" \
     https://api.telegram.org/bot${TOKEN}/sendPhoto

