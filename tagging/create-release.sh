#!/bin/bash
# Cherry-picks a commit or commits from a source branch to a target branch
# Usage: ./cherry-pick-fix.sh [<commit-hash>] [<target-branch>] [--show-commit]

# Colors
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
RESET="\033[0m"

ok() { echo -e "[${GREEN}OK${RESET}] $1"; }
error() { echo -e "[${RED}ERROR${RESET}] $1"; }
warn() { echo -e "[${YELLOW}WARN${RESET}] $1"; }

SHOW_COMMIT=false
for arg in "$@"; do
    if [[ "$arg" == "--show-commit" ]]; then
        SHOW_COMMIT=true
    fi
done

# Prompt for commit hash if missing
if [[ -z $1 ]]; then
    read -p "Enter the commit hash to cherry-pick: " commit_hash
else
    commit_hash=$1
fi

# Prompt for target branch if missing
if [[ -z $2 ]]; then
    read -p "Enter the target branch (e.g., master or candidate-1.0.x): " target_branch
else
    target_branch=$2
fi

# Validate input
if [[ -z $commit_hash ]]; then
    error "No commit hash provided."
    exit 2
fi
if [[ -z $target_branch ]]; then
    error "No target branch provided."
    exit 2
fi

git fetch origin

# Check if target branch exists
if ! git show-ref --verify --quiet "refs/heads/$target_branch" &&
   ! git ls-remote --exit-code --heads origin "$target_branch" &>/dev/null; then
    error "Target branch '$target_branch' does not exist locally or remotely."
    exit 1
fi

# Warn if there are untracked files
UNTRACKED_COUNT=$(git ls-files --others --exclude-standard | wc -l | xargs)
if [[ $UNTRACKED_COUNT -gt 0 ]]; then
    warn "There are $UNTRACKED_COUNT untracked files in the working directory."
fi

# Checkout target branch and update
git checkout "$target_branch"
if [ $? -ne 0 ]; then
    error "Failed to check out target branch '$target_branch'."
    exit 1
fi

git merge origin/"$target_branch" --ff-only
if [ $? -ne 0 ]; then
    error "Target branch '$target_branch' is inconsistent with origin/$target_branch."
    exit 1
fi

# Check if the commit is already in the target branch
if git merge-base --is-ancestor "$commit_hash" "$target_branch"; then
    if [[ "$SHOW_COMMIT" == true ]]; then
        commit_info=$(git log -n 1 --pretty=format:"%h %s" "$commit_hash")
        warn "Commit $commit_info is already included in '$target_branch'. Nothing to cherry-pick."
    else
        warn "Commit '$commit_hash' is already included in '$target_branch'. Nothing to cherry-pick."
    fi
    exit 0
fi

ok "Cherry-picking commit $commit_hash to '$target_branch'..."
git cherry-pick "$commit_hash"
if [ $? -ne 0 ]; then
    error "Conflicts detected during cherry-pick. Please resolve manually."
    exit 1
fi

git push origin "$target_branch"
ok "Cherry-picked commit $commit_hash to '$target_branch'"

# Warn again if untracked files remain
UNTRACKED_COUNT_AFTER=$(git ls-files --others --exclude-standard | wc -l | xargs)
if [[ $UNTRACKED_COUNT_AFTER -gt 0 ]]; then
    warn "There are still $UNTRACKED_COUNT_AFTER untracked files in the working directory after cherry-pick."
fi
