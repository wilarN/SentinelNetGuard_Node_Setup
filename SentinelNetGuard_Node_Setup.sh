#!/bin/bash

# GitHub repository URL
GITHUB_REPO="https://github.com/wilarN/SentinelNetGuard_Node-Host_Software"

# Installation directory
INSTALL_DIR="/opt/SentinelNetGuard"

# Custom command to run the main.py script
CUSTOM_COMMAND="sennet"

# Check for root privileges
if [ "$(id -u)" != "0" ]; then
  echo "Please run the SentinelNetGuard setup script with sudo or as root."
  exit 1
fi

# Initialize variables
pre_arg=""
part1_arg=""
part2_arg=""

# Check if the -pre argument is set
if [ "$1" == "-pre" ] && [ -n "$2" ]; then
    pre_arg="$2"
fi

# Check if the -part1 argument is set
if [ "$3" == "-part1" ] && [ -n "$4" ]; then
    part1_arg="$4"
fi

# Check if the -part2 argument is set
if [ "$5" == "-part2" ] && [ -n "$6" ]; then
    part2_arg="$6"
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

mv "$INSTALL_DIR/sennet" "/usr/local/bin/$CUSTOM_COMMAND"
chmod +x "/usr/local/bin/$CUSTOM_COMMAND"

echo $pre_arg
echo $part1_arg
echo $part2_arg
sleep 5

# Start
cd "$INSTALL_DIR"
if [ -n "$pre_arg" ] && [ -n "$part1_arg" ] && [ -n "$part2_arg" ]; then
    python3 main.py -pre "$pre_arg" -part1 "$part1_arg" -part2 "$part2_arg"
else
    python3 main.py -pre "$pre_arg" -part1 "$part1_arg" -part2 "$part2_arg"
fi
