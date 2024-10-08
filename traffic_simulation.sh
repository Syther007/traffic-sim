#!/bin/bash

# traffic_simulation.sh - A script to download URLs from a list and generate statistics

# Usage: ./traffic_simulation.sh <url_list_file> [timeout] [max_retries] [proxy]
# <url_list_file>: Path to the text file containing a list of URLs to download.
# [timeout]: Optional. Timeout for each download in seconds. Default is 10 seconds.
# [max_retries]: Optional. Maximum number of retries for each download. Default is 3 retries.
# [proxy]: Optional. Proxy URL to use for downloads. Set to "none" to disable proxy. Default is https://127.0.0.1:443.
# [download_location]: Optional. Path to save downloaded content. Default is /dev/null.

# Examples:
# ./traffic_simulation.sh urls.txt
# ./traffic_simulation.sh urls.txt 15 5
# ./traffic_simulation.sh urls.txt 15 5 http://proxy.example.com:8080
# ./traffic_simulation.sh urls.txt 15 5 none

# Default values for timeout, max retries, and proxy
DEFAULT_TIMEOUT=10
DEFAULT_MAX_RETRIES=3
DEFAULT_PROXY="https://127.0.0.1:443"
DEFAULT_DOWNLOAD_LOCATION="/dev/null"

# Check if the input file is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <url_list_file> [timeout] [max_retries] [proxy]"
  exit 1
fi

URL_LIST_FILE=$1
TIMEOUT=${2:-$DEFAULT_TIMEOUT}
MAX_RETRIES=${3:-$DEFAULT_MAX_RETRIES}
PROXY=${4:-$DEFAULT_PROXY}
DOWNLOAD_LOCATION=${5:-$DEFAULT_DOWNLOAD_LOCATION}


# Check if the input file exists
if [ ! -f "$URL_LIST_FILE" ]; then
  echo "File not found: $URL_LIST_FILE"
  exit 1
fi

# Variables to hold total size and total time
total_size=0
total_time=0
urls_downloaded=0


# Function to download a URL and measure time and size
download_url() {
  local url=$1
  local curl_command="curl -L -s --max-time $TIMEOUT --retry $MAX_RETRIES -w '%{size_download} %{time_total}' -o $DOWNLOAD_LOCATION $url"

  # Add proxy settings if proxy is not set to "none"
  if [ "$PROXY" != "none" ]; then
    curl_command="curl -L -s --proxy $PROXY --max-time $TIMEOUT --retry $MAX_RETRIES -w '%{size_download} %{time_total}' -o $DOWNLOAD_LOCATION $url"
  fi

  # Use `curl` to download the file to /dev/null and measure the duration and size
  local output=$(eval $curl_command 2>&1)

  # Check if curl command was successful
  if [ $? -ne 0 ]; then
    echo "Error downloading URL: $url"
    return
  fi

  # Extract size and real time (in seconds)
  local size=$(echo "$output" | awk '{print $1}')
  local real_time=$(echo "$output" | awk '{print $2}')
  total_time=$(echo "$total_time + $real_time" | bc)

  total_size=$(echo "$total_size + $size" | bc)

  urls_downloaded=$((urls_downloaded + 1))
  echo "URL: $url"
  echo "Time: $real_time seconds"
  echo "Size: $size bytes"
  echo "Progress: $urls_downloaded/$total_urls URLs downloaded"
  echo
}

# # Function to download a URL and measure time and size
# download_url() {
#   local url=$1
#   local curl_command="curl -L -s -o /dev/null --max-time $TIMEOUT --retry $MAX_RETRIES $url"
#   # Add proxy settings if proxy is not set to "none"
#   if [ "$PROXY" != "none" ]; then
#     curl_command="curl -L -s -o /dev/null --proxy $PROXY --max-time $TIMEOUT --retry $MAX_RETRIES $url"
#   fi
#   # Use `curl` to download the file to /dev/null and `time` to measure the duration
#   local output=$( (time -p $curl_command) 2>&1 )
#   # Extract real time (in seconds)
#   local real_time=$(echo "$output" | grep real | awk '{print $2}')
#   total_time=$(echo "$total_time + $real_time" | bc)
#   # Use `curl` to get the size of the downloaded content
#   local size=$($curl_command -w '%{size_download}')
#   total_size=$(echo "$total_size + $size" | bc)
#   urls_downloaded=$((urls_downloaded + 1))
#   echo "URL: $url"
#   echo "Time: $real_time seconds"
#   echo "Size: $size bytes"
#   echo "Progress: $urls_downloaded/$total_urls URLs downloaded"
#   echo
# }

# Get the total number of URLs in the file
total_urls=$(wc -l < "$URL_LIST_FILE")

# Loop through each URL in the file
while IFS= read -r url; do
  download_url "$url"
done < "$URL_LIST_FILE"

# Convert total size to MB
total_size_mb=$(echo "scale=2; $total_size / 1048576" | bc)

# Print summary report
echo "Total size downloaded: $total_size_mb MB"
echo "Total time taken: $total_time seconds"
echo "Total URLs downloaded: $urls_downloaded"

