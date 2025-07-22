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

# Check if this is a recursive call from parafast itself
if [[ -n "$PARAFAST_INSTALLER_MODE" ]]; then
    echo -e "${YELLOW}[Info] Installer called from parafast, skipping auto-run${NC}"
    exit 0
fi

if ! command -v curl &> /dev/null; then
    error_exit "Install curl first: 'pkg install curl' (Termux) or 'sudo apt install curl' (Linux)"
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
    error_exit "Unsupported architecture: $ARCH"
fi

# Cleanup
rm -f ~/go/bin/parafast ~/go/bin/parafast_main 2>/dev/null || true
mkdir -p ~/go/bin || error_exit "Failed to create ~/go/bin"

# Download and install
echo -e "${YELLOW}Downloading parafast...${NC}"
curl -L "$DOWNLOAD_URL" -o ~/go/bin/parafast || error_exit "Download failed!"
chmod +x ~/go/bin/parafast || error_exit "Failed to make executable"

# Add to PATH if not present
if ! grep -q 'export PATH=$PATH:$HOME/go/bin' ~/.bashrc; then
    echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.bashrc
fi

# Load PATH in current shell
export PATH="$PATH:$HOME/go/bin"

echo -e "${GREEN}✔ Installation successful!${NC}"

# Run parafast safely without looping
echo -e "${YELLOW}🚀 Starting parafast...${NC}"
PARAFAST_INSTALLER_MODE=1 ~/go/bin/parafast || {
    echo -e "${RED}Failed to start parafast automatically. You can run it manually with:${NC}"
    echo -e "${YELLOW}parafast${NC}"
}

exit 0
