#!/bin/bash

modprobe nf_conntrack
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -A POSTROUTING -t nat -j MASQUERADE -v
