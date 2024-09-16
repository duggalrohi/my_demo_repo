Once your vagrant machines are up
        Both Machines
Edit slurm.conf at the last line to update NodeName=server1 from localhost

        Server1 Machine
sudo dnf install slurm-pam_slurm 

        Controller Machine Set Up

sudo /usr/sbin/create-munge-key
sudo scp /etc/munge/munge.key vagrant@server1:/home/vagrant/


        Server1 Machine Set Up
sudo cp ~/munge.key /etc/munge
sudo chown munge /etc/munge/munge.key

        Both Machines
sudo systemctl enable munge.service
sudo systemctl start munge.service

        Controller Machine
sudo systemctl enable slurmctld.service
sudo systemctl start slurmctld.service

        Server1 Machine
sudo systemctl enable slurmd.service
sudo systemctl start slurmd.service
sudo su 
echo "UsePAM yes" >> /etc/ssh/sshd_config
echo -e "root\nwheel" >> /etc/pam.d/allowed_ssh_groups
cd /etc/pam.d
vi sshd
# Add these lines after line
# line in file sshd: account    required     pam_nologin.so
#------------------------------------
account sufficient pam_listfile.so item=group sense=allow file=/etc/pam.d/allowed_ssh_groups onerr=fail
-account required pam_slurm.so
#------------------------------------

        Controller Machine
sudo scontrol reconfig


