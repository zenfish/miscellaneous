
Some rough bits that don't go anywhere else
--------------------------------------------

Better dox are in the headers of all the various files


block-all-but.sh - uses linux's iptables to block all ports but a few, 
somewhat safe doing it over the net.

https - a little python web SSL server... used it for testing some
of my cert stuff.  Lots of these out there, this is mine for now.

f-u-openssl - a quick way to generate a CA, server cert, and host
certs for openvpn and https and all that.  Oh, openssl, how I detest thee.

route.sh - forwards a port (A) of a certain protocol from one host
(B) to a second port (C) on a 2nd IP (D). Linux only, unless your
OS also happens to support iptables.

