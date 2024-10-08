#!/bin/bash

# Parameters for traffic_simulation.sh
URL_LIST_FILE="url_small.txt"
# URL_LIST_FILE="url2.txt"
TIMEOUT=15
MAX_RETRIES=5
# PROXY="none"
PROXY="https://127.0.0.1:443"

DELAY=2  # Default delay time
TOTAL_SIZE=0
NUM_ITERATIONS=5

# Loop to run the traffic simulation multiple times
for ((i=1; i<=NUM_ITERATIONS; i++)); do
  echo "Running iteration $i of $NUM_ITERATIONS..."
  
  # Run the traffic simulation and capture the output
  OUTPUT=$(./traffic_simulation.sh "$URL_LIST_FILE" "$TIMEOUT" "$MAX_RETRIES" "$PROXY")
  
  # Extract the total size downloaded from the output
  SIZE=$(echo "$OUTPUT" | grep "Total size downloaded:" | awk '{print $4}')
  
  # Convert size to bytes and add to total size
  TOTAL_SIZE=$(echo "$TOTAL_SIZE + $SIZE * 1048576" | bc)
  
  echo "$OUTPUT"

  # Add echo message before sleeping
  echo "Sleeping for $DELAY seconds before the next iteration..."  # {{ edit_1 }}
  
  # Delay before the next iteration
  sleep "$DELAY"  # Add delay here
done

# Convert total size to MB for final output
TOTAL_SIZE_MB=$(echo "scale=2; $TOTAL_SIZE / 1048576" | bc)

# Print the final total size downloaded
echo "Total size downloaded across all iterations: $TOTAL_SIZE_MB MB"
