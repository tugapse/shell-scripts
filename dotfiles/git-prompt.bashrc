# Source the Git prompt script if it exists.
# This provides the __git_ps1 function for displaying Git status in the prompt.
if [ -f /usr/share/git/completion/git-prompt.sh ]; then
    . /usr/share/git/completion/git-prompt.sh
fi

# Configure __git_ps1 behavior to show various Git repository states.
export GIT_PS1_SHOWDIRTYSTATE=true      # Show '+' for unstaged, '*' for staged changes.
export GIT_PS1_SHOWUNTRACKEDFILES=true # Show '%' for untracked files.
export GIT_PS1_SHOWSTASHSTATE=true     # Show '$' for stashed changes.
export GIT_PS1_SHOWUPSTREAM="auto"     # Show relationship with upstream branch (e.g., '<', '>', '<>', '=').
export GIT_PS1_SHOWCOLORHINTS=true     # Add color to the Git status part.

# Define individual components of the PS1 (Primary Prompt String) for clarity.
# ANSI escape codes (\[\e[...m\] or \[\033[...m\]) are used for colors.
# \u: current username
# \h: hostname
# \w: current working directory (full path)
# \$: displays '#' if root, '$' otherwise

USER_STRING="\[\033[1;32m\]\u\[\033[0m\]"             # Bold Green Username
HOST_STRING="@\[\033[1;36m\]\h\[\033[0m\]:"            # Bold Cyan Hostname
WORKING_DIR="\[\033[1;33m\]\w\[\e[0m\]"               # Yellow Working Directory
GIT_OUTPUT_STRING="\$(__git_ps1 \" [%s]\"\[\e[33m\])" # Git branch and status (Yellow, in brackets)
END_STRING="\[\e[0m\] \$ "                            # Reset color, then '$ ' or '# '

# Combine user and host parts.
USER_HOST="${USER_STRING}${HOST_STRING}"

# Construct the PS1 string using line continuation for improved readability.
# The order defines the appearance of the prompt: User@Host -> Working Directory -> Git Status -> Prompt Symbol
export PS1=""\
"${USER_HOST}"\
"${WORKING_DIR}"\
"${GIT_OUTPUT_STRING}"\
"${END_STRING}"
