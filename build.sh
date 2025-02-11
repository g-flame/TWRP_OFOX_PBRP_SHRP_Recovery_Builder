#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    echo -e "${2}${1}${NC}"
}

# Function to check if a command was successful
check_status() {
    if [ $? -eq 0 ]; then
        print_message "$1 - Completed Successfully" "$GREEN"
    else
        print_message "$1 - Failed" "$RED"
        exit 1
    fi
}

# Clear the terminal
clear

# Print banner
print_message "=================================" "$BLUE"
print_message "  TWRP Build Script for Marino" "$BLUE"
print_message "=================================" "$BLUE"

# Create build directory
print_message "\nCreating build directory..." "$YELLOW"
mkdir -p ~/twrp_marino
cd ~/twrp_marino
check_status "Create directory"

# Install required packages
print_message "\nInstalling required packages..." "$YELLOW"
sudo apt update
sudo apt install -y git-core gnupg flex bison build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 libncurses5 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig python2 python-is-python2
check_status "Package installation"

# Setup repo command
print_message "\nSetting up repo command..." "$YELLOW"
mkdir -p ~/bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
export PATH=~/bin:$PATH
check_status "Repo setup"

# Initialize repo
print_message "\nInitializing repository..." "$YELLOW"
repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-8.1
check_status "Repo initialization"

# Sync repo
print_message "\nSyncing repository (this may take a while)..." "$YELLOW"
repo sync -j$(nproc --all)
check_status "Repo sync"

# Clone device tree
print_message "\nCloning device tree..." "$YELLOW"
git clone https://github.com/Maanush2004/android_device_lenovo_marino device/lenovo/marino
check_status "Device tree clone"

# Setup ccache
print_message "\nSetting up ccache..." "$YELLOW"
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
ccache -M 50G
check_status "Ccache setup"

# Setup build environment
print_message "\nSetting up build environment..." "$YELLOW"
source build/envsetup.sh
check_status "Build environment setup"

# Lunch device
print_message "\nConfiguring device..." "$YELLOW"
lunch omni_marino-eng
check_status "Device configuration"

# Start build
print_message "\nStarting build process..." "$YELLOW"
export ALLOW_MISSING_DEPENDENCIES=true
mka recoveryimage
check_status "Build process"

# Check if build completed and recovery.img exists
if [ -f "out/target/product/marino/recovery.img" ]; then
    print_message "\nBuild completed successfully!" "$GREEN"
    print_message "Recovery image location: out/target/product/marino/recovery.img" "$GREEN"
else
    print_message "\nBuild failed: recovery.img not found" "$RED"
    exit 1
fi

# Print completion message
print_message "\n=================================" "$BLUE"
print_message "  Build Process Completed" "$BLUE"
print_message "=================================" "$BLUE"