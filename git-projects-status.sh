#!/bin/bash

# ==============================================================================
# Git Repository Status Checker
# ==============================================================================
# This script scans a specified parent directory for direct child directories
# that are also Git repositories. For each identified repository, it changes
# into that directory (in a subshell) and executes a predefined Git status
# command to display its current state (e.g., modified files, untracked files).
#
# Optionally, it can integrate with Bash's 'git-prompt.sh' to display the
# current branch information alongside the repository name.
#
# Ideal for developers managing multiple local Git projects and wanting a
# quick overview of uncommitted changes across them.
# ==============================================================================

# --- Configuration ---

# Set to 'true' to enable the git-prompt functionality (__git_ps1).
# Otherwise, it defaults to empty.
USE_GIT_PROGRAM_PROMPT=false

# Define the parent directory containing your Git repositories.
# Defaults to your home directory's 'Code' folder.
PARENT_DIRECTORY="$HOME/Code"

# The glob pattern used to find potential repository directories within PARENT_DIRECTORY.
# By default, '*/' matches all direct child directories.
# Examples:
#   - '*/': All direct child directories (most common).
#   - 'project-*': Directories starting with 'project-'.
#   - '*/src': Directories named 'src' within immediate subdirectories.
SCAN_GLOB_PATTERN='*/'

# Command to execute for displaying Git status.
# Defaults to 'git status -s' (short status).
GIT_STATUS_COMMAND="git status -s"

# Internal variable to store the command for git branch info (e.g., __git_ps1).
# This is initially empty and gets set if USE_GIT_PROGRAM_PROMPT is true and the git-prompt script is found.
_GIT_BRANCH_INFO_COMMAND=""

# --- Script Logic ---

# Check if the parent directory exists. Exit if not.
if [[ ! -d "$PARENT_DIRECTORY" ]]; then
    echo "Error: Directory '$PARENT_DIRECTORY' not found. Please verify the path."
    exit 1
fi

# Load git-prompt.sh if enabled and available.
# This makes __git_ps1 available for use.
if [[ "$USE_GIT_PROGRAM_PROMPT" == "true" && -f /usr/share/git/completion/git-prompt.sh ]]; then
    . /usr/share/git/completion/git-prompt.sh
    _GIT_BRANCH_INFO_COMMAND="__git_ps1 [%s]"
fi

echo "--- Scanning Git repositories in: $PARENT_DIRECTORY (using pattern: $SCAN_GLOB_PATTERN) ---"

# Loop through each item matching the glob pattern within the parent directory.
# The 'nullglob' and 'dotglob' options enhance globbing behavior.
shopt -s nullglob # Ensures globs that match nothing expand to nothing (not the pattern itself)
shopt -s dotglob  # Allows globs to match files/directories starting with a dot (like .git, if desired)

for repo_candidate in "$PARENT_DIRECTORY"/"$SCAN_GLOB_PATTERN"; do
    # Skip if it's not a directory or if it's not a Git repository.
    # We still perform the -d check as the glob pattern might be more general.
    if [[ -d "$repo_candidate" && -d "$repo_candidate/.git" ]]; then
        # Use a subshell to perform operations within the repository's directory.
        # This ensures the main script's working directory remains unchanged.
        (
            # Change to the repository directory. Exit subshell if 'cd' fails.
            if ! cd "$repo_candidate"; then
                echo "Error: Could not access repository directory: $repo_candidate"
                exit 1 # Exit the subshell, not the main script
            fi

            # Get the base name of the repository for display.
            repo_name=$(basename "$repo_candidate")

            # Execute the git branch info command (e.g., __git_ps1) if enabled.
            # Capture its output, trimming any newlines.
            # If _GIT_BRANCH_INFO_COMMAND is empty, this will result in an empty string.
            branch_info=$($_GIT_BRANCH_INFO_COMMAND 2>/dev/null | tr -d '\n')

            # Print the repository name and branch info on a single line.
            printf "--> %s %s\n" "$repo_name" "$branch_info"

            # Execute the defined Git status command (e.g., git status -s).
            # This will show any uncommitted changes or untracked files.
            $GIT_STATUS_COMMAND

        ) # End of subshell

        echo "----------------------------------------------------"
    fi
done

# Disable shell options modified by the script to avoid affecting subsequent commands
shopt -u nullglob
shopt -u dotglob

echo "--- Scan complete. ---"