#!/bin/bash
set -e

if [ ! -n "$N" ]; then
  echo "ERROR: N must be defined as the number of replicas"
  exit 1
fi

if [ ! -n "$SEC" ]; then
  echo "ERROR: SEC must be defined as the number of seconds to execute for"
  exit 1
fi

if [ ! -n "$REPS" ]; then
  echo "ERROR: REPS must be defined as the number of times to execute for"
  exit 1
fi

if [ ! -n "$NUM_OSD" ]; then
  echo "ERROR: NUM_OSD must be defined as the number of OSDs in the cluster"
  exit 1
fi

if [ ! -n "$SIZE" ]; then
  SIZE="4096 8192 16384 32768 65536 131072 262144 524288 1048576 2097152 4194304"
fi

if [ ! -d "/data" ]; then
  echo "ERROR: folder '/data' doesn't exist"
  exit 1
fi

YEAR=`date +%Y`
MONTH=`date +%m`
DAY=`date +%d`
TIME=`date +%H%M`

ceph_health()
{
  echo -n "Waiting for pool operation to finish..."
  while [ "$(/usr/bin/ceph health)" != "HEALTH_OK" ] ; do
    sleep 2
    echo -n "."
  done
  echo ""
}

# set PGS to the recommended values
if [ "$NUM_OSD" -le 2 ] ; then
  PGS=32
elif [ "$NUM_OSD" -le 3 ] ; then
  PGS=64
elif [ "$NUM_OSD" -le 5 ] ; then
  PGS=128
elif [ "$NUM_OSD" -le 10 ] ; then
  PGS=512
else
  PGS=4096
fi

BASE_PATH="/data/${YEAR}_${MONTH}_${DAY}_${TIME}/${NUM_OSD}"
for ((n=1; n<=N; n++)); do

  # check if we have enough OSDs for replication
  if [ "$NUM_OSD" -lt "$n" ] ; then
    continue
  fi

for size in $SIZE ; do
for ((rep=1; rep<=REPS; rep++)); do
  RESULTS_PATH="${BASE_PATH}/${n}/${size}/"
  mkdir -p ${RESULTS_PATH}
  POOL=perf
  echo "===> CREATE POOL: ${POOL} (`date +%H:%M:%S`)"
  /usr/bin/ceph osd pool create ${POOL} ${PGS} ${PGS}
  /usr/bin/ceph osd pool set ${POOL} size ${n}
  ceph_health
  echo "===> RADOS BENCH WRITE TEST: START (`date +%H:%M:%S`)"
  /usr/bin/rados bench ${SEC} write -b ${size} -p ${POOL} --no-cleanup > ${RESULTS_PATH}/${rep}_write.csv
  echo "===> RADOS BENCH WRITE TEST: END (`date +%H:%M:%S`)"
  echo "===> RADOS BENCH SEQ TEST: START (`date +%H:%M:%S`)"
  /usr/bin/rados bench ${SEC} seq -b ${size} -p ${POOL} > ${RESULTS_PATH}/${rep}_seq.csv
  echo "===> RADOS BENCH SEQ TEST: END (`date +%H:%M:%S`)"
  /usr/bin/ceph osd pool delete ${POOL} ${POOL} --yes-i-really-really-mean-it
  echo "===> DELETE POOL: ${POOL} (`date +%H:%M:%S`)"
done
done
done
