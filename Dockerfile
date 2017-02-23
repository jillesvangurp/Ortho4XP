FROM debian:latest

# upgrade system dependencies
RUN apt-get update -y && apt-get upgrade -y
# now lets install everything we need, this will take some time ...

RUN apt-get install -y python3 python3-pip imagemagick python3-gdal python3-pil  python3-pil.imagetk gimp python3-pyproj libnvtt.bin x11-apps xterm sudo

RUN pip3 install requests overpy numpy

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

# build the docker file
# docker build . -t ortho
# then use the ortho_osx.sh script to launch an xterm that opens the ortho dir
