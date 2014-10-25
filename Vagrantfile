VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "chef/ubuntu-14.04"

  config.vm.network 'forwarded_port', guest: 8080, host: 8080

  config.omnibus.chef_version = :latest
  config.berkshelf.berksfile_path = './Berksfile'
  config.berkshelf.enabled = true

  CHEF_CONFIGURATION = JSON.parse(Pathname(__FILE__).dirname.join('chef_configuration.json').read)

  config.vm.provision :chef_solo do |chef|
    chef.run_list = CHEF_CONFIGURATION.delete('run_list')
    chef.json = CHEF_CONFIGURATION
  end

  config.vm.provider 'virtualbox' do |v|
    v.customize ['modifyvm', :id, '--memory', 1024]
  end

end
