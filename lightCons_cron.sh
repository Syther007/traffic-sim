#!/usr/bin/env bash

allThreads=(
       "https://www.asite.com" 
       "https://icanhazip.com" 
       "https://cats.com"
       "https://cat.com"
       "https://fish.com"
       "https://www.dog.com"
       "https://api.ipify.org"
)

total=$(expr ${#allThreads[@]} - 1)
ArrCnt=0;
SUC=0;
FAL=0;
TOL=0;
maxIterations=50000  # Set the desired number of iterations
currentIteration=0

totalDownloaded=0  # Initialize total downloaded size in bytes

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
        echo Total: $TOL
        echo Success: $SUC
        echo Fault: $FAL
        echo Total Downloaded: ${totalDownloadedMB} MB  # Display total downloaded in MB

        if (($ArrCnt >= $total));
        then ((ArrCnt=0));
        else ((ArrCnt=$ArrCnt+1));
        fi;

        # Clean up the temporary file
        rm "$tempFile"

        ((currentIteration++))  # Increment the current iteration count
done 

# At the end of the script, display the total downloaded size
echo "Final Total Downloaded: ${totalDownloadedMB} MB"
