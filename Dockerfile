FROM ubuntu:22.04

LABEL maintainer="lucas@vieira.io"
LABEL version="1.1"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update \
    && apt-get -y upgrade

RUN apt-get -y install postgresql-14 jq wget curl perl make build-essential bucardo

ARG BUCARDO_VERSION=5.6.0

WORKDIR /tmp
RUN wget -O /tmp/bucardo.tgz http://bucardo.org/downloads/Bucardo-${BUCARDO_VERSION}.tar.gz && \
    tar zxf /tmp/bucardo.tgz && \
    cd Bucardo-${BUCARDO_VERSION} && \
    INSTALL_BUCARDODIR=/usr/bin perl Makefile.PL && \
    make -j && \
    make install && \
    rm -rf /tmp/Bucardo-${BUCARDO_VERSION}

COPY etc/pg_hba.conf /etc/postgresql/14/main/
COPY etc/bucardorc /etc/bucardorc

RUN mkdir /var/run/bucardo 
RUN chown postgres /etc/postgresql/14/main/pg_hba.conf /etc/bucardorc /var/log/bucardo /var/run/bucardo
RUN usermod -aG postgres bucardo

RUN service postgresql start \
    && su - postgres -c "bucardo install --batch"

COPY lib/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME "/media/bucardo"
WORKDIR /media/bucardo

CMD ["/bin/bash","-c","/entrypoint.sh"]
