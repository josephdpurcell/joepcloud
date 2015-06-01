#!/bin/bash
# Compute node provisioning.
DIR=$1

# Copy ntp config.
cp $DIR/ntp/ntp.conf /etc/ntp.conf
service ntp restart

# Install the compute service on the compute node.
DEBIAN_FRONTEND=noninteractive apt-get -y install nova-compute sysfsutils
cp $DIR/nova/nova.conf /etc/nova/nova.conf
service nova-compute restart
rm -f /var/lib/nova/nova.sqlite

touch /tmp/provisioned
