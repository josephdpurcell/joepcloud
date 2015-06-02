# joepcloud

The problem I have encountered is that DevStack, while a nice way to get started interacting with OpenStack's dashboard, it didn't help me understand each component individually, nor the intricacies of installing them.

The joepcloud is an attempt to understand OpenStack by getting it working using VMs that are provisioned with a script that could also be used to provision real hardware, i.e. just give me a bash script!

The bash script should also represent a documented understanding of "this is what it really takes to get started". The DevStack stack.sh has a lot going on, and I'm hoping that getting started with OpenStack is actually simpler.

## Methodology

To complete this goal, I'm following these instructions:

1. [Chapter 2. Basic environment - Networking - OpenStack Networking (neutron)](http://docs.openstack.org/kilo/install-guide/install/apt/content/ch_basic_environment.html)
1. [Chapter 2. Basic environment - Network Time Protocol (NTP)](http://docs.openstack.org/kilo/install-guide/install/apt/content/ch_basic_environment.html)
1. [Chapter 2. Basic environment - OpenStack packages](http://docs.openstack.org/kilo/install-guide/install/apt/content/ch_basic_environment.html)
1. [Chapter 2. Basic environment - Database](http://docs.openstack.org/kilo/install-guide/install/apt/content/ch_basic_environment.html) (Note: used mysql instead of maria.)
1. [Chapter 2. Basic environment - Messaing server](http://docs.openstack.org/kilo/install-guide/install/apt/content/ch_basic_environment.html)
1. [Chapter 3. Add the Identity service - Install and configure](http://docs.openstack.org/kilo/install-guide/install/apt/content/keystone-install.html)
1. [Chapter 3. Add the Identity service - Create the service entity and API endpoint](http://docs.openstack.org/kilo/install-guide/install/apt/content/keystone-services.html)
1. [Chapter 3. Add the Identity service - Create projects, users, and roles](http://docs.openstack.org/kilo/install-guide/install/apt/content/keystone-services.html)
1. [Chapter 4. Add the Image service - Install and configure](http://docs.openstack.org/kilo/install-guide/install/apt/content/glance-install.html)
1. [Chapter 5. Add the Compute service - Install and configure controller node](http://docs.openstack.org/kilo/install-guide/install/apt/content/ch_nova.html)
1. [Chapter 5. Add the Compute service - Install and configure a compute node](http://docs.openstack.org/kilo/install-guide/install/apt/content/ch_nova.html)
1. [Chapter 6. Add a networking component - OpenStack Networking (neutron) - Install and configure controller node](http://docs.openstack.org/kilo/install-guide/install/apt/content/neutron-controller-node.html)
1. [Chapter 6. Add a networking component - OpenStack Networking (neutron) - Install and configure network node](http://docs.openstack.org/kilo/install-guide/install/apt/content/neutron-network-node.html)
Next: neutron agent-list on the controller should show the network node
Then: http://docs.openstack.org/kilo/install-guide/install/apt/content/neutron-compute-node.html

## Terminology

* service - a service in this context is an OpenStack service, such as Identity, Image, Compute, Storage, Swift, etc.
* Keystone - this is a synonym for the Identity service
* Glance - this is a synonym for the Image service
* Nova - this is a synonym for the Compute service
* Neutron - this is a synonym for the Network service

## What is OpenStack?

This is my interpretation of OpenStack: in short, it is a way to easily create machines and network them. To use a comparison, it is an open source version of AWS.

There are many services to OpenStack, here are key ones:

* Identity - handles users and permissions, and manages a catalog of available services
* Image - stores server images and provides metadata on those images
* Compute - manages cloud computing tasks; interacts with Image for getting images and Identity for auth
* Network - manages virtual networking on all nodes

See the full list of current "OpenStack Capabilities" [here](https://www.openstack.org/software/roadmap/).

## Architecture

The joepcloud has the following nodes with their related responsibilities:

* controller - this is the machine that will handle Identity and Image and Compute and Network services
* network - ??
* compute - this gets the Compute service also installed

## Setup

1. `vagrant up`
1. [Verify](http://docs.openstack.org/juno/install-guide/install/apt/content/ch_basic_environment.html) each node is synced correctly for ntp:
  1. `vagrant ssh node0 -c "ntpq -c peers"`
    1. Contents in the remote column should indicate the hostname or IP address of one or more NTP servers.
  1. `vagrant ssh node0 -c "ntpq -c assoc"`
    1. Contents in the condition column should indicate sys.peer for at least one server.
  1. `vagrant ssh node1 -c "ntpq -c peers" && vagrant ssh node2 -c "ntpq -c peers"`
    1. Contents in the remote column should indicate the hostname of the controller node.
    1. Contents in the refid column typically reference IP addresses of upstream servers.
  1. `vagrant ssh node1 -c "ntpq -c assoc" && vagrant ssh node2 -c "ntpq -c assoc"`
    1.  Contents in the condition column should indicate sys.peer.
1. Verify the controller node has the dependencies needed:
  1. `vagrant ssh node0 -c "ntpq -c assoc"`
  1. `mysql -u root -ppass` should allow you to login to mysql
  1. Ensure the right version of mysql is installed: `vagrant@node0-controller:~$ mysql --version
  mysql  Ver 14.14 Distrib 5.5.43, for debian-linux-gnu (x86_64) using readline 6.3`
  1. Ensure the right version of rabbitmq is installed and that it is running: `vagrant@node0-controller:~$ sudo rabbitmqctl status | grep rabbit
  Status of node 'rabbit@node0-controller' ...
   {running_applications,[{rabbit,"RabbitMQ","3.5.3"},`
  1. Ensure that keystone is running properly:
    1. Get the list of projects: `openstack --os-auth-url http://node0-controller.joepcloud.local:35357 --os-project-name admin --os-username admin --os-auth-type password project list`
    1. Get the list of users: `openstack --os-auth-url http://node0-controller.joepcloud.local:35357 --os-project-name admin --os-username admin --os-auth-type password user list`
    1. Get the list of roles: `openstack --os-auth-url http://node0-controller.joepcloud.local:35357 --os-project-name admin --os-username admin --os-auth-type password role list`
    1. Get the list of services: `openstack --os-auth-url http://node0-controller.joepcloud.local:35357 --os-project-name admin --os-username admin --os-auth-type password service list`
    1. Get an auth token as a guest: `openstack --os-auth-url http://node0-controller.joepcloud.local:5000 --os-project-domain-id default --os-user-domain-id default --os-project-name demo --os-username demo --os-auth-type password token issue`
    1. Ensure guest has no access to admin functions: `openstack --os-auth-url http://node0-controller.joepcloud.local:5000 --os-project-domain-id default --os-user-domain-id default --os-project-name demo --os-username demo --os-auth-type password user list` (this should fail)
  1. Ensure glance has the image we setup: `openstack --os-auth-url http://node0-controller.joepcloud.local:35357 --os-project-name admin --os-username admin --os-auth-type password image list` should show "cirros-0.3.4-x86_64"

## System Requirements

### node0-controller

* ubuntu 14.04
* mysql 5.5
* rabbitmq 3.5.3
* python 2.7.6
* keystone (kilo release)
* glance (kilo release)
* nova api (kilo release)

### node1-network

* ubuntu 14.04

### node2-compute

* ubuntu 14.04
* nova compute (kilo release)

## Credentials

### node0-controller

```
mysql
  u: root
  p: pass
  purpose: administration

  u: keystone
  p: pass
  purpose: the Identity service's access for r/w to the db

  u: glance
  p: pass
  purpose: the Image service's access for r/w to the db

  u: nova
  p: pass
  purpose: the Compute service's access for r/w to the db

  u: neutron
  p: pass
  purpose: the Network service's access for r/w to the db

rabbitmq
  u: openstack
  p: pass
  purpose: everything

keystone:
  admin_token: 92f5ed574490fdec2b79
  purpose: temporarily? used for making API requests to keystone

  u: admin
  p: pass
  purpose: administration of OpenStack

  u: demo
  p: pass
  purpose: demoing of OpenStack with restricted access

  u: glance
  p: pass
  purpose: managing disk images with the Image service

  u: nova
  p: pass
  purpose: managing taks for the Compute service

  u: neutron
  p: pass
  purpose: managing networking config for the Network service

neutron:
    metadata_agent_shared_secret: luChyijyujofshudjegNevNeatEnyip8
    purpose: no idea??
```

### node1-network

```
neutron:
    metadata_agent_shared_secret: luChyijyujofshudjegNevNeatEnyip8
    purpose: no idea??
```

## TODOs

1. The very next todo is to get neutron working.
1. Verify that the ntp config is secure / proper. I just trial and error'd until it worked.
1. Disable or remove any automatic update services because they can impact your OpenStack environment.
1. Consider using `mysql_secure_installation` in provision script.
1. Consider a way to allow the user to set their own passwords.
1. Figure out if all the dependencies are correct
1. Modify this installation to allow configurable ips.
1. Make provisioning idempotent.
1. Make the verification of system dependency checks scriptable.
1. Use ansible!

