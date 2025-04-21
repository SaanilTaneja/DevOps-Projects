#!/bin/bash

#####################################################################
# Author  : Saanil Taneja
# Date    : 21st April, 2025
# Purpose : AWS Resource Usage Tracker (S3, EC2, Lamdba, IAM Users)
# Version : v1
#####################################################################

set +x # Debug Mode
set -e # Exit script if encountered any error
set -o pipefail # Exit script if encountered any pipe failures

# List S3 Buckets
echo "List of S3 Buckets"
aws s3 ls

# List EC2 Instances
echo "List of EC2 Instances"
aws ec2 describe-instances | jq '.Reservations[].Instances[].InstanceId' # Use 'jq' - Json and 'yq' - Yaml to extract precise info

# List Lambda Functions
echo "List of Lambda Functions"
aws lambda list-functions

# List IAM Users
echo "List of IAM Users"
aws iam list-users | jq '.Users[] | {UserName, UserId}'
