#!/bin/bash
# sync-setup.sh - Syncthing setup helper for omo-mem
# Detects Syncthing, shows device ID, and prints setup instructions

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux)  echo "linux" ;;
        *)      echo "unknown" ;;
    esac
}

OS=$(detect_os)

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         omo-mem Syncthing Setup Helper                     ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if Syncthing is installed
check_syncthing() {
    if command -v syncthing &> /dev/null; then
        echo -e "${GREEN}✓ Syncthing is installed${NC}"
        syncthing --version | head -1
        return 0
    else
        echo -e "${RED}✗ Syncthing is not installed${NC}"
        return 1
    fi
}

# Install instructions by OS
show_install_instructions() {
    echo ""
    echo -e "${YELLOW}Installation instructions:${NC}"
    echo ""
    
    case "$OS" in
        macos)
            echo "  brew install syncthing"
            echo ""
            echo "  # Start Syncthing (run in background)"
            echo "  brew services start syncthing"
            echo ""
            echo "  # Or run manually"
            echo "  syncthing"
            ;;
        linux)
            echo "  # Add official repository (Debian/Ubuntu)"
            echo "  sudo mkdir -p /etc/apt/keyrings"
            echo "  sudo curl -L -o /etc/apt/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg"
            echo '  echo "deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list'
            echo "  sudo apt-get update"
            echo "  sudo apt-get install syncthing"
            echo ""
            echo "  # Start Syncthing"
            echo "  systemctl --user enable syncthing"
            echo "  systemctl --user start syncthing"
            ;;
        *)
            echo "  Visit: https://syncthing.net/downloads/"
            ;;
    esac
    echo ""
    echo -e "${YELLOW}After installing, run this script again.${NC}"
}

# Get and display device ID
show_device_id() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}This device's ID:${NC}"
    echo ""
    
    DEVICE_ID=$(syncthing device-id 2>/dev/null || syncthing -device-id 2>/dev/null || echo "")
    
    if [ -n "$DEVICE_ID" ]; then
        echo -e "  ${GREEN}${DEVICE_ID}${NC}"
        echo ""
        echo -e "${CYAN}Copy this ID and add it to your other devices.${NC}"
    else
        echo -e "${RED}Could not get device ID. Is Syncthing running?${NC}"
        echo ""
        echo "Start Syncthing first:"
        case "$OS" in
            macos) echo "  brew services start syncthing" ;;
            linux) echo "  systemctl --user start syncthing" ;;
        esac
    fi
}

# Show folder setup instructions
show_folder_setup() {
    OMOMEM_PATH="$HOME/workspace/omo-mem"
    
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Folder Setup Instructions:${NC}"
    echo ""
    echo "1. Open Syncthing Web UI:"
    echo "   http://localhost:8384"
    echo ""
    echo "2. Add Remote Device (for each other machine):"
    echo "   - Click 'Add Remote Device'"
    echo "   - Paste the device ID from the other machine"
    echo "   - Give it a name (e.g., 'mbp', 'sh', 'mba')"
    echo "   - Save"
    echo ""
    echo "3. Add Folder to sync:"
    echo "   - Click 'Add Folder'"
    echo "   - Folder Label: omo-mem"
    echo "   - Folder Path: ${OMOMEM_PATH}"
    echo "   - Share with: Select all your devices"
    echo "   - Save"
    echo ""
    echo "4. On other devices:"
    echo "   - Accept the folder share request"
    echo "   - Set path to: ~/workspace/omo-mem"
    echo ""
}

# Show relay info
show_relay_info() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Relay Configuration:${NC}"
    echo ""
    echo "Your devices will use public relays automatically since they"
    echo "can't directly connect (different networks, no port forwarding)."
    echo ""
    echo "Default relay pool: relays.syncthing.net"
    echo ""
    echo "This is secure:"
    echo "  - All traffic is TLS encrypted"
    echo "  - Relays cannot read your data"
    echo "  - Connection is end-to-end encrypted"
    echo ""
}

# Show useful commands
show_commands() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Useful Commands:${NC}"
    echo ""
    echo "  # Check device ID"
    echo "  syncthing device-id"
    echo ""
    echo "  # Find sync conflicts"
    echo "  find ~/workspace/omo-mem -name '*.sync-conflict*'"
    echo ""
    echo "  # Check Syncthing status"
    case "$OS" in
        macos) echo "  brew services info syncthing" ;;
        linux) echo "  systemctl --user status syncthing" ;;
    esac
    echo ""
    echo "  # View logs"
    case "$OS" in
        macos) echo "  cat ~/Library/Application\\ Support/Syncthing/syncthing.log" ;;
        linux) echo "  journalctl --user -u syncthing -f" ;;
    esac
    echo ""
}

# Show conflict resolution
show_conflict_resolution() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Handling Sync Conflicts:${NC}"
    echo ""
    echo "When the same file is edited on multiple devices before syncing,"
    echo "Syncthing creates a conflict file:"
    echo ""
    echo "  MEMORY.sync-conflict-20260226-143052-ABCDEFG.md"
    echo ""
    echo "To resolve:"
    echo "  1. Find conflicts: find ~/workspace/omo-mem -name '*.sync-conflict*'"
    echo "  2. Compare with original: diff MEMORY.md MEMORY.sync-conflict-*.md"
    echo "  3. Merge changes manually into the original file"
    echo "  4. Delete the conflict file"
    echo ""
}

# Main flow
if check_syncthing; then
    show_device_id
    show_folder_setup
    show_relay_info
    show_commands
    show_conflict_resolution
else
    show_install_instructions
fi

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                    Setup Complete                          ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
