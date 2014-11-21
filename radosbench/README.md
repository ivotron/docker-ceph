# radosbench

A convenience container to execute rados bench.

Make sure to pass your /etc/ceph and /data paths as a 
volume/bind-mount.

Example:

```bash
docker run \
  -e SEC=300 -e N=3 -e PGS=512 \
  -v $HOME/rados_results/:/data \
  -v /etc/ceph:/etc/ceph \
  ivotron/radosbench
```
