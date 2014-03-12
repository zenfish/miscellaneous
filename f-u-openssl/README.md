
Create a CA, a server cert suitable for https/vpn, and a client
cert for vpn/whatever. Sticks them all in a subdir called "certitude".

   Usage: ./rot-in-hell.sh

Probably done the wrong way. It seems to work.  I hate openssl.
And openvpn. And pgp. And ssh. Crypto in general kinda blows.

Serial number is somewhat random, so browsers whine less when you
blow away the old one and replace it.

Change variables in the file "certy-vars" to change behavior (key
size and the sort.)


-> Based on the easy rsa cert stuff <-


A haiku to openssl:

    openssl
    a black crane over the lake
    may you rot in hell
