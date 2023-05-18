#!/bin/bash

# Function to check if a command is installed
check_command() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install a command if not already installed
install_command() {
    if ! check_command "$1"; then
        echo "Installing $1"
        sudo apt-get install -y "$1"
        if [ "$1" = "gowitness" ]; then
            go install github.com/sensepost/gowitness@latest
        fi
    fi
}

# Check and install required commands
echo "Checking and installing required tools"

# Check and install go
install_command go

# Check and install assetfinder
install_command assetfinder

# Check and install subfinder
install_command subfinder

# Check and install httprobe
install_command httprobe

# Check and install nmap
install_command nmap

# Check and install gowitness
install_command gowitness

# Make subdigger.sh a system command
chmod +x subdigger.sh
sudo ln -sf "$(pwd)/subdigger.sh" /usr/local/bin/subdigger

echo "Installation complete."
