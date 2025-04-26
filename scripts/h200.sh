#!/bin/bash
#PBS -q rt_HF
#PBS -l select=2:ncpus=384:ngpus=32:mpiprocs=192
#PBS -N ft_imnet1k
#PBS -l walltime=06:30:00
#PBS -P gcc50533
#PBS -j oe
#PBS -V
#PBS -koed
#PBS -o output/

# cat $JOB_SCRIPT
echo "ABCI 3.0 ..................................................................................."
JOB_ID=$(echo "${PBS_JOBID}" | cut -d '.' -f 1)
echo "JOB ID: ---- >>>>>>  $JOB_ID"

# ========= Get local Directory ======================================================
# cd $PBS_O_WORKDIR
pwd -LP
# ======== Modules and Python on main .configure.sh ==================================
source ./config.sh
######################################################################################
# ========== For MPI

echo "######################### START ########################################"
# cat scripts/hinadori.sh

echo "______Start Computing_________"
start_time=$(date +%s%3N)

. scripts/mpi_launch.sh

echo "This experiment Duration: ${imsize}x${imsize} "
convert_milliseconds "$total_duration"
echo "______Finish_________"
echo "                   "
## Debuggin purposes???
echo "code=$?"