# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "debian/contrib-jessie64"
  config.vm.provision "shell", path: "provision.sh"

  config.vm.network "public_network"

  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 4
  end

  config.vm.provision :'puppet' do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.manifest_file  = "ghtorrent.pp"
    puppet.module_path = "puppet/modules"
    puppet.options = "--verbose --debug"
  end

end
