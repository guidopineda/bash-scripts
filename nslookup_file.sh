#!/bin/bash

# This script will get the DNS name assoicated with an IP address

input="epp_all.txt"
while IFS= read -r line
do
    echo $line `nslookup $line | egrep "name" | cut -d '=' -f2`
#    nslookup $line | egrep "name"
done < "$input"
