#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

error_exit() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
    exit 1
}

# Simple and reliable loop prevention
if ps -o cmd= -C "parafast" | grep -q "parafast"; then
    echo -e "${YELLOW}Parafast is already running! Exiting...${NC}"
    exit 0
fi

if ! command -v curl &> /dev/null; then
    error_exit "Install curl first: 'pkg install curl' (Termux) or 'sudo apt install curl' (Linux)"
fi

ARCH=$(uname -m)
echo -e "${YELLOW}Detected architecture: $ARCH${NC}"

URL32="https://github.com/chamanola/parafast/raw/main/android%2032%20bit/parafast"
URL64="https://github.com/chamanola/parafast/raw/main/android%2Blinux%2064bit/parafast"

case "$ARCH" in
    armv7l|i686|x86|arm) DOWNLOAD_URL=$URL32 ;;
    arm64|aarch64|x86_64) DOWNLOAD_URL=$URL64 ;;
    *) error_exit "Unsupported CPU: $ARCH" ;;
esac

# Clean and simple installation
{
    rm -f ~/go/bin/parafast
    mkdir -p ~/go/bin
    curl -L "$DOWNLOAD_URL" -o ~/go/bin/parafast
    chmod +x ~/go/bin/parafast
} || error_exit "Installation failed"

# Add to PATH if missing
grep -q 'export PATH=$PATH:$HOME/go/bin' ~/.bashrc || \
    echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.bashrc

export PATH="$PATH:$HOME/go/bin"

echo -e "${GREEN}✔ Successfully installed!${NC}"
echo -e "${YELLOW}Starting Parafast...${NC}"

# Safest possible execution
(~/go/bin/parafast &) 2>/dev/null || \
    echo -e "${RED}Couldn't auto-start. Run manually: ${YELLOW}parafast${NC}"

exit 0
