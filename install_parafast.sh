ARCH=$(uname -m)

URL32="https://github.com/chamanola/parafast/raw/main/android%2032%20bit/parafast"
URL64="https://github.com/chamanola/parafast/raw/main/android%2Blinux%2064bit/parafast"

if [[ "$ARCH" == "armv7l" || "$ARCH" == "i686" || "$ARCH" == "x86" || "$ARCH" == "arm" ]]; then
    echo "32-bit architecture detected (armv7, i686, x86, or arm). Installing 32-bit Parafast..."
    DOWNLOAD_URL=$URL32
elif [[ "$ARCH" == "arm64" || "$ARCH" == "aarch64" || "$ARCH" == "x86_64" ]]; then
    echo "64-bit architecture detected (arm64, aarch64, x86_64). Installing 64-bit Parafast..."
    DOWNLOAD_URL=$URL64
else
    echo "⚠️ Unsupported architecture detected: $ARCH."
    exit 1
fi

echo "Removing any existing expiry lock file..."
rm -f /data/data/com.termux/files/home/.parafast_expired 2>/dev/null

echo "Installing Parafast..."
mkdir -p ~/go/bin
curl -Lo ~/go/bin/parafast $DOWNLOAD_URL && chmod +x ~/go/bin/parafast

echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.bashrc && source ~/.bashrc

echo "Cleaning up installation files..."
SCRIPT_NAME=$(basename "$0")
rm -f "$SCRIPT_NAME" 2>/dev/null

echo -e "\n✅ Parafast installation successful!"

echo "Starting Parafast..."
parafast

exit 0
