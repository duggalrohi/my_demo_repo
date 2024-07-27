#Define the list of machines
slurm_cluster = {
    :controller => {
        :hostname => "controller",
        :ipaddress => "192.168.33.10"
    },
    :server1 => {                                                              
        :hostname => "server1",
        :ipaddress => "192.168.33.11"
    }
    # ,
    # :server2 => {                                                              
    #     :hostname => "server2",
    #     :ipaddress => "192.168.33.12"
    # }
}

#Provisioning inline script
$script = <<SCRIPT
# echo " ";
# SCRIPT
# echo " "
sudo dnf -y config-manager --set-enabled crb;
sudo dnf install epel-release -y;
sudo crb enable ;
sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org;
sudo dnf install https://www.elrepo.org/elrepo-release-9.el9.elrepo.noarch.rpm -y;
sudo dnf --enablerepo=elrepo-kernel install kernel-ml -y;
sudo sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=0/' /etc/default/grub;
sudo grub2-mkconfig -o /boot/grub2/grub.cfg;

sudo dnf install -y ansible ;
sudo dnf install -y top ;
sudo dnf install -y htop ;
sudo dnf install -y vim ;
sudo dnf install -y slurm; 
sudo dnf install -y slurm-slurmctld ;
sudo dnf install -y slurm-slurmd ;
sudo dnf install -y munge ;
sudo dnf install -y munge-libs ;
sudo dnf install -y munge-devel ;
sudo dnf install -y wget ;
sudo dnf install -y slurm-llnl;
echo -e "\n\n\n" | ssh-keygen -t rsa;
ssh-copy-id -i ~/.ssh/id_rsa.pub vagrant@server1;
# ssh-copy-id -i ~/.ssh/id_rsa.pub vagrant@server2

echo "192.168.33.10    controller" >> /etc/hosts;
echo "192.168.33.11    server1" >> /etc/hosts;
# echo "192.168.33.12    server2" >> /etc/hosts
wget https://raw.github.com/guillermo-carrasco/mussolblog/master/setting_up_a_testing_SLURM_cluster/slurm.conf;
sudo dnf install -y epel-release;
sudo dnf install -y fio;
SCRIPT

Vagrant.configure("2") do |global_config|
    
    
    slurm_cluster.each_pair do |name, options|
        global_config.vm.define name do |config|
            
            
            #VM configurations
            config.ssh.insert_key = false
	        # config.ssh.forward_agent = true
            # config.ssh.forward_x11 = true
            # Configure SSH access
            # config.ssh.username = "rohit"
            config.ssh.private_key_path = "C:\\Users\\rohit\\.vagrant.d\\insecure_private_keys\\vagrant.key.ed25519"
            # config.ssh.password = "vagrant"

            config.vm.box = "bento/rockylinux-9"
            # config.vm.network "private_network", ip: "192.168.33.10"
            config.vm.network "public_network"
            config.vm.hostname = "#{name}"
            config.vm.network :private_network, ip: options[:ipaddress]
            config.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true
            config.vm.usable_port_range = 8000..9000
            # config.vm.synced_folder "C:\\Users\\rohit\\Desktop\\projects\\cluster", "/home/vagrant"
            config.vm.provider :virtualbox do |v|
                v.customize ["modifyvm", :id, "--memory", "512"]
                v.gui = false
            end

            config.vm.define "controller", primary: true do |controller|
                controller.vm.network "forwarded_port", guest: 22, host: 2222, auto_correct: true
                controller.vm.usable_port_range=(8000..9000)
            # Add any additional port forwarding configuration specific to the "controller" machine
            end
        
            # Define port forwarding for the "server1" machine
            config.vm.define "server1" do |server|
                server.vm.network "forwarded_port", guest: 22, host: 2223, auto_correct: true
                server.vm.usable_port_range=(8000..9000)
            # Add any additional port forwarding configuration specific to the "server" machine
            end

            # # Define port forwarding for the "server2" machine
            # config.vm.define "server2" do |server|
            #     server.vm.network "forwarded_port", guest: 22, host: 2224, auto_correct: true
            #     server.vm.usable_port_range=(8000..9000)
            # # Add any additional port forwarding configuration specific to the "server" machine
            # end

            #VM specifications
            # config.vm.provider :virtualbox do |v|
            #     v.customize ["modifyvm", :id, "--memory", "512"]
            #     v.gui = true
            # end

            #VM provisioning
            #ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip
            config.vm.provision :shell, :inline => $script
        end
    end
end



#Provisioning inline script
# $script = <<SCRIPT
# echo " "
# sudo dnf -y config-manager --set-enabled crb
# sudo dnf install epel-release -y
# sudo crb enable 
# sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
# sudo dnf install https://www.elrepo.org/elrepo-release-9.el9.elrepo.noarch.rpm -y
# sudo dnf --enablerepo=elrepo-kernel install kernel-ml -y
# sudo sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=0/' /etc/default/grub
# sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# sudo dnf install -y ansible 
# sudo dnf install -y top 
# sudo dnf install -y htop 
# sudo dnf install -y vim 
# sudo dnf install -y slurm 
# sudo dnf install -y slurm-slurmctld 
# sudo dnf install -y slurm-slurmd 
# sudo dnf install -y munge 
# sudo dnf install -y munge-libs 
# sudo dnf install -y munge-devel 
# sudo dnf install -y wget 
# sudo dnf install -y slurm-llnl
# echo -e "\n\n\n" | ssh-keygen -t rsa
# ssh-copy-id -i ~/.ssh/id_rsa.pub vagrant@server1
# ssh-copy-id -i ~/.ssh/id_rsa.pub vagrant@server2

# echo "192.168.33.10    controller" >> /etc/hosts
# echo "192.168.33.11    server1" >> /etc/hosts
# echo "192.168.33.12    server2" >> /etc/hosts
# wget https://raw.github.com/guillermo-carrasco/mussolblog/master/setting_up_a_testing_SLURM_cluster/slurm.conf
# SCRIPT