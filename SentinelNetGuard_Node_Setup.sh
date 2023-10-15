#!/bin/bash

# GitHub repository URL
GITHUB_REPO="https://github.com/wilarN/SentinelNetGuard_Node-Host_Software"

# Installation directory
INSTALL_DIR="/opt/SentinelNetGuard"

# Custom command to run the main.py script
CUSTOM_COMMAND="sng"

# Check for root privileges
if [ "$(id -u)" != "0" ]; then
  echo "Please run the SentinelNetGuard setup script with sudo or as root."
  exit 1
fi

# Check for Python 3
if ! command -v python3 &> /dev/null; then
  echo "Python 3 is not installed."
  # Install Python 3
  apt-get install python3
  # Install pip3
  apt-get install python3-pip
fi

mkdir -p "$INSTALL_DIR"

git clone "$GITHUB_REPO" "$INSTALL_DIR"

chown -R root:root "$INSTALL_DIR"
chmod -R 755 "$INSTALL_DIR"
chmod -R o+x "$INSTALL_DIR"

pip3 install -r "$INSTALL_DIR/requirements.txt"

mv "$INSTALL_DIR/sng" "/usr/local/bin/$CUSTOM_COMMAND"
chmod +x "/usr/local/bin/$CUSTOM_COMMAND"

# Start
cd "$INSTALL_DIR"
python3 main.py
