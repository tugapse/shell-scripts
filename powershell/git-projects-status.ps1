# ==============================================================================
# Git Repository Status Checker
# ==============================================================================
# This script scans a specified parent directory for Git repositories to
# provide a quick overview of their current status (e.g., modified files,
# untracked files).
#
# It displays the current Git branch name for each repository.
#
# This version assumes 'posh-git' might be installed for the user's interactive
# PowerShell experience, but the script itself retrieves branch information
# using standard Git commands for reliable output.
# Ideal for developers managing multiple local Git projects.
# ==============================================================================

# --- Configuration ---

# Parent directory to scan for Git repositories.
# This defaults to your user's 'Code' folder.
$ParentDirectory = Join-Path $Home "Code"

# Git command to execute for status checking (e.g., 'git status -s').
$GitStatusExecuteCommand = "git status -s"

# --- Script Logic ---

# Check if the configured parent directory exists.
if (-not (Test-Path $ParentDirectory -PathType Container)) {
    Write-Error "Error: Directory '$ParentDirectory' not found."
    Exit 1
}

Write-Host "Scanning direct child directories of: $ParentDirectory"
Write-Host "----------------------------------------------------"

# Loop through each direct child directory.
Get-ChildItem -Path $ParentDirectory -Directory | ForEach-Object {
    $currentDir = $_.FullName

    # Check if the directory is a Git repository.
    if (Test-Path (Join-Path $currentDir ".git") -PathType Container) {
        # Use Push-Location and Pop-Location to manage directory changes,
        # ensuring the script returns to its original directory.
        Push-Location $currentDir

        try {
            $gitBranchInfo = ""
            # Get Git branch info using a standard Git command.
            # This is robust and doesn't rely on Posh-Git's prompt modifications.
            $branch = (git rev-parse --abbrev-ref HEAD 2>$null)
            if ($branch) {
                $gitBranchInfo = "[$branch]"
            }

            # Execute the Git status command.
            $gitStatus = (Invoke-Expression "$GitStatusExecuteCommand" 2>$null)

            if (-not [string]::IsNullOrWhiteSpace($gitStatus)) {
                Write-Host "Processing repository: $($_.Name) $gitBranchInfo"
                Invoke-Expression "$GitStatusExecuteCommand"
                Write-Host "----------------------------------------------------"
            }
        }
        finally {
            Pop-Location # Ensure we always return to the original directory.
        }
    }
}

Write-Host "--- Scan complete. ---"