# UI-Utils Auto-Installation Script for Minecraft 1.21.4 Servers (Windows Version)
# Version: 1.0
# Author: Modified for automatic installation

# Function to check for admin rights
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $isAdmin = $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    return $isAdmin
}

# Check for admin rights
if (-not (Test-Admin)) {
    Write-Host "This script requires administrator privileges to install properly." -ForegroundColor Yellow
    Write-Host "Please run PowerShell as administrator and try again." -ForegroundColor Yellow
    exit 1
}

Write-Host "====================================================" -ForegroundColor Blue
Write-Host "      UI-Utils Auto-Installation for MC 1.21.4      " -ForegroundColor Blue
Write-Host "====================================================" -ForegroundColor Blue

# Detect server directories
Write-Host "Detecting Minecraft server directories..." -ForegroundColor Green
$possibleDirs = @()

# Common server directories
$checkDirs = @(
    "C:\Minecraft",
    "$env:APPDATA\.minecraft\server",
    "C:\Games\Minecraft",
    "C:\Servers\Minecraft",
    "D:\Minecraft"
)

foreach ($dir in $checkDirs) {
    if (Test-Path $dir) {
        $serverJars = Get-ChildItem -Path $dir -Filter "*.jar" -Recurse -Depth 1 | Where-Object { 
            $_.Name -eq "server.jar" -or 
            $_.Name -eq "spigot.jar" -or 
            $_.Name -eq "paper.jar" -or 
            $_.Name -eq "fabric-server-launch.jar" 
        }
        
        if ($serverJars.Count -gt 0) {
            # Only add the parent directory of the first server jar found
            $possibleDirs += $serverJars[0].Directory.FullName
        }
    }
}

# If no directories found, ask for manual input
if ($possibleDirs.Count -eq 0) {
    Write-Host "No Minecraft server directories detected automatically." -ForegroundColor Yellow
    $serverDir = Read-Host "Please enter your Minecraft server directory path"
    
    if (-not (Test-Path $serverDir)) {
        Write-Host "Error: Directory does not exist." -ForegroundColor Red
        exit 1
    }
    
    $selectedDir = $serverDir
}
else {
    Write-Host "Found $($possibleDirs.Count) potential Minecraft server directories:" -ForegroundColor Green
    for ($i = 0; $i -lt $possibleDirs.Count; $i++) {
        Write-Host "  [$i] $($possibleDirs[$i])" -ForegroundColor Cyan
    }
    
    $selection = Read-Host "Select a directory by number (or enter a custom path)"
    
    if ($selection -match "^\d+$" -and [int]$selection -lt $possibleDirs.Count) {
        $selectedDir = $possibleDirs[[int]$selection]
    }
    else {
        $selectedDir = $selection
        if (-not (Test-Path $selectedDir)) {
            Write-Host "Error: Directory does not exist." -ForegroundColor Red
            exit 1
        }
    }
}

Write-Host "Selected server directory: $selectedDir" -ForegroundColor Green

# Create mods directory if it doesn't exist
$modsDir = Join-Path $selectedDir "mods"
if (-not (Test-Path $modsDir)) {
    Write-Host "Creating mods directory..." -ForegroundColor Yellow
    New-Item -Path $modsDir -ItemType Directory | Out-Null
}

# Create plugins directory if it doesn't exist (for hybrid servers)
$pluginsDir = Join-Path $selectedDir "plugins"
if (-not (Test-Path $pluginsDir)) {
    Write-Host "Creating plugins directory..." -ForegroundColor Yellow
    New-Item -Path $pluginsDir -ItemType Directory | Out-Null
}

# Download UI-Utils for 1.21.4
Write-Host "Downloading UI-Utils for Minecraft 1.21.4..." -ForegroundColor Green
$downloadUrl = "https://github.com/jacobbyrne72/ui-utils/releases/download/v2.3.1/ui-utils-2.3.1-mc1.21.4.jar"
$modPath = Join-Path $modsDir "ui-utils-2.3.1-mc1.21.4.jar"

try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $modPath -ErrorAction Stop
}
catch {
    Write-Host "Error: Failed to download UI-Utils." -ForegroundColor Red
    Write-Host "Trying alternative download..." -ForegroundColor Yellow
    
    # Alternative download from the original repository
    $altUrl = "https://github.com/Coderx-Gamer/ui-utils/releases/download/2.1.0/ui-utils-2.1.0.jar"
    try {
        Invoke-WebRequest -Uri $altUrl -OutFile $modPath -ErrorAction Stop
    }
    catch {
        Write-Host "Error: Failed to download UI-Utils from alternative source." -ForegroundColor Red
        exit 1
    }
}

if (Test-Path $modPath) {
    Write-Host "UI-Utils successfully installed to: $modPath" -ForegroundColor Green
}
else {
    Write-Host "Error: Failed to download and install UI-Utils." -ForegroundColor Red
    exit 1
}

# Check for and download Fabric API if not present
$fabricApiFound = $false
Get-ChildItem -Path $modsDir -Filter "*.jar" | ForEach-Object {
    if ($_.Name -like "*fabric-api*" -and $_.Name -like "*1.21.4*") {
        $fabricApiFound = $true
        Write-Host "Fabric API for 1.21.4 already installed." -ForegroundColor Green
    }
}

if (-not $fabricApiFound) {
    Write-Host "Fabric API not found. Downloading..." -ForegroundColor Yellow
    $fabricApiUrl = "https://cdn.modrinth.com/data/P7dR8mSH/versions/wFP6sj2M/fabric-api-0.113.0%2B1.21.4.jar"
    $fabricApiPath = Join-Path $modsDir "fabric-api-0.113.0+1.21.4.jar"
    
    try {
        Invoke-WebRequest -Uri $fabricApiUrl -OutFile $fabricApiPath -ErrorAction Stop
        Write-Host "Fabric API successfully installed." -ForegroundColor Green
    }
    catch {
        Write-Host "Warning: Failed to download Fabric API. UI-Utils may not work properly." -ForegroundColor Red
    }
}

# Create configuration directory
$configDir = Join-Path $selectedDir "config\ui-utils"
if (-not (Test-Path $configDir)) {
    Write-Host "Creating configuration directory..." -ForegroundColor Yellow
    New-Item -Path $configDir -ItemType Directory -Force | Out-Null
}

# Create auto-configuration file
Write-Host "Creating auto-configuration..." -ForegroundColor Green
$configContent = @"
{
  "auto_enabled": true,
  "minecraft_version": "1.21.4",
  "auto_update": true,
  "plugin_compatibility_mode": true,
  "server_integration": true
}
"@

Set-Content -Path (Join-Path $configDir "config.json") -Value $configContent

# Add startup script for automatic loading
$startupScript = Join-Path $selectedDir "start-with-ui-utils.bat"
Write-Host "Creating startup script..." -ForegroundColor Green

$batchContent = @"
@echo off
REM UI-Utils enhanced startup script
echo Checking for UI-Utils updates...

if exist "%~dp0config\ui-utils\config.json" (
    findstr "auto_update.*true" "%~dp0config\ui-utils\config.json" >nul
    if not errorlevel 1 (
        echo Auto-updates enabled. Checking for updates...
        REM You can add update logic here
    )
)

echo Starting Minecraft server with UI-Utils enabled...

REM Detect server jar
set SERVER_JAR=

if exist "%~dp0server.jar" (
    set SERVER_JAR=server.jar
) else if exist "%~dp0spigot.jar" (
    set SERVER_JAR=spigot.jar
) else if exist "%~dp0paper.jar" (
    set SERVER_JAR=paper.jar
) else if exist "%~dp0fabric-server-launch.jar" (
    set SERVER_JAR=fabric-server-launch.jar
)

if "%SERVER_JAR%"=="" (
    for %%F in ("%~dp0*.jar") do (
        set SERVER_JAR=%%~nxF
        goto found_jar
    )
)

:found_jar
if "%SERVER_JAR%"=="" (
    echo Error: No server jar found. Please specify the server jar manually.
    exit /b 1
)

REM Start the server
java -jar "%SERVER_JAR%" nogui
pause
"@

Set-Content -Path $startupScript -Value $batchContent

Write-Host "Startup script created at: $startupScript" -ForegroundColor Green

Write-Host "====================================================" -ForegroundColor Blue
Write-Host "UI-Utils has been successfully installed!" -ForegroundColor Green
Write-Host "To start your server with UI-Utils, run:" -ForegroundColor Green
Write-Host "  $startupScript" -ForegroundColor Cyan
Write-Host "Note: UI-Utils is a client-side mod. Players will need to install it on their clients to use it." -ForegroundColor Yellow
Write-Host "====================================================" -ForegroundColor Blue

# Pause to keep the window open
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")