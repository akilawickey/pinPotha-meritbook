#!/bin/bash

# Fix CocoaPods permissions and install dependencies
echo "Fixing CocoaPods permissions..."

# Fix ownership of CocoaPods directory
sudo chown -R $(whoami) ~/.cocoapods 2>/dev/null || echo "Note: Some permissions may need manual fixing"

# Set UTF-8 encoding
export LANG=en_US.UTF-8

# Navigate to iOS directory
cd "$(dirname "$0")/ios"

# Clean previous installations
echo "Cleaning previous CocoaPods installation..."
rm -rf Pods Podfile.lock

# Update CocoaPods repo
echo "Updating CocoaPods repository..."
pod repo update

# Install pods
echo "Installing CocoaPods dependencies..."
pod install

echo "Done! If you see any errors, try running: sudo chown -R $(whoami) ~/.cocoapods"

