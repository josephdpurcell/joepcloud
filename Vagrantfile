# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # Provisioning all
  config.vm.provision :shell, path: "provisioning/bootstrap-all.sh"

  # Controller node.
  config.vm.define "node0" do |node0|
    # Variables.
    ip          = "10.0.0.11"
    project     = "node0-controller.joepcloud"
    mem = "2048"
    docroot = "/var/www"
    provisioningroot = "/vagrant/node0-controller/provisioning"

    # Base Box
    node0.vm.box     = "chef/ubuntu-14.04"

    # Networking
    node0.vm.network "private_network", ip: ip
    node0.ssh.forward_agent = true
    node0.vm.hostname = "#{project}.local"

    # NFS Mount
    node0.vm.synced_folder ".", "/vagrant", type: "nfs"
    node0.vm.synced_folder "node0-controller", docroot, type: "nfs"

    # Memory
    node0.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", mem]
    end

    # Provisioning
    config.vm.provision :shell, path: "node0-controller/provisioning/bootstrap.sh", args: [provisioningroot]
  end

  # Network node.
  config.vm.define "node1" do |node1|
    # Variables.
    ip          = "10.0.0.12"
    project     = "node1-network.joepcloud"
    mem = "512"
    docroot = "/var/www"
    provisioningroot = "/vagrant/node1-network/provisioning"

    # Base Box
    node1.vm.box     = "chef/ubuntu-14.04"

    # Networking
    node1.vm.network "private_network", ip: ip
    node1.ssh.forward_agent = true
    node1.vm.hostname = "#{project}.local"

    # NFS Mount
    node1.vm.synced_folder ".", "/vagrant", type: "nfs"
    node1.vm.synced_folder "node1-network", docroot, type: "nfs"

    # Memory
    node1.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", mem]
    end

    # Provisioning
    config.vm.provision :shell, path: "node1-network/provisioning/bootstrap.sh", args: [provisioningroot]
  end

  # Compute node.
  config.vm.define "node2" do |node2|
    # Variables.
    ip          = "10.0.0.13"
    project     = "node2-compute.joepcloud"
    mem = "2048"
    docroot = "/var/www"
    provisioningroot = "/vagrant/node2-compute/provisioning"

    # Base Box
    node2.vm.box     = "chef/ubuntu-14.04"

    # Networking
    node2.vm.network "private_network", ip: ip
    node2.ssh.forward_agent = true
    node2.vm.hostname = "#{project}.local"

    # NFS Mount
    node2.vm.synced_folder ".", "/vagrant", type: "nfs"
    node2.vm.synced_folder "node2-compute", docroot, type: "nfs"

    # Memory
    node2.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", mem]
    end

    # Provisioning
    config.vm.provision :shell, path: "node2-compute/provisioning/bootstrap.sh", args: [provisioningroot]
  end
end
