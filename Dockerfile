FROM debian:jessie

MAINTAINER "Diego Marangoni" <https://github.com/diegomarangoni>

RUN groupadd -r mysql && useradd -r -g mysql mysql

RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db

RUN echo 'deb http://sfo1.mirrors.digitalocean.com/mariadb/repo/10.0/debian jessie main' > /etc/apt/sources.list.d/mariadb.list \
    && { \
        echo 'Package: *'; \
        echo 'Pin: release o=MariaDB'; \
        echo 'Pin-Priority: 999'; \
    } > /etc/apt/preferences.d/mariadb

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
        apt-get install -y mariadb-galera-server xtrabackup netcat-openbsd socat pv

RUN rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/lib/mysql && mkdir -p /var/lib/mysql \
    && sed -Ei 's/^(bind-address)/#&/' /etc/mysql/my.cnf

VOLUME /var/lib/mysql

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 3306 4567 4568 4444 13306
