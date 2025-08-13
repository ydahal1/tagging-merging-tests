#!/bin/bash
# Creates a new major version candidate branch from master
# Usage: ./create-major.sh [<major-number>] (e.g., 3)

# Colors
GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

# Functions for colored messages
ok() { echo -e "[${GREEN}OK${RESET}] $1"; }
error() { echo -e "[${RED}ERROR${RESET}] $1"; }

# Prompt for major number if not provided
if [[ -z $1 ]]; then
    read -p "Enter the new major version number (e.g., 3): " major
else
    major=$1
fi

# Validate input: must be a number
if ! [[ $major =~ ^[0-9]+$ ]]; then
    error "Invalid major version number: '$major'"
    exit 2
fi

version="${major}.0.x"
new_branch="candidate-$version"

git fetch origin

# Check if branch already exists locally
if git show-ref --verify --quiet "refs/heads/$new_branch"; then
    error "Branch '$new_branch' already exists locally."
    exit 1
fi

# Check if branch already exists remotely
if git ls-remote --exit-code --heads origin "$new_branch" &>/dev/null; then
    error "Branch '$new_branch' already exists on remote."
    exit 1
fi

git checkout master
if [ $? -ne 0 ]; then
    error "Target branch master failed to check out."
    exit 1
fi

git merge origin/master --ff-only
if [ $? -ne 0 ]; then
    error "Target branch master is inconsistent with origin/master."
    exit 1
fi

ok "Creating new major branch $new_branch from master"
git checkout -b "$new_branch"
if [ $? -ne 0 ]; then
    error "Failed to create $new_branch."
    exit 1
fi

git push origin "$new_branch"
ok "Created and pushed $new_branch"
