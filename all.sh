#!/bin/bash

# Define the scripts to be run as variables
script1="./test.sh"
script2="./traffic_simulation.sh url2.txt"
script3="./script.sh"


# Add the scripts to an array
scripts=("$script1" "$script2" "$script3")

# Configuration
loop_count=5          # Number of times to loop through the scripts
loop_sleep_time=10    # Time to sleep between loops in seconds
script_sleep_time=5   # Time to sleep between each script call in seconds

# Create log file with date in the name
log_file="run_multiple_scripts_$(date +%Y-%m-%d_%H-%M-%S).log"

# Function to log messages to both console and log file
log_message() {
    echo "$1" | tee -a "$log_file"
}

# Function to run scripts sequentially
run_scripts() {
    for script in "${scripts[@]}"; do
        eval "$script" >> "$log_file" 2>&1
        if [[ $? -eq 0 ]]; then
            log_message "Executed: $script"
        else
            log_message "Failed to execute: $script"
        fi
        log_message "Sleeping for $script_sleep_time seconds"
        sleep $script_sleep_time
    done
}

# Main loop
for ((i=1; i<=loop_count; i++)); do
    log_message "Loop $i of $loop_count"
    run_scripts
    if [[ $i -lt loop_count ]]; then
        log_message "Sleeping for $loop_sleep_time seconds"
        sleep $loop_sleep_time
    fi
done

log_message "All loops completed"
