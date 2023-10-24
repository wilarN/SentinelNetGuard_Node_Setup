#!/bin/bash

GITHUB_REPO="https://github.com/wilarN/SentinelNetGuard_Node-Host_Software"

INSTALL_DIR="/opt/SentinelNetGuard"

CUSTOM_COMMAND="sennet"

if [ "$(id -u)" != "0" ]; then
  echo "Please run the SentinelNetGuard setup script with sudo or as root."
  exit 1
fi

if [ "$1" == "--uninstall" ]; then
  if [ -d "$INSTALL_DIR" ]; then
    echo "Uninstalling SentinelNetGuard Node..."
    sleep 1
    rm -r "$INSTALL_DIR"
    rm -r "/usr/local/bin/$CUSTOM_COMMAND"
    echo "SentinelNetGuard has been uninstalled."
  else
    echo "SentinelNetGuard is not installed."
  fi
  exit 0
fi

if [ -d "$INSTALL_DIR" ]; then
  echo "Node already present at: $INSTALL_DIR, removing..."
  sleep 1
  rm -r "$INSTALL_DIR"
  rm -r "/usr/local/bin/$CUSTOM_COMMAND"
fi


PID=$(lsof -i :59923 -t)
sudo kill 59923

# Check if a process is using the port already.
if [ -n "$PID" ]; then
    echo "Process with PID $PID is using port 59923. Killing it..."
    kill -9 "$PID"
	sleep 2
else
    echo "No process found using port 59923."
	sleep 2
fi

pre_arg=""
part1_arg=""
part2_arg=""
whitelist=""

if [ "$1" == "-pre" ] && [ -n "$2" ]; then
    pre_arg="$2"
fi

if [ "$3" == "-part1" ] && [ -n "$4" ]; then
    part1_arg="$4"
fi

if [ "$5" == "-part2" ] && [ -n "$6" ]; then
    part2_arg="$6"
fi

if [ "$7" == "-whitelist" ] && [ -n "$8" ]; then
    whitelist="$6"
fi


if ! command -v python3 &> /dev/null; then
  echo "Python 3 is not installed."
  apt-get install python3
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

cd "$INSTALL_DIR"
python3 main.py -pre "$pre_arg" -part1 "$part1_arg" -part2 "$part2_arg" -whitelist "$whitelist"
