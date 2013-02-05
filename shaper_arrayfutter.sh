#!/bin/bash

# declare -a verboten=( "172.16.0.6" "172.16.0.7" "255.255.255.255" "224.0.0.1" ); 		filtern
declare -a ips
declare -a vorhanden


for line in $(cat ips.log)
do vorhanden=("${vorhanden[@]}" "$line")
done

for line in $(cat /proc/net/ip_conntrack | sed -e 's/ dst.*//'  -e 's/.*src=//g' | grep 172.16.)
do [[ ${vorhanden[@]} =~ $line ]] && continue
ips=("${ips[@]}" "$line") && vorhanden=("${vorhanden[@]}" "$line")
done

echo "anzahl neue ips"
echo ${#ips[@]}
echo "anzahl gespeicherte ips"
cat ips.log | wc -l
echo ""
for ip in ${ips[@]}; do
#echo $ip
echo $ip >> ips.log
done
