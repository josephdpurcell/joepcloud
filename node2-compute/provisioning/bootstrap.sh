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

# Setup Network service.
# Note: this is also called Neutron.
# 1. Update sysctl.conf
cp $DIR/sysctl.conf /etc/sysctl.conf
sysctl -p
# 2. Install Neutron.
DEBIAN_FRONTEND=noninteractive apt-get -y install neutron-plugin-ml2 neutron-plugin-openvswitch-agent
# 3. Update neutron config.
cp $DIR/neutron/neutron.conf /etc/neutron/neutron.conf
cp $DIR/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini
# 4. Restart services.
service openvswitch-switch restart
service nova-compute restart

touch /tmp/provisioned
