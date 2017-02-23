#!/usr/bin/env bash

# install xquartz
# reboot before starting xquartz or this wont work
# fork a process that redirects to X
# you may need to brew install socat for this
socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\" &

# now tell the docker container to connect to the display; replace the ip address with your local ip
docker run \
    -it \
    -e DISPLAY=192.168.1.2:0 \
    ortho \
    xterm
