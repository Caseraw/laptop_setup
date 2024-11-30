#!/bin/bash

# Default configuration
DEFAULT_ANSWERS_FILE="setup_answers.conf"
ANSWERS_FILE=""
AUTO_YES=false
DRY_RUN=false

# Utility functions
draw_line() {
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' '-'
}

ask() {
  local prompt="$1"
  local default="$2"
  if $AUTO_YES; then
    echo "$prompt [AUTO: $default]"
    echo "$default"
    return
  fi
  read -p "$prompt [Default: $default]: " response
  echo "${response:-$default}"
}

save_answer() {
  local key="$1"
  local value="$2"
  if [[ -n "$ANSWERS_FILE" ]]; then
    echo "$key=$value" >> "$ANSWERS_FILE"
  fi
}

load_answers() {
  if [[ -f "$ANSWERS_FILE" ]]; then
    echo "Loading answers from $ANSWERS_FILE..."
    source "$ANSWERS_FILE"
  else
    echo "No answers file found at $ANSWERS_FILE. Proceeding without importing."
  fi
}

create_new_answers_file() {
  local destination="$1"
  if [[ -z "$destination" ]]; then
    destination="$(pwd)/$DEFAULT_ANSWERS_FILE"
  fi
  ANSWERS_FILE="$destination"
  > "$ANSWERS_FILE" # Truncate or create the file
  echo "New answers file will be saved to $ANSWERS_FILE"
}

show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo
  echo "Options:"
  echo "  --setup                        Run the setup process."
  echo "  --yes                          Auto-confirm all prompts with default options."
  echo "  --import [FILE_PATH]           Import answers from a specified file. Defaults to 'setup_answers.conf'."
  echo "  --new-answers-file [FILE_PATH] Create a new answers file. Optional: Specify the file path."
  echo "  --dry-run                      Show what the script will do without making changes."
  echo "  --help                         Show this help message and exit."
  echo
  echo "Examples:"
  echo "  $0 --setup --yes                                Run the setup with auto-confirmed prompts."
  echo "  $0 --setup --dry-run                            Show planned actions without applying changes."
  echo "  $0 --setup --import /path/to/answers.conf       Import answers from a specific file."
}

run_command() {
  if $DRY_RUN; then
    echo "[DRY-RUN] $*"
  else
    eval "$@" || { echo "Error: Command failed - $*"; exit 1; }
  fi
}

set_hostname() {
  draw_line
  echo "Setting Hostname"
  draw_line
  local hostname=$(ask "Enter hostname" "worker.local")
  run_command "sudo hostnamectl set-hostname '$hostname'"
  run_command "sudo hostnamectl"
}

configure_sudoers() {
  draw_line
  echo "Configuring sudoers for user"
  draw_line
  local username=$(ask "Enter username for sudoers rule" "caseraw")
  run_command "echo '$username ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/$username"
}

install_packages() {
  draw_line
  local proceed=$(ask "Proceed with installing essential packages?" "yes")
  if [[ "$proceed" != "yes" ]]; then
    echo "Skipping package installation."
    return
  fi
  draw_line
  echo "Installing essential packages"
  draw_line
  run_command "sudo dnf -y install \
    git \
    bash-completion \
    tmux \
    tilix \
    gnome-tweaks \
    tree \
    lsof  \
    pavucontrol \
    cmatrix \
    vim-enhanced \
    tcpdump \
    nc \
    wget \
    curl \
    akmod-nvidia xorg-x11-drv-nvidia-cuda \
    toolbox \
    podman \
    podman-compose \
    podman-docker \
    skopeo \
    buildah"
}

setup_firewall() {
  draw_line
  local proceed=$(ask "Proceed with setting up the firewall?" "yes")
  if [[ "$proceed" != "yes" ]]; then
    echo "Skipping firewall setup."
    return
  fi
  draw_line
  echo "Setting up firewall"
  draw_line
  run_command "sudo systemctl enable firewalld --now"
  run_command "sudo firewall-cmd --state"
  run_command "sudo firewall-cmd --list-all"
}

setup_podman(){
  draw_line
  local proceed=$(ask "Proceed with Podman setup?" "yes")
  if [[ "$proceed" != "yes" ]]; then
    echo "Skipping Podman setup."
    return
  fi
  draw_line
  echo "Setting up Podman."
  draw_line
  run_command "systemctl --user start podman.socket"
  run_command "systemctl --user enable podman.socket"
  run_command "mkdir -p $HOME/Documents/Projects"
  run_command "sudo semanage fcontext -a -t httpd_sys_content_t '$HOME/Documents/Projects(/.*)?'"
  run_command "sudo restorecon -R -v $HOME/Documents/Projects"
}

install_vscode() {
  draw_line
  local proceed=$(ask "Proceed with installing Visual Studio Code?" "yes")
  if [[ "$proceed" != "yes" ]]; then
    echo "Skipping Visual Studio Code installation."
    return
  fi
  draw_line
  echo "Installing Visual Studio Code"
  draw_line
  run_command "sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc"
  run_command "sudo sh -c 'echo -e \"[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc\" > /etc/yum.repos.d/vscode.repo'"
  run_command "sudo dnf check-update | true"
  run_command "sudo dnf install -y code"
}

install_flatpack_packages() {
  draw_line
  local proceed=$(ask "Proceed with installing Flatpack packages?" "yes")
  if [[ "$proceed" != "yes" ]]; then
    echo "Skipping Flatpack packages installation."
    return
  fi
  draw_line
  echo "Installing Flatpack packages"
  draw_line
  run_command "sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo"
  run_command "flatpak install -y flathub org.videolan.VLC"
  run_command "flatpak install -y flathub com.obsproject.Studio"
  run_command "flatpak install -y flathub org.gimp.GIMP"
  run_command "flatpak install -y flathub org.videolan.VLC"
  run_command "flatpak install -y flathub org.inkscape.Inkscape"
  run_command "flatpak install -y flathub com.jgraph.drawio.desktop"
  run_command "flatpak install -y flathub org.olivevideoeditor.Olive"
  run_command "flatpak install -y flathub com.spotify.Client"
  run_command "flatpak install -y flathub com.stremio.Stremio"
  run_command "flatpak install -y flathub org.chromium.Chromium"
  run_command "flatpak install -y flathub com.google.Chrome"
  run_command "flatpak install -y flathub com.brave.Browser"
  run_command "flatpak install -y flathub org.remmina.Remmina"
  run_command "flatpak install -y flathub org.wireshark.Wireshark"
  run_command "flatpak install -y flathub com.getpostman.Postman"
  run_command "flatpak install -y flathub org.gnome.Extensions"
  run_command "flatpak install -y flathub com.slack.Slack"
  run_command "flatpak install -y flathub com.discordapp.Discord"
  run_command "flatpak install -y flathub com.microsoft.Teams"
  run_command "flatpak install -y flathub com.skype.Client"
  run_command "flatpak install -y flathub org.telegram.desktop"
  run_command "flatpak install -y flathub io.bit3.WhatsAppQT"
  run_command "flatpak install -y flathub im.riot.Riot"
  run_command "flatpak install -y flathub us.zoom.Zoom"
}

display_completion_message() {
  draw_line
  echo "Setup completed successfully!"
  echo "Your system is ready to use."
  draw_line
}

run_setup() {
  set_hostname
  configure_sudoers
  install_packages
  setup_firewall
  setup_podman
  install_vscode
  install_flatpack_packages
  display_completion_message
}

main() {
  if [[ $# -eq 0 || "$1" == "--help" ]]; then
    show_help
    exit 0
  fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --setup)
        RUN_SETUP=true
        shift
        ;;
      --yes)
        AUTO_YES=true
        shift
        ;;
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      --import)
        if [[ -n "$2" && "$2" != "--"* ]]; then
          ANSWERS_FILE="$2"
          shift 2
        else
          ANSWERS_FILE="$(pwd)/$DEFAULT_ANSWERS_FILE"
          shift
        fi
        load_answers
        ;;
      --new-answers-file)
        if [[ -n "$2" && "$2" != "--"* ]]; then
          create_new_answers_file "$2"
          shift 2
        else
          create_new_answers_file
          shift
        fi
        ;;
      --help)
        show_help
        exit 0
        ;;
      *)
        echo "Unknown argument: $1"
        show_help
        exit 1
        ;;
    esac
  done

  if [[ "$RUN_SETUP" == "true" ]]; then
    run_setup
  else
    echo "Error: The --setup parameter is required to run the setup."
    show_help
    exit 1
  fi
}

# Start the script
main "$@"
