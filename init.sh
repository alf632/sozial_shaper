#!/bin/bash

modprobe nf_conntrack
iptables -A POSTROUTING -t nat -j MASQUERADE -v
