#!/bin/bash
declare -a ips 
for ip in $(cat ips.log); do ips=("${ips[@]}" "$ip"); done
interface="eth0"
output="shapertcng.tc"
bandout="10"
bandin="50"

######################eth0#######################

banddevided="$(( $(( $bandout * 100 )) / ${#ips[@]} ))"

echo "#define INTERFACE $interface" > $output
i=1
echo "dev $interface {" >> $output
echo "	egress {" >> $output
for ip in "${ips[@]}" 
do echo "		class (<\$_$i>)	if ip_src == $ip ;" >> $output ; i=`expr $i + 1` ; done
#echo "		class ( 0 ) if 1;" >> $output
echo "		htb {" >> $output
echo "			class ( rate $(( $bandout ))Mbps, ceil $(( $bandout ))Mbps ) {" >> $output
i=1
for ip in "${ips[@]}"
do echo "				\$_$i = class ( rate $(( $banddevided ))kbps, ceil $(( $bandout ))Mbps ) { pfifo; } ;" >> $output ; i=`expr $i + 1` ;done
echo "				}" >> $output
echo "			}" >> $output
echo "		}" >> $output
echo "}" >> $output

######################eth1#######################

banddevided="$(( $(( $bandin * 100 )) / ${#ips[@]} ))"
interface="eth1"


echo "#define INTERFACE $interface" >> $output
i=1
echo "dev $interface {" >> $output
echo "  egress {" >> $output
for ip in "${ips[@]}" 
do echo "               class (<\$_$i>) if ip_dst == $ip ;" >> $output ; i=`expr $i + 1` ; done
#echo "         class ( 0 ) if 1;" >> $output
echo "          htb {" >> $output
echo "                  class ( rate $(( $bandin ))Mbps, ceil $(( $bandin ))Mbps ) {" >> $output
i=1
for ip in "${ips[@]}"
do echo "                               \$_$i = class ( rate $(( $banddevided ))kbps, ceil $(( $bandin ))Mbps ) { pfifo; } ;" >> $output ; i=`expr $i + 1` ;done
echo "                          }" >> $output
echo "                  }" >> $output
echo "          }" >> $output
echo "}" >> $output

tcng shapertcng.tc -t tc > shapertcngbin.sh
cat shapertcngbin.sh | sed 's/add/replace/' > shapertcngbinseded.sh && ./shapertcngbinseded.sh
rm ips.log && touch ips.log
