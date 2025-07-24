#!/bin/bash
# core.sh — core EFI boot entries functions

source "$(dirname "${BASH_SOURCE[0]}")/config.sh"
source "$(dirname "${BASH_SOURCE[0]}")/io.sh"

list_entries() {
    print_info "Listing current EFI boot entries:"
    sudo "$EFIBOOTMGR"
    pause
}

delete_entry() {
    read -rp "Enter the BootXXXX ID to delete (e.g., 0001): " entry
    if [[ ! $entry =~ ^[0-9A-Fa-f]{4}$ ]]; then
        print_error "Invalid boot entry ID format."
        return
    fi
    print_warning "Deleting boot entry $entry..."
    sudo "$EFIBOOTMGR" -b "$entry" -B
    print_success "Entry $entry deleted."
    pause
}

change_order() {
    print_info "Current Boot Order:"
    sudo "$EFIBOOTMGR" | grep "^BootOrder"
    read -rp "Enter new boot order (comma-separated BootXXXX IDs, e.g. 0003,0001,0002): " new_order
    if [[ -z "$new_order" ]]; then
        print_warning "No new order provided. Aborting."
        return
    fi
    sudo "$EFIBOOTMGR" -o "$new_order"
    print_success "Boot order changed to: $new_order"
    pause
}

add_entry() {
    read -rp "Enter new boot entry label: " label
    read -rp "Enter disk path (e.g. /dev/sda): " disk
    read -rp "Enter partition number (e.g. 1): " part
    read -rp "Enter EFI file path (e.g. \\EFI\\ubuntu\\grubx64.efi): " file
    print_info "Adding new boot entry..."
    sudo "$EFIBOOTMGR" --disk "$disk" --part "$part" --create --label "$label" --loader "$file"
    print_success "Boot entry '$label' added."
    pause
}

hide_entry() {
    print_info "Hiding a boot entry (removing from BootOrder without deletion)."
    read -rp "Enter the BootXXXX ID to hide: " entry
    if [[ ! $entry =~ ^[0-9A-Fa-f]{4}$ ]]; then
        print_error "Invalid boot entry ID format."
        return
    fi
    # Fetch current BootOrder
    local current_order
    current_order=$(sudo "$EFIBOOTMGR" | grep "^BootOrder" | awk -F' ' '{print $2}')
    # Remove the entry from order
    local new_order
    new_order=$(echo "$current_order" | sed "s/$entry//g" | sed 's/,,/,/g' | sed 's/^,//' | sed 's/,$//')
    if [[ "$current_order" == "$new_order" ]]; then
        print_warning "Entry $entry is not in BootOrder or already hidden."
        return
    fi
    sudo "$EFIBOOTMGR" -o "$new_order"
    print_success "Entry $entry hidden (removed from BootOrder)."
    pause
}

