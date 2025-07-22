#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

echo -e "${YELLOW}     ===========================================${NC}"
echo -e "${CYAN}             PARAFAST INSTALLATION TOOL${NC}"
echo -e "${YELLOW}     ===========================================${NC}"
echo ""

error_exit() {
    echo -e "${RED}[✗] ERROR: $1${NC}" >&2
    exit 1
}

if ! command -v curl &> /dev/null; then
    error_exit "curl is required but not installed.\nInstall using:\n  ${YELLOW}Termux: pkg install curl\n  Linux: sudo apt install curl${NC}"
fi

ARCH=$(uname -m)
echo -e "${CYAN}  🔍 Detected architecture: ${YELLOW}$ARCH${NC}"

URL32="https://github.com/chamanola/parafast/raw/main/android%2032%20bit/parafast"
URL64="https://github.com/chamanola/parafast/raw/main/android%2Blinux%2064bit/parafast"

if [[ "$ARCH" == "armv7l" || "$ARCH" == "i686" || "$ARCH" == "x86" || "$ARCH" == "arm" ]]; then
    echo -e "${GREEN}  ↓ Downloading 32-bit version...${NC}"
    DOWNLOAD_URL=$URL32
elif [[ "$ARCH" == "arm64" || "$ARCH" == "aarch64" || "$ARCH" == "x86_64" ]]; then
    echo -e "${GREEN}  ↓ Downloading 64-bit version...${NC}"
    DOWNLOAD_URL=$URL64
else
    error_exit "Unsupported architecture: $ARCH"
fi

echo -e "${YELLOW}  🧹 Cleaning previous installations...${NC}"
rm -f ~/go/bin/parafast ~/go/bin/parafast_main 2>/dev/null || true
mkdir -p ~/go/bin || error_exit "Failed to create ~/go/bin directory"

echo -e "${CYAN}  ⚡ Downloading parafast...${NC}"
if ! curl -L "$DOWNLOAD_URL" -o ~/go/bin/parafast; then
    error_exit "Download failed! Check your internet connection"
fi

chmod +x ~/go/bin/parafast || error_exit "Failed to make parafast executable"

if ! grep -q 'export PATH=$PATH:$HOME/go/bin' ~/.bashrc; then
    echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.bashrc
    echo -e "${GREEN}  ✓ Added to PATH${NC}"
fi

export PATH="$PATH:$HOME/go/bin"

sleep 2

echo -e "${GREEN}"
echo "     ╔══════════════════════════════════════════╗"
echo "                INSTALLATION COMPLETE!         "
echo "     ╚══════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${MAGENTA}   Thank you for installing Parafast!${NC}"
echo ""

sleep 1

exit 0
