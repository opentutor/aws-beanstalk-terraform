#!/bin/bash

# fetch firewall logs first:

aws s3 sync s3://mentorpal-aws-waf-logs-us-east-1-v2 ./logs-v2
aws s3 sync s3://mentorpal-aws-waf-logs-us-west-2-cf ./logs-cf

# then go to ./analyzed and run to_json.sh first and then 
# use the analyze.js script to inspect logs
