#!/bin/bash

# Exit immediately if a command exits with a non-zero status,
# treat unset variables as an error, and prevent errors in a pipeline from being masked.
set -euo pipefail

echo "🔹 Job started on $(hostname) at $(date)"

# Initialize Conda and activate the 'sratools_env' environment
source /opt/miniconda3/etc/profile.d/conda.sh
conda activate sratools_env

# Define the list of SRA projects to process
projects=("PRJNA987406" "PRJNA1124177" "PRJNA985099")

# Set the output directory where the FASTQ files will be stored
output_dir="/home/user1/transcot/DATA/raw"
mkdir -p "${output_dir}"

# Set the temporary directory to store the downloaded .sra files
temp_dir="/home/user1/transcot/DATA/data/tmp"
mkdir -p "${temp_dir}"

# Function to clean up temporary files at the end of the script
cleanup_temp() {
    echo "Cleaning up temporary files..."
    rm -rf "${temp_dir:?}/"*
}
# Ensure that temporary files are removed on script exit, even if an error occurs
trap cleanup_temp EXIT

# Loop through each project in the projects list
for project in "${projects[@]}"; do
    echo "Processing project: ${project}"
    
    # Retrieve the run information (CSV format) for the current project from NCBI SRA
    runinfo=$(esearch -db sra -query "${project}" | efetch -format runinfo)
    
    # Save the run information to a CSV file for verification or debugging purposes
    echo "${runinfo}" > "${temp_dir}/${project}_runinfo.csv"
    
    # Extract the run IDs (SRR identifiers) from the CSV output, skipping the header row
    run_ids=$(echo "${runinfo}" | awk -F, 'NR>1 {print $1}')
    
    # Loop through each extracted run ID and process it
    for run in ${run_ids}; do
        echo "Downloading run: ${run}"
        
        # Download the .sra file into the temporary directory using prefetch
        if prefetch "${run}" --output-directory "${temp_dir}"; then
            echo "Converting run: ${run} to FASTQ format"
            # Convert the downloaded .sra file to FASTQ format using fasterq-dump
            # --split-files splits paired-end reads into separate files
            fasterq-dump --split-files "${temp_dir}/${run}/${run}.sra" -O "${output_dir}"
            # Remove the temporary files for the current run to free up space
            rm -rf "${temp_dir:?}/${run}"
        else
            echo "Download failed for ${run}. Skipping to the next run." >&2
        fi
    done
done

# Deactivate the Conda environment
conda deactivate

echo "Download, conversion, and cleanup completed."