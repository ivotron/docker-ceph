#!/bin/bash
set -e

if [ ! -n "$PGS" ]; then
  echo "ERROR: PGS must be defined as the number of placement groups"
  exit 1
fi

if [ ! -n "$N" ]; then
  echo "ERROR: N must be defined as the number of replicas"
  exit 1
fi

if [ ! -n "$SEC" ]; then
  echo "ERROR: SEC must be defined as the number of seconds to execute for"
  exit 1
fi

if [ ! -d "/data" ]; then
  echo "ERROR: folder '/data' doesn't exist"
  exit
fi

YEAR=`date +%Y`
MONTH=`date +%m`
DAY=`date +%d`
TIME=`date +%H%M`
O_SIZE="4096 16384 65536 262144 524288 1048576 4194304"

ceph_health()
{
  echo -n "Waiting for pool operation to finish..."
  while [ "$(/usr/bin/ceph health)" != "HEALTH_OK" ] ; do
    sleep 1
    echo -n "."
  done
  echo ""
}

for SIZE in ${O_SIZE} ; do
  RESULTS_PATH="/data/${YEAR}_${MONTH}_${DAY}_${TIME}_${SIZE}_${N}"
  POOL=${TIME}_perf
  mkdir ${RESULTS_PATH}
  echo "===> CREATE POOL: ${POOL} (`date +%H:%M:%S`)"
  /usr/bin/ceph osd pool create ${POOL} ${PGS} ${PGS}
  /usr/bin/ceph osd pool set ${POOL} size ${N}
  ceph_health
  echo "===> RADOS BENCH WRITE TEST: START (`date +%H:%M:%S`)"
  /usr/bin/rados bench ${SEC} write -p ${POOL} --no-cleanup > ${RESULTS_PATH}/write.csv
  echo "===> RADOS BENCH WRITE TEST: END (`date +%H:%M:%S`)"
  echo "===> RADOS BENCH SEQ TEST: START (`date +%H:%M:%S`)"
  /usr/bin/rados bench ${SEC} seq -p ${POOL} > ${RESULTS_PATH}/seq.csv
  echo "===> RADOS BENCH SEQ TEST: END (`date +%H:%M:%S`)"
  /usr/bin/ceph osd pool delete ${POOL} ${POOL} --yes-i-really-really-mean-it
  echo "===> DELETE POOL: ${POOL} (`date +%H:%M:%S`)"
done
