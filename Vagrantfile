# -*- mode: ruby -*-
# vi: set ft=ruby :
# To use this virtual machine install Vagrant and VirtualBox.
# vagrant up

Vagrant.require_version ">= 2.0.0"


Vagrant.configure(2) do |config|

  # check for updates of the base image
  config.vm.box_check_update = true
  # wait a while longer
  config.vm.boot_timeout = 1200

  # disable update guest additions
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
  end

  if Vagrant.has_plugin?("vagrant-hostmanager")
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.manage_guest = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = true
  end
  # enable ssh agent forwarding
  config.ssh.forward_agent = true

  # use the standard vagrant ssh key
  config.ssh.insert_key = false

  # disable guest additions
  config.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true

  config.vm.define "wso2vagrant" do |srv|
    srv.vm.box = "centos/7"
    srv.vm.hostname = "wso2vagrant"
    srv.vm.network 'private_network', ip: "192.168.56.7"
    srv.vm.provider :virtualbox do |virtualbox|
      virtualbox.customize ["modifyvm", :id,
         "--audio", "none",
         "--cpus", 2,
         "--memory", 4096,
         "--graphicscontroller", "VMSVGA",
         "--vram", "64"
      ]
      virtualbox.gui = false
      virtualbox.name = "wso2vagrant"
    end
  end

  config.vm.provision "ansible" do |ansible|
    ansible.compatibility_mode = "2.0"
    ansible.playbook = "site.yml"
    ansible.inventory_path = "inventory/dev/hosts"
    ansible.limit = "apim"
    ansible.verbose = "v"
  end
end
