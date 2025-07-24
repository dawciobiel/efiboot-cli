#!/bin/bash
# export.sh — export/import EFI boot entries as JSON

source "$(dirname "${BASH_SOURCE[0]}")/config.sh"
source "$(dirname "${BASH_SOURCE[0]}")/io.sh"

check_jq() {
    if ! command -v jq &>/dev/null; then
        print_error "'jq' is required but not installed."
        exit 1
    fi
}

export_all() {
    check_jq
    mkdir -p "$BACKUP_DIR"
    print_info "Exporting all EFI boot entries to JSON file..."

    local entries=()
    local current_entry=""

    while IFS= read -r line; do
        if [[ $line =~ ^Boot([0-9A-Fa-f]{4})(\*)?\ (.*) ]]; then
            [[ -n $current_entry ]] && entries+=("$current_entry")
            local bootnum="${BASH_REMATCH[1]}"
            local active_flag="${BASH_REMATCH[2]}"
            local label="${BASH_REMATCH[3]}"
            current_entry=$(jq -n \
                --arg bootnum "$bootnum" \
                --arg label "$label" \
                --argjson active "$( [[ "$active_flag" == "*" ]] && echo true || echo false )" \
                '{bootnum: $bootnum, label: $label, active: $active}')
        elif [[ $line =~ File:\ (.*) ]]; then
            current_entry=$(echo "$current_entry" | jq --arg file "${BASH_REMATCH[1]}" '. + {file: $file}')
        elif [[ $line =~ Device:\ (.*),\ Partition:\ ([0-9]+) ]]; then
            current_entry=$(echo "$current_entry" | jq \
                --arg disk "${BASH_REMATCH[1]}" \
                --arg part "${BASH_REMATCH[2]}" \
                '. + {disk: $disk, part: $part}')
        fi
    done < <(sudo "$EFIBOOTMGR" -v)

    [[ -n $current_entry ]] && entries+=("$current_entry")

    jq -s '.' <<< "${entries[@]}" > "$EXPORT_FILE"
    print_success "Exported all entries to: $EXPORT_FILE"
    pause
}

import_all() {
    check_jq
    if [[ ! -f "$EXPORT_FILE" ]]; then
        print_error "Backup file not found: $EXPORT_FILE"
        return
    fi
    print_info "Importing EFI boot entries from $EXPORT_FILE..."
    local entries
    entries=$(jq -c '.[]' "$EXPORT_FILE")
    while IFS= read -r entry; do
        local label file disk part
        label=$(jq -r '.label' <<< "$entry")
        file=$(jq -r '.file' <<< "$entry")
        disk=$(jq -r '.disk' <<< "$entry")
        part=$(jq -r '.part' <<< "$entry")
        if [[ -z "$label" || -z "$file" || -z "$disk" || -z "$part" ]]; then
            print_warning "Skipping incomplete entry"
            continue
        fi
        print_info "Creating boot entry: $label"
        sudo "$EFIBOOTMGR" -c -d "$disk" -p "$part" -L "$label" -l "$file"
    done <<< "$entries"
    print_success "Import completed."
    pause
}

export_one() {
    check_jq
    read -rp "Enter boot entry number (e.g., 0001): " id
    id=$(echo "$id" | tr 'a-z' 'A-Z')
    local match=false
    local current_entry=""

    while IFS= read -r line; do
        if [[ $line =~ ^Boot($id)(\*)?\ (.*) ]]; then
            match=true
            local bootnum="${BASH_REMATCH[1]}"
            local active_flag="${BASH_REMATCH[2]}"
            local label="${BASH_REMATCH[3]}"
            current_entry=$(jq -n \
                --arg bootnum "$bootnum" \
                --arg label "$label" \
                --argjson active "$( [[ "$active_flag" == "*" ]] && echo true || echo false )" \
                '{bootnum: $bootnum, label: $label, active: $active}')
        elif [[ "$match" == true && $line =~ File:\ (.*) ]]; then
            current_entry=$(echo "$current_entry" | jq --arg file "${BASH_REMATCH[1]}" '. + {file: $file}')
        elif [[ "$match" == true && $line =~ Device:\ (.*),\ Partition:\ ([0-9]+) ]]; then
            current_entry=$(echo "$current_entry" | jq \
                --arg disk "${BASH_REMATCH[1]}" \
                --arg part "${BASH_REMATCH[2]}" \
                '. + {disk: $disk, part: $part}')
        elif [[ $line =~ ^Boot[0-9A-Fa-f]{4} ]] && [[ "$match" == true ]]; then
            break
        fi
    done < <(sudo "$EFIBOOTMGR" -v)

    if [[ "$match" == true ]]; then
        mkdir -p "$BACKUP_DIR"
        local file="$BACKUP_DIR/bootentry-${id}.json"
        echo "$current_entry" | jq . > "$file"
        print_success "Exported entry $id to $file"
    else
        print_error "Entry Boot$id not found."
    fi
    pause
}

import_one() {
    check_jq
    read -rp "Enter JSON filename to import from (relative to $BACKUP_DIR): " filename
    local filepath="$BACKUP_DIR/$filename"
    if [[ ! -f "$filepath" ]]; then
        print_error "File not found: $filepath"
        pause
        return
    fi
    local entry
    entry=$(jq -c '.' "$filepath")
    local label file disk part
    label=$(jq -r '.label' <<< "$entry")
    file=$(jq -r '.file' <<< "$entry")
    disk=$(jq -r '.disk' <<< "$entry")
    part=$(jq -r '.part' <<< "$entry")
    if [[ -z "$label" || -z "$file" || -z "$disk" || -z "$part" ]]; then
        print_error "Incomplete JSON entry data."
        pause
        return
    fi
    print_info "Creating EFI boot entry: $label"
    sudo "$EFIBOOTMGR" -c -d "$disk" -p "$part" -L "$label" -l "$file"
    print_success "Entry imported successfully."
    pause
}

