#!/usr/bin/env bash

log_file="logs/lightCons_cron_log_$(date +%Y-%m-%d).log"    # Set the log file name
maxIterations=20000                                         # Set the number of iterations

allThreads=(
       "https://www.asite.com" 
       "https://icanhazip.com" 
       "https://cats.com"
       "https://cat.com"
       "https://fish.com"
       "https://www.dog.com"
       "https://api.ipify.org"
)


SUC=0;
FAL=0;
TOL=0;
ArrCnt=0;
totalDownloaded=0
currentIteration=0
start_time=$(date +%s)
total=$(expr ${#allThreads[@]} - 1)


# Create a log file and write the header information
{
    echo "Log File Created: $(date)"
    echo "Operating System: $(uname -s)"
    echo "Hostname: $(hostname)"
    echo "Local IP: $(hostname -I | awk '{print $1}')"
    echo "Public IP: $(curl -s https://icanhazip.com)"
    echo "----------------------------------------"
} > "$log_file"  # Only write header to log file

# Temporary file to capture stdout
temp_output=$(mktemp)

# Function to handle cleanup
cleanup() {
    # Calculate and log the total execution time
    end_time=$(date +%s)
    execution_time=$((end_time - start_time))  # Calculate elapsed time in seconds
    echo "Total Execution Time: $execution_time seconds"
    echo "Total Execution Time: $execution_time seconds" >> "$log_file"  # Log the execution time

    # Append the last 20 lines of the output to the log file
    {
        echo "----------------------------------------"
        echo "Last 20 lines of output:"
        tail -n 20 "$temp_output"
    } >> "$log_file"

    # Clean up the temporary output file
    rm "$temp_output"
}

# Set trap to call cleanup on EXIT
trap cleanup EXIT

while (( currentIteration < maxIterations ));
do
    # Use a temporary file to store the downloaded content
    tempFile=$(mktemp)

    if curl -x "127.0.0.1:443" --max-time 5 -s -w 'Request Code: %{http_code}\n' -o "$tempFile" ${allThreads[$ArrCnt]};
    then 
        ((SUC=SUC+1))
        # Calculate the size of the downloaded file in bytes and convert to MB
        downloadedSize=$(du -b "$tempFile" | cut -f1)
        totalDownloaded=$((totalDownloaded + downloadedSize))
    else 
        ((FAL=FAL+1))
    fi
    
    # Convert total downloaded size to MB
    totalDownloadedMB=$(echo "scale=2; $totalDownloaded/1024/1024" | bc)

    ((TOL=TOL+1))
    
    # Log the output to the temporary file and display it in the terminal
    {
        echo "Total: $TOL"
        echo "Success: $SUC"
        echo "Fault: $FAL"
        echo "Total Downloaded: ${totalDownloadedMB} MB"  # Display total downloaded in MB
    } | tee -a "$temp_output"  # Append output to the temporary file and display in terminal

    # Clean up the temporary file
    rm "$tempFile"

    ((currentIteration++))  # Increment the current iteration count
done 



cleanup()