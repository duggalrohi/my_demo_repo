
# Welcome to the MPI 
## Debug Errors

Source: 
Follow this implementation of [slurm-ssh-node-proxycommand](https://github.com/AaltoSciComp/slurm-ssh-node-proxycommand/blob/main/slurm-ssh-node-proxycommand).

!!! example "slurm ssh node proxycommand"
  
    === "slurm-ssh-node-proxycommand"

        ``` bash
        
        cat > /nfs/home/$USER/slurm-ssh-node-proxycommand <<EOW
        #!/bin/bash

        JOBID=$(sbatch --output=/dev/null --error=/dev/null -J shell-proxycommand --wrap="sleep 32000000" --parsable "$@")
        ret=$?
        if [ $ret -ne 0 ];then
            exit $ret
        fi

        trap "{ scancel --quiet $JOBID ; exit ; }" SIGINT SIGTERM EXIT

        while true ; do
            sleep 1
            state=$(squeue -j $JOBID -O State --noheader)
            #echo "'$state'" > /dev/stderr
            case $state in
                RUNNING*)
                    #echo "running" > /dev/stderr
                    break
                    ;;
                PENDING*|CONFIGURING*)
                    #echo "waiting: $state" > /dev/stderr
                    ;;
                *)
                    echo "Failed: unknown job state \"$state\"" > /dev/stderr
                    exit 1
                    ;;
            esac
        done

        # Can't exec, since then the job won't be cancelled when done.
        node=$(squeue -j $JOBID -O NodeList --noheader)
        nc $node 22
        # TODO: SLURM_JOB_ID is set in the proxied SSH job, it's hard for us
        # to control that from here.
        EOW
        ```

    === "~/.ssh/config"

        ``` bash
        cat > /etc/systemd/system/user-.slice.d/10-defaults.conf <<EOW
        Host raapoivsc
            ProxyCommand ssh raapoi /nfs/home/duggalro/slurm-ssh-node-proxycommand --partition quicktest --time 0-00:10:00
            StrictHostKeyChecking no
            UserKnownHostsFile /dev/null
            User duggalro

        # You also need a cluster alias, unless you write the stuff directly
        # in ProxyCommand line ssh command above:

        Host *
            ForwardAgent yes
            ForwardX11 yes
            ForwardX11Trusted yes
            IdentityFile ~/.ssh/id_rsa
            AddKeysToAgent yes


        Host raapoi
            HostName raapoi.vuw.ac.nz
            User duggalro
        EOW

        ```

    === "ssh-copy-id"

        ``` bash
        user@personal:~$ ssh-copy-id -i ~/.ssh/id_rsa.pub user@raapoi.vuw.ac.nz

        # Now should be able to get to a compute node with vs code
        Connect to host > raapoivsc
        ```



