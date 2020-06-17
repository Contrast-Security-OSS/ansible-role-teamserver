# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.define 'ansible-role-teamserver' do |c|
    c.vm.box = 'ubuntu/trusty64'
    c.vm.hostname = 'ansible-role-teamserver'
    c.vm.provision 'ansible' do |ansible|
      ansible.playbook = 'test.yml'
      ansible.verbose = 'v'
      #ansible.tags = 'update_teamserver_property_files'
      #ansible.extra_vars = 'tests/test.yml'
      #ansible.inventory_path = 'tests/inventory'
      ansible.host_key_checking = false
    end
  end
end
