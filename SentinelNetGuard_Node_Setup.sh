#!/bin/bash

GITHUB_REPO="https://github.com/wilarN/SentinelNetGuard_Node-Host_Software"

INSTALL_DIR="/opt/SentinelNetGuard"

CUSTOM_COMMAND="sennet"

if [ "$(id -u)" != "0" ]; then
  echo "Please run the SentinelNetGuard setup script with sudo or as root."
  exit 1
fi

INSTALL_USER=${SUDO_USER:-$USER}

if [ "$1" == "--uninstall" ]; then
  if [ -d "$INSTALL_DIR" ]; then
    echo "Uninstalling SentinelNetGuard Node..."
    sleep 1
    rm -r "$INSTALL_DIR"
    rm -r "/usr/local/bin/$CUSTOM_COMMAND"
    rm -rf /var/log/sentinelnetguard
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
debug_flag=""

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
    whitelist="$8"
fi

for arg in "$@"; do
    if [ "$arg" == "--debug" ]; then
        debug_flag="--debug"
    fi
done


apt-get update
apt-get install -y python3 python3-venv python3-pip


mkdir -p "$INSTALL_DIR"

git clone "$GITHUB_REPO" "$INSTALL_DIR" || {
  echo "Failed to clone SentinelNetGuard repository."
  exit 1
}

python3 -m venv "$INSTALL_DIR/venv"

chown -R $INSTALL_USER:$INSTALL_USER "$INSTALL_DIR"
chmod -R 755 "$INSTALL_DIR"

mkdir -p /var/log/sentinelnetguard
chown -R $INSTALL_USER:$INSTALL_USER /var/log/sentinelnetguard
chmod 755 /var/log/sentinelnetguard

sudo -u "$INSTALL_USER" "$INSTALL_DIR/venv/bin/pip" install -r "$INSTALL_DIR/requirements.txt"

mv "$INSTALL_DIR/sennet" "/usr/local/bin/$CUSTOM_COMMAND"
chmod +x "/usr/local/bin/$CUSTOM_COMMAND"

cd "$INSTALL_DIR"
"$INSTALL_DIR/venv/bin/python" main.py -pre "$pre_arg" -part1 "$part1_arg" -part2 "$part2_arg" -whitelist "$whitelist" $debug_flag
