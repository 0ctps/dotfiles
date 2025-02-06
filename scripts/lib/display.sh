#!/bin/bash

# Get terminal size
get_terminal_size() {
    local -n width=$1
    local -n height=$2
    read -r height width < <(stty size)
}

# Remove ANSI escape sequences
strip_ansi() {
    local text="$1"
    echo -e "${text}" | sed 's/\x1B\[[0-9;]*[mGK]//g'
}

# Calculate actual display width
get_display_width() {
    local text="$1"
    local stripped=$(strip_ansi "${text}")
    echo ${#stripped}
}

# Define frame width
FRAME_WIDTH=20  # Border line width

# Calculate number of IPs per line
calculate_ips_per_line() {
    local term_width
    local term_height
    get_terminal_size term_width term_height

    local box_width=$((FRAME_WIDTH + 2))  # Frame width + spacing
    echo $((term_width / box_width))
}

# Generate top frame
create_top_frame() {
    echo -en "${GRAY}╭"
    printf '%.0s─' $(seq 1 $((FRAME_WIDTH - 2)))
    echo -en "╮${RESET}"
}

# Generate bottom frame
create_bottom_frame() {
    echo -en "${GRAY}╰"
    printf '%.0s─' $(seq 1 $((FRAME_WIDTH - 2)))
    echo -en "╯${RESET}"
}

# Format IP status line
format_ip_status() {
    local ip=$1
    local status=$2
    local icon=$3

    # Calculate status icon display width
    local status_icon
    if [[ "$status" == "active" ]]; then
        status_icon="$GREEN${icon}${RESET}"
    else
        status_icon="$RED${icon}${RESET}"
    fi
    local icon_width=$(get_display_width "$status_icon")

    # Calculate IP address display width
    local ip_width=$(get_display_width "$ip")

    # Fixed spacing
    local fixed_space=2

    # Display IP address
    echo -en "${GRAY}│${RESET}$ip"

    # Calculate and add padding
    local padding=$((FRAME_WIDTH - ip_width - icon_width - fixed_space - 1))
    printf "%${padding}s" ""

    # Display status icon
    echo -en "$status_icon ${GRAY}│${RESET}"
}

# Display results
display_results() {
    local filter=$1
    local results_file=$2
    local active_count=0
    local inactive_count=0
    local total_count=0
    local temp_file=$(mktemp)

    # Calculate IPs per line based on terminal width
    local ips_per_line=$(calculate_ips_per_line)

    # Count and filter results
    while IFS=: read -r ip icon status; do
        ((total_count++))
        if [[ "$status" == "active" ]]; then
            ((active_count++))
        else
            ((inactive_count++))
        fi

        if [[ $filter == "all" ]] || \
           [[ $filter == "inactive" && "$status" == "inactive" ]] || \
           [[ $filter == "active" && "$status" == "active" ]]; then
            echo "$ip:${icon}:$status" >> "$temp_file"
        fi
    done < "$results_file"

    echo -e "\n$BOLD""Network Scan Results${RESET}\n"

    # Initialize temporary variables
    local count=0
    declare -a current_ips

    # Load results into array
    mapfile -t results < "$temp_file"
    local total_results=${#results[@]}
    local current_index=0

    while ((current_index < total_results)); do
        # Store current line's IP addresses in array
        count=0
        unset current_ips
        declare -a current_ips

        while ((count < ips_per_line && current_index < total_results)); do
            current_ips[$count]="${results[$current_index]}"
            ((count++))
            ((current_index++))
        done

        # Display top frame
        for ((i = 0; i < count; i++)); do
            create_top_frame
            if ((i < count - 1)); then echo -n "  "; fi
        done
        echo

        # Display IP and status
        for ((i = 0; i < count; i++)); do
            IFS=: read -r ip2 icon2 status2 <<< "${current_ips[$i]}"
            format_ip_status "$ip2" "$status2" "$icon2"
            if ((i < count - 1)); then echo -n "  "; fi
        done
        echo

        # Display bottom frame
        for ((i = 0; i < count; i++)); do
            create_bottom_frame
            if ((i < count - 1)); then echo -n "  "; fi
        done
        echo
    done

    # Display summary
    echo -e "\n$BOLD""Summary${RESET}"
    echo -en "${GRAY}╭────────────────────────────────────╮${RESET}\n"
    echo -en "${GRAY}│${RESET} Active Hosts:    $GREEN$active_count${RESET}"
    printf "%*s${GRAY}│${RESET}\n" $((18 - ${#active_count})) ""
    echo -en "${GRAY}│${RESET} Inactive Hosts:  $RED$inactive_count${RESET}"
    printf "%*s${GRAY}│${RESET}\n" $((18 - ${#inactive_count})) ""
    echo -en "${GRAY}│${RESET} Total Hosts:     $BLUE$total_count${RESET}"
    printf "%*s${GRAY}│${RESET}\n" $((18 - ${#total_count})) ""
    echo -en "${GRAY}╰────────────────────────────────────╯${RESET}\n"
    
    # Remove temporary file
    rm -f "$temp_file"
}
