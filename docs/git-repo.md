# Project Title
## Git Repository Automation Tool

# Introduction
### Overview of the Project

This project is a command-line tool designed to automate the setup, update, and removal of Python projects from Git repositories. It provides features such as cloning repositories, setting up Python virtual environments, managing dependencies via `requirements.txt` or custom `build.sh`, creating executable wrappers/symlinks in a designated bin directory for easy access, updating existing projects with Git pull and stash management, listing all managed projects, specifying a Python version for virtual environment creation, reinstalling projects with fresh setup.

# Installation
### Dependencies and Setup

The project relies on essential system commands such as `git`, `find`, `chmod`, `ln`, `rm`, and `pwd`. The specific Python executable to use can be specified via the `-pv` or `--python-version` option. If not provided, it defaults to using 'python3'.

Installation instructions and dependencies are not explicitly provided in the source files.

### Running the Script

To run the script, save it as a file (e.g., `git-repo.sh`) and make it executable with `chmod +x git-repo.sh`. Then, you can execute the script with your desired options.

## Example Command
```bash
./git-repo-py --help
```
### Dependencies

* `python3` or any other Python version as specified via `-pv` or `--python-version`

# Usage Instructions
### Running the Script

To run the script, provide it with a repository name and GitHub URL. You can specify options such as cloning a branch (`-b`) or using a custom Python executable (`-pv`).

## Example Command
```bash
./git-repo-py my-web-app https://github.com/myuser/my-web-app.git -b develop -pv python3.9
```
### Options

* `--remove <repository_name>`: Remove the symbolic link and project directory.
* `--update <repository_name>`: Clean cache, stash changes, pull latest, pop stash.
* `--reinstall <repo_name> <url>`: Remove and re-set up the project (requires repository name and GitHub URL).
* `--branch <branch_name>`: Specify the Git branch to clone (used with setup/reinstall modes).
* `--python-version <python_executable>`: Specifies the Python executable to use for the virtual environment.
* `--force-create-run`: Always generates a default Python wrapper in `\${TOOLS_BIN_DIR}`, overriding project's `run.sh`.
* `--list`: Lists all projects managed by git-repo-py.

# Configuration
### Project Settings

The script does not explicitly mention configuration options. The tool operates based on its internal logic and parameters provided through command-line options.

Configuration options are not explicitly detailed in the source files.

### Environment Variables

Some environment variables are used throughout the script, such as `TOOLS_BASE_DIR` and `TOOLS_BIN_DIR`. These can be modified to change their default values.

## Example Command
```bash
export TOOLS_BASE_DIR="/path/to/base/dir"
```

# Additional Resources
No additional resources or external links were provided in the source files.