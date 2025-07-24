#!/bin/bash
#
# efiboot-cli
#
# Description:
#   Console utility for managing EFI boot entries on Linux systems.
#   Supports displaying, modifying, importing/exporting, validating,
#   and cleaning EFI boot entries using efibootmgr.
#
# Requirements:
#   - Linux system with EFI boot support
#   - efibootmgr installed and accessible (usually /usr/sbin/efibootmgr)
#   - Bash shell
#
# Author:
#   Dawid Bielecki (dawciobiel)
#   http://github.com/dawciobiel/efiboot-cli
#
# License:
#   GNU General Public License v3.0 (GPL-3.0)
#


# Load libs
LIB_DIR="$(dirname "$0")/lib"

source "$LIB_DIR/colors.sh"
source "$LIB_DIR/config.sh"
source "$LIB_DIR/io.sh"
source "$LIB_DIR/core.sh"
source "$LIB_DIR/export.sh"
source "$LIB_DIR/diagnostics.sh"


main_menu() {
    while true; do
        # clear_screen
        print_header
        echo "1) Show EFI boot entries"
        echo "2) Change boot order"
        echo "3) Delete boot entry"
        echo "4) Add boot entry"
        echo "5) Hide boot entry"
        echo "6) Export all entries"
        echo "7) Import all entries"
        echo "8) Export single entry"
        echo "9) Import single entry"
        echo "10) EFI diagnostics"
        # echo "11) Clean dead entries"
        echo "12) Show only Linux/Windows entries"
        echo "13) Validate boot entries"
        echo "0) Exit"
        echo

        read -rp "Choose option: " opt
        case "$opt" in
            1) list_entries ;;
            2) change_order ;;
            3) delete_entry ;;
            4) add_entry ;;
            5) hide_entry ;;
            6) export_all ;;
            7) import_all ;;
            8) export_one ;;
            9) import_one ;;
            10) diagnose_efi ;;
            # 11) clean_dead_entries ;;
            12) filter_linux_windows ;;
            13) validate_boot_entries ;;
            0) print_info "Exiting..."; exit 0 ;;
            *) print_warning "Invalid option." ;;
        esac
    done
}

main_menu

