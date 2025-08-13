#!/bin/bash
# Creates a new minor version candidate branch
# Usage: ./create-minor.sh [<source-major.minor.x>] [<new-major.minor.x>]
# Example: ./create-minor.sh 1.0.x 1.1.x

# Colors
GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

ok() { echo -e "[${GREEN}OK${RESET}] $1"; }
error() { echo -e "[${RED}ERROR${RESET}] $1"; }

# Prompt for source version if not provided
if [[ -z $1 ]]; then
    read -p "Enter the source version (e.g., 1.0.x): " source_version
else
    source_version=$1
fi

# Prompt for new version if not provided
if [[ -z $2 ]]; then
    read -p "Enter the new minor version (e.g., 1.1.x): " new_version
else
    new_version=$2
fi

# Validate input format
if [[ -z $source_version || ! $source_version =~ ^[0-9]+\.[0-9]+\.x$ ]]; then
    error "Invalid source version format: '$source_version' (expected e.g., 1.0.x)"
    exit 2
fi

if [[ -z $new_version || ! $new_version =~ ^[0-9]+\.[0-9]+\.x$ ]]; then
    error "Invalid new version format: '$new_version' (expected e.g., 1.1.x)"
    exit 2
fi

# Ensure same major version
source_major=$(echo "$source_version" | cut -d. -f1)
new_major=$(echo "$new_version" | cut -d. -f1)

if [[ "$source_major" != "$new_major" ]]; then
    error "New minor version must have the same major version as the source ($source_major.x.x)"
    exit 1
fi

source_branch="candidate-$source_version"
new_branch="candidate-$new_version"

git fetch origin

# Check if source branch exists locally or remotely
if ! git show-ref --verify --quiet "refs/heads/$source_branch" &&
   ! git ls-remote --exit-code --heads origin "$source_branch" &>/dev/null; then
    error "Source branch '$source_branch' does not exist locally or on remote."
    exit 1
fi

# Check if new branch already exists locally
if git show-ref --verify --quiet "refs/heads/$new_branch"; then
    error "Branch '$new_branch' already exists locally."
    exit 1
fi

# Check if new branch already exists remotely
if git ls-remote --exit-code --heads origin "$new_branch" &>/dev/null; then
    error "Branch '$new_branch' already exists on remote."
    exit 1
fi

# Checkout source branch
git checkout "$source_branch"
if [ $? -ne 0 ]; then
    error "Failed to check out source branch '$source_branch'."
    exit 1
fi

# Merge from remote to ensure it’s up to date
git merge origin/"$source_branch" --ff-only
if [ $? -ne 0 ]; then
    error "Source branch '$source_branch' is inconsistent with origin/$source_branch."
    exit 1
fi

ok "Creating new minor branch $new_branch from $source_branch"
git checkout -b "$new_branch"
if [ $? -ne 0 ]; then
    error "Failed to create $new_branch."
    exit 1
fi

git push origin "$new_branch"
ok "Created and pushed $new_branch"
