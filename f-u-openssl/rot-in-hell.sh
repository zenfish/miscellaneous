#!/bin/bash -x

#
# Create a CA, a server cert suitable for https/vpn, and a client 
# cert for vpn/whatever. Sticks them all in a subdir called
# "certitude".
#
#   Usage: ./rot-in-hell.sh
#
# Probably done the wrong way. It seems to work.  I hate openssl.
# And openvpn. And pgp. And ssh. Crypto in general kinda blows.
#
#
# -> Based on the easy rsa cert stuff <-
#

#
#   A haiku to openssl:
#
#       openssl
#       a black crane over the lake
#       may you rot in hell
#

. certy-vars

./clean-all

# file prefixes
ca="ca"
server="server"
client="client"
target_dir="certitude"

rm $ca.* server.* $client.*
rm -rf $target_dir
mkdir $target_dir

# create CA
echo creating CA with $KEY_SIZE bits
openssl req -batch -days 3650 -nodes -new -newkey rsa:$KEY_SIZE -x509 -keyout $ca.key -out $ca.crt -config stupid.cnf

# server
echo creating server certz
openssl req -batch -days 3650 -nodes -new -newkey rsa:$KEY_SIZE -keyout $server.key -out $server.csr -extensions server -config stupid.cnf
openssl $ca -keyfile $ca.key -cert $ca.crt -batch -days 3650 -out $server.crt -in $server.csr -extensions server -config stupid.cnf

# client
echo and finally the client
openssl req -nodes -batch -new -newkey rsa:$KEY_SIZE -keyout $client.key -out $client.csr -config stupid.cnf
openssl $ca -cert $ca.crt -batch -keyfile $ca.key -days 365 -out $client.crt -in $client.csr -config stupid.cnf

mv $ca.* server.* $client.* $target_dir

