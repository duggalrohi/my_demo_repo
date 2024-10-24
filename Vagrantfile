# Define the list of machines
slurm_cluster = {
    :head => {
        :hostname => "head",
        :ipaddress => "192.168.56.10",
        :port => "2222",
        :box => "bento/rockylinux-8",
        :memory => "2048",
        :cpus => "4",
        :gui => false
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
        :box => "bento/rockylinux-9",
        :memory => "1024",
        :cpus => "1",
        :gui => false,
        :disk_size => "4GB"
    }
}


# VAGRANT CONFIGURATION

Vagrant.configure("2") do |global_config|
    slurm_cluster.each_pair do |name, options|
        global_config.vm.define name do |config|
            # VM configurations
            config.ssh.insert_key = false
            config.ssh.forward_agent = true
            config.vm.synced_folder '.', '/vagrant'
            config.ssh.keys_only=true
            
            # Define port forwarding for the "server3" machine
            if name == :head
                config.vm.hostname = options[:hostname]
                config.vm.network :private_network, ip: options[:ipaddress]
                config.vm.usable_port_range = 8000..9000
                config.vm.box = options[:box]                
                config.vm.network "forwarded_port", guest: 22, host: options[:port], auto_correct: true
                # VM specifications
                config.vm.provider :virtualbox do |v|
                    v.name = options[:hostname]
                    v.customize ["modifyvm", :id, "--memory", options[:memory]]
                    v.cpus = options[:cpus]
                    v.gui = options[:gui]
                end
            end

            # Define port forwarding for the "server3" machine
            if name == :compute
                config.vm.hostname = options[:hostname]
                config.vm.network :private_network, ip: options[:ipaddress]
                config.vm.usable_port_range = 8000..9000
                config.vm.box = options[:box]                
                config.vm.network "forwarded_port", guest: 22, host: options[:port], auto_correct: true
                # VM specifications
                config.vm.provider :virtualbox do |v|
                    v.name = options[:hostname]
                    v.customize ["modifyvm", :id, "--memory", options[:memory]]
                    v.cpus = options[:cpus]
                    v.gui = options[:gui]
                end
            end

            # Define port forwarding for the "server3" machine
            if name == :database
                config.vm.hostname = options[:hostname]
                config.vm.network :private_network, ip: options[:ipaddress]
                config.vm.usable_port_range = 8000..9000
                config.vm.box = options[:box]                
                config.vm.network "forwarded_port", guest: 22, host: options[:port], auto_correct: true
                # VM specifications
                config.vm.provider :virtualbox do |v|
                    v.name = options[:hostname]
                    v.customize ["modifyvm", :id, "--memory", options[:memory]]
                    v.cpus = options[:cpus]
                    v.gui = options[:gui]
                end
            end

            # Define port forwarding for the "server3" machine
            if name == :extra
                config.vm.hostname = options[:hostname]
                config.vm.network :private_network, ip: options[:ipaddress]
                config.vm.usable_port_range = 8000..9000
                config.vm.box = options[:box]                
                config.vm.network "forwarded_port", guest: 22, host: options[:port], auto_correct: true
                # VM specifications
                config.vm.provider :virtualbox do |v|
                    v.name = options[:hostname]
                    v.customize ["modifyvm", :id, "--memory", options[:memory]]
                    v.cpus = options[:cpus]
                    v.gui = options[:gui]
                end
                (0..2).each do |i|
                    config.vm.disk :disk, size: options[:disk_size], name: "disk-#{i}"
                end
            end


        end
    end
end 
