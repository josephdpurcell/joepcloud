#!/bin/bash
# Network node provisioning.
DIR=$1

# Copy ntp config.
cp $DIR/ntp/ntp.conf /etc/ntp.conf
service ntp restart

# Update sysctl.conf
cp $DIR/sysctl.conf /etc/sysctl.conf
sysctl -p

# Install neutron.
DEBIAN_FRONTEND=noninteractive apt-get -y install neutron-plugin-ml2 neutron-plugin-openvswitch-agent neutron-l3-agent neutron-dhcp-agent neutron-metadata-agent
cp $DIR/neutron/dhcp_agent.ini /etc/neutron/dhcp_agent.ini
cp $DIR/neutron/l3_agent.ini /etc/neutron/l3_agent.ini
cp $DIR/neutron/metadata_agent.ini /etc/neutron/metadata_agent.ini
cp $DIR/neutron/neutron.conf /etc/neutron/neutron.conf
cp $DIR/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini
# Create bridge
service openvswitch-switch restart
ovs-vsctl add-br br-ex
ovs-vsctl add-port br-ex eth2
# Restart services
service neutron-plugin-openvswitch-agent restart
service neutron-l3-agent restart
service neutron-dhcp-agent restart
service neutron-metadata-agent restart

touch /tmp/provisioned
