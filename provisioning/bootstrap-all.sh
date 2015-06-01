#!/bin/bash
# Provisioning for all nodes.

# Add all hosts.
echo "10.0.0.11 node0-controller.joepcloud.local" >> /etc/hosts
echo "10.0.0.12 node1-network.joepcloud.local" >> /etc/hosts
echo "10.0.0.13 node2-compute.joepcloud.local" >> /etc/hosts

# Install dev tools
DEBIAN_FRONTEND=noninteractive apt-get -y install vim zsh

# Common tools needed.
DEBIAN_FRONTEND=noninteractive apt-get -y install curl

# Add OpenStack repos.
DEBIAN_FRONTEND=noninteractive apt-get -y install ubuntu-cloud-keyring
echo "deb http://ubuntu-cloud.archive.canonical.com/ubuntu" "trusty-updates/kilo main" > /etc/apt/sources.list.d/cloudarchive-kilo.list

# Update the package list.
DEBIAN_FRONTEND=noninteractive apt-get -y update

# You must install NTP to properly synchronize services among nodes. We recommend that you configure the controller node to reference more accurate (lower stratum) servers and other nodes to reference the controller node.
DEBIAN_FRONTEND=noninteractive apt-get -y install ntp

# Add inputrc for bash history completion.
cp /vagrant/provisioning/bash/.inputrc /home/vagrant/.inputrc
cp /vagrant/provisioning/bash/.inputrc /root/.inputrc
