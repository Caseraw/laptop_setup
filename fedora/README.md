
# Setup Script for Fedora Workstations

This Bash script automates the initial setup and configuration of a Fedora workstation. It performs essential tasks like setting the hostname, configuring sudoers, installing required packages, setting up the firewall, and installing Visual Studio Code. The script is interactive, but it also supports automation and dry-run functionality.

## Features

- **Interactive Setup**: Prompt-based configuration with default values.
- **Hostname Configuration**: Allows setting a custom hostname.
- **Sudoers Configuration**: Adds the current or specified user to the sudoers file without requiring a password.
- **Package Installation**: Installs a curated list of essential tools and utilities.
- **Firewall Setup**: Enables and configures `firewalld`.
- **Visual Studio Code Installation**: Adds the Microsoft repository and installs Visual Studio Code.
- **Dry-Run Mode**: Preview actions without making changes.
- **Error Handling**: Ensures safe execution by halting on critical errors.

## Requirements

- Fedora Workstation
- Root or sudo privileges
- GNOME desktop environment (for some features)

## Usage

### General Syntax
```bash
./setup.sh [OPTIONS]
```

### Options
- `--setup`: Run the setup process.
- `--yes`: Auto-confirm all prompts with default values.
- `--import [FILE_PATH]`: Import answers from a specified file. Defaults to `setup_answers.conf`.
- `--new-answers-file [FILE_PATH]`: Create a new answers file interactively. Optionally specify the file path.
- `--dry-run`: Show planned actions without applying changes.
- `--help`: Display help and usage instructions.

### Examples

#### Run Interactive Setup
```bash
./setup.sh --setup
```

#### Auto-Confirm Prompts
```bash
./setup.sh --setup --yes
```

#### Dry-Run Mode
```bash
./setup.sh --setup --dry-run
```

#### Import Answers File
```bash
./setup.sh --setup --import /path/to/answers.conf
```

#### Create a New Answers File
```bash
./setup.sh --setup --new-answers-file /path/to/new_answers.conf
```

## Features in Detail

### Hostname Setup
Prompts for a hostname, with a default value of `worker.local`.

### Sudoers Configuration
Adds the specified user to the sudoers file, allowing password-less sudo operations.

### Package Installation
Installs tools like `git`, `tmux`, `vim`, `podman`, and more for development and productivity.

### Firewall Setup
Enables and configures `firewalld`, ensuring the system is secure.

### Visual Studio Code Installation
Adds the Microsoft repository and installs Visual Studio Code.

## Error Handling
The script includes robust error handling. If a command fails, the script halts and displays an error message.

## Dry-Run Mode
In `--dry-run` mode, the script simulates all actions without making any changes, allowing you to preview the setup process.

## Contributions
Feel free to fork this repository and submit pull requests with improvements or additional features.

## License
This script is open-source and available under the MIT License.
