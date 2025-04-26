
<div align="center">
<img src="docs/images/infinigen.png" width="300"></img>
</div>

# [This is a main copy from the original repo to work on Hinadori.](https://infinigen.org)



## Getting Started

- Prepare env or conda or anything you like for **Python <= 3.11.x**
-   Update pip: pip install --upgrade pip

2.- Clone this repository: 
- git clone https://github.com/Daweek/infinigen_at_hinadori

3.- Install all the necessary depencies for Infingen by following command:

- pip install -e ".[terrain,vis]"

4.- Install additional dependencies:
- pip install pyopengl-accelerate pandas matplotlib

5.- Run the test script on ybatch or interactive node:

- yrun a6000_8
- . scripts/hinadori.sh

The **hinadori.sh** has been designed to use as much processors as the node have. It will be launch a MPI process on each thread. This is executed on the **mpi_launch.sh**. Feel free to play around and modify. 

The output file from MPI is delivered here: "output"

The synthetics images generated from InfiniGen are rendered here: "rendering/job_******"

On the same folder, I am drawing some metrics to a graphs:

- all_images_grid.png 
- execution_time_metrics_combined.png
- stacked_worst execution_time.png
- worst_execution_times.png

The code still is in development -> By Edo.