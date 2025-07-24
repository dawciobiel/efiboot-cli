# efiboot-cli

`efiboot-cli` is a user-friendly command-line interface for managing EFI boot entries on Linux systems.  
It wraps around `efibootmgr` and provides an intuitive, color-enhanced menu for common boot configuration tasks.

## Features

- View current EFI boot entries
- Change boot order interactively
- Add or delete boot entries
- Export/import all entries to/from `.json`
- Export/import individual entries
- Filter entries (Linux / Windows)
- Validate boot entries (checks loader file paths)
- Perform basic EFI diagnostics
- Clean up dead or invalid entries (WIP)

## Requirements

- Linux system with EFI firmware
- Bash shell
- `efibootmgr` installed (usually found at `/usr/sbin/efibootmgr`)
- `jq` for JSON import/export
- Root privileges (or sudo access) for modifying EFI entries

## Installation

Clone the repository:

```bash
git clone https://github.com/dawciobiel/efiboot-cli.git
cd efiboot-cli
chmod +x efiboot-cli.sh
````

Run the CLI:

```bash
./efiboot-cli.sh
```

## Example

```
efiboot-cli v0.1.0

1) Show EFI boot entries
2) Change boot order
3) Delete boot entry
...
13) Validate boot entries
0) Exit
```

## Export format

Entries are exported to a readable `.json` format. Example:

```json
{
  "Boot0000": {
    "description": "opensuse-secureboot",
    "file": "\\EFI\\opensuse\\shim.efi",
    "active": true
  }
}
```

## Author

Created by **Dawid Bielecki**  
GitHub: [@dawciobiel](https://github.com/dawciobiel)  
Project: [efiboot-cli](https://github.com/dawciobiel/efiboot-cli)  

## License

This project is licensed under the **GNU GPLv3 License**.
