#!/bin/bash

#
#  Usage: $0 comma-seperated-list-of-ports
#

#
# A simple INBOUND TCP/UDP port blocker (doesn't do anything for outbound)... 
# for good security you generally would like to allow rather than deny ports;
# that said, the usual way to do so in iptables looks something like:
#
#   drop all
#   allow ports x, y, z
#
# If you're logged in over the network, you never get to the allow ports 
# (because you'll drop your own connection) and can easily lock yourself out.
#
# So this simply takes a list of ports and blocks all ports except a few by 
# using the not (e.g. "!") syntax. Of course I have to look this up everytime 
# I use it, hence this script.
#
# To use, give it a comma sep'd list of ports; for UDP add a "u" 
# after the port, so this would block all ports other than
# TCP 33 and UDP 99:
#
#    $0 33,53u
#
# *** The script defaults to leaving TCP port 22 open, so with
# *** zero arguments blocks all but TCP port 22 (SSH).
#
# WARNING - uses newfangled bourne stuff for arrays & string manip
#

#
# WARNING #2 - no error checking, you probably should flush any
# old ones before running this, etc., etc.
#


# figure out a better way...?
eth="eth0"

usage="Usage: $0 comma-seperated-list-of-ports"

if [ $# -gt 2 ] ; then
    echo $usage
    exit 1
fi

MAX_PORTS=15    # apparently....

# defaults
tcp_ports="22"
udp_ports=""

#
# rip apart the args
#
parse_one() {

    # redundant, but not sure how to use $1 in there...
    argz=$1
    ports=(${argz//,/ })

    # echo $ports

    for port in "${ports[@]}"; do
        # echo trying... $port
        # UDP
        if $(echo $port | grep -q 'u') ; then
            # pick off the "u" at the end
            port=${port:0:-1} 
            #echo udp: $port
            udp_ports="$udp_ports",$port
        # TCP
        else
            #echo tcp: $port
            tcp_ports="$tcp_ports",$port
        fi
    done

    # newfangled shell stuff to clip off the first comma
    tcp_ports=${tcp_ports:1}
    udp_ports=${udp_ports:1}

    n_tcp=$(echo $tcp_ports | awk -F, '{ print NF}' )
    n_udp=$(echo $udp_ports | awk -F, '{ print NF}' )

    if [ $n_tcp -gt $MAX_PORTS ] ; then
        echo "Too many tcp ports specified ($n_tcp), maximum is $MAX_PORTS"
        exit 2
    fi

    if [ $n_udp -gt $MAX_PORTS ] ; then
        echo "Too many udp ports specified ($n_udp), maximum is $MAX_PORTS"
        exit 3
    fi

}

# default or supplying your own?
if [ "X$1" = "X" ]; then
    echo "Blocking all but TCP port 22 (default)"
else
    # echo parsing... $1
    tcp_ports=""
    parse_one $1
fi

echo
echo It looks like you want these ports open:
echo
echo "    TCP port(s): $tcp_ports"
echo "    UDP port(s): $udp_ports"


# -m multiport used to specify multiple ports

if [ "X$tcp_ports" != "X" ]; then
    tcp_ip_tables="iptables -A INPUT -p tcp -i $eth -m multiport ! --dport $tcp_ports -j DROP"
    echo
    echo executing this for TCP ports:
    echo
    echo "    $tcp_ip_tables"
    echo
    $tcp_ip_tables
fi

if [ "X$udp_ports" != "X" ]; then
    udp_ip_tables="iptables -A INPUT -p udp -i $eth -m multiport ! --dport $udp_ports -j DROP"
    echo
    echo executing this for UDP ports:
    echo
    echo "    $udp_ip_tables"
    echo
    $udp_ip_tables
fi

