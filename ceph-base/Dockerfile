# DOCKER-VERSION 1.2.0
# 
# Ceph base image
#
# VERSION 1.0.0


FROM stackbrew/ubuntu:trusty
MAINTAINER Seán C McCord "ulexus@gmail.com"

ADD ceph.list /etc/apt/sources.list.d/
ADD ceph.keys /tmp/
RUN apt-key add /tmp/ceph.keys

# Make sure we are up-to-date
RUN apt-get update
RUN apt-get upgrade -y

# Install ceph
RUN apt-get install -y ceph

# cleanup
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
