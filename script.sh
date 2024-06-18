#!/bin/bash

# Specify the input file containing the URLs
input_file="urls.txt"
# Specify the output directory to save the downloaded files
output_dir="downloads"
# Set the timeout value (in seconds)
timeout=30
# Set the random delay range (in seconds)
min_delay=5
max_delay=60
# Set the maximum number of retries for each download
max_retries=3
# Set the simulate_download variable to control the download behavior
simulate_download=true

# Check if the output directory exists, create it if not
if [ ! -d "$output_dir" ]; then
    mkdir "$output_dir"
fi

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
        wget --quiet --timeout="$timeout" --tries="$max_retries" -r -p -A "*.{html,pdf,doc,docx,txt,zip,jpg,jpeg,png,gif,bmp,css,js}" -O /dev/null "$url"
    else
        wget --quiet --timeout="$timeout" --tries="$max_retries" -r -p -A "*.{html,pdf,doc,docx,txt,zip,jpg,jpeg,png,gif,bmp,css,js}" -O "$output_dir/$filename" "$url"
    fi

    # Calculate the total downloaded size
    file_size=$(stat -c%s "$output_dir/$filename")
    total_size=$((total_size+file_size))
    download_count=$((download_count+1))
    echo "Downloaded $url (size: ${file_size} bytes)"
    # Print a progress report
    progress=$(echo "scale=2; ($download_count / $(wc -l < "$input_file")) * 100" | bc -l)
    echo "Progress: $progress% ($download_count/$(( $(wc -l < "$input_file") )))"
    # Add a random delay within the specified range
    sleep $((RANDOM % ($max_delay - $min_delay + 1) + $min_delay))
done < "$input_file"

# Calculate the total downloaded size in MB
total_size_mb=$(echo "$total_size / 1024 / 1024" | bc -l)

# Print the total downloaded size and count
echo "Total downloaded size: ${total_size} bytes (approximately ${total_size_mb} MB)"
echo "Total downloaded files: $download_count"