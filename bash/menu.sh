#!/usr/bin/bash

# Path to your colors file (make sure this path is correct)
__colors_file="$HOME/.source/colors.bashrc"

# Set to 'true' when an option is selected or menu is exited
__close_menu=false

# --- Menu Display Settings ---
# Minimum width for each option line (including the "> " or "  " prefix).
# This helps align text and create a consistent look.
# The text will be RIGHT-aligned within this width.
__OPTION_MIN_WIDTH=20 # You can adjust this value as needed

# --- Color Variations ---
# Uncomment ONE set of highlight colors to use it.

# Default (Current): White text on Medium Blue background
__HIGHLIGHT_FORECOLOR="255 255 255" # White text
__HIGHLIGHT_BACKCOLOR="0 100 200"   # Medium Blue background

# Variation 1: Black text on Vibrant Green background
# __HIGHLIGHT_FORECOLOR="0 0 0"       # Black text
# __HIGHLIGHT_BACKCOLOR="0 200 0"     # Vibrant Green background

# Variation 2: White text on Deep Magenta background
# __HIGHLIGHT_FORECOLOR="255 255 255" # White text
# __HIGHLIGHT_BACKCOLOR="150 0 150"   # Deep Magenta background

# Variation 3: Yellow text on Dark Gray background
# __HIGHLIGHT_FORECOLOR="255 255 0"   # Yellow text
# __HIGHLIGHT_BACKCOLOR="50 50 50"    # Dark Gray background

# Variation 4: Cyan text on Navy Blue background
# __HIGHLIGHT_FORECOLOR="0 255 255"   # Cyan text
# __HIGHLIGHT_BACKCOLOR="0 0 100"     # Navy Blue background


# Source color functions if the file exists
if [ -f "$__colors_file" ]; then
    source "$__colors_file"
fi

# Main menu function
# This function sets the selected option directly into a variable passed by name.
# It returns 0 on selection, 1 if no option was selected.
# Usage: menu <result_variable_name> <prompt_string> <option1> <option2> ...
menu(){
    local -n result_var_ref="$1" # Nameref to the variable that will hold the result
    shift # Remove the result_variable_name from arguments

    local prompt_user="${1:-Please select an option (Up, Down, Return/Space to select):}"
    shift # Remove the prompt_user from arguments

    local -a menu_options=( "$@" )
    local selected_option=0
    __close_menu=false
    local return_code=1 # Default to 1 (no selection)

    # Save current terminal settings and switch to raw mode (no echo, no canonical processing)
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
        # Clear screen, move cursor to top-left, and print the menu content
        draw_menu_internal "$prompt_user" "$selected_option" "${menu_options[@]}"
        
        # Read user input and update selected_option or set __close_menu
        read_input_internal selected_option menu_options return_code # Pass return_code by name
    done

    # Restore original terminal settings when the menu closes
    stty "$old_stty_settings"
    
    # After the loop, and after restoring stty, assign the selected item to the nameref variable.
    if [[ "$return_code" -eq 0 ]]; then # Only assign if an option was truly selected
        result_var_ref="${menu_options[$selected_option]}"
    else
        result_var_ref="" # Clear the variable if nothing was selected
    fi

    # Print a final newline for cleaner prompt after the menu closes.
    echo ""

    return "$return_code"
}

# Function to read user input (key presses)
# Takes the names of selected_option, menu_options, and return_code as arguments to modify them
read_input_internal() {
    local -n selected_option_ref="$1"
    local -n menu_options_ref="$2"
    local -n return_code_ref="$3" # For setting exit code of menu function
    local key_char
    local read_status

    # Read a single character without echoing, with a 0.2s timeout
    IFS= read -rsn1 -t 0.2 key_char
    read_status=$? # Capture the exit status of 'read'

    case "$key_char" in
        $'\x1b') # ESC character - indicates an escape sequence (e.g., arrow keys)
            # Read the next two characters of the escape sequence (e.g., [A for Up arrow)
            read -rsn2 -t 0.1 rest_of_sequence
            case "$rest_of_sequence" in
                "[A") # Up arrow key
                    selected_option_ref=$(( (selected_option_ref - 1 + ${#menu_options_ref[@]}) % ${#menu_options_ref[@]} ))
                    ;;
                "[B") # Down arrow key
                    selected_option_ref=$(( (selected_option_ref + 1) % ${#menu_options_ref[@]} ))
                    ;;
                *)
                    # Ignore other ESC sequences (e.g., other arrow keys, F-keys, etc.)
                    ;;
            esac
            ;;
        $'\x0a'|$'\x0d') # Newline (LF) or Carriage Return (CR) - typically the Enter key
            __close_menu=true # Signal to close the menu
            return_code_ref=0 # Set return code for success (option selected)
            ;;
        $'\x20') # Spacebar (ASCII 32) - often used for selection in TUIs
            __close_menu=true # Signal to close the menu
            return_code_ref=0 # Set return code for success (option selected)
            ;;
        "") # If key_char is empty (e.g., timeout or a specific terminal's Enter key behavior)
            # Check if read was successful (status 0) which can happen with certain Enter key presses
            if [[ "$read_status" -eq 0 ]]; then 
                __close_menu=true
                return_code_ref=0
            fi
            # For timeout (read_status 142), nothing happens, loop continues.
            ;;
        *)
            # Ignore any other single character key presses
            ;;
    esac
}

# Function to draw the menu on the screen
# This clears the entire screen and prints the menu from the top.
# The cursor will naturally end up at the end of the printed content.
draw_menu_internal() {
    local prompt_text="$1"
    local current_selected_option="$2"
    shift 2
    local -a menu_options_arr=( "$@" )

    # Clear entire screen and move cursor to top-left (Row 1, Column 1)
    # This ensures a clean slate for each redraw.
    printf "\e[2J" # Clear entire screen
    printf "\e[H"  # Move cursor to top-left (Row 1, Column 1)

    # Display the prompt, followed by two newlines for separation.
    printf "%s\n\n" "$prompt_text"

    # Print menu options
    for i in "${!menu_options_arr[@]}"; do
        if [[ "$i" -eq "$current_selected_option" ]]; then
            # Apply True Color highlighting if color functions are available
            if command -v set_true_forecolor &> /dev/null && command -v set_true_backcolor &> /dev/null && command -v reset_color &> /dev/null; then
                set_true_forecolor $__HIGHLIGHT_FORECOLOR
                set_true_backcolor $__HIGHLIGHT_BACKCOLOR
                # Print selected option with RIGHT padding and then a newline
                printf "> %*s\n" $__OPTION_MIN_WIDTH "${menu_options_arr[$i]}"
                reset_color
            else
                # Fallback to basic highlighting with RIGHT padding
                printf "> %*s <\n" $__OPTION_MIN_WIDTH "${menu_options_arr[$i]}"
            fi
        else
            # Print non-selected options with indentation and RIGHT padding
            printf "  %*s\n" $__OPTION_MIN_WIDTH "${menu_options_arr[$i]}"
        fi
    done
    # The cursor will automatically be positioned at the start of the line
    # immediately following the last printed menu item.
}

# This script is designed to be sourced or copied into another script,
# or called directly by piping arguments.
# Example of direct usage with the new variable passing method:
# Create a dummy variable for the result:
# declare my_selection
# ./interactive_menu.sh my_selection "Select a number:" "One" "Two" "Three"
# echo "You selected: $my_selection"
