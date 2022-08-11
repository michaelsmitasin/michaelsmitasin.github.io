#! /bin/bash

while [[ 1 = 1 ]]
do
	sleep $(echo "$RANDOM" | cut -c -2)
	curl -s -X GET http://ipinfo.io/ip > /var/tmp/currentip
done
