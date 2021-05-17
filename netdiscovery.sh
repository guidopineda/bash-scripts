#!/bin/bash

# This script will gather data from the systems within the same network

for ip in 10.117.142.{1..126}; do
    ping -c 1 -W 1 $ip | grep "64 bytes" &
done
