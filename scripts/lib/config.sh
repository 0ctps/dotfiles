#!/bin/bash

# Network scanning configuration
MAX_PARALLEL_PINGS=50
PING_TIMEOUT_SEC=0.1
IPS_PER_LINE=3             # Number of boxes per line

# Status display configuration
ICON_ACTIVE="▣"            # Filled box for active
ICON_INACTIVE="□"          # Empty box for inactive
ICON_ERROR="⚠"            # Warning for errors
ICON_UNKNOWN="?"          # Question mark for unknown state

# Basic color codes (simpler ANSI codes for better compatibility)
GREEN='\033[32m'
RED='\033[31m'
BLUE='\033[34m'
GRAY='\033[90m'
BOLD='\033[1m'
RESET='\033[0m'
