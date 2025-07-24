#!/bin/bash
# io.sh — input/output functions and colored messages

source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BOLD}${CYAN}efiboot-cli v${EFIBOOT_CLI_VERSION}${RESET}"
    echo
}

pause() {
    read -rp "Press Enter to continue..."
}

clear_screen() {
    clear
}

