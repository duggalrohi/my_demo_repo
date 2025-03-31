# Define the list of machines
slurm_cluster = {
  :head => {
    :hostname => "head",
    :ipaddress => "192.168.56.10",
    :port => "2227",
    :port_prometheus => "9090",
    :port_grafana => "3000",
    :box => "bento/rockylinux-8",
    :memory => "2048",
    :cpus => "4",
    :gui => false,
    :setup_script => "PostVagrantScript.sh"
  },
  :compute => {                                                              
    :hostname => "compute",
    :ipaddress => "192.168.56.11",
    :port => "2223",
    :box => "bento/rockylinux-8",
    :memory => "2048",
    :cpus => "4",
    :gui => false
  },
  :database => {                                                              
    :hostname => "database",
    :ipaddress => "192.168.56.12",
    :port => "2224",
    :box => "bento/rockylinux-8",
    :memory => "1024",
    :cpus => "1",
    :gui => false
  },
  :extra => {                                                              
    :hostname => "extra",
    :ipaddress => "192.168.56.13",
    :port => "2225",
    :box => "bento/rockylinux-8",
    :memory => "1024",
    :cpus => "1",
    :gui => false,
    :disk_size => "4GB"
  },
  :node01 => {                                                              
    :hostname => "node01",
    :ipaddress => "192.168.56.14",
    :port => "2226",
    :box => "bento/rockylinux-8",
    :memory => "1024",
    :cpus => "1",
    :gui => false,
    # :disk_size => "4GB",
    :setup_script => "NewNode_PostVagrantScript.sh"
  },
}

# Vagrant Configuration
Vagrant.configure("2") do |global_config|
  slurm_cluster.each do |name, options|
    global_config.vm.define name do |config|
      # VM common configurations
      config.ssh.insert_key = false
      config.ssh.forward_agent = true
      config.ssh.keys_only = true
      config.vm.synced_folder '.', '/vagrant'
      config.vm.box = options[:box]
      config.vm.hostname = options[:hostname]
      config.vm.network :private_network, ip: options[:ipaddress]
      config.vm.network "forwarded_port", guest: 22, host: options[:port], auto_correct: true

      # VM-specific configurations
      config.vm.provider :virtualbox do |v|
        v.name = options[:hostname]
        v.customize ["modifyvm", :id, "--memory", options[:memory]]
        v.cpus = options[:cpus]
        v.gui = options[:gui]
        v.linked_clone = true
        v.check_guest_additions = false
      end

      # Additional configurations for specific nodes
      config.vm.provision "shell", privileged: true, path: options[:setup_script] if options[:setup_script]
      
      if name == :extra 
        (0..2).each do |i|
          config.vm.disk :disk, size: options[:disk_size], name: "disk-#{i}" if options[:disk_size]
        end
      end
    end
  end
end
