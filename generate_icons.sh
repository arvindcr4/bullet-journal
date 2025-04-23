#!/bin/bash

# Script to generate iOS app icons and splash screens for the Bullet Journal app
# This script uses ImageMagick to generate the required assets

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "ImageMagick is not installed. Please install it with:"
    echo "brew install imagemagick"
    exit 1
fi

# Create icons directory if it doesn't exist
mkdir -p www/icons

# Colors
ICON_BG="#007AFF"  # Apple blue
SPLASH_BG="white"
TEXT_COLOR="white"
SPLASH_TEXT_COLOR="#333333"

# Function to generate an icon
generate_icon() {
    local size=$1
    local output_file="www/icons/icon-${size}x${size}.png"
    
    echo "Generating icon ${size}x${size}..."
    
    # Calculate font sizes based on icon size
    local bullet_size=$((size / 2))
    local text_size=$((size / 5))
    
    # Create the icon using ImageMagick
    convert -size ${size}x${size} xc:${ICON_BG} \
        -fill ${TEXT_COLOR} \
        -gravity center \
        -font Helvetica-Bold \
        -pointsize ${bullet_size} -annotate +0-$((size/10)) "•" \
        -pointsize ${text_size} -annotate +0+$((size/4)) "BJ" \
        -quality 100 \
        "${output_file}"
}

# Function to generate a splash screen
generate_splash() {
    local width=$1
    local height=$2
    local output_file="www/icons/splash-${width}x${height}.png"
    
    echo "Generating splash screen ${width}x${height}..."
    
    # Calculate font sizes based on splash screen size
    local bullet_size=$((width / 5))
    local text_size=$((width / 15))
    
    # Create the splash screen using ImageMagick
    convert -size ${width}x${height} xc:${SPLASH_BG} \
        -gravity center \
        -font Helvetica-Bold \
        -fill ${ICON_BG} \
        -pointsize ${bullet_size} -annotate +0-$((height/10)) "•" \
        -fill ${SPLASH_TEXT_COLOR} \
        -pointsize ${text_size} -annotate +0+$((height/10)) "Bullet Journal" \
        -quality 100 \
        "${output_file}"
}

# Generate app icons
generate_icon 152
generate_icon 167
generate_icon 180

# Generate splash screens
echo "Generating splash screens (this may take a moment)..."
generate_splash 2048 2732  # 12.9" iPad Pro
generate_splash 1668 2224  # 10.5" iPad Pro
generate_splash 1536 2048  # 9.7" iPad

echo "Icon and splash screen generation complete!"
echo "Files created in www/icons/ directory:"
ls -la www/icons/
