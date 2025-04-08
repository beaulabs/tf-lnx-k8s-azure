#!/bin/bash

# This bash script returns your public facing IP address (WAN-IP). 
# To be used in conjunction with anything you particularly need your public IPv4
# for access purposes when setting public cloud security groups.

# Below uses DNS resolution and formats response to JSON. Will record as {"IPAddress":"<ip>"}
# Uncomment the two lines below if you want to the DNS type.

# INTERNETIP="$(dig +short myip.opendns.com @resolver1.opendns.com -4)"
# echo $(jq -n --arg internetip "$INTERNETIP" '{"IPAddress":$internetip}')

# Or you can also just use API call to return your IP. Simpler in some ways because you will get a universal output
# regardless of OS type -> {"ip":"<ip>"} -> meaning you don't have to regex or perform string manipulation (yay!).
# Uncomment the line below if you wish to use API call.

curl -s https://api.ipify.org?format=json