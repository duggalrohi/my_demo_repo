#!/bin/bash
# This script sets up necessary dependencies for a development environment
# using DNF, with clean and organized code.

# Exit immediately if a command exits with a non-zero status
set -e


# Define repository and packages
ENABLE_REPO="epel"
DISABLE_REPO="OpenHPC-updates,OpenHPC"
PACKAGES=(
    ansible
    cryptsetup
    dbus-devel
    @Development
    fio
    freeipmi-devel
    gcc
    git
    golang
    gtk2-devel
    htop
    http-parser-devel
    hwloc
    hwloc-devel
    iftop
    jq
    json-c-devel
    libbpf
    libibmad
    libibumad
    libjwt-devel
    libseccomp-devel
    libssh2-devel
    libuuid-devel
    man2html
    mariadb-devel
    mariadb-server
    munge
    munge
    munge-devel
    munge-devel
    munge-libs
    munge-libs
    ncdu
    ncurses-devel
    numactl
    numactl-devel
    openmpi
    openssl
    openssl-devel
    openssl-devel
    pam-devel
    perl-ExtUtils-MakeMaker
    perl-Switch
    python3
    python3-mysql
    readline-devel
    rpm-build
    rrdtool-devel
    singularity-ce
    slurm
    slurm-devel
    slurm-pam_slurm
    slurm-slurmctld
    slurm-slurmd
    slurm-slurmdbd
    squashfs-tools 
    vim
    vim-enhanced
    wget
    xorg-x11-xauth

)

EXCLUDE_PACKAGES=(
    lua
    lua-devel
)

# Function to enable a repo and install packages
install_packages() {
    echo "Enabling repository: $REPO"
    echo "Installing required packages..."
    echo "${PACKAGES[@]}"
    # Use "${PACKAGES[@]}" to expand the package list
    dnf --enablerepo="$ENABLE_REPO" install -y "${PACKAGES[@]}" --disablerepo="$DISABLE_REPO"
}


##############################################
# Basic OS Setup
##############################################

# Host resolution
if ! grep -q "head" /etc/hosts; then
    echo "192.168.56.10    head" >> /etc/hosts;
    echo "192.168.56.11    compute" >> /etc/hosts;
    echo "192.168.56.12    database" >> /etc/hosts;
    echo "192.168.56.13    login" >> /etc/hosts;
    # Disable selinux and firewall
    setenforce 0
    cat >/etc/selinux/config<<__EOF
SELINUX=disabled
SELINUXTYPE=targeted
__EOF
    systemctl disable firewalld
    systemctl stop firewalld
    #########################################
fi



#########################################
# Useful software to have on the cluster
#########################################
if ! grep -q '^#exclude=slurm*' /etc/yum.repos.d/epel.repo; then
    
    rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org;
    dnf install https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm -y;
    dnf config-manager --set-enabled powertools; # EL8
    dnf install epel-release -y;
    dnf clean all;

    sed -i 's/^#exclude=slurm*/#exclude=slurm*/' /etc/yum.repos.d/epel.repo;
    
    install_packages
    
    echo "Installation completed successfully."


    # RHEL9
    # dnf config-manager --set-enabled crb;        # EL9
    # dnf -y config-manager --set-enabled crb; #RHEL9
    # crb enable;

    # dnf install https://www.elrepo.org/elrepo-release-9.el9.elrepo.noarch.rpm -y; # For RHEL-9
    # dnf --enablerepo=elrepo-kernel install kernel-ml -y;
    # sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=0/' /etc/default/grub;
    # grub2-mkconfig -o /boot/grub2/grub.cfg;
    # dnf install -y ansible;

fi





#####################################################
# Install slurm master
#####################################################



if [ ! -f /etc/munge/munge.key ]; then
    # Add global users
    export MUNGE_ID=994
    export SLURM_ID=1001
    groupadd -g $MUNGE_ID munge
    useradd  -m -c "MUNGE Uid 'N' Gid Emporium" -d /var/lib/munge -u $MUNGE_ID -g munge  -s /sbin/nologin munge
    groupadd -g $SLURM_ID slurm
    useradd  -m -c "Slurm workload manager" -d /var/lib/slurm -u $SLURM_ID -g slurm  -s /bin/bash slurm
    cp /usr/lib/systemd/system/munge.service /etc/systemd/system/munge.service
    sed -i 's/ExecStart=\/usr\/sbin\/munged/ExecStart=\/usr\/sbin\/munged --num-threads 10/' /etc/systemd/system/munge.service
    /usr/sbin/create-munge-key
    scp /etc/munge/munge.key login:/etc/munge
    scp /etc/munge/munge.key database:/etc/munge
    scp /etc/munge/munge.key compute:/etc/munge
    scp /etc/munge/munge.key login:/etc/munge
    scp /etc/munge/munge.key database:/etc/munge
    scp /etc/munge/munge.key compute:/etc/munge
fi



if [ ! -f /etc/slurm/slurm.conf ]; then

    # Slurm Conf
    cat <<EOF > /etc/slurm/slurm.conf
#CommunicationParameters=EnableIPv6
#SrunPortRange=60001-63000

SchedulerPort=7321

# SPECIAL PURPOSE NODES
NodeName=extra,database

# COMPUTE NODES
NodeName=compute RealMemory=1700 CPUs=4 State=UNKNOWN
PartitionName=debug Nodes=compute Default=YES MaxTime=0-00:30:00 State=UP DefaultTime=0-00:10:00


DefMemPerCPU=20
MaxMemPerCPU=50


# See the slurm.conf man page for more information.
#
ControlMachine=head
ControlAddr=192.168.56.10

AuthType=auth/munge
CryptoType=crypto/munge
MailProg=/usr/bin/mail

MpiDefault=pmix
MpiParams=ports=12000-12999

ProctrackType=proctrack/cgroup
PrologFlags=contain
TaskPlugin=affinity,cgroup

LaunchParameters=send_gids
RebootProgram=/sbin/reboot
ReturnToService=1

SlurmctldPidFile=/var/run/slurm/slurmctld.pid
SlurmctldPort=6817

SlurmdPidFile=/var/run/slurm/slurmd.pid
SlurmdPort=6818

SlurmdSpoolDir=/var/spool/slurm/slurmd
SlurmUser=slurm

SlurmdLogFile=/var/log/slurm/slurmd.log
StateSaveLocation=/var/spool/slurm/slurmctld

SwitchType=switch/none

UsePAM=1
#
#
# TIMERS
InactiveLimit=0
KillWait=30
MinJobAge=300
SlurmctldTimeout=120
SlurmdTimeout=300
Waittime=0
#
#
# SCHEDULING
SchedulerType=sched/backfill
SelectType=select/cons_tres
SelectTypeParameters=CR_Core_Memory
#
#
# JOB PRIORITY
#
PriorityType=priority/multifactor
PriorityDecayHalfLife=7-0
PriorityFavorSmall=NO
PriorityMaxAge=10-0
PriorityWeightAge=100000
PriorityWeightFairshare=1000000
PriorityWeightJobSize=100000
PriorityWeightPartition=100000
PriorityWeightQOS=100000

PropagateResourceLimitsExcept=MEMLOCK
PriorityFlags=ACCRUE_ALWAYS,FAIR_TREE
AccountingStorageEnforce=associations,limits,qos,safe


# LOGGING AND ACCOUNTING
AccountingStorageHost=database
AccountingStoragePort=6819
AccountingStorageType=accounting_storage/slurmdbd
AccountingStorageUser=slurm
AccountingStoreJobComment=YES
ClusterName=cluster

JobCompType=jobcomp/none
JobAcctGatherFrequency=30
JobAcctGatherType=jobacct_gather/none

SlurmctldLogFile=/var/log/slurm/slurmctld.log

DebugFlags=backfill,cpu_bind,priority,reservation,selecttype,steps,NO_CONF_HASH
SlurmctldDebug=info
SlurmdDebug=verbose
EOF
    echo "Slurm.conf written"
    # sudo scp /etc/slurm/slurm.conf head:/etc/slurm/slurm.conf
    sudo scp /etc/slurm/slurm.conf database:/etc/slurm/slurm.conf
    sudo scp /etc/slurm/slurm.conf compute:/etc/slurm/slurm.conf
fi

SERVICES=(
    munge.service
    slurmctld.service
)

if systemctl is-active --quiet "${SERVICES[1]}"; then
    echo ""${SERVICES[1]}" is running."
else
    if systemctl is-failed --quiet "${SERVICES[1]}"; then
        if [ -f /etc/slurm/slurm.conf ]; then
            # Correct perms
            mkdir -p /var/spool/slurm/slurmctld
            chown slurm: /var/spool/slurm/slurmctld
            chmod 755 /var/spool/slurm/slurmctld
            touch /var/log/slurm/slurmctld.log
            chown slurm: /var/log/slurm/slurmctld.log
            touch /var/log/slurm/slurm_jobacct.log /var/log/slurm/slurm_jobcomp.log
            chown slurm: /var/log/slurm/slurm_jobacct.log /var/log/slurm/slurm_jobcomp.log
        fi 
        
        # Take additional actions here, e.g., restart the service or send a notification
        systemctl enable "${SERVICES[@]}"
        systemctl restart "${SERVICES[@]}"
        echo "$(systemctl status "${SERVICES[1]}")"
    else
        echo ""${SERVICES[1]}" is not running but has not failed (e.g., stopped)."
    fi
fi

# Check sinfo works
sinfo




#----------------------------------------------------------
# Once your vagrant machines are up
#         Both Machines
# Edit slurm.conf at the last line to update NodeName=server1 from localhost

#         Server1 Machine
# sudo dnf install slurm-pam_slurm 

#         Controller Machine Set Up

# sudo /usr/sbin/create-munge-key
# sudo scp /etc/munge/munge.key vagrant@server1:/home/vagrant/


#         Server1 Machine Set Up
# sudo cp ~/munge.key /etc/munge
# sudo chown munge /etc/munge/munge.key

#         Both Machines
# sudo systemctl enable munge.service
# sudo systemctl start munge.service

#         Controller Machine
# sudo systemctl enable slurmctld.service
# sudo systemctl start slurmctld.service

#         Server1 Machine
# sudo systemctl enable slurmd.service
# sudo systemctl start slurmd.service
# sudo su 
# echo "UsePAM yes" >> /etc/ssh/sshd_config
# echo -e "root\nwheel" >> /etc/pam.d/allowed_ssh_groups
# cd /etc/pam.d
# vi sshd
# # Add these lines after line
# # line in file sshd: account    required     pam_nologin.so
# #------------------------------------
# account sufficient pam_listfile.so item=group sense=allow file=/etc/pam.d/allowed_ssh_groups onerr=fail
# -account required pam_slurm.so
# #------------------------------------

#         Controller Machine
# sudo scontrol reconfig
#----------------------------------------------------------
