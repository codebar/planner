# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # ubuntu/vivid64 (the next version, after trusty64 which is used below)
  # doesn't play well with salt right now, as it moved to systemd and away from
  # upstart
  config.vm.box = "ubuntu/trusty64"

  config.vm.network :private_network, ip: "192.168.8.13"
  config.vm.network :forwarded_port, guest: 3000, host: 3000

  # for the love of all that is holy, use NFS... it is painfully slow otherwise
  # (sorry Windows users)
  # http://blog.dcxn.com/2013/08/14/3-tips-for-fast-vagrant-rails-environments/
  # how to fix possible issues with /etc/exports
  # http://stackoverflow.com/questions/20726248/vagrant-error-nfs-is-reporting-that-your-exports-file-is-invalid
  nfs_setting = RUBY_PLATFORM =~ /darwin/ || RUBY_PLATFORM =~ /linux/
  config.vm.synced_folder ".", "/vagrant", id: "vagrant-root", nfs: nfs_setting
  config.vm.synced_folder "salt/roots/", "/srv/salt/", id: "salt-root", nfs: nfs_setting

  config.vm.provision :salt, run: "always" do |salt|
    salt.minion_config = "salt/roots/minion"
    salt.run_highstate = true

    salt.verbose = true
    salt.log_level = "info"
    salt.colorize = true

    salt.install_type = "git"
    salt.install_args = "v2015.5.0"
  end

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
  end

end
