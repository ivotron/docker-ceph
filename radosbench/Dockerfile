# radosbench

FROM ivotron/ceph-base:0.87.1
MAINTAINER Ivo Jimenez "ivo.jimenez@gmail.com"

# Execute rados entrypoint
ADD entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
