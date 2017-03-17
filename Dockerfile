FROM ubuntu:xenial
MAINTAINER Mitchell Hewes <me@mitcdh.com>

ENV DRIVE_PATH="/drive" OVERLAY_VERSION="v1.19.1.1" OVERLAY_ARCH="amd64"

ADD https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz /tmp/s6-overlay.tar.gz

RUN tar xfz /tmp/s6-overlay.tar.gz -C / \
 && echo "deb http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu xenial main" >> /etc/apt/sources.list \
 && echo "deb-src http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu xenial main" >> /etc/apt/sources.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F639B041 \
 && apt-get update \
 && apt-get install -yy google-drive-ocamlfuse \
 && apt-get clean all \
 && rm /var/log/apt/* /var/log/alternatives.log /var/log/bootstrap.log /var/log/dpkg.log
 && 

COPY docker-entrypoint.sh /usr/local/bin/

VOLUME /config

CMD ["docker-entrypoint.sh"]