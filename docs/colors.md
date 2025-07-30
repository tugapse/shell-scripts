# Bash Terminal Color Utilities

This script provides a set of functions to control text colors in the bash terminal.

## Introduction

The project aims to offer color utilities for the bash terminal, including support for standard ANSI 16 colors, the 256-color palette, and True Color (24-bit RGB).

## Usage Instructions

To use this script, follow these steps:

1. Source the script by running `source /path/to/colors.sh`
2. Use the functions as needed:
	* Print all 256 color codes: `print_colors_table`
	* Set foreground color using 256-color palette code: `set_forecolor <code>`
	* Set background color using 256-color palette code: `set_backcolor <code>`
	* Reset colors and attributes to default: `reset_color`
	* Set True Color (RGB) foreground color: `set_true_forecolor <red> <green> <blue>`
	* Set True Color (RGB) background color: `set_true_backcolor <red> <green> <blue>`
3. Use the provided examples as a starting point:
	* Mix colors using different palettes (`example_mix_colors`)
	* Highlight messages with various colors and attributes (`example_highlight_messages`)
	* Display status indicators with bright/bold text (`example_status_indicators`)
	* Simulate colored directory listing (simple example, use at your own discretion): `example_colored_ls`
4. Note: You can run multiple examples sequentially by uncommenting the main execution block in the script.

## Examples

* Color table
![Alt text](../assets/colors_table.png?raw=true "print_color_table")

* Highlight example
![Alt text](../assets/highlight.png?raw=true "example_highlight")

* Mix colors example
![Alt text](../assets/mix_colors.png?raw=true "example_mix_colors")

* Status indicator example
![Alt text](../assets/status_indicator.png?raw=true "status_idicator")

* Progress bar example
![Alt text](../assets/progress_bar.png?raw=true "progress_bar")