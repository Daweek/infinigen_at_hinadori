#!/bin/bash
#YBATCH -r threadripper-3960x_8
#SBATCH -N 1
#SBATCH -J InifiGen
#SBATCH --time=120:00:00
#SBATCH --output output/%j-t.out

## Pyenv loading
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv init --path)"
eval "$(pyenv virtualenv-init -)"

# My Routine to measure time
echo "Including extra util routines to measure time..."
convert_milliseconds() {
    local total_ms=$1

    # Calculate total seconds and remaining milliseconds
    local total_seconds=$(echo "$total_ms / 1000" | bc)
    local remaining_ms=$((total_ms % 1000))  # Remaining milliseconds

    # Calculate days, hours, minutes, and seconds using bc
    local days=$(echo "$total_seconds / 86400" | bc)
    local hours=$(echo "($total_seconds % 86400) / 3600" | bc)
    local minutes=$(echo "($total_seconds % 3600) / 60" | bc)
    local seconds=$(echo "$total_seconds % 60" | bc)

    # Print in D:H:M:S.ms format
    printf "%d days, %02d hours, %02d minutes, %02d seconds, %03d milliseconds\n" "$days" "$hours" "$minutes" "$seconds" "$remaining_ms"
}

## Modules
. /etc/profile.d/modules.sh
module purge
module load openmpi/4.0.5 cuda/11.8 cudnn/cuda-11.x/8.9.0 nccl/cuda-11.7/2.14.3

export PYTHONUNBUFFERED=1
export PYTHONWARNINGS="ignore"

echo "######################### START ########################################"
# cat scripts/hinadori.sh

echo "______Start Computing_________"
start_time=$(date +%s%3N)

. scripts/mpi_launch.sh

end_time=$(date +%s%3N)
total_duration=$((end_time - start_time))
times+=("$total_duration")

echo "This experiment Duration: ${imsize}x${imsize} "
convert_milliseconds "$total_duration"
echo "______Finish_________"
echo "                   "
## Debuggin purposes???
echo "code=$?"