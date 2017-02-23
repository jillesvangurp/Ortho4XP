FROM debian:latest

# upgrade system dependencies
RUN apt-get update -y && apt-get upgrade -y
# now lets install everything we need, this will take some time ...
RUN apt-get install -y python3 python3-pip imagemagick
RUN pip3 install requests overpy numpy
# firefox is included here to transitively pull in a lot of the x related dependencies we'll also need for the
# ortho4xp ui.
RUN apt-get install -y python3-gdal python3-pil  python3-pil.imagetk gimp python3-pyproj libnvtt.bin
RUN apt-get install -y x11-apps xterm sudo

# we'll need some way to run the orthoxp gui via X windows from inside a Docker container
# adapted from http://fabiorehm.com/blog/2014/09/11/running-gui-apps-with-docker/
# Replace 1000 with your user / group id
# on osx run id -u and id -g to find out uid and gid
RUN export uid=501 && \
    export gid=20 && \
    mkdir -p /home/developer && \
    echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:${uid}:" >> /etc/group

RUN echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer
RUN chmod 0440 /etc/sudoers.d/developer
RUN chown ${uid}:${gid} -R /home/developer

# copy over the ortho4xp stuff we checked out
RUN mkdir /home/developer/ortho4
WORKDIR /home/developer/ortho4
COPY ./ /home/developer/ortho4/

USER developer
ENV HOME /home/developer
ENV XAUTHORITY=~/.Xauthority
ENV DISPLAY :0
CMD /usr/bin/firefox
RUN mkdir /tmp/.X11-unix
VOLUME ["/tmp/.X11-unix/"]

# OSX specifics to run the container
# install xquartz and start it:
# open -a XQuartz
# setup your environment:
# export DISPLAY='localhost:0'
# /usr/X11R6/bin/xhost +

# docker run -ti --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix <imageid> xterm
