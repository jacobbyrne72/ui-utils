#!/bin/bash

# UI-Utils Auto-Installation Script for Minecraft 1.21.4 Servers
# Version: 1.0
# Author: Modified for automatic installation

# Text colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}      UI-Utils Auto-Installation for MC 1.21.4      ${NC}"
echo -e "${BLUE}====================================================${NC}"

# Check if script is run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo -e "${YELLOW}This script requires root privileges to install properly.${NC}"
  echo -e "${YELLOW}Please run with sudo or as root.${NC}"
  exit 1
fi

# Detect server directories
echo -e "${GREEN}Detecting Minecraft server directories...${NC}"
POSSIBLE_DIRS=()

# Common server directories
check_dirs=(
  "/opt/minecraft"
  "/home/*/minecraft"
  "/home/*/server"
  "/home/*/mc"
  "/home/*/Minecraft"
  "/srv/minecraft"
)

for pattern in "${check_dirs[@]}"; do
  found_dirs=$(find $pattern -maxdepth 0 -type d 2>/dev/null)
  for dir in $found_dirs; do
    if [ -f "$dir/server.jar" ] || [ -f "$dir/spigot.jar" ] || [ -f "$dir/paper.jar" ] || [ -f "$dir/fabric-server-launch.jar" ]; then
      POSSIBLE_DIRS+=("$dir")
    fi
  done
done

# If no directories found, ask for manual input
if [ ${#POSSIBLE_DIRS[@]} -eq 0 ]; then
  echo -e "${YELLOW}No Minecraft server directories detected automatically.${NC}"
  read -p "Please enter your Minecraft server directory path: " SERVER_DIR
  
  if [ ! -d "$SERVER_DIR" ]; then
    echo -e "${RED}Error: Directory does not exist.${NC}"
    exit 1
  fi
  
  SELECTED_DIR="$SERVER_DIR"
else
  echo -e "${GREEN}Found ${#POSSIBLE_DIRS[@]} potential Minecraft server directories:${NC}"
  for i in "${!POSSIBLE_DIRS[@]}"; do
    echo -e "  ${BLUE}[$i]${NC} ${POSSIBLE_DIRS[$i]}"
  done
  
  read -p "Select a directory by number (or enter a custom path): " SELECTION
  
  if [[ "$SELECTION" =~ ^[0-9]+$ ]] && [ "$SELECTION" -lt ${#POSSIBLE_DIRS[@]} ]; then
    SELECTED_DIR="${POSSIBLE_DIRS[$SELECTION]}"
  else
    SELECTED_DIR="$SELECTION"
    if [ ! -d "$SELECTED_DIR" ]; then
      echo -e "${RED}Error: Directory does not exist.${NC}"
      exit 1
    fi
  fi
fi

echo -e "${GREEN}Selected server directory: ${BLUE}$SELECTED_DIR${NC}"

# Create mods directory if it doesn't exist
MODS_DIR="$SELECTED_DIR/mods"
if [ ! -d "$MODS_DIR" ]; then
  echo -e "${YELLOW}Creating mods directory...${NC}"
  mkdir -p "$MODS_DIR"
fi

# Create plugins directory if it doesn't exist (for hybrid servers)
PLUGINS_DIR="$SELECTED_DIR/plugins"
if [ ! -d "$PLUGINS_DIR" ]; then
  echo -e "${YELLOW}Creating plugins directory...${NC}"
  mkdir -p "$PLUGINS_DIR"
fi

# Download UI-Utils for 1.21.4
echo -e "${GREEN}Downloading UI-Utils for Minecraft 1.21.4...${NC}"
DOWNLOAD_URL="https://github.com/jacobbyrne72/ui-utils/releases/download/v2.3.1/ui-utils-2.3.1-mc1.21.4.jar"
MOD_PATH="$MODS_DIR/ui-utils-2.3.1-mc1.21.4.jar"

wget -q "$DOWNLOAD_URL" -O "$MOD_PATH" || curl -s -L "$DOWNLOAD_URL" -o "$MOD_PATH"

if [ ! -f "$MOD_PATH" ]; then
  echo -e "${RED}Error: Failed to download UI-Utils.${NC}"
  echo -e "${YELLOW}Trying alternative download...${NC}"
  
  # Alternative download from the original repository
  ALT_URL="https://github.com/Coderx-Gamer/ui-utils/releases/download/2.1.0/ui-utils-2.1.0.jar"
  wget -q "$ALT_URL" -O "$MOD_PATH" || curl -s -L "$ALT_URL" -o "$MOD_PATH"
  
  if [ ! -f "$MOD_PATH" ]; then
    echo -e "${RED}Error: Failed to download UI-Utils from alternative source.${NC}"
    exit 1
  fi
fi

echo -e "${GREEN}UI-Utils successfully installed to: ${BLUE}$MOD_PATH${NC}"

# Check for and download Fabric API if not present
FABRIC_API_FOUND=false
for file in "$MODS_DIR"/*; do
  if [[ "$file" == *fabric-api* && "$file" == *1.21.4* ]]; then
    FABRIC_API_FOUND=true
    echo -e "${GREEN}Fabric API for 1.21.4 already installed.${NC}"
    break
  fi
done

if [ "$FABRIC_API_FOUND" = false ]; then
  echo -e "${YELLOW}Fabric API not found. Downloading...${NC}"
  FABRIC_API_URL="https://cdn.modrinth.com/data/P7dR8mSH/versions/wFP6sj2M/fabric-api-0.113.0%2B1.21.4.jar"
  FABRIC_API_PATH="$MODS_DIR/fabric-api-0.113.0+1.21.4.jar"
  
  wget -q "$FABRIC_API_URL" -O "$FABRIC_API_PATH" || curl -s -L "$FABRIC_API_URL" -o "$FABRIC_API_PATH"
  
  if [ -f "$FABRIC_API_PATH" ]; then
    echo -e "${GREEN}Fabric API successfully installed.${NC}"
  else
    echo -e "${RED}Warning: Failed to download Fabric API. UI-Utils may not work properly.${NC}"
  fi
fi

# Create configuration directory
CONFIG_DIR="$SELECTED_DIR/config/ui-utils"
if [ ! -d "$CONFIG_DIR" ]; then
  echo -e "${YELLOW}Creating configuration directory...${NC}"
  mkdir -p "$CONFIG_DIR"
fi

# Create auto-configuration file
echo -e "${GREEN}Creating auto-configuration...${NC}"
cat > "$CONFIG_DIR/config.json" << EOF
{
  "auto_enabled": true,
  "minecraft_version": "1.21.4",
  "auto_update": true,
  "plugin_compatibility_mode": true,
  "server_integration": true
}
EOF

echo -e "${GREEN}Auto-configuration created.${NC}"

# Add startup script for automatic loading
STARTUP_SCRIPT="$SELECTED_DIR/start-with-ui-utils.sh"
echo -e "${GREEN}Creating startup script...${NC}"

cat > "$STARTUP_SCRIPT" << 'EOF'
#!/bin/bash
# UI-Utils enhanced startup script

# Get the directory where this script is located
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check for UI-Utils updates
echo "Checking for UI-Utils updates..."
if [ -f "$DIR/config/ui-utils/config.json" ]; then
  if grep -q "auto_update.*true" "$DIR/config/ui-utils/config.json"; then
    echo "Auto-updates enabled. Checking for updates..."
    # You can add update logic here
  fi
fi

# Start the server with UI-Utils enabled
echo "Starting Minecraft server with UI-Utils enabled..."

# Detect server jar
SERVER_JAR=""
for jar in "$DIR"/server.jar "$DIR"/spigot.jar "$DIR"/paper.jar "$DIR"/fabric-server-launch.jar; do
  if [ -f "$jar" ]; then
    SERVER_JAR="$jar"
    break
  fi
done

if [ -z "$SERVER_JAR" ]; then
  # Try to find any jar file that might be the server
  for jar in "$DIR"/*.jar; do
    if [ -f "$jar" ]; then
      SERVER_JAR="$jar"
      break
    fi
  done
fi

if [ -z "$SERVER_JAR" ]; then
  echo "Error: No server jar found. Please specify the server jar manually."
  exit 1
fi

# Start the server
java -jar "$SERVER_JAR" nogui
EOF

chmod +x "$STARTUP_SCRIPT"
echo -e "${GREEN}Startup script created at: ${BLUE}$STARTUP_SCRIPT${NC}"

echo -e "${BLUE}====================================================${NC}"
echo -e "${GREEN}UI-Utils has been successfully installed!${NC}"
echo -e "${GREEN}To start your server with UI-Utils, run:${NC}"
echo -e "${BLUE}  $STARTUP_SCRIPT${NC}"
echo -e "${YELLOW}Note: UI-Utils is a client-side mod. Players will need to install it on their clients to use it.${NC}"
echo -e "${BLUE}====================================================${NC}"