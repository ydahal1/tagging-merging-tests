# Git Version Management Scripts

This directory contains a set of Bash scripts to help manage versioned candidate branches, major/minor releases, upmerges, and cherry-picking commits in a Git repository.

> It is required to use the scripts below for the actions mentioned, and recommended to run the commands without arguments so the scripts can prompt you with examples.

## create-major.sh

Creates a new **major version** candidate branch from `master`.

```bash
# Provide the major number as an argument
bash create-major.sh <major-number>

# Or run without arguments and the script will prompt you
bash create-major.sh
```

```bash
bash create-major.sh 3
# Creates candidate-3.0.x from master and pushes it to origin

bash create-major.sh
# Prompts: Enter the new major version number (e.g., 3 to create candidate-3.0.x)
# Then creates candidate-<entered>.0.x from master and pushes it to origin
```

## create-minor.sh

Creates a new **minor version** candidate branch from an existing candidate branch.

```bash
# Provide source version and new minor number as arguments
bash create-minor.sh <source-version> <new-minor-number>

# Or run without arguments and the script will prompt you
bash create-minor.sh
```

```bash
bash create-minor.sh 1.2.x 4
# Creates candidate-1.4.x from candidate-1.2.x and pushes it to origin

bash create-minor.sh
# Prompts:
# Enter the source version (e.g., 1.2.x)
# Enter the new minor version (e.g., 4 to create 1.4.x)
# Then creates candidate-<source-major>.<new-minor>.x from the source branch and pushes it to origin
```

## create-release.sh

Creates a **Tombolo release** branch (tombolo-NNN.MMM.PPP) from an existing candidate branch (candidate-NNN.MMM.x) and tags it.

```bash
# Provide the release version as an argument
bash create-release.sh <version>

# Or run without arguments and the script will prompt you
bash create-release.sh

```

```bash
bash create-release.sh 1.0.3

# Creates release branch tombolo-1.0.3 from candidate-1.0.x, tags it as v1.0.3, and pushes both to origin
bash create-release.sh
# Prompts: Enter the release version (e.g., 1.0.3)
# Then creates tombolo-<entered> from the corresponding candidate branch, tags it, and pushes both to origin
```

## upmerge.sh

Upmerges changes from a **source candidate branch** into a **target branch** (another candidate branch or master).  
It automatically commits and pushes the merged changes. The script will stop if there are uncommitted changes in the working directory.

```bash
# Provide source and target branches as arguments
bash upmerge.sh <source-version> <target-version>

# Or run without arguments and the script will prompt you
bash upmerge.sh
```

```bash
bash upmerge.sh 1.0.x 1.1.x
# Merges changes from candidate-1.0.x into candidate-1.1.x, commits, and pushes to origin

bash upmerge.sh 1.0.x master
# Merges changes from candidate-1.0.x into master, commits, and pushes to origin

bash upmerge.sh
# Prompts:
# Enter the source version (e.g., 1.0.x)
# Enter the target version (e.g., 1.1.x or master)
# Then performs the upmerge
```

## cherry-pick-fix.sh

Cherry-picks a specific commit from a **source branch** to a **target branch**.  
Displays the latest commits from the source branch (hash, message, date, time) and ensures the target branch is clean before cherry-picking.

```bash
# Provide source branch, target branch, optional --show-commit, and optional --list=N
bash cherry-pick-fix.sh <source-branch> <target-branch> [--show-commit] [--list=N]

# Or run without arguments and the script will prompt you
bash cherry-pick-fix.sh
```

```bash
bash cherry-pick-fix.sh candidate-1.0.x master
# Displays the last 10 commits from candidate-1.0.x
# Prompts: Enter the commit hash to cherry-pick
# Then cherry-picks the commit to master and pushes it to origin

bash cherry-pick-fix.sh candidate-1.0.x master --list=5 --show-commit
# Displays the last 5 commits from candidate-1.0.x with commit info
# Prompts for commit hash and cherry-picks to master

bash cherry-pick-fix.sh
# Prompts:
# Enter the source branch (e.g., candidate-1.0.x)
# Enter the commit hash to cherry-pick
# Enter the target branch (e.g., master or candidate-1.0.x)
# Then cherry-picks the commit
```
