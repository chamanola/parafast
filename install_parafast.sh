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

if ! command -v curl &> /dev/null; then
    error_exit "curl is required but not installed. Please install curl first."
fi

ARCH=$(uname -m)
echo -e "${YELLOW}Detected architecture: $ARCH${NC}"

URL32="https://github.com/chamanola/parafast/raw/main/android%2032%20bit/parafast"
URL64="https://github.com/chamanola/parafast/raw/main/android%2Blinux%2064bit/parafast"

if [[ "$ARCH" == "armv7l" || "$ARCH" == "i686" || "$ARCH" == "x86" || "$ARCH" == "arm" ]]; then
    echo -e "${GREEN}32-bit architecture detected. Installing 32-bit Parafast...${NC}"
    DOWNLOAD_URL=$URL32
elif [[ "$ARCH" == "arm64" || "$ARCH" == "aarch64" || "$ARCH" == "x86_64" ]]; then
    echo -e "${GREEN}64-bit architecture detected. Installing 64-bit Parafast...${NC}"
    DOWNLOAD_URL=$URL64
else
    error_exit "Unsupported architecture detected: $ARCH"
fi

echo -e "${YELLOW}Cleaning up previous installations...${NC}"
rm -f ~/go/bin/parafast 2>/dev/null || true
rm -f ~/go/bin/parafast_main 2>/dev/null || true

mkdir -p ~/go/bin || error_exit "Failed to create ~/go/bin directory"

echo -e "${YELLOW}Downloading Parafast...${NC}"
if ! curl -L "$DOWNLOAD_URL" -o ~/go/bin/parafast; then
    error_exit "Failed to download Parafast"
fi

chmod +x ~/go/bin/parafast || error_exit "Failed to make parafast executable"

if ! grep -q 'export PATH=$PATH:$HOME/go/bin' ~/.bashrc; then
    echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.bashrc

    source ~/.bashrc 2>/dev/null || true
fi

echo -e "${GREEN}\nInstallation successful!${NC}"
echo -e "You can now run Parafast by typing: ${YELLOW}parafast${NC}"

echo -e "\n${YELLOW}Installation complete. Run 'parafast' manually to start.${NC}"
exit 0

parafast
