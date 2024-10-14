# Define the list of machines
slurm_cluster = {
    :head => {
        :hostname => "head",
        :ipaddress => "192.168.56.10"
    },
    :compute => {                                                              
        :hostname => "compute",
        :ipaddress => "192.168.56.11"
    },
    :database => {                                                              
        :hostname => "database",
        :ipaddress => "192.168.56.12"
    },
    :extra => {                                                              
        :hostname => "extra",
        :ipaddress => "192.168.56.13"
    }
}


# VAGRANT CONFIGURATION

Vagrant.configure("2") do |global_config|
    slurm_cluster.each_pair do |name, options|
        global_config.vm.define name do |config|
            # VM configurations
            config.ssh.insert_key = false
            config.ssh.forward_agent = true
            config.ssh.forward_x11=true
            config.vm.synced_folder '.', '/vagrant', disabled: true
            config.ssh.keys_only=true
            
            # Define port forwarding for the "server3" machine
            if name == :head
                config.vm.hostname = options[:hostname]
                config.vm.network :private_network, ip: options[:ipaddress]
                config.vm.usable_port_range = 8000..9000
                config.vm.box = "bento/rockylinux-8"                
                config.vm.network "forwarded_port", guest: 22, host: 2222, auto_correct: true
                # VM specifications
                config.vm.provider :virtualbox do |v|
                    v.customize ["modifyvm", :id, "--memory", "2048"]
                    v.cpus = 4
                    v.gui = false
                end
            end

            # Define port forwarding for the "server3" machine
            if name == :compute
                config.vm.hostname = options[:hostname]
                config.vm.network :private_network, ip: options[:ipaddress]
                config.vm.usable_port_range = 8000..9000
                config.vm.box = "bento/rockylinux-8"                
                config.vm.network "forwarded_port", guest: 22, host: 2223, auto_correct: true
                # VM specifications
                config.vm.provider :virtualbox do |v|
                    v.customize ["modifyvm", :id, "--memory", "2048"]
                    v.cpus = 4
                    v.gui = false
                end
            end

            # Define port forwarding for the "server3" machine
            if name == :database
                config.vm.hostname = options[:hostname]
                config.vm.network :private_network, ip: options[:ipaddress]
                config.vm.usable_port_range = 8000..9000
                config.vm.box = "bento/rockylinux-8"                
                config.vm.network "forwarded_port", guest: 22, host: 2224, auto_correct: true
                # VM specifications
                config.vm.provider :virtualbox do |v|
                    v.customize ["modifyvm", :id, "--memory", "1024"]
                    v.cpus = 1
                    v.gui = false
                end
            end

            # Define port forwarding for the "server3" machine
            if name == :extra
                config.vm.hostname = options[:hostname]
                config.vm.network :private_network, ip: options[:ipaddress]
                config.vm.usable_port_range = 8000..9000
                config.vm.box = "bento/rockylinux-8"                
                config.vm.network "forwarded_port", guest: 22, host: 2225, auto_correct: true
                # VM specifications
                config.vm.provider :virtualbox do |v|
                    v.customize ["modifyvm", :id, "--memory", "1024"]
                    v.cpus = 1
                    v.gui = false
                end
            end


        end
    end
end 
