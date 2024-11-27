
# Welcome to the MPI 
## Debug Errors

!!! example "srun"
  
    === "submit.sl"

        ``` bash
         
        #!/bin/bash -x
        #SBATCH --job-name=helloworld_mpi
        ##SBATCH --mail-user="<your-email-address>"
        ##SBATCH --mail-type="ALL"
        #SBATCH --time=00:00:10
        #SBATCH --partition=parallel
        #SBATCH --output=%x_%j.out
        #SBATCH --nodes=2
        #SBATCH --ntasks=10
        #SBATCH --mem-per-cpu=1G
        #SBATCH --constraint="IB"

        # making sure we start with a clean module environment
        module purge

        echo "## Loading module"
        ml purge; ml gnu9/9.4.0 openmpi4/4.1.1 ohpc config; ml list
        # Compile program
        mpicc helloworld_mpi.c -o helloworld_mpi

        TEST_DIR=$(pwd)
        echo "## Current dircectory $TEST_DIR"

        echo "## Running test"
        #Failure: srun errors while mpirun does not
        #srun ./helloworld_mpi
        #Success: testing with mpi version specific, works
        srun --mpi=pmi2 ./helloworld_mpi
        #Success: alternative command, but not needed because srun takes care of it
        #mpirun -np $SLURM_NTASKS ./helloworld_mpi

        echo "## Test finished. Goodbye"
        ```

    === "Error"

        ``` bash
        --------------------------------------------------------------------------
        The application appears to have been direct launched using "srun",
        but OMPI was not built with SLURM's PMI support and therefore cannot
        execute. There are several options for building PMI support under
        SLURM, depending upon the SLURM version you are using:

        version 16.05 or later: you can use SLURM's PMIx support. This
        requires that you configure and build SLURM --with-pmix.

        Versions earlier than 16.05: you must use either SLURM's PMI-1 or
        PMI-2 support. SLURM builds PMI-1 by default, or you can manually
        install PMI-2. You must then build Open MPI using --with-pmi pointing
        to the SLURM PMI library location.

        Please configure as appropriate and try again.
        --------------------------------------------------------------------------

        ```

    === "Debug"

        ``` bash
        # Debug mpi
        OMPI_MCA_pmix_base_verbose=10 srun ./helloworld_mpi

        # Check mpi info
        ompi_info
        
        # Debug slurm
        SLURM_DEBUG=2 srun --export="NCCL_DEBUG=INFO,NCCL_IB_DISABLE=1,PMIX_MCA_gds=hash" 
            --mpi=pmix_v4 -N 1 --ntasks=1 -w amd01n01 ./helloworld_mpi
        
        # Verify mpi or pmix implementation
        srun --mpi=list
        
        # Run from login node
        SLURM_DEBUG=2 srun --export="NCCL_DEBUG=INFO,NCCL_IB_DISABLE=1,PMIX_MCA_gds=hash" 
            --mpi=pmix -N 1 --ntasks=1 -w amd01n01 ./helloworld_mpi

        ```

    === "helloworld_mpi.c"

        ``` c
        #include <stdio.h>
        #include <mpi.h>

        int main (int argc, char *argv[])
        {
        int i, rank, size, processor_name_len;
        char name [MPI_MAX_PROCESSOR_NAME];

        MPI_Init (&argc, &argv);

        MPI_Comm_size (MPI_COMM_WORLD, &size);
        MPI_Comm_rank (MPI_COMM_WORLD, &rank);
        MPI_Get_processor_name (name, &processor_name_len);

        printf ("Hello World from rank %03d out of %03d running on %s!\n", rank, size, name);

        if (rank == 0 )
            printf ("MPI World size = %d processes\n", size);

        MPI_Finalize ();
        return 0;
        }

        ```
