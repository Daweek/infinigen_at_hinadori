#!/bin/bash

# Global variable for the seed option
SEED=00

# Variables to store execution times
time_generate_scene_layout=0
time_populate_unique_assets=0
time_render_rgb_images=0
time_render_accurate_ground_truth=0

# Function to format time in hh:mm:ss
format_time() {
    local total_seconds=$1
    printf "%02d:%02d:%02d" $((total_seconds / 3600)) $(((total_seconds % 3600) / 60)) $((total_seconds % 60))
}

# Function to generate a scene layout
generate_scene_layout() {
    local start_time=$(date +%s)
    python -m infinigen_examples.generate_nature --seed $SEED --task coarse -g desert.gin simple.gin --output_folder outputs/hello_world/coarse
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
    python -m infinigen_examples.generate_nature --seed $SEED --task populate fine_terrain -g desert.gin simple.gin --input_folder outputs/hello_world/coarse --output_folder outputs/hello_world/fine
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
    python -m infinigen_examples.generate_nature --seed $SEED --task render -g desert.gin simple.gin --input_folder outputs/hello_world/fine --output_folder outputs/hello_world/frames
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
    python -m infinigen_examples.generate_nature --seed $SEED --task render -g desert.gin simple.gin --input_folder outputs/hello_world/fine --output_folder outputs/hello_world/frames -p render.render_image_func=@flat/render_image
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

# Summary of execution times
echo -e "\n\e[34mExecution Time Summary:\e[0m"
echo -e "\e[34m- Scene Layout Generation: $(format_time $time_generate_scene_layout)\e[0m"
echo -e "\e[34m- Populate Unique Assets: $(format_time $time_populate_unique_assets)\e[0m"
echo -e "\e[34m- Render RGB Images: $(format_time $time_render_rgb_images)\e[0m"
echo -e "\e[34m- Render Accurate Ground-Truth: $(format_time $time_render_accurate_ground_truth)\e[0m"