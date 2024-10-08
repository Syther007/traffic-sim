#!/bin/bash

# Specify the input file containing the URLs
input_file="urls.txt"

# Specify the output directory to save the downloaded files
output_dir="downloads"

# Set the timeout value (in seconds)
timeout=30

# Set the random delay range (in seconds)
min_delay=1
max_delay=5

# Set the maximum number of retries for each download
max_retries=3

# Set the simulate_download variable to control the download behavior
simulate_download=true


# Check if wget is installed
if ! command -v wget &> /dev/null; then
    echo "Error: wget is not installed. Please install wget to run this script."
    exit 1
fi


# Check if the output directory exists, create it if not
if [ ! -d "$output_dir" ]; then
    mkdir "$output_dir"
    echo "Output directory created."
else
    echo "Output directory already exists."
fi

# Create a timestamped log file
log_file=$(date +"%Y-%m-%d_%H-%M-%S").log
echo "Starting script execution at $(date)..." >> $log_file

# Initialize variables to track the total downloaded size and count
total_size=0
download_count=0


# Iterate through each URL in the input file
while IFS= read -r url; do
    # Extract the filename from the URL
    filename=$(basename -- "$url")

    # Get the base directory of the URL
    base_dir=$(dirname -- "$url")

    # Download the website assets using wget with a timeout, retries, and simulate_download
    if [ "$simulate_download" = true ]; then
        # wget --timeout="$timeout" --tries="$max_retries" --quiet -r -p -A "*.{html,pdf,doc,docx,txt,zip,jpg,jpeg,png,gif,bmp,css,js}" -O /dev/null "$url"
        wget -e use_proxy=yes -e https_proxy=127.0.0.1:443 --timeout="$timeout" --tries="$max_retries" -O /dev/null "$url"
    else
        wget -e use_proxy=yes -e https_proxy=127.0.0.1:443 --timeout="$timeout" --tries="$max_retries" --quiet -r -p -A "*.{html,pdf,doc,docx,txt,zip,jpg,jpeg,png,gif,bmp,css,js}" -O "$output_dir/$filename" "$url"
    fi

    # Calculate the total downloaded size
    if [ "$simulate_download" = false ]; then
        file_size=$(stat -c%s "$output_dir/$filename")
        total_size=$((total_size+file_size))
    fi
    download_count=$((download_count+1))
    echo "$(date) - Downloaded $url (size: ${file_size} bytes)" >> $log_file

    # Print a progress report
    progress=$(echo "scale=2; ($download_count / $(wc -l < "$input_file")) * 100" | bc -l)
    echo "$(date) - Progress: $progress% ($download_count/$(( $(wc -l < "$input_file") )))" >> $log_file

    # Add a random delay within the specified range
    sleep $((RANDOM % ($max_delay - $min_delay + 1) + $min_delay))
done < "$input_file"

# Calculate the total downloaded size in MB
total_size_mb=$(echo "$total_size / 1024 / 1024" | bc -l)

# Print the total downloaded size and count
echo "$(date) - Total downloaded size: ${total_size} bytes (approximately ${total_size_mb} MB)"
echo "$(date) - Total downloaded files: $download_count" >> $log_file

# Close the log file
echo "$(date) - Script execution completed." >> $log_file
