#!/bin/bash

# ==============================================================================
# Git Repository Status Checker
# ==============================================================================
# This script scans a specified parent directory for Git repositories to
# provide a quick overview of their current status (e.g., modified files,
# untracked files).
#
# Optionally, it can display the current Git branch name for each repository
# if 'git-prompt.sh' integration is enabled.
#
# Ideal for developers managing multiple local Git projects.
# ==============================================================================

# --- Configuration ---

# Set to 'true' to enable __git_ps1 for branch display; 'false' to disable.
USE_GIT_PROGRAM_PROMPT=true

# Parent directory to scan for Git repositories.
PARENT_DIRECTORY="$HOME/Code"

# Git command to execute for status checking (e.g., 'git status -s').
GIT_STATUS_EXECUTE_COMMAND="git status -s"

# Internal variable for git-prompt command; set only if USE_GIT_PROGRAM_PROMPT is true.
GIT_PROGRAM_EXECUTE_PROMPT=""

# --- Script Logic ---

# Check if the configured parent directory exists.
if [ ! -d "$PARENT_DIRECTORY" ]; then
    echo "Error: Directory '$PARENT_DIRECTORY' not found."
    exit 1
fi

# Load git-prompt.sh if enabled and available.
if [[ -f /usr/share/git/completion/git-prompt.sh && "$USE_GIT_PROGRAM_PROMPT" == "true"  ]]; then
    . /usr/share/git/completion/git-prompt.sh
    GIT_PROGRAM_EXECUTE_PROMPT="__git_ps1 [%s]"
fi

echo "Scanning direct child directories of: $PARENT_DIRECTORY"
echo "----------------------------------------------------"

# Loop through each direct child directory.
for dir in "$PARENT_DIRECTORY"/*/; do
    # Check if the item is a directory and a Git repository.
    if [ -d "$dir" ]; then
        if [ -d "$dir/.git" ]; then
            # Use a subshell to isolate directory changes.
            (
                cd "$dir" || { echo "Error: Could not change to directory $dir"; continue; }

                # Get Git branch info (if enabled).
                GIT_BRANCH_INFO=$($GIT_PROGRAM_EXECUTE_PROMPT)
                # Execute the Git status command.
                gitstatus=$($GIT_STATUS_EXECUTE_COMMAND)

                if [ -n "$gitstatus" ]; then
                    printf "Processing repository: %s %s\n" "$(basename "$dir")" "$GIT_BRANCH_INFO"
                    $GIT_STATUS_EXECUTE_COMMAND
                    echo "----------------------------------------------------"
                fi
            )
        fi
    fi
done

echo "--- Scan complete. ---"