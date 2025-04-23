#!/bin/bash

# Script to create a simple placeholder bullet journal icon using ImageMagick

echo "Creating placeholder 1024x1024 bullet journal icon..."

# Check for ImageMagick
if ! command -v magick &> /dev/null; then
    echo "Error: ImageMagick is not installed or too old."
    echo "Please install it with: brew install imagemagick"
    exit 1
fi

# Create output directory
mkdir -p temp

# Generate a simple bullet journal icon
# - Background color gradient
# - Journal cover with binding
# - Bullet points

# Create a simpler placeholder icon in one command (slightly smaller to account for shadow)
magick -size 960x960 xc:#f5f5f5 \
    -fill "#2c4c94" -draw "roundrectangle 152,152 808,808 40,40" \
    -fill "#153060" -draw "rectangle 190,152 230,808" \
    -fill white -pointsize 55 -font "Helvetica" -gravity center \
    -draw "text 50,-180 '• Task'" \
    -draw "text 50,-90 '- Note'" \
    -draw "text 50,0 '○ Event'" \
    -draw "text 50,90 '• Journal'" \
    -draw "text 50,180 '* Important'" \
    -alpha set \
    temp/icon-no-shadow.png

# Add a subtle shadow
magick temp/icon-no-shadow.png \
    \( +clone -background black -shadow 80x10+0+10 \) \
    +swap -background none -layers merge +repage \
    temp/icon-with-shadow.png

# Resize to exact 1024x1024 dimensions and center on white background
magick -size 1024x1024 xc:white \
    temp/icon-with-shadow.png -resize 1024x1024 -gravity center -composite \
    icon-source.png

# Verify the dimensions
DIMENSIONS=$(identify -format "%wx%h" icon-source.png)
echo "Generated icon dimensions: $DIMENSIONS"

# Clean up temp files
rm -rf temp

echo "Placeholder icon created as icon-source.png"
echo "Now running the generate_store_icons.sh script with this icon..."

# Run the icon generator with our new source icon
./generate_store_icons.sh icon-source.png

echo "Icon generation complete!"

