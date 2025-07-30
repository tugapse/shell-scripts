# Git Repository Status Checker

## Introduction
This script scans a specified parent directory for Git repositories to provide a quick overview of their current status (e.g., modified files, untracked files). It can also display the current Git branch name for each repository if 'git-prompt.sh' integration is enabled.

## Installation
Installation instructions and dependencies are not explicitly provided in the source files.

## Usage Instructions
To use this script:

1. Save it as a file (e.g., `bash/git-projects-status.sh`).
2. Make sure to have Bash installed on your system.
3. Ensure that the parent directory specified in the script (`$PARENT_DIRECTORY`) exists and is accessible.

Run the script using:
```bash
./git-projects-status.sh
```
This will scan for Git repositories in the specified parent directory and display their status.

## Configuration
The following configuration options are available:

* `USE_GIT_PROGRAM_PROMPT`: Set to `'true'` to enable __git_ps1 for branch display; set to `'false'` to disable.
* `$PARENT_DIRECTORY`: Specify the parent directory to scan for Git repositories.

To modify these settings, edit the script directly or use environment variables.

## Additional Resources
No additional resources or external links were provided in the source files.
