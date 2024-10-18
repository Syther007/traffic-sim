#!/bin/bash

(crontab -l ; echo "30 2 * * * cd /home/ubuntu/traffic-sim && /home/ubuntu/traffic-sim/lightCons_cron.sh") | sort -u | crontab -
