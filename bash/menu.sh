#!/usr/bin/env bash

# ==============================================================================
# Interactive Terminal Menu for Bash
# ==============================================================================
# This script provides a simple, interactive menu for command-line applications.
# It allows users to select an option using arrow keys (Up/Down, Left/Right)
# and confirm with Enter or Space.
#
# Features:
# - Clean output: All interactive display is sent to stderr, leaving stdout
#   clean for piping the selected result.
# - Customizable colors: Supports True Color (24-bit RGB) if color functions
#   are sourced, with fallback to basic highlighting.
# - Columnar display: Options can be arranged into multiple columns for better
#   readability with consistent alignment.
# - Enhanced navigation: Use Up/Down arrows to move between options (circularly
#   through all options), and Left/Right arrows to jump between columns
#   (also circularly through all options).
# - Command-line arguments: Configure columns, cell size, and highlight colors
#   directly from the command line. The prompt is now optional and can be
#   set via an argument.
# - Truncate long names: Option names longer than the cell size will be
#   truncated with an ellipsis (...) for better display.
#
# Usage:
#   ./menu [OPTIONS] "Option 1" "Option 2" ...
#
# Options:
#   -c, --columns <num>      Number of columns to display options (default: 2)
#   -s, --cell-size <num>    Minimum width for each option cell (default: 20)
#   -f, --fore-color <R G B> RGB values for highlight foreground color (e.g., "255 255 255")
#   -b, --back-color <R G B> RGB values for highlight background color (e.g., "0 100 200")
#   -p, --prompt <text>      Custom prompt message for the menu (default: "Select option:")
#   -h, --help               Display this help message and exit.
#
# Examples:
#   # Basic usage with options (uses default prompt):
#   selected_item=$(./menu "Apple" "Banana" "Orange")
#
#   # Custom prompt via argument:
#   selected_os=$(./menu -p "Which OS do you prefer?" "Linux" "macOS" "Windows")
#
#   # Display in 3 columns with a larger cell size:
#   ./menu -c 3 -s 30 "Item A" "Item B" "Item C" "Item D" "Item E"
#
#   # Custom highlight colors (Yellow text on Dark Gray background):
#   ./menu -f "255 255 0" -b "50 50 50" "Setting 1" "Setting 2"
#
#   # Pipe the output to another command:
#   ./menu -c 4 "txt" "md" "log" "json" | xargs -I {} touch "new_file.{}"
#
#   # Example with long names and truncation:
#   ./menu -s 15 "This is a very long option name" "Another long item" "Short"
#
# Configuration:
# - __colors_file: Path to a Bash script defining `set_true_forecolor`,
#   `set_true_backcolor`, and `reset_color` for True Color support.
# - __COLUMN_SPACING: Number of spaces between columns.
# ==============================================================================

# Script Version
VERSION="1.0.6"

# Set to 'true' when an option is selected or menu is exited
__close_menu=false

# --- Default Menu Display Settings (can be overridden by CLI args) ---
__OPTION_MIN_WIDTH=20 # Minimum width for the option text itself
__MENU_COLUMNS=2      # Number of columns to display
__COLUMN_SPACING=4    # Spaces between columns for visual separation

# --- Default Color Variations (can be overridden by CLI args) ---
__HIGHLIGHT_FORECOLOR="255 255 255" # White text
__HIGHLIGHT_BACKCOLOR="0 100 200"   # Medium Blue background
__HEADER_SEPARATOR="\n"

# Function to display the help message
display_help() {
    cat << EOF
Script version: $VERSION
Usage: ./menu [OPTIONS] "Option 1" "Option 2" ...
This script provides an interactive terminal menu.


Options:
  -c, --columns <num>      Number of columns to display options (default: 2)
  -s, --cell-size <num>    Minimum width for each option cell (default: 20)
  -f, --fore-color <R G B> RGB values for highlight foreground color (e.g., "255 255 255")
  -b, --back-color <R G B> RGB values for highlight background color (e.g., "0 100 200")
  -p, --prompt <text>      Custom prompt message for the menu (default: "Select option:")
  -h, --help               Display this help message and exit.

Examples:
  ./menu "Apple" "Banana" "Orange"
  ./menu -p "Which OS?" "Linux" "macOS" "Windows"
  ./menu -c 3 -s 30 "Item A" "Item B" "Item C" "Item D" "Item E"
  ./menu -f "255 255 0" -b "50 50 50" "Setting 1" "Setting 2"
  ./menu -c 4 "txt" "md" "log" "json" | xargs -I {} touch "new_file.{}"

Configuration:
  - __colors_file: Path to a Bash script defining 'set_true_forecolor',
    'set_true_backcolor', and 'reset_color' for True Color support.
  - __COLUMN_SPACING: Number of spaces between columns.
EOF
}

# ==============================================================================
# Argument Parsing
# ==============================================================================
# Initialize variables to hold parsed arguments
_cli_columns=""
_cli_cell_size=""
_cli_fore_color=""
_cli_back_color=""
_cli_prompt_arg="" # Variable for prompt from -p/--prompt
_cli_header_separator="\n"
_cli_options=()

# Use getopt to parse long and short options
# -o: short options (c, s, f, b, p, h all require an argument except h)
# --long: long options (columns, cell-size, fore-color, back-color, prompt, help all require an argument except help)
# Note: 'h' and 'help' do not have a colon, indicating they don't take an argument.
PARSED_OPTIONS=$(getopt -o c:s:f:b:p:h --long columns:,cell-size:,fore-color:,back-color:,prompt:,help -- "$@")

# Check for parsing errors
if [ $? -ne 0 ]; then
    echo "Error: Invalid arguments provided. Use --help for usage." >&2
    exit 1
fi

# Set positional parameters to the parsed output of getopt
eval set -- "$PARSED_OPTIONS"

# Loop through the parsed arguments and assign values
while true; do
    case "$1" in
        -c|--columns)
            _cli_columns="$2"
            shift 2
            ;;
        -s|--cell-size)
            _cli_cell_size="$2"
            shift 2
            ;;
        -f|--fore-color)
            _cli_fore_color="$2"
            shift 2
            ;;
        -b|--back-color)
            _cli_back_color="$2"
            shift 2
            ;;
        -p|--prompt)
            _cli_prompt_arg="$2"
            shift 2
            ;;
        -hs|--header-separator) 
            _cli_header_separator="$2"
            shift 2
            ;;
        -h|--help) # Handle --help argument
            display_help
            exit 0
            ;;
  
        --) # End of options marker
            shift
            break
            ;;
        *)
            echo "Internal error during argument parsing!" >&2
            exit 1
            ;;
    esac
done

# All remaining arguments are now strictly the menu options
_cli_options=("$@")

# Override default global configuration variables with CLI arguments if provided
if [[ -n "$_cli_columns" ]]; then
    __MENU_COLUMNS=$_cli_columns
fi
if [[ -n "$_cli_cell_size" ]]; then
    __OPTION_MIN_WIDTH=$_cli_cell_size
fi
if [[ -n "$_cli_fore_color" ]]; then
    __HIGHLIGHT_FORECOLOR=$_cli_fore_color
fi
if [[ -n "$_cli_back_color" ]]; then
    __HIGHLIGHT_BACKCOLOR=$_cli_back_color
fi
if [[ -n "$_cli_header_separator" ]]; then
    __HEADER_SEPARATOR=$_cli_header_separator
fi

# Determine the final prompt to use: CLI arg > default
_final_prompt=""
if [[ -n "$_cli_prompt_arg" ]]; then
    _final_prompt="$_cli_prompt_arg"
else
    _final_prompt="Select an option:" # Default prompt if -p/--prompt is not provided
fi

# ==============================================================================
# Menu Core Functions
# ==============================================================================

# Main menu function
# Prints the selected option to stdout.
# Returns 0 on selection, 1 if no option was selected.
# All interactive display is sent to stderr.
menu(){
    # Use the prompt passed as the first argument to this function
    local prompt_user="$1"
    shift # Remove the prompt_user from arguments

    local -a menu_options=( "$@" ) # These are the _cli_options
    local selected_option=0
    __close_menu=false
    local return_code=1 # Default to 1 (no selection)

    # Save current terminal settings and switch to raw mode
    local old_stty_settings=$(stty -g)
    stty -icanon -echo

    # Exit if no menu options are provided
    if [ ${#menu_options[@]} -eq 0 ]; then
        echo "Error: No menu options provided." >&2
        stty "$old_stty_settings"
        return 1
    fi

    # Main menu loop
    while [ "$__close_menu" == false ]; do
        # Clear screen and draw menu to stderr
        draw_menu_internal "$prompt_user" "$selected_option" "${menu_options[@]}"
        
        # Read user input
        read_input_internal selected_option menu_options return_code
    done

    # Restore original terminal settings
    stty "$old_stty_settings"
    
    # Print selected item to stdout if an option was chosen
    if [[ "$return_code" -eq 0 ]]; then
        echo "${menu_options[$selected_option]}"
    fi

    # Print a final newline to stderr for cleaner prompt
    echo "" >&2

    return "$return_code"
}

# Function to read user input (key presses)
read_input_internal() {
    local -n selected_option_ref="$1"
    local -n menu_options_ref="$2"
    local -n return_code_ref="$3"
    local key_char
    local read_status

    # Calculate necessary layout variables for navigation
    local num_options=${#menu_options_ref[@]}
    local num_cols=$__MENU_COLUMNS
    local num_rows=$(( (num_options + num_cols - 1) / num_cols )) # Ceiling division

    # Read a single character without echoing, with a 0.2s timeout
    IFS= read -rsn1 -t 0.2 key_char
    read_status=$?

    case "$key_char" in
        $'\x1b') # ESC character (indicates an escape sequence like arrow keys)
            # Read the next two characters of the escape sequence
            read -rsn2 -t 0.1 rest_of_sequence
            case "$rest_of_sequence" in
                "[A") # Up arrow key
                    selected_option_ref=$(( (selected_option_ref - 1 + num_options) % num_options ))
                    ;;
                "[B") # Down arrow key
                    selected_option_ref=$(( (selected_option_ref + 1) % num_options ))
                    ;;
                "[C") # Right arrow key
                    # Move right by 'num_rows' steps, wrapping around the total options
                    selected_option_ref=$(( (selected_option_ref + num_rows) % num_options ))
                    ;;
                "[D") # Left arrow key
                    # Move left by 'num_rows' steps, wrapping around the total options
                    selected_option_ref=$(( (selected_option_ref - num_rows + num_options) % num_options ))
                    ;;
                *)
                    # Ignore other ESC sequences
                    ;;
            esac
            ;;
        $'\x0a'|$'\x0d') # Newline (LF) or Carriage Return (CR) - Enter key
            __close_menu=true
            return_code_ref=0
            ;;
        $'\x20') # Spacebar
            __close_menu=true
            return_code_ref=0
            ;;
        "") # Empty if timeout or specific terminal's Enter key behavior
            if [[ "$read_status" -eq 0 ]]; then
                __close_menu=true
                return_code_ref=0
            fi
            ;;
        *)
            # Ignore any other single character key presses
            ;;
    esac
}

# Function to draw the menu on the screen
# Clears the entire screen and prints the menu from the top to stderr.
draw_menu_internal() {
    local prompt_text="$1"
    local current_selected_option="$2"
    shift 2
    local -a menu_options_arr=( "$@" )
    local num_options=${#menu_options_arr[@]}
    local num_cols=$__MENU_COLUMNS
    local num_rows=$(( (num_options + num_cols - 1) / num_cols )) # Ceiling division

    # Calculate the total width for each cell, including prefix, suffix, and column spacing
    # Prefix "> " is 2 chars, Suffix " <" is 2 chars.
    local cell_total_width=$(( __OPTION_MIN_WIDTH + 2 + 2 + __COLUMN_SPACING ))

    # Clear screen and move cursor to top-left. All output to stderr.
    printf "\e[2J" >&2
    printf "\e[H"  >&2

    # Display the prompt to stderr.
    printf "%s $__HEADER_SEPARATOR" "$prompt_text" >&2

    # Print menu options in columns to stderr.
    for ((row = 0; row < num_rows; row++)); do
        for ((col = 0; col < num_cols; col++)); do
            local option_index=$(( row + col * num_rows ))
            if (( option_index < num_options )); then
                local original_option_text="${menu_options_arr[$option_index]}"
                local display_option_text="$original_option_text"
                local prefix="  " # Default prefix for non-selected
                local suffix="  "    # Default suffix for non-selected (2 spaces for alignment)

                # Truncate if text is too long for the cell
                local max_text_width=$__OPTION_MIN_WIDTH
                if (( ${#display_option_text} > max_text_width )); then
                    display_option_text="${display_option_text:0:$((max_text_width - 3))}..."
                fi

                if (( option_index == current_selected_option )); then
                    prefix="> "
                    suffix=" <" # Add a visual indicator for selected option
                    # Apply True Color highlighting if color functions are available
                    set_true_forecolor $__HIGHLIGHT_FORECOLOR >&2
                    set_true_backcolor $__HIGHLIGHT_BACKCOLOR >&2
                fi
                
                # Calculate padding needed for the display_option_text within its __OPTION_MIN_WIDTH
                local text_padding=$(( __OPTION_MIN_WIDTH - ${#display_option_text} ))
                if (( text_padding < 0 )); then text_padding=0; fi # Ensure no negative padding

                # Print prefix, option text, suffix, and then fill the rest of the cell_total_width
                printf "%s%s%*s%s" "$prefix" "$display_option_text" "$text_padding" "" "$suffix" >&2

                # Reset color after each highlighted option
                if (( option_index == current_selected_option )); then
                    reset_color >&2
                fi
            else
                # Print empty space for alignment for empty cells to match cell_total_width
                printf "%*s" "$cell_total_width" "" >&2
            fi
        done
        printf "\n" >&2 # Newline after each row
    done
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



# When the script is executed directly, parse arguments and call the menu function.
# This makes the script a self-contained command-line tool.
menu "$_final_prompt" "${_cli_options[@]}"
