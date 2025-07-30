#!/usr/bin/bash
#
# Bash Terminal Color Utilities
#
# This script provides a set of functions to control text colors in the bash terminal.
# It supports standard ANSI 16 colors, the 256-color palette, and True Color (24-bit RGB).
#
# Features:
# - Predefined variables for basic ANSI colors.
# - Function to display a table of all 256 color codes.
# - Functions to set foreground and background colors using the 256-color palette.
# - Functions to set foreground and background colors using True Color (RGB).
# - A universal reset function for all color and text attributes.
#
# Compatibility:
# - ANSI 16 colors: Universally supported by almost all terminal emulators.
# - 256-color palette: Supported by most modern terminal emulators (e.g., xterm,
#   GNOME Terminal, Konsole, iTerm2). Check 'tput colors' (should return 256).
# - True Color (24-bit RGB): Supported by newer terminal emulators (e.g., Alacritty, Kitty,
#   iTerm2, recent versions of GNOME Terminal/Konsole). Check 'echo $COLORTERM'
#   (might return 'truecolor' or '24bit').
#
# Usage:
# Source this script in your .bashrc or another script:
#   source /path/to/your_script.sh
#
# Then call the functions as needed.
#
# Examples:
#   echo "${COLOR_RED}This text is red (ANSI).${COLOR_RESET}"
#   print_colors_table
#   set_forecolor 196; echo "This text is bright red (256-color)."; reset_color
#   set_true_forecolor 255 165 0; echo "This text is orange (True Color)."; reset_color
#   set_true_forecolor 128 0 128; set_true_backcolor 40 40 40; echo "Purple text on dark gray background."; reset_color
#

# --- Basic ANSI Color Definitions (16 Colors) ---
# These variables hold the escape codes for standard ANSI colors.
# Use these for wide compatibility. Remember to always reset with COLOR_RESET.

# Normal Foreground Colors (0;3x)
COLOR_BLACK="\033[0;30m"  # Black
COLOR_RED="\033[0;31m"    # Red
COLOR_GREEN="\033[0;32m"  # Green
COLOR_YELLOW="\033[0;33m" # Yellow
COLOR_BLUE="\033[0;34m"   # Blue
COLOR_MAGENTA="\033[0;35m" # Magenta
COLOR_CYAN="\033[0;36m"   # Cyan
COLOR_WHITE="\033[0;37m"  # White (often displays as light gray)

# Normal Background Colors (0;4x)
BG_BLACK="\033[0;40m"    # Black Background
BG_RED="\033[0;41m"      # Red Background
BG_GREEN="\033[0;42m"    # Green Background
BG_YELLOW="\033[0;43m"   # Yellow Background
BG_BLUE="\033[0;44m"     # Blue Background
BG_MAGENTA="\033[0;45m"  # Magenta Background
BG_CYAN="\033[0;46m"     # Cyan Background
BG_WHITE="\033[0;47m"    # White Background (often displays as light gray)

# Bright/Bold Foreground Colors (1;3x or 0;9x depending on terminal/standard)
# Combining 1 (bold) with 3x (normal color) often results in a "bright" color.
# Some terminals also explicitly support 9x for bright colors. We'll use 1;3x for broader compatibility.
COLOR_BRIGHT_BLACK="\033[1;30m"  # Bright Black (often Dark Gray)
COLOR_BRIGHT_RED="\033[1;31m"    # Bright Red
COLOR_BRIGHT_GREEN="\033[1;32m"  # Bright Green
COLOR_BRIGHT_YELLOW="\033[1;33m" # Bright Yellow
COLOR_BRIGHT_BLUE="\033[1;34m"   # Bright Blue
COLOR_BRIGHT_MAGENTA="\033[1;35m" # Bright Magenta
COLOR_BRIGHT_CYAN="\033[1;36m"   # Bright Cyan
COLOR_BRIGHT_WHITE="\033[1;37m"  # Bright White

# Bright Background Colors (1;4x or 0;10x)
# Similar to foreground, 1;4x or 0;10x for bright backgrounds.
# Note: Not all terminals render "bright background" distinctly from normal.
BG_BRIGHT_BLACK="\033[1;40m"    # Bright Black Background (often Dark Gray)
BG_BRIGHT_RED="\033[1;41m"      # Bright Red Background
BG_BRIGHT_GREEN="\033[1;42m"    # Bright Green Background
BG_BRIGHT_YELLOW="\033[1;43m"   # Bright Yellow Background
BG_BRIGHT_BLUE="\033[1;44m"     # Bright Blue Background
BG_BRIGHT_MAGENTA="\033[1;45m"  # Bright Magenta Background
BG_BRIGHT_CYAN="\033[1;46m"     # Bright Cyan Background
BG_BRIGHT_WHITE="\033[1;47m"    # Bright White Background

# Other Common Text Attributes
ATTR_BOLD="\033[1m"      # Bold text
ATTR_DIM="\033[2m"       # Dim/Faint text (not universally supported)
ATTR_ITALIC="\033[3m"    # Italic text (not universally supported)
ATTR_UNDERLINE="\033[4m" # Underlined text
ATTR_BLINK="\033[5m"     # Blinking text (often annoying, not always supported)
ATTR_INVERSE="\033[7m"   # Inverse/Reverse (swaps FG/BG colors)
ATTR_HIDDEN="\033[8m"    # Hidden/Concealed text (e.g., for passwords)
ATTR_STRIKETHROUGH="\033[9m" # Strikethrough (not universally supported)

# Reset Attributes
COLOR_RESET="\033[0m"  # Resets all attributes (color, bold, etc.) to default

# Specific Reset Codes (less common, but useful for fine control)
RESET_FG_COLOR="\033[39m" # Resets only foreground color to default
RESET_BG_COLOR="\033[49m" # Resets only background color to default
RESET_BOLD_DIM="\033[22m" # Resets bold or dim effect
RESET_ITALIC="\033[23m"   # Resets italic effect
RESET_UNDERLINE="\033[24m" # Resets underline effect
RESET_BLINK="\033[25m"    # Resets blink effect
RESET_INVERSE="\033[27m"  # Resets inverse effect
RESET_HIDDEN="\033[28m"   # Resets hidden effect
RESET_STRIKETHROUGH="\033[29m" # Resets strikethrough effect

# --- Color Utility Functions ---

# print_colors_table
# Description: Displays a comprehensive table of all 256 available colors
#              in the 8-bit color palette. Each color is printed along with
#              its corresponding 0-255 code.
# Usage: print_colors_table
print_colors_table(){
    # Script to display all 256 colors (for foreground)
    for i in {0..255}; do
        printf "\e[38;5;%sm%3s " "$i" "$i"
        if (( (i + 1) % 16 == 0 )); then
            echo -e "\e[0m" # Reset colors and start a new line every 16 colors
        fi
    done
    echo -e "\e[0m" # Final reset to ensure terminal returns to default state
}

# set_forecolor
# Description: Sets the terminal's foreground (text) color using a 256-color palette code.
# Arguments:
#   $1 - The 0-255 integer code for the desired 256-color.
# Usage:
#   set_forecolor 196  # Sets foreground to a bright red
#   echo "Hello"       # "Hello" will be bright red
#   reset_color        # Important: Call reset_color afterwards
set_forecolor() {
    printf "\e[38;5;%sm" "$1"
}

# set_backcolor
# Description: Sets the terminal's background color using a 256-color palette code.
# Arguments:
#   $1 - The 0-255 integer code for the desired 256-color.
# Usage:
#   set_backcolor 27   # Sets background to a deep blue
#   echo "World"       # "World" will have a deep blue background
#   reset_color        # Important: Call reset_color afterwards
set_backcolor() {
    printf "\e[48;5;%sm" "$1"
}

# reset_color
# Description: Resets all terminal formatting attributes (foreground/background colors,
#              bold, italics, etc.) to their default values. This is crucial
#              to prevent colors from "leaking" to subsequent terminal output
#              (like your prompt).
# Usage:
#   reset_color
reset_color() {
    printf "\e[0m"
}

# set_true_forecolor
# Description: Sets the terminal's foreground (text) color using a True Color (24-bit RGB) value.
#              Requires a terminal emulator that supports True Color.
# Arguments:
#   $1 - Red component (0-255)
#   $2 - Green component (0-255)
#   $3 - Blue component (0-255)
# Usage:
#   set_true_forecolor 255 165 0  # Sets foreground to orange
#   echo "True Color!"           # "True Color!" will be orange
#   reset_color                  # Important: Call reset_color afterwards
set_true_forecolor() {
    local r="$1"
    local g="$2"
    local b="$3"
    printf "\e[38;2;%s;%s;%sm" "$r" "$g" "$b"
}

# set_true_backcolor
# Description: Sets the terminal's background color using a True Color (24-bit RGB) value.
#              Requires a terminal emulator that supports True Color.
# Arguments:
#   $1 - Red component (0-255)
#   $2 - Green component (0-255)
#   $3 - Blue component (0-255)
# Usage:
#   set_true_backcolor 40 40 40 # Sets background to dark gray
#   echo "Background"          # "Background" will have a dark gray background
#   reset_color                 # Important: Call reset_color afterwards
set_true_backcolor() {
    local r="$1"
    local g="$2"
    local b="$3"
    printf "\e[48;2;%s;%s;%sm" "$r" "$g" "$b"
}


# ==============================================================================
# --- EXAMPLES OF USAGE ---
# These examples demonstrate how to use the color functions defined above.
# To run these examples, first source this script: `source /path/to/colors.sh`
# Then, you can call the functions or run the specific example blocks.
# ==============================================================================

# --- Example 1: Mixing ANSI, 256-Color, and True Color ---
# This example showcases how to use the different color capabilities together,
# demonstrating the shift from basic to more granular color control.
example_mix_colors() {
    echo "--- Example 1: Mixing Color Palettes ---"

    echo -e "${COLOR_BLUE}This is basic ANSI Blue text.${COLOR_RESET}"
    echo -e "${COLOR_GREEN}And this is ANSI Green.${COLOR_RESET}"
    echo ""

    echo "Now using 256-color palette (8-bit colors):"
    set_forecolor 208 # A vibrant orange
    echo "This text is an exciting orange."
    reset_color

    set_backcolor 17 # A dark purple background
    echo "And this text has a dark purple background."
    reset_color

    set_forecolor 118 # A bright lime green
    set_backcolor 52  # A dark red background
    echo "This is lime green text on a dark red background."
    reset_color
    echo ""

    echo "Finally, using True Color (24-bit RGB):"
    # Custom shade of pink
    set_true_forecolor 255 105 180
    echo "This text is a lovely custom pink!"
    reset_color

    # Custom shade of dark blue background
    set_true_backcolor 25 25 112
    echo "And this has a dark slate blue background."
    reset_color

    # Both True Colors: Gold text on a deep emerald green background
    set_true_forecolor 218 165 32  # Goldenrod
    set_true_backcolor 0 102 51   # Deep Emerald Green
    echo "This is stunning goldenrod text on a deep emerald background!"
    reset_color

    echo ""
    echo "All colors reset. Back to default terminal text."
    echo ""
}

# --- Example 2: Highlighting Messages ---
# This example simulates displaying different types of messages (info, warning, error)
# using various color types to draw attention.
example_highlight_messages() {
    echo "--- Example 2: Highlighting Messages ---"

    # Info Message (Basic ANSI)
    echo -e "${COLOR_CYAN}INFO: Data processing started successfully.${COLOR_RESET}"

    # Warning Message (256-Color Yellow on Dark Orange Background)
    set_forecolor 226  # Bright Yellow
    set_backcolor 166  # Dark Orange
    echo "WARNING: Disk space is running low. Please clean up soon!"
    reset_color

    # Error Message (True Color Bright Red on Dark Red Background)
    set_true_forecolor 255 0 0
    set_true_backcolor 100 0 0
    echo "ERROR: Critical system failure. Reboot required immediately!"
    reset_color

    # Success Message (256-Color Green)
    set_forecolor 40 # Darker green for a solid success look
    echo "SUCCESS: All tasks completed without errors."
    reset_color

    echo ""
    echo "Message highlighting complete."
    echo ""
}

# --- Example 3: Status Indicators with Bright/Bold Text ---
# This example shows how to use ANSI bold/bright attributes along with colors
# to create distinct status indicators.
example_status_indicators() {
    echo "--- Example 3: Status Indicators ---"

    # Online Status (Bright Green)
    # "\033[1;32m" combines bold (1) with green (32) to get bright green
    printf "${COLOR_GREEN}\033[1mONLINE${COLOR_RESET}: All services are running smoothly.\n"

    # Idle Status (Bright Yellow)
    printf "${COLOR_YELLOW}\033[1mIDLE  ${COLOR_RESET}: No active processes detected.\n"

    # Busy Status (Bright Cyan on Dark Blue Background)
    # Combining bold with 256-color/True Color usually means putting '1;' at the start of the SGR sequence.
    printf "\e[1;38;5;96m\e[48;5;18mBUSY  \e[0m: System is performing heavy computations.\n"

    # Offline Status (Bright Red)
    printf "${COLOR_RED}\033[1mOFFLINE${COLOR_RESET}: Connection lost. Please check network.\n"

    echo ""
    echo "Status indicators complete."
    echo ""
}

# --- Example 4: Colored Directory Listing Simulation ---
# This example simulates coloring files based on type (e.g., executables, archives)
# in a directory listing.
example_colored_ls() {
    echo "--- Example 4: Colored Directory Listing (Simulated) ---"

    echo "Listing files in current directory (simulated):"

    # Simulate some files (replace with 'ls -l' if you want real files, but parsing 'ls' is complex for scripting)
    declare -a files=(
        "README.md"
        "script.sh"
        "archive.tar.gz"
        "config.txt"
        "app_main"
        "image.jpg"
    )

    for file in "${files[@]}"; do
        if [[ "$file" =~ \.sh$ ]]; then
            # Shell scripts (256-color light blue)
            set_forecolor 117
            echo "- ${file}"
            reset_color
        elif [[ "$file" =~ \.gz$|\.zip$|\.tar$ ]]; then
            # Archives (256-color bright magenta)
            set_forecolor 201
            echo "- ${file}"
            reset_color
        elif [[ "$file" =~ ^app_ ]]; then
            # Executables (True Color bright green)
            set_true_forecolor 0 255 0
            echo "- ${file}"
            reset_color
        elif [[ "$file" =~ \.md$ ]]; then
            # Markdown files (ANSI Yellow)
            echo "${COLOR_YELLOW}- ${file}${COLOR_RESET}"
        else
            # Other files (Default color)
            echo "- ${file}"
        fi
    done

    echo ""
    echo "Directory listing complete."
    echo ""
}

# --- Example 5: Basic Progress Bar ---
# A simple text-based progress bar using a single background color.
example_progress_bar() {
    echo "--- Example 5: Basic Progress Bar ---"

    echo "Processing data..."

    # Using True Color Green for the progress bar
    set_true_backcolor 50 205 50 # Lime Green Background
    set_true_forecolor 255 255 255 # White text

    # Simulate progress
    for i in $(seq 1 10); do
        # Print a block, then backspace, then wait
        # The backspaces (\b) move the cursor left without erasing, then we overwrite
        printf "\r[ %-10s ] %s%%" "$(printf "%*s" "$i" "" | tr ' ' '#')" "$((i * 10))"
        sleep 0.3 # Reduced sleep time for faster demo
    done
    reset_color # Crucial to reset after the bar
    echo -e "\nProcessing complete!" # Newline after the bar

    echo ""
    echo "Progress bar example finished."
    echo ""
}

# --- Example 6: Interactive Menu with Highlighted Selection ---
# This example demonstrates creating a simple interactive menu where the selected
# option is highlighted with colors. This requires some basic cursor control.
# Note: For arrow keys, a more robust TUI library or 'bind -x' is needed.
# This example uses 'A' for Up and 'B' for Down due to simplicity with 'read -n1'.
example_interactive_menu() {
    echo "--- Example 6: Interactive Menu ---"
    # Hide cursor (optional, but good for interactive elements)
    printf "\e[?25l"

    local menu_options=("Option A: Start Service" "Option B: Check Status" "Option C: View Logs" "Option D: Exit")
    local selected_option=0 # Index of the currently selected option

    # Function to draw the menu
    draw_menu_internal() {
        local i
        # Move cursor to start of menu area (approx. 2 lines down from current pos, then clear down)
        # We save cursor position, print menu, then restore to allow clean redraw
        printf "\e[s" # Save cursor position
        printf "\e[H\e[B" # Move to home, then down 1 line (adjust if script output shifts it)
        printf "\e[J" # Clear screen from cursor down

        echo "Please select an option ( Up, Down):"
        for i in "${!menu_options[@]}"; do
            if [[ "$i" -eq "$selected_option" ]]; then
                # Highlight selected option with True Color background
                set_true_forecolor 255 255 255 # White text
                set_true_backcolor 0 100 200  # Medium Blue background
                echo "> ${menu_options[$i]}"
                reset_color
            else
                echo "  ${menu_options[$i]}"
            fi
        done
        printf "\e[u" # Restore cursor position
    }

    # Read user input for navigation
    read_input_internal() {
        # Read a single character, without echoing, timeout of 0.1s
        read -rsn1 -t 0.1 key
        case "$key" in
            A) # Up key (using 'Up' as placeholder for simplicity)
                selected_option=$(( (selected_option - 1 + ${#menu_options[@]}) % ${#menu_options[@]} ))
                ;;
            B) # Down key (using 'Down' as placeholder for simplicity)
                selected_option=$(( (selected_option + 1) % ${#menu_options[@]} ))
                ;;
            
        esac
        return 0 # Signal to continue loop
    }

    # Main menu loop
    while true; do
        draw_menu_internal
        read_input_internal 
    done

    # Show cursor again when done
    printf "\e[?25h"

    echo ""
    echo "You selected: ${menu_options[$selected_option]}"
    echo "Exiting menu."
    echo ""
}


# ==============================================================================
# --- MAIN SCRIPT EXECUTION (Optional - Uncomment to run all examples) ---
# You can uncomment these lines to run all examples sequentially when the script is executed.
# Or, you can source the script and call specific example functions manually.
# ==============================================================================

# echo "Running all examples..."
# print_colors_table
# example_mix_colors
# example_highlight_messages
# example_status_indicators
# example_colored_ls
# example_progress_bar
# example_interactive_menu
# echo "All examples finished."
