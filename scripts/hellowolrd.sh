#!/bin/bash

# print all arguments passed to the script
echo -e "\e[34mArguments passed to the script: $@\e[0m"
# Check if the script is being run with the correct number of arguments
if [ "$#" -lt 1 ]; then
    echo -e "\e[31mError: At least one argument (SEED) is required.\e[0m"
    echo -e "\e[33mUsage: $0 <SEED> [<OUTPUT_DIR>]\e[0m"
    exit 1
fi


# Global variables for the seed and output directory
SEED=${1:-0}  # Default to 0 if no argument is provided
OUTPUT_DIR=${2:-outputs/default}  # Default to "outputs/default" if no argument is provided

# Print the SEED and OUTPUT_DIR values
echo -e "\e[34mSEED passed to the script: $SEED\e[0m"
echo -e "\e[34mOutput directory: $OUTPUT_DIR\e[0m"

# Ensure the OUTPUT_DIR exists
if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
    echo -e "\e[34mCreated output directory: $OUTPUT_DIR\e[0m"
fi

# Use $OUTPUT_DIR for all output paths
CURRENT_DATE=$(date +"%Y-%m-%d_%H-%M-%S")
OUTPUT_FOLDER="${OUTPUT_DIR}/hello_world_${CURRENT_DATE}_${SEED}"

# Ensure the OUTPUT_FOLDER exists
if [ ! -d "$OUTPUT_FOLDER" ]; then
    mkdir -p "$OUTPUT_FOLDER"
    echo -e "\e[34mCreated output folder: $OUTPUT_FOLDER\e[0m"
fi

# Function to format time in hh:mm:ss
format_time() {
    local total_seconds=$1
    printf "%02d:%02d:%02d" $((total_seconds / 3600)) $(((total_seconds % 3600) / 60)) $((total_seconds % 60))
}

# Function to generate a scene layout
generate_scene_layout() {
    local start_time=$(date +%s)
    python -m infinigen_examples.generate_nature --seed $SEED --task coarse -g desert.gin simple.gin --output_folder ${OUTPUT_FOLDER}/coarse
    if [ $? -ne 0 ]; then
        echo -e "\e[31mError: Failed to generate a scene layout\e[0m"
        return 1  # Indicate failure
    fi
    local end_time=$(date +%s)
    time_generate_scene_layout=$((end_time - start_time))
    echo -e "\e[32mSuccess: Scene layout generated successfully in $(format_time $time_generate_scene_layout)\e[0m"
    return 0  # Indicate success
}

# Function to populate unique assets
populate_unique_assets() {
    local start_time=$(date +%s)
    python -m infinigen_examples.generate_nature --seed $SEED --task populate fine_terrain -g desert.gin simple.gin --input_folder ${OUTPUT_FOLDER}/coarse --output_folder ${OUTPUT_FOLDER}/fine
    if [ $? -ne 0 ]; then
        echo -e "\e[31mError: Failed to populate unique assets\e[0m"
        return 1  # Indicate failure
    fi
    local end_time=$(date +%s)
    time_populate_unique_assets=$((end_time - start_time))
    echo -e "\e[32mSuccess: Unique assets populated successfully in $(format_time $time_populate_unique_assets)\e[0m"
    return 0  # Indicate success
}

# Function to render RGB images
render_rgb_images() {
    local start_time=$(date +%s)
    python -m infinigen_examples.generate_nature --seed $SEED --task render -g desert.gin simple.gin --input_folder ${OUTPUT_FOLDER}/fine --output_folder ${OUTPUT_FOLDER}/frames
    if [ $? -ne 0 ]; then
        echo -e "\e[31mError: Failed to render RGB images\e[0m"
        return 1  # Indicate failure
    fi
    local end_time=$(date +%s)
    time_render_rgb_images=$((end_time - start_time))
    echo -e "\e[32mSuccess: RGB images rendered successfully in $(format_time $time_render_rgb_images)\e[0m"
    return 0  # Indicate success
}

# Function to render accurate ground-truth
render_accurate_ground_truth() {
    local start_time=$(date +%s)
    python -m infinigen_examples.generate_nature --seed $SEED --task render -g desert.gin simple.gin --input_folder ${OUTPUT_FOLDER}/fine --output_folder ${OUTPUT_FOLDER}/frames -p render.render_image_func=@flat/render_image
    if [ $? -ne 0 ]; then
        echo -e "\e[31mError: Failed to render accurate ground-truth\e[0m"
        return 1  # Indicate failure
    fi
    local end_time=$(date +%s)
    time_render_accurate_ground_truth=$((end_time - start_time))
    echo -e "\e[32mSuccess: Accurate ground-truth rendered successfully in $(format_time $time_render_accurate_ground_truth)\e[0m"
    return 0  # Indicate success
}


# Main script execution
if generate_scene_layout; then
    if populate_unique_assets; then
        if render_rgb_images; then
            if render_accurate_ground_truth; then
                echo -e "\e[32mAll steps completed successfully!\e[0m"
            else
                echo -e "\e[33mStopping due to failure in render_accurate_ground_truth...\e[0m"
            fi
        else
            echo -e "\e[33mStopping due to failure in render_rgb_images...\e[0m"
        fi
    else
        echo -e "\e[33mStopping due to failure in populate_unique_assets...\e[0m"
    fi
else
    echo -e "\e[33mStopping due to failure in generate_scene_layout...\e[0m"
fi


# Filepath for the summary log
SUMMARY_LOG="${OUTPUT_DIR}/execution_summary.log"

# Append the summary to the log file
{
    echo -e "\n\e[34mExecution Time Summary for SEED - MPI Process : $SEED\e[0m"
    echo -e "- Scene Layout Generation: $(format_time $time_generate_scene_layout)"
    echo -e "- Populate Unique Assets: $(format_time $time_populate_unique_assets)"
    echo -e "- Render RGB Images: $(format_time $time_render_rgb_images)"
    echo -e "- Render Accurate Ground-Truth: $(format_time $time_render_accurate_ground_truth)"
} >> "$SUMMARY_LOG"

echo -e "\e[34mSummary for SEED (MPI Process) $SEED has been written to $SUMMARY_LOG\e[0m"