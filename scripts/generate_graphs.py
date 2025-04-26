import re
import matplotlib.pyplot as plt
import numpy as np
import argparse
import os
from matplotlib.ticker import FuncFormatter
import glob
from PIL import Image

# Parse command-line arguments
parser = argparse.ArgumentParser(description="Generate graphs from execution summary logs.")
parser.add_argument("--input_dir", type=str, required=True, help="Path to the input directory containing the log file.")
args = parser.parse_args()

# Filepath for the summary log
log_file = os.path.join(args.input_dir, "execution_summary.log")

# Data storage
seeds = []
scene_layout_times = []
populate_assets_times = []
render_rgb_times = []
render_ground_truth_times = []

# Function to convert hh:mm:ss to seconds
def time_to_seconds(time_str):
    h, m, s = map(int, time_str.split(":"))
    return h * 3600 + m * 60 + s

# Function to convert seconds to hh:mm:ss
def seconds_to_human_readable(seconds):
    h = seconds // 3600
    m = (seconds % 3600) // 60
    s = seconds % 60
    return f"{h:02}:{m:02}:{s:02}"

# Custom formatter for the y-axis
def format_y_axis(seconds, _):
    return seconds_to_human_readable(int(seconds))

# Parse the log file
with open(log_file, "r") as file:
    for line in file:
        # Extract SEED
        seed_match = re.search(r"Execution Time Summary for SEED - MPI Process : (\d+)", line)
        if seed_match:
            seeds.append(int(seed_match.group(1)))

        # Extract times
        time_match = re.search(r"Scene Layout Generation: (\d+:\d+:\d+)", line)
        if time_match:
            scene_layout_times.append(time_to_seconds(time_match.group(1)))

        time_match = re.search(r"Populate Unique Assets: (\d+:\d+:\d+)", line)
        if time_match:
            populate_assets_times.append(time_to_seconds(time_match.group(1)))

        time_match = re.search(r"Render RGB Images: (\d+:\d+:\d+)", line)
        if time_match:
            render_rgb_times.append(time_to_seconds(time_match.group(1)))

        time_match = re.search(r"Render Accurate Ground-Truth: (\d+:\d+:\d+)", line)
        if time_match:
            render_ground_truth_times.append(time_to_seconds(time_match.group(1)))

# Ensure SEED values are sorted from 0 to 11
sorted_indices = np.argsort(seeds)
seeds = np.array(seeds)[sorted_indices]
scene_layout_times = np.array(scene_layout_times)[sorted_indices]
populate_assets_times = np.array(populate_assets_times)[sorted_indices]
render_rgb_times = np.array(render_rgb_times)[sorted_indices]
render_ground_truth_times = np.array(render_ground_truth_times)[sorted_indices]

# Calculate the maximum y-axis value across all metrics
max_y_value = max(
    max(scene_layout_times),
    max(populate_assets_times),
    max(render_rgb_times),
    max(render_ground_truth_times),
)

# Create a single figure with subplots
fig, axs = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle("Execution Time Metrics per SEED (MPI Process)", fontsize=16)

# Apply the custom formatter to each subplot
formatter = FuncFormatter(format_y_axis)

# Function to add values on top of bars (vertically)
def add_values_on_bars(ax, bars):
    for bar in bars:
        height = bar.get_height()
        ax.text(
            bar.get_x() + bar.get_width() / 2.0,  # X position
            height,  # Y position
            seconds_to_human_readable(int(height)),  # Text (formatted as hh:mm:ss)
            ha="center", va="bottom", rotation=90, fontsize=8  # Vertical alignment
        )

# Scene Layout Generation
bars = axs[0, 0].bar(seeds, scene_layout_times, color="skyblue")
axs[0, 0].set_title("Scene Layout Generation")
axs[0, 0].set_xlabel("SEED (MPI Process)")
axs[0, 0].set_ylabel("Execution Time (hh:mm:ss)")
axs[0, 0].yaxis.set_major_formatter(formatter)
axs[0, 0].set_ylim(0, max_y_value)  # Set the same y-axis limit
axs[0, 0].grid(axis="y")
add_values_on_bars(axs[0, 0], bars)  # Add values on top of bars

# Populate Unique Assets
bars = axs[0, 1].bar(seeds, populate_assets_times, color="lightgreen")
axs[0, 1].set_title("Populate Unique Assets")
axs[0, 1].set_xlabel("SEED (MPI Process)")
axs[0, 1].set_ylabel("Execution Time (hh:mm:ss)")
axs[0, 1].yaxis.set_major_formatter(formatter)
axs[0, 1].set_ylim(0, max_y_value)  # Set the same y-axis limit
axs[0, 1].grid(axis="y")
add_values_on_bars(axs[0, 1], bars)  # Add values on top of bars

# Render RGB Images
bars = axs[1, 0].bar(seeds, render_rgb_times, color="salmon")
axs[1, 0].set_title("Render RGB Images")
axs[1, 0].set_xlabel("SEED (MPI Process)")
axs[1, 0].set_ylabel("Execution Time (hh:mm:ss)")
axs[1, 0].yaxis.set_major_formatter(formatter)
axs[1, 0].set_ylim(0, max_y_value)  # Set the same y-axis limit
axs[1, 0].grid(axis="y")
add_values_on_bars(axs[1, 0], bars)  # Add values on top of bars

# Render Accurate Ground-Truth
bars = axs[1, 1].bar(seeds, render_ground_truth_times, color="gold")
axs[1, 1].set_title("Render Accurate Ground-Truth")
axs[1, 1].set_xlabel("SEED (MPI Process)")
axs[1, 1].set_ylabel("Execution Time (hh:mm:ss)")
axs[1, 1].yaxis.set_major_formatter(formatter)
axs[1, 1].set_ylim(0, max_y_value)  # Set the same y-axis limit
axs[1, 1].grid(axis="y")
add_values_on_bars(axs[1, 1], bars)  # Add values on top of barslue)  # Set the same y-axis limit
axs[1, 1].grid(axis="y")

# Adjust layout and save the figure
plt.tight_layout(rect=[0, 0, 1, 0.96])  # Leave space for the main title
output_graph_path = os.path.join(args.input_dir, "execution_time_metrics_combined.png")
plt.savefig(output_graph_path)
# plt.show()

print(f"Combined graph has been generated and saved to {output_graph_path}.")

# Calculate the worst (maximum) time for each function
worst_times = {
    "Scene Layout Generation": max(scene_layout_times),
    "Populate Unique Assets": max(populate_assets_times),
    "Render RGB Images": max(render_rgb_times),
    "Render Accurate Ground-Truth": max(render_ground_truth_times),
}

# Calculate the total worst time
total_worst_time = sum(worst_times.values())

# Create a new figure for the worst times graph
fig, ax = plt.subplots(figsize=(8, 6))
bars = ax.bar(worst_times.keys(), worst_times.values(), color=["skyblue", "lightgreen", "salmon", "gold"])
ax.set_title("Worst Execution Time for Each Function")
ax.set_ylabel("Execution Time (hh:mm:ss)")
ax.yaxis.set_major_formatter(formatter)  # Apply the custom formatter to display hh:mm:ss
ax.grid(axis="y")

# Add values and execution ratios on top of the bars
for i, (label, value) in enumerate(worst_times.items()):
    ratio = (value / total_worst_time) * 100  # Calculate the ratio as a percentage
    ax.text(
        i, value, f"{seconds_to_human_readable(value)}\n({ratio:.1f}%)",  # Text with time and ratio
        ha="center", va="bottom", fontsize=10, rotation=90
    )

# Save the worst times graph
worst_times_graph_path = os.path.join(args.input_dir, "worst_execution_times.png")
plt.tight_layout()
plt.savefig(worst_times_graph_path)
# plt.show()

print(f"Worst execution times graph has been generated and saved to {worst_times_graph_path}.")


# Calculate the worst (maximum) time for each function
worst_times = {
    "Scene Layout Generation": max(scene_layout_times),
    "Populate Unique Assets": max(populate_assets_times),
    "Render RGB Images": max(render_rgb_times),
    "Render Accurate Ground-Truth": max(render_ground_truth_times),
}

# Calculate the total worst time
total_worst_time = sum(worst_times.values())

# Create a new figure for the combined worst time graph
fig, ax = plt.subplots(figsize=(8, 6))

# Define colors for each function
colors = ["skyblue", "lightgreen", "salmon", "gold"]

# Create a stacked bar chart
bottom = 0
for (label, value), color in zip(worst_times.items(), colors):
    bars = ax.bar(
        ["Total Execution Time"], [value], bottom=bottom, color=color, label=label
    )
    # Add the execution time on top of each segment
    for bar in bars:
        height = bar.get_height()
        ax.text(
            bar.get_x() + bar.get_width() / 2.0,  # X position
            bottom + height / 2.0,  # Y position (center of the segment)
            seconds_to_human_readable(int(height)),  # Text (formatted as hh:mm:ss)
            ha="center", va="center", fontsize=10  # Center alignment
        )
    bottom += value  # Update the bottom for the next segment

# Add total time on top of the figure
ax.text(
    0, bottom + 500,  # Position slightly above the bar
    f"Total: {seconds_to_human_readable(total_worst_time)}",  # Total time text
    ha="center", va="bottom", fontsize=12, fontweight="bold", color="black"
)

# Add title, labels, and legend
ax.set_title("Total Worst Execution Time (Stacked by Function)")
ax.set_ylabel("Execution Time (hh:mm:ss)")
ax.yaxis.set_major_formatter(formatter)  # Apply the custom formatter to display hh:mm:ss
ax.grid(axis="y")
ax.legend(loc="upper right")


# Save the combined worst time graph
stacked_worst_time_graph_path = os.path.join(args.input_dir, "stacked_worst_execution_time.png")
plt.tight_layout()
plt.savefig(stacked_worst_time_graph_path)
# plt.show()

print(f"Stacked worst execution time graph has been generated and saved to {stacked_worst_time_graph_path}.")


##################### Print a grid with all examples #####################
## Generalized path to include all MPI processes
job_id = os.path.basename(args.input_dir)  # Extract the job ID from the input directory
base_path = os.path.join(args.input_dir, f"hello_world_*")
process_paths = glob.glob(base_path)  # Find all directories matching the pattern

# Iterate over all MPI process directories and collect images
all_images = []
image_labels = []  # To store the MPI process names for each image
for process_path in process_paths:
    image_dir = os.path.join(process_path, "frames/Image/camera_0/")
    if os.path.exists(image_dir):
        image_files = glob.glob(os.path.join(image_dir, "*.png"))
        process_name = os.path.basename(process_path)  # Extract the MPI process name
        for image_file in image_files:
            all_images.append(image_file)
            image_labels.append(process_name)  # Associate the process name with the image

# Sort the images and labels for consistent ordering
sorted_images_and_labels = sorted(zip(all_images, image_labels))
all_images, image_labels = zip(*sorted_images_and_labels)

# Define the grid size for the image grid
grid_size = int(len(all_images) ** 0.5) + 1  # Square root of the number of images, rounded up

# Create a figure for the image grid
fig, axs = plt.subplots(grid_size, grid_size, figsize=(12, 12))

# Flatten the axes array for easier indexing
axs = axs.flatten()

# Loop through the images and add them to the grid
for i, (image_file, label) in enumerate(zip(all_images, image_labels)):
    # Open Image
    img = Image.open(image_file)

    # Display the image in the corresponding subplot
    axs[i].imshow(img)
    axs[i].axis("off")  # Turn off the axis for better visualization
    axs[i].set_title(f'MPI process: {i}', fontsize=8)  # Add the MPI process name as the title

# Turn off any remaining empty subplots
for j in range(len(all_images), len(axs)):
    fig.delaxes(axs[j])  # Remove the empty subplot

# Adjust layout and save the figure
output_image_grid_path = os.path.join(args.input_dir, f"all_images_grid.png")
plt.tight_layout()
plt.savefig(output_image_grid_path)
# plt.show()

print(f"Image grid for all MPI processes has been generated and saved to {output_image_grid_path}.")

