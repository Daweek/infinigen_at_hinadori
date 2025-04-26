#!/bin/bash
# filepath: /home/edgar/working/synthetic_data/infinigen/scripts/mpi_launch.sh

# Determine the maximum number of processes based on available CPU cores
NUM_PROCESSES=$(nproc)
echo -e "Number of available CPU cores: ${NUM_PROCESSES}"

# Path to the hellowolrd.sh script
SCRIPT_PATH="./scripts/hellowolrd.sh"

# Get the job's process ID
JOB_ID=${SLURM_JOB_ID:-$$}  # Use SLURM_JOB_ID if available, otherwise use the script's process ID

# Create a unique output directory based on the job's process ID
OUTPUT_DIR="rendering/job_${JOB_ID}"
if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
    echo -e "\e[34mCreated output directory: $OUTPUT_DIR\e[0m"
else
    echo -e "\e[34mOutput directory already exists: $OUTPUT_DIR\e[0m"
fi

# Check if the script exists
if [ ! -f "$SCRIPT_PATH" ]; then
    echo -e "\e[31mError: Script $SCRIPT_PATH not found!\e[0m"
    exit 1
fi

# Launch the MPI processes directly with a unique seed for each process
echo -e "\e[34mLaunching $NUM_PROCESSES MPI processes to execute $SCRIPT_PATH with unique seeds...\e[0m"
mpirun --use-hwthread-cpus --oversubscribe -np $NUM_PROCESSES bash -c ". $SCRIPT_PATH \$OMPI_COMM_WORLD_RANK $OUTPUT_DIR"

# Check if mpirun executed successfully
if [ $? -eq 0 ]; then
    echo -e "\e[32mMPI processes completed successfully!\e[0m"
else
    echo -e "\e[31mError: MPI processes failed!\e[0m"
fi

# Generate graphs using the JOB_ID folder as input
python ./scripts/generate_graphs.py --input_dir "$OUTPUT_DIR"
if [ $? -eq 0 ]; then
    echo -e "\e[32mGraphs generated successfully!\e[0m"
else
    echo -e "\e[31mError: Failed to generate graphs!\e[0m"
fi

echo -e "\e[34mAll tasks completed!->>>>> By Edg@r J.\e[0m"
