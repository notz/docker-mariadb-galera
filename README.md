# Supported tags and respective `Dockerfile` links

-   [`latest` (*latest/Dockerfile*)](https://github.com/diegomarangoni/docker-mariadb-galera/blob/master/Dockerfile)

# How to use this image.

When you run the image without giving any command, the entrypoint will loop infinitely until you create, inside de container, a file at `/tmp/cmd`.
When the `/tmp/cmd` file is created, the entrypoint get the file content as string and execute it.

So, basically, you can get a cluster running by following the steps:

- start each node with:

```
docker run \
    -v /path/to/my.cnf:/etc/mysql/my.cnf \
    -v /path/to/mariadb:/var/lib/mysql \
    -v /path/to/certs/:/etc/ssl/mysql:ro \
    -e MYSQL_ALLOW_EMPTY_PASSWORD=true \
    diegomarangoni/mariadb-galera
```

- concat all containers IP into a `gcomm://` string, like:

```
gcomm://10.0.0.1,10.0.0.2,10.0.0.3
```

- choose one of the hosts to start as new cluster:

```
docker exec NAME_OF_CONTAINER /bin/sh -c "echo 'mysqld --wsrep-new-cluster --wsrep-cluster-address=gcomm://10.0.0.1,10.0.0.2,10.0.0.3' > /tmp/cmd"
```

- on all the subsequent nodes, one at a time, starts it as part of existing cluster:

```
docker exec NAME_OF_CONTAINER /bin/sh -c "echo 'mysqld --wsrep-cluster-address=gcomm://10.0.0.1,10.0.0.2,10.0.0.3' > /tmp/cmd"
```

That's it, now you should have a running MariaDB cluster.

## SSL certificates

You can generate self-signed certificate, mount the directory inside the container and set the appropriate `[sst]` settings at `/etc/mysql/my.cnf`.

## Example `my.cnf` file:

```
[mysqld]
datadir=/var/lib/mysql
socket=/var/run/mysqld/mysqld.sock
user=mysql
binlog-format=ROW
default-storage-engine=InnoDB
innodb-autoinc-lock-mode=2
innodb-flush-log-at-trx-commit=0
innodb-buffer-pool-size=122M
innodb-doublewrite=1
innodb-flush-method=O_DIRECT
wsrep-provider=/usr/lib/galera/libgalera_smm.so
wsrep-cluster-name=my_super_cluster
wsrep-sst-method=rsync
query-cache-size=524288
log-error=/dev/stderr

[mysql_safe]
log-error=/dev/stderr
pid-file=/var/run/mysqld/mysqld.pid

[sst]
tca=/etc/ssl/mysql/ca.pem
tcert=/etc/ssl/mysql/server-cert.pem
tkey=/etc/ssl/mysql/server-key.pem
```
