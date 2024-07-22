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
while :;
do
        #if curl --max-time 10 -s -w 'Request Code: %{http_code}\n' https://icanhazip.com;
        if curl -x "127.0.0.1:443" --max-time 5 -s -w 'Request Code: %{http_code}\n' ${allThreads[$ArrCnt]};
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

        #echo $ArrCnt
        #echo echo ${allThreads[$ArrCnt]}

        #sleep 5

done 
