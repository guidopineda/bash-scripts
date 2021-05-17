#!/bin/bash

# This script will get the DNS name assoicated with an IP address

for ip in 10.117.141.{192..255}; do
    nslookup $ip | egrep "name"
done
