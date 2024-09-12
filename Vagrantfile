# Define the list of machines
slurm_cluster = {
    :controller => {
        :hostname => "controller",
        :ipaddress => "192.168.56.10"
    },
    :server1 => {                                                              
        :hostname => "server1",
        :ipaddress => "192.168.56.11"
    }
    # ,
    # :server2 => {                                                              
    #     :hostname => "server2",
    #     :ipaddress => "192.168.56.12"
    # }
}

# Provisioning inline script
$script = <<SCRIPT
# echo -e '\\n\\n\\n' | ssh-keygen -t rsa;
# sudo dnf install -yq vim wget curl;
sudo dnf -y config-manager --set-enabled crb;
sudo dnf install epel-release -y;
sudo crb enable;
sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org;
sudo dnf install https://www.elrepo.org/elrepo-release-9.el9.elrepo.noarch.rpm -y;
# sudo dnf --enablerepo=elrepo-kernel install kernel-ml -y;
# sudo sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=0/' /etc/default/grub;
# sudo grub2-mkconfig -o /boot/grub2/grub.cfg;
# sudo dnf install -y ansible;
sudo dnf install -y htop vim slurm slurm-slurmctld slurm-slurmd munge munge-libs munge-devel wget;
# ssh-copy-id -i ~/.ssh/id_rsa.pub vagrant@server1;
# ssh-copy-id -i ~/.ssh/id_rsa.pub vagrant@server2;
echo "192.168.56.10    controller" >> /etc/hosts;
echo "192.168.56.11    server1" >> /etc/hosts;
echo "192.168.56.12    server2" >> /etc/hosts;
# wget https://raw.github.com/guillermo-carrasco/mussolblog/master/setting_up_a_testing_SLURM_cluster/slurm.conf;
# sudo dnf install -y fio;
sudo useradd -u 50002 -g users -G wheel -d /home/rohit -p rohit -c "Rohit Duggal" rohit 
sudo usermod -a -G wheel vagrant
SCRIPT

Vagrant.configure("2") do |global_config|
    slurm_cluster.each_pair do |name, options|
        global_config.vm.define name do |config|
            # VM configurations
            config.ssh.insert_key = false
            config.ssh.forward_agent = true
            config.ssh.forward_x11=true
            config.vm.synced_folder '.', '/vagrant', disabled: true
            config.ssh.keys_only=true
            #config.ssh.private_key_path = "C:\\Users\\rohit\\.vagrant.d\\insecure_private_keys\\vagrant.key.ed25519"
            
            if name == :server1
                config.vm.box = "bento/rockylinux-8"
            end
            if name == :server2
                config.vm.box = "archlinux/archlinux"
            else
                config.vm.box = "bento/rockylinux-9"
            end
            

            config.vm.hostname = options[:hostname]
            config.vm.network :private_network, ip: options[:ipaddress]
            config.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true
            config.vm.usable_port_range = 8000..9000

            # VM specifications
            config.vm.provider :virtualbox do |v|
                v.customize ["modifyvm", :id, "--memory", "1024"]
                # v.memory = 1024
                v.cpus = 2
                v.gui = false
            end

            # Define port forwarding for the "controller" machine
            if name == :controller
                config.vm.network "forwarded_port", guest: 22, host: 2222, auto_correct: true
            end

            # Define port forwarding for the "server1" machine
            if name == :server1
                config.vm.network "forwarded_port", guest: 22, host: 2223, auto_correct: true
            end

            # Define port forwarding for the "server2" machine
            if name == :server2
                config.vm.network "forwarded_port", guest: 22, host: 2224, auto_correct: true
            end

            # VM provisioning
            config.vm.provision :shell, 
                :inline => $script
        end
    end
end 
