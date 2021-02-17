FROM ubuntu:xenial
MAINTAINER Mitchell Hewes <me@mitcdh.com>

ENV DRIVE_PATH="/mnt/gdrive"

RUN echo "deb http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu xenial main" >> /etc/apt/sources.list \
 && echo "deb-src http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu xenial main" >> /etc/apt/sources.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F639B041 \
 && apt-get update \
 && apt-get install -yy google-drive-ocamlfuse fuse \
 && apt-get clean all \
 && echo "user_allow_other" >> /etc/fuse.conf \
 && rm /var/log/apt/* /var/log/alternatives.log /var/log/bootstrap.log /var/log/dpkg.log

COPY docker-entrypoint.sh /usr/local/bin/

CMD ["docker-entrypoint.sh"]

# healthcheck
HEALTHCHECK cmd mount | grep -q "google-drive-ocamlfuse" || exit 1
