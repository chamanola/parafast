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

# Check if this is a recursive call
if [ -n "$PARAFAST_INSTALLER_RUNNING" ]; then
    echo -e "${YELLOW}[Info] Installer already running, skipping auto-run${NC}"
    exit 0
fi

export PARAFAST_INSTALLER_RUNNING=1

if ! command -v curl &> /dev/null; then
    error_exit "Install curl first: 'pkg install curl' or 'apt install curl'"
fi

ARCH=$(uname -m)
echo -e "${YELLOW}Detected architecture: $ARCH${NC}"

URL32="https://github.com/chamanola/parafast/raw/main/android%2032%20bit/parafast"
URL64="https://github.com/chamanola/parafast/raw/main/android%2Blinux%2064bit/parafast"

if [[ "$ARCH" == "armv7l" || "$ARCH" == "i686" || "$ARCH" == "x86" || "$ARCH" == "arm" ]]; then
    echo -e "${GREEN}Installing 32-bit version...${NC}"
    DOWNLOAD_URL=$URL32
elif [[ "$ARCH" == "arm64" || "$ARCH" == "aarch64" || "$ARCH" == "x86_64" ]]; then
    echo -e "${GREEN}Installing 64-bit version...${NC}"
    DOWNLOAD_URL=$URL64
else
    error_exit "Unsupported CPU: $ARCH"
fi

# Cleanup and install
rm -f ~/go/bin/parafast 2>/dev/null || true
mkdir -p ~/go/bin || error_exit "Cannot create ~/go/bin"
curl -L "$DOWNLOAD_URL" -o ~/go/bin/parafast || error_exit "Download failed"
chmod +x ~/go/bin/parafast || error_exit "Cannot make executable"

# Add to PATH if needed
if ! grep -q 'export PATH=$PATH:$HOME/go/bin' ~/.bashrc; then
    echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.bashrc
fi

# Source in current shell
export PATH=$PATH:$HOME/go/bin

echo -e "${GREEN}Installation complete!${NC}"

# Safe single execution
echo -e "${YELLOW}Running Parafast...${NC}"
exec ~/go/bin/parafast "$@"

exit 0
