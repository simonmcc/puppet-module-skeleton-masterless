# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "precise64"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  # enable hostmanager so that /etc/hosts gets maintained in the guests
  config.hostmanager.enabled = true

  config.vm.define "familytracker" do |familytracker|
    familytracker.vm.hostname = "familytracker"
    familytracker.vm.network "private_network", ip: "192.168.50.4"
    familytracker.vm.provision :shell, :path => "deploy/bootstrap.sh", :args => "site.pp"

    # Create a forwarded port mapping which allows access to a specific port
    # within the machine from a port on the host machine. In the example below,
    # accessing "localhost:8080" will access port 80 on the guest machine.
    familytracker.vm.network :forwarded_port, guest: 80, host: 8080
  end

  config.vm.define "graphite" do |graphite|
    graphite.vm.hostname = "graphite"
    graphite.vm.network "private_network", ip: "192.168.50.5"
    graphite.vm.provision :shell, :path => "deploy/bootstrap.sh", :args => "site.pp"

    # Create a forwarded port mapping which allows access to a specific port
    # within the machine from a port on the host machine. In the example below,
    # accessing "localhost:8080" will access port 80 on the guest machine.
    graphite.vm.network :forwarded_port, guest: 80, host: 8088
  end
end
