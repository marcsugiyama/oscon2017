# Borrowed heavily from:
# https://github.com/rudolfb/vagrant-phoenix-postgres
# https://hub.docker.com/r/marcelocg/phoenix/
# https://hub.docker.com/_/postgres/
#
###############################################################################
#
# Build container:
# docker build -t phoenix .
#
# Start container:
# docker run -it -p 4000:4000 -v $PWD/app:/app phoenix
#
# Forwards Phoenix port (4000). Mounts ./app as /app
#
# Start postgres:
# service postgresql start
#
# TODO:
# Make postgres data files persistent
#
###############################################################################
FROM ubuntu:xenial

MAINTAINER Marc Sugiyama <marc.sugiyama@erlang-solutions.com> inotify-tools

# Dependencies

RUN apt-get -y update
RUN apt-get -y install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev libgtk2.0-0 libgtk2.0-bin libgtk2.0-common git-core wget libgl1-mesa-glx libgl1 libnotify4 libsm6 libxxf86vm1 curl software-properties-common inotify-tools

# node-js

RUN curl -sL https://deb.nodesource.com/setup_5.x | bash - \
    && apt-get install -y nodejs

# postgres

# explicitly set user/group IDs
RUN groupadd -r postgres --gid=999 && useradd -r -g postgres --uid=999 postgres

# make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
        && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

ENV PG_VERSION 9.5
ENV PG_CONF /etc/postgresql/$PG_VERSION/main/postgresql.conf
ENV PG_HBA /etc/postgresql/$PG_VERSION/main/pg_hba.conf

RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' > /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -

RUN apt-get update \
        && apt-get -y upgrade \
        && apt-get install -y \
                postgresql-$PG_VERSION \
                postgresql-contrib-$PG_VERSION \
                libpq-dev

RUN sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"

RUN echo "local   all             all                                     trust" > $PG_HBA \
    && echo "host    all             all             127.0.0.1/32            trust" >> $PG_HBA \
    && echo "host    all             all             ::1/128                 trust" >> $PG_HBA

ENV PATH /usr/lib/postgresql/$PG_MAJOR/bin:$PATH

EXPOSE 5432

# Elixir

RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb \
    && dpkg -i erlang-solutions_1.0_all.deb \
    && apt-get update \
    && apt-get -y install erlang erlang-manpages erlang-doc erlang-tools elixir

# Phoenix

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phoenix_new-1.2.1.ez

EXPOSE 4000

WORKDIR /app

CMD ["bash"]
