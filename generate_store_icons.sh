#!/bin/bash

# Script to generate all required icon sizes for different app stores
# Requires ImageMagick to be installed

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check for ImageMagick
if ! command -v magick &> /dev/null; then
    echo -e "${RED}Error: ImageMagick is not installed or too old.${NC}"
    echo "Please install it with:"
    echo "  brew install imagemagick"
    exit 1
fi

# Print usage information
function print_usage() {
    echo -e "${BLUE}Bullet Journal Icon Generator${NC}"
    echo "Generates all required icon sizes for AltStore, Setapp, and Aptoide distribution"
    echo ""
    echo "Usage: $0 <source_icon_path>"
    echo ""
    echo "Arguments:"
    echo "  <source_icon_path>   Path to the source icon file (must be 1024x1024 PNG)"
    echo ""
    echo "Example:"
    echo "  $0 ./app-icon-source.png"
}

# Check if source icon path was provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: No source icon path provided.${NC}"
    print_usage
    exit 1
fi

SOURCE_ICON="$1"

# Check if file exists
if [ ! -f "$SOURCE_ICON" ]; then
    echo -e "${RED}Error: Source icon file not found: $SOURCE_ICON${NC}"
    exit 1
fi

# Validate image format (must be PNG)
FORMAT=$(identify -format "%m" "$SOURCE_ICON" 2>/dev/null)
if [ "$FORMAT" != "PNG" ]; then
    echo -e "${RED}Error: Source icon must be in PNG format.${NC}"
    echo "Current format: $FORMAT"
    exit 1
fi

# Validate dimensions (must be 1024x1024)
DIMENSIONS=$(identify -format "%wx%h" "$SOURCE_ICON" 2>/dev/null)
if [ "$DIMENSIONS" != "1024x1024" ]; then
    echo -e "${RED}Error: Source icon must be 1024x1024 pixels.${NC}"
    echo "Current dimensions: $DIMENSIONS"
    exit 1
fi

# Create base directories for storing icons
BASE_DIR="distribution/assets/icons"
ALTSTORE_DIR="$BASE_DIR/altstore"
SETAPP_DIR="$BASE_DIR/setapp"
APTOIDE_DIR="$BASE_DIR/aptoide"
WWW_ICONS_DIR="www/icons"

# Create directories if they don't exist
mkdir -p "$ALTSTORE_DIR"
mkdir -p "$SETAPP_DIR"
mkdir -p "$APTOIDE_DIR"

echo -e "${GREEN}Creating icons for all platforms...${NC}"

# Standard icon sizes needed across all platforms
ICON_SIZES=(
    20 29 40 58 60 76 80 87 
    120 152 167 180 192 512 1024
)

# Additional sizes mentioned in the README
ADDITIONAL_SIZES=(
    72 96 128 144 384
)

# Process all icon sizes
for SIZE in "${ICON_SIZES[@]}" "${ADDITIONAL_SIZES[@]}"; do
    echo -e "${BLUE}Generating ${SIZE}x${SIZE} icon...${NC}"
    
    # Create basic resized version
    # Create basic resized version
    magick "$SOURCE_ICON" -resize ${SIZE}x${SIZE} "$BASE_DIR/icon-${SIZE}x${SIZE}.png"
    # Copy to store-specific directories
    cp "$BASE_DIR/icon-${SIZE}x${SIZE}.png" "$ALTSTORE_DIR/"
    cp "$BASE_DIR/icon-${SIZE}x${SIZE}.png" "$SETAPP_DIR/"
    cp "$BASE_DIR/icon-${SIZE}x${SIZE}.png" "$APTOIDE_DIR/"
    
    # Also update the app's www/icons directory with the basic icon sizes
    if [[ " 72 96 128 144 152 167 180 192 384 512 " =~ " $SIZE " ]]; then
        cp "$BASE_DIR/icon-${SIZE}x${SIZE}.png" "$WWW_ICONS_DIR/"
    fi
done

# Generate iOS App Icon Set - used for the native app build
echo -e "${YELLOW}Creating iOS App Icon Set for Xcode...${NC}"

CONTENTS_JSON='{
  "images" : [
    {"size":"20x20","idiom":"iphone","filename":"icon-40x40.png","scale":"2x"},
    {"size":"20x20","idiom":"iphone","filename":"icon-60x60.png","scale":"3x"},
    {"size":"29x29","idiom":"iphone","filename":"icon-58x58.png","scale":"2x"},
    {"size":"29x29","idiom":"iphone","filename":"icon-87x87.png","scale":"3x"},
    {"size":"40x40","idiom":"iphone","filename":"icon-80x80.png","scale":"2x"},
    {"size":"40x40","idiom":"iphone","filename":"icon-120x120.png","scale":"3x"},
    {"size":"60x60","idiom":"iphone","filename":"icon-120x120.png","scale":"2x"},
    {"size":"60x60","idiom":"iphone","filename":"icon-180x180.png","scale":"3x"},
    {"size":"20x20","idiom":"ipad","filename":"icon-20x20.png","scale":"1x"},
    {"size":"20x20","idiom":"ipad","filename":"icon-40x40.png","scale":"2x"},
    {"size":"29x29","idiom":"ipad","filename":"icon-29x29.png","scale":"1x"},
    {"size":"29x29","idiom":"ipad","filename":"icon-58x58.png","scale":"2x"},
    {"size":"40x40","idiom":"ipad","filename":"icon-40x40.png","scale":"1x"},
    {"size":"40x40","idiom":"ipad","filename":"icon-80x80.png","scale":"2x"},
    {"size":"76x76","idiom":"ipad","filename":"icon-76x76.png","scale":"1x"},
    {"size":"76x76","idiom":"ipad","filename":"icon-152x152.png","scale":"2x"},
    {"size":"83.5x83.5","idiom":"ipad","filename":"icon-167x167.png","scale":"2x"},
    {"size":"1024x1024","idiom":"ios-marketing","filename":"icon-1024x1024.png","scale":"1x"}
  ],
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}'

# Create AppIcon.appiconset directories for each store
for STORE in "altstore" "setapp" "aptoide"; do
    ICONSET_DIR="$BASE_DIR/$STORE/AppIcon.appiconset"
    mkdir -p "$ICONSET_DIR"
    
    # Copy each required icon to the iconset directory
    for SIZE in "${ICON_SIZES[@]}"; do
        cp "$BASE_DIR/icon-${SIZE}x${SIZE}.png" "$ICONSET_DIR/"
    done
    
    # Create Contents.json
    echo "$CONTENTS_JSON" > "$ICONSET_DIR/Contents.json"
done

# Create an AltStore-specific manifest icon reference
echo -e "${YELLOW}Creating AltStore manifest icons reference...${NC}"

cat > "$ALTSTORE_DIR/manifest_icons.json" << EOF
"icons": [
  {
    "size": "60x60",
    "url": "https://your-hosting.com/apps/icon-60x60.png"
  },
  {
    "size": "1024x1024",
    "url": "https://your-hosting.com/apps/icon-1024x1024.png"
  }
]
EOF

# Generate splash screens required for iOS
echo -e "${YELLOW}Generating splash screens for iPad...${NC}"

# Splash screen sizes from README
SPLASH_SIZES=(
    "1536x2048"  # iPad
    "1668x2224"  # iPad Pro 10.5"
    "2048x2732"  # iPad Pro 12.9"
)

SPLASH_DIR="$BASE_DIR/splash"
mkdir -p "$SPLASH_DIR"

# Basic splash screen with icon centered
for SIZE in "${SPLASH_SIZES[@]}"; do
    WIDTH=${SIZE%x*}
    HEIGHT=${SIZE#*x}
    ICON_SIZE=$((WIDTH / 4))  # Icon will be 1/4 of the width
    
    echo -e "${BLUE}Generating splash screen ${SIZE}...${NC}"
    
    # Create a blank white background
    # Create a blank white background
    magick -size ${SIZE} xc:#F5F5F5 "$SPLASH_DIR/splash-${SIZE}.png"
    
    # Resize the icon and place it in the center
    magick "$SOURCE_ICON" -resize ${ICON_SIZE}x${ICON_SIZE} "$SPLASH_DIR/temp-icon.png"
    
    # Calculate position to center the icon
    X_POS=$(( (WIDTH - ICON_SIZE) / 2 ))
    Y_POS=$(( (HEIGHT - ICON_SIZE) / 2 ))
    
    # Composite the icon onto the background
    magick "$SPLASH_DIR/splash-${SIZE}.png" "$SPLASH_DIR/temp-icon.png" -geometry +${X_POS}+${Y_POS} -composite "$SPLASH_DIR/splash-${SIZE}.png"
    # Clean up temp file
    rm "$SPLASH_DIR/temp-icon.png"
    
    # Copy to each store directory
    cp "$SPLASH_DIR/splash-${SIZE}.png" "$ALTSTORE_DIR/"
    cp "$SPLASH_DIR/splash-${SIZE}.png" "$SETAPP_DIR/"
    cp "$SPLASH_DIR/splash-${SIZE}.png" "$APTOIDE_DIR/"
    
    # Also copy to www/icons for web use
    cp "$SPLASH_DIR/splash-${SIZE}.png" "$WWW_ICONS_DIR/"
done

echo -e "${GREEN}All icons and splash screens have been generated successfully!${NC}"
echo ""
echo -e "${YELLOW}Output locations:${NC}"
echo "  - Base icons: $BASE_DIR"
echo "  - AltStore icons: $ALTSTORE_DIR"
echo "  - Setapp icons: $SETAPP_DIR"
echo "  - Aptoide icons: $APTOIDE_DIR"
echo "  - Splash screens: $SPLASH_DIR"
echo "  - Web app icons: $WWW_ICONS_DIR"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Include these icons in your app builds for each store"
echo "2. Use AppIcon.appiconset directories in your Xcode projects"
echo "3. Update your AltStore manifest with the correct icon URLs"
echo "4. Use the splash screens in your app's launch screen configuration"

# Make script executable by default
chmod +x "$0"

