# joepcloud

The problem I have encountered is that DevStack, while a nice way to get started interacting with OpenStack's dashboard, it didn't help me understand each component individually, nor the intricacies of installing them.

The joepcloud is an attempt to understand OpenStack by getting it working using VMs that are provisioned with a script that could also be used to provision real hardware, i.e. just give me a bash script!

The bash script should also represent a documented understanding of "this is what it really takes to get started". The DevStack stack.sh has a lot going on, and I'm hoping that getting started with OpenStack is actually simpler.

## Setup

1. `vagrant up`
1. [Verify](http://docs.openstack.org/juno/install-guide/install/apt/content/ch_basic_environment.html) each node is synced correctly:
  1. `vagrant ssh node0 -c "ntpq -c peers"`
    1. Contents in the remote column should indicate the hostname or IP address of one or more NTP servers.
  1. `vagrant ssh node0 -c "ntpq -c assoc"`
    1. Contents in the condition column should indicate sys.peer for at least one server.
  1. `vagrant ssh node1 -c "ntpq -c peers" && vagrant ssh node2 -c "ntpq -c peers"`
    1. Contents in the remote column should indicate the hostname of the controller node.
    1. Contents in the refid column typically reference IP addresses of upstream servers.
  1. `vagrant ssh node1 -c "ntpq -c assoc" && vagrant ssh node2 -c "ntpq -c assoc"`
    1.  Contents in the condition column should indicate sys.peer.

## TODOs

1. Verify that the ntp config is secure / proper. I just trial and error'd until it worked.
