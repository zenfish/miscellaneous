#!/bin/bash

#
# forward a port with iptables (linux)... usage:
#
#   $0 up|down ipaddr-1 port-1 ipaddr-2 port-2 protocol
#
# E.g.
#
#   $0 up 10.0.0.1 666 192.168.0.2 777 tcp
#
#  Would connect anyone reaching:
#
#       tcp port 666 on 10.0.0.1 
#
#  And send it to:
#
#       tcp port 777 on 192.168.0.2
#
#  If you use "down" you must use the EXACT same arguments as with the "up" 
# command or won't work (at least, I think... iptables is pretty mysterious... 
# you could always flush them.
#
#  No error checking, although (a) iptables usually will gripe if it doesn't 
# like your arguments, and (b) it'll print out the usage message if you don't 
# use exactly 6 arguments.
#
# The "up" command will also turn on ipforwarding by running this:
#
#    echo "1" > /proc/sys/net/ipv4/ip_forward
#
# The "down" command WILL NOT set that to 0, if you want that turned off
# you have to do it yourself (it might break other things in my system.)
#

if [ $# -ne 6 ] ; then
   echo "Usage: $0 up|down ip-1 port-1 ip-2 port-2 tcp|udp"
   exit 1
fi

# up or down?
if [ "X$1" = "Xup" ] ; then
    direction="up"
elif [ "X$1" = "Xdown" ] ; then
    direction="down"
else
    echo First argument must be either \"up\" or \"down\"
    exit 2
fi

local_ip=$2
local_port=$3
remote_ip=$4
remote_port=$5
proto=$6

# will not reverse this, as other PUCK stuff might break, but ensure it's on!
echo "1" > /proc/sys/net/ipv4/ip_forward

if [ $direction = "up" ] ; then
    echo "forwarding $proto traffic from $local_ip : $local_port => $remote_ip : $remote_port"
    iptables -t nat -A PREROUTING  -p tcp -d $local_ip --dport $local_port   -j DNAT --to-destination $remote_ip:$remote_port
    iptables -t nat -A POSTROUTING -p tcp --dport $remote_port -j MASQUERADE
else
    echo "disabling forwarding of $proto traffic from $local_ip : $local_port => $remote_ip : $remote_port"
    iptables -t nat -D PREROUTING  -p tcp -d $local_ip --dport $local_port   -j DNAT --to-destination $remote_ip:$remote_port
    iptables -t nat -D POSTROUTING -p tcp --dport $remote_port -j MASQUERADE
fi

