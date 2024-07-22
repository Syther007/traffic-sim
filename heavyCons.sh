#!/usr/bin/env bash

allThreads=(
       "https://speed.hetzner.de/100MB.bin" 
      # "https://speed.hetzner.de/1GB.bin"
      # "https://speed.hetzner.de/10GB.bin"
)


total=$(expr ${#allThreads[@]} - 1)
ArrCnt=0;
SUC=0;
FAL=0;
TOL=0;
while :;
do
        if wget -e use_proxy=yes -e https_proxy=127.0.0.1:443 -O - -t 1 -T 10 /dev/null ${allThreads[$ArrCnt]};

        then ((SUC=SUC+1))
        else ((FAL=FAL+1))
        fi
        ((TOL=TOL+1))
        echo Total: $TOL
        echo Success: $SUC
        echo Fault: $FAL

        if (($ArrCnt >= $total));
        then ((ArrCnt=0));
        else ((ArrCnt=$ArrCnt+1));
        fi;

        sleep 5

done 
