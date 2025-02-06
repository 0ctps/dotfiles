#!/bin/bash

# Get default network configuration
get_default_network() {
    local gateway=$(ip route | grep default | awk '{print $3}' | head -n1)
    if [[ -z "$gateway" ]]; then
        echo "Error: Could not determine default gateway." >&2
        exit 1
    fi

    local interface=$(ip route | grep default | awk '{print $5}' | head -n1)
    if [[ -z "$interface" ]]; then
        echo "Error: Could not determine network interface." >&2
        exit 1
    fi

    local network=$(ip route | grep -v default | grep $interface | grep -v linkdown | head -n1 | awk '{print $1}')
    if [[ -z "$network" ]]; then
        echo "Error: Could not determine network address." >&2
        exit 1
    fi

    echo "$network"
}

# Validate IP address format
is_valid_ip() {
    local ip=$1
    if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        IFS='.' read -ra OCTETS <<< "$ip"
        for octet in "${OCTETS[@]}"; do
            if [[ $octet -gt 255 ]]; then
                return 1
            fi
        done
        return 0
    else
        return 1
    fi
}

# Validate subnet mask
is_valid_subnet() {
    local subnet=$1
    if [[ $subnet =~ ^[0-9]+$ ]] && (( subnet >= 0 && subnet <= 32 )); then
        return 0
    else
        return 1
    fi
}

# Convert IP address to decimal format
ip_to_decimal() {
    local ip=$1
    IFS='.' read -ra OCTETS <<< "$ip"
    echo $((OCTETS[0] * 256**3 + OCTETS[1] * 256**2 + OCTETS[2] * 256 + OCTETS[3]))
}

# Convert decimal to IP address
decimal_to_ip() {
    printf "%d.%d.%d.%d" $(($1>>24)) $(($1>>16&255)) $(($1>>8&255)) $(($1&255))
}

# Check if an IP address is active
check_ip_status() {
    local ip=$1
    if ping -c 1 -W "$PING_TIMEOUT_SEC" "$ip" &> /dev/null; then
        echo "$ip:$ICON_ACTIVE:active"
    else
        echo "$ip:$ICON_INACTIVE:inactive"
    fi
}

# Scan network range
scan_network() {
    local start_ip=$1
    local end_ip=$2
    local subnet_mask=$3
    local results_file=$4

    for ((ip=start_ip+1; ip<end_ip; ip++)); do
        check_ip_status "$(decimal_to_ip $ip)" >> "$results_file" &

        while [ $(jobs -p | wc -l) -ge $MAX_PARALLEL_PINGS ]; do
            sleep 0.1
        done
    done

    wait
}
