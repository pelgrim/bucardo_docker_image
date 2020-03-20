FROM ubuntu:xenial

LABEL maintainer="lucas@vieira.io"
LABEL version="1.0"

ENV PG_VERSION 12

RUN apt-get update \
    && apt-get -y install software-properties-common wget jq netcat

RUN add-apt-repository \
    "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main"

RUN wget -q -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN apt-get -y update \
    && apt-get -y upgrade

RUN apt-get -y install postgresql-${PG_VERSION} postgresql-plperl-${PG_VERSION} bucardo

RUN apt-get -y install build-essential git
RUN git clone https://github.com/bucardo/bucardo
RUN cd bucardo
RUN perl Makefile.PL
RUN make
RUN make test
RUN make install
RUN cd -

COPY etc/pg_hba.conf /etc/postgresql/${PG_VERSION}/main/
COPY etc/bucardorc /etc/bucardorc

RUN chown postgres /etc/postgresql/${PG_VERSION}/main/pg_hba.conf
RUN chown postgres /etc/bucardorc
RUN chown postgres /var/log/bucardo
RUN mkdir /var/run/bucardo && chown postgres /var/run/bucardo
RUN usermod -aG bucardo postgres

RUN service postgresql start \
    && su - postgres -c "bucardo install --batch"

COPY lib/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME "/media/bucardo"
CMD ["/bin/bash","-c","/entrypoint.sh"]