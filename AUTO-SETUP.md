# UI-Utils Automatic Setup for Minecraft 1.21.4

This is an automated setup version of UI-Utils for Minecraft 1.21.4 servers. The scripts in this repository will automatically detect and configure UI-Utils for your Minecraft server.

## Quick Start

### For Windows:

1. Download the `auto-setup.ps1` file
2. Right-click and select "Run with PowerShell" (Run as Administrator for best results)
3. Follow the prompts to select your Minecraft server directory
4. The script will automatically install UI-Utils and Fabric API if needed

### For Linux:

1. Download the `auto-setup.sh` file
2. Make it executable: `chmod +x auto-setup.sh`
3. Run it with sudo: `sudo ./auto-setup.sh`
4. Follow the prompts to select your Minecraft server directory
5. The script will automatically install UI-Utils and Fabric API if needed

## Features

- Automatic server detection
- Downloads and installs UI-Utils and Fabric API for 1.21.4
- Creates an automatic configuration
- Generates startup scripts
- Works with all Minecraft server types (Vanilla, Spigot, Paper, Fabric)

## Requirements

- Minecraft 1.21.4
- Java 17 or higher
- Fabric server (or a server with Fabric installed)

## Important Notes

- UI-Utils is a client-side mod. This means it needs to be installed on each player's client to work.
- This setup script helps server owners prepare their servers for use with UI-Utils.
- The auto-update feature will ensure you always have the latest version.

## Manual Installation (if automatic fails)

If the automatic setup fails, you can manually install UI-Utils:

1. Download UI-Utils 2.1.0 or later for Minecraft 1.21.4 from [the releases page](https://github.com/jacobbyrne72/ui-utils/releases)
2. Download the Fabric API for 1.21.4
3. Place both JARs in your server's "mods" folder
4. Restart your server

## Troubleshooting

If you encounter any issues during setup:

- Ensure you're running the scripts with Administrator/sudo privileges
- Make sure your server is for Minecraft 1.21.4
- Check that you're using a Fabric server or have Fabric installed
- Verify that Java 17 or higher is installed

## License

This modification maintains the original license from the UI-Utils project:

- CC BY-NC-SA 4.0
- The mod may not be uploaded to any mod hosting websites or other platforms, including but not limited to 9minecraft.net, without explicit written permission from MrBreakNFix and Coderx_Gamer. All rights reserved.

## Credits

- Original UI-Utils by Coderx_Gamer and MrBreakNFix
- Auto-setup scripts and modifications by jacobbyrne72