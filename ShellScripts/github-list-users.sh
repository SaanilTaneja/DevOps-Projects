#!/bin/bash

#################################################################
# Author  : Saanil Taneja
# Date    : 21st April, 2025
# Version : v1
# Purpose : List Users allowed to read the repo
# Syntax  : ./list-users.sh <username> <repo> 
# ###############################################################

set -e
set -o pipefail

function helper {
     expected_cmd_args=2
     if [ $# -ne $expected_cmd_args ]; then
        echo "Wrong Syntax!"
	echo "Correct Syntax is ./list-users.sh <username> <repo>"
	echo "Please Try Again"
	exit 1
     fi     
   }

helper "$@"

# GitHub API URL
API_URL="https://api.github.com"

# GitHub username and personal access token
USERNAME=$username
TOKEN=$token

# User and Repository information
REPO_OWNER=$1
REPO_NAME=$2

# Function to make a GET request to the GitHub API
function github_api_get {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"

    # Send a GET request to the GitHub API with authentication
    curl -s -u "${USERNAME}:${TOKEN}" "$url"
}

# Function to list users with read access to the repository
function list_users_with_read_access {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"

    # Fetch the list of collaborators on the repository
    collaborators="$(github_api_get "$endpoint" | jq -r '.[] | select(.permissions.pull == true) | .login')"

    # Display the list of collaborators with read access
    if [[ -z "$collaborators" ]]; then
        echo "No users with read access found for ${REPO_OWNER}/${REPO_NAME}."
    else
        echo "Users with read access to ${REPO_OWNER}/${REPO_NAME}:"
        echo "$collaborators"
    fi
}

# Main script

echo "Listing users with read access to ${REPO_OWNER}/${REPO_NAME}..."
list_users_with_read_access
