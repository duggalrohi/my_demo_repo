
# Welcome to the SlurmStatus Setup 
## Slurm Job Status

 

!!! example "Jobs Status"
  
    === "show.sh"

        ``` bash
        
        cat > /nfs/home/$USER/show.sh <<EOW
        #!/bin/bash
        # Check if partition and job state are provided as arguments
        if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: $0 <partition> <job_state>"
        echo "Example: $0 gpu,bigmem R"
        exit 1
        fi

        PARTITION=$1
        JOB_STATE=$2

        squeue -p $PARTITION -t $JOB_STATE -O "JobId,UserName,tres-alloc:45" -h | awk '{
        # Extract fields
        user = $2
        split($3, tres, ",")  # Split TRES field by commas
        # Check if the number of fields is 4 (missing "gres/gpu"), add "gres/gpu=0" if true
        if (length(tres) == 4) {
            tres[length(tres)+1] = "gres/gpu=0"
        }
        # for (i in tres) print tres[i]
            # Initialize counters
            cpus = 0; mem = 0; gpus = 0; jobs = 0

            # Loop over each element in the TRES field
            for (i in tres) {
                if (tres[i] ~ /cpu=/) {
                    cpus += substr(tres[i], index(tres[i], "=")+1)
                }
                else if (tres[i] ~ /mem=/) {
                    mem_val = substr(tres[i], index(tres[i], "=")+1)
                    # Handle different memory units (K, M, G, T)
                    if (mem_val ~ /K$/) mem += mem_val + 0
                    else if (mem_val ~ /M$/) mem += (substr(mem_val, 1, length(mem_val)-1) * 1)
                    else if (mem_val ~ /G$/) mem += (substr(mem_val, 1, length(mem_val)-1) * 1024)
                    else if (mem_val ~ /T$/) mem += (substr(mem_val, 1, length(mem_val)-1) * 1024 * 1024)
                }
                else if (tres[i] ~ /gpu=/) {
                    gpus += substr(tres[i], index(tres[i], "=")+1)
                }
                else if (tres[i] ~ /node=/) {
                    nodes += substr(tres[i], index(tres[i], "=")+1)
                }
            }

            # Default to 1 node if node count is not explicitly specified
            if (jobs == 0) jobs = 1

            # Accumulate results per user
            user_jobs[user] += jobs
            total_cpus[user] += cpus
            total_mem[user] += mem
            total_gpus[user] += gpus

            # Accumulate grand totals
            grand_total_cpus += cpus
            grand_total_mem += mem
            grand_total_gpus += gpus
            grand_total_jobs += jobs
        }
        END {
            # Print results per user
            printf "%-10s %-10s %-10s %-10s %-10s\n", "User", "CPUs", "Memory(GB)", "GPUs", "Jobs"
            for (user in user_nodes) {
                printf "%-10s %-10d %-10.2f %-10d %-10d\n", user, total_cpus[user], total_mem[user] / 1024, total_gpus[user], user_jobs[user]
            }

            # Print grand totals
            printf "%-10s %-10s %-10s %-10s %-10s\n", "----------", "----------", "----------", "----------", "----------"
            printf "%-10s %-10d %-10.2f %-10d %-10d\n", "Total", grand_total_cpus, grand_total_mem / 1024, grand_total_gpus, grand_total_jobs
        }'
        EOW
        ```


    === "run"

        ``` bash
        user@personal:~$ bash show.sh partition R

        
        ```



