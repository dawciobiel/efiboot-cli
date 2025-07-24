#!/bin/bash
# diagnostics.sh — EFI diagnostics and cleaning functions

source "$(dirname "${BASH_SOURCE[0]}")/config.sh"
source "$(dirname "${BASH_SOURCE[0]}")/io.sh"

diagnose_efi() {
    print_info "Running EFI diagnostics..."

    if [[ -d /sys/firmware/efi ]]; then
        print_success "System is running in EFI mode."
    else
        print_error "System is NOT running in EFI mode."
    fi

    if command -v "$EFIBOOTMGR" &>/dev/null; then
        print_success "efibootmgr is available at $EFIBOOTMGR."
    else
        print_error "efibootmgr not found at $EFIBOOTMGR."
    fi

    pause
}

clean_dead_entries() {
    print_info "Cleaning invalid or dead boot entries..."

    local entries
    entries=$(sudo "$EFIBOOTMGR" -v)
    # This is a placeholder: real cleaning requires more logic to check paths on disk.

    print_warning "Automatic cleaning not implemented yet."
    pause
}

filter_linux_windows() {
    print_info "Filtering boot entries: Linux or Windows"

    echo "1) Show Linux entries"
    echo "2) Show Windows entries"
    read -rp "Choose option: " opt

    case "$opt" in
        1) sudo "$EFIBOOTMGR" -v | grep -iE "linux|ubuntu|debian|arch|grub" ;;
        2) sudo "$EFIBOOTMGR" -v | grep -i "windows" ;;
        *) print_warning "Invalid option." ;;
    esac

    pause
}

validate_boot_entries() {
    echo
    echo "[INFO] Validating EFI boot entries..."
    echo

    local line efi_path valid=0 invalid=0 total=0
    local mount_point="/boot/efi"

    mapfile -t lines < <(/usr/sbin/efibootmgr -v)

    for line in "${lines[@]}"; do
        if [[ "$line" =~ ^BootOrder: ]] || [[ "$line" =~ ^BootCurrent: ]]; then
            continue
        fi

        if [[ "$line" =~ ^Boot([0-9A-Fa-f]{4}) ]]; then
            ((total++))

            if echo "$line" | grep -q 'File('; then
                efi_path=$(echo "$line" | sed -n 's/.*File(\\\?\([^)]*\)).*/\1/p')
                efi_path="${efi_path//\\//}"

                if [[ -f "$mount_point/$efi_path" ]]; then
                    echo -e "${GREEN}✔${NC} ${line%%$'\t'*} — loader found at $mount_point/$efi_path"
                    ((valid++))
                else
                    echo -e "${RED}✘${NC} ${line%%$'\t'*} — loader NOT found at $mount_point/$efi_path"
                    ((invalid++))
                fi
            else
                echo -e "${YELLOW}⚠${NC} ${line%%$'\t'*} — no EFI file path found, skipping validation"
                ((invalid++))
            fi
        fi
    done

    echo
    echo "[INFO] Validation complete: $valid valid, $invalid invalid, total $total entries."
    echo
    read -rp "Press Enter to continue..."
}


