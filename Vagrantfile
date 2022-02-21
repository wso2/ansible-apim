# -*- mode: ruby -*-
# vi: set ft=ruby :
# To use these virtual machine install Vagrant and VirtuaBox.
# vagrant up centos7
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

  # enable ssh agent forwarding
  config.ssh.forward_agent = true

  # use the standard vagrant ssh key
  config.ssh.insert_key = false

  # disable guest additions
  config.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true

  config.vm.define "centos7" do |srv|
    srv.vm.box = "centos/7"
    srv.vm.hostname = "centos7"
    srv.vm.network 'private_network', ip: "192.168.56.7"

    # set no_share to false to enable file sharing
    srv.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true
    srv.vm.provider :virtualbox do |virtualbox|
      virtualbox.customize ["modifyvm", :id,
         "--audio", "none",
         "--cpus", 2,
         "--memory", 4096,
         "--graphicscontroller", "VMSVGA",
         "--vram", "64"
      ]
      virtualbox.gui = false
      virtualbox.name = "centos7"
    end
    end

  config.vm.provision "ansible" do |ansible|
    ansible.compatibility_mode = "2.0"
    ansible.playbook = "site.yml"
    ansible.inventory_path = "inventory/hosts"
    ansible.limit = "apim"
    ansible.verbose = "vv"
  end
end
