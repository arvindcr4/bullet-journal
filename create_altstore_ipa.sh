#!/bin/bash

# Script to create an AltStore-compatible IPA from the Bullet Journal web app
# No App Store signing required for AltStore

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Bullet Journal - AltStore IPA Generator${NC}"
echo "This script generates an unsigned IPA package for AltStore distribution"
echo ""

# Clean up any previous build
echo -e "${YELLOW}Cleaning up previous builds...${NC}"
rm -rf build/altstore
mkdir -p build/altstore/Payload

# Define locations
APP_DIR="build/altstore/Payload/BulletJournal.app"
DIST_DIR="distribution/altstore/ipa"
ICON_DIR="distribution/altstore/icons"

mkdir -p "$APP_DIR"
mkdir -p "$DIST_DIR"
mkdir -p "$ICON_DIR"

# Copy web assets to app bundle
echo -e "${YELLOW}Copying web assets...${NC}"
mkdir -p "$APP_DIR/www"
cp -R www/* "$APP_DIR/www/"

# Copy icons
if [ -f "$ICON_DIR/icon-1024x1024.png" ]; then
    echo -e "${YELLOW}Using existing icons...${NC}"
else
    echo -e "${YELLOW}Copying icons to AltStore directory...${NC}"
    cp -R distribution/assets/icons/altstore/* "$ICON_DIR/"
fi

# Create Info.plist
echo -e "${YELLOW}Creating Info.plist...${NC}"

cat > "$APP_DIR/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleIdentifier</key>
	<string>io.yarvind.bulletjournal.alt</string>
	<key>CFBundleDisplayName</key>
	<string>BulletJournal</string>
	<key>CFBundleName</key>
	<string>BulletJournal</string>
	<key>CFBundleExecutable</key>
	<string>BulletJournal</string>
	<key>CFBundleVersion</key>
	<string>1.0.0</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0.0</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>LSRequiresIPhoneOS</key>
	<true/>
	<key>UILaunchStoryboardName</key>
	<string>LaunchScreen</string>
	<key>UIRequiresFullScreen</key>
	<true/>
	<key>UISupportedInterfaceOrientations</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
		<string>UIInterfaceOrientationPortraitUpsideDown</string>
	</array>
	<key>UISupportedInterfaceOrientations~ipad</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
		<string>UIInterfaceOrientationPortraitUpsideDown</string>
	</array>
	<key>UIStatusBarStyle</key>
	<string>UIStatusBarStyleDefault</string>
	<key>NSPhotoLibraryUsageDescription</key>
	<string>Stores your journal images in your Photo Library</string>
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>Allows tagging journal entries with your location (optional)</string>
	<key>UIViewControllerBasedStatusBarAppearance</key>
	<true/>
	<key>UIRequiresPersistentWiFi</key>
	<true/>
	<key>UIBackgroundModes</key>
	<array>
		<string>fetch</string>
	</array>
</dict>
</plist>
EOF

# Create a dummy executable (needed for IPA structure)
echo -e "${YELLOW}Creating dummy executable...${NC}"
echo '#!/bin/bash
echo "This is a web-based application for use with AltStore"
exit 0' > "$APP_DIR/BulletJournal"
chmod +x "$APP_DIR/BulletJournal"

# Create a simple launch screen storyboard
echo -e "${YELLOW}Creating launch screen...${NC}"
mkdir -p "$APP_DIR/Base.lproj"

cat > "$APP_DIR/Base.lproj/LaunchScreen.storyboard" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB" version="3.0" toolsVersion="21507" targetRuntime="iOS.CocoaTouch" propertyAccessControl="none" useAutolayout="YES" launchScreen="YES" useTraitCollections="YES" useSafeAreas="YES" colorMatched="YES" initialViewController="01J-lp-oVM">
    <device id="retina6_12" orientation="portrait" appearance="light"/>
    <dependencies>
        <plugIn identifier="com.apple.InterfaceBuilder.IBCocoaTouchPlugin" version="21505"/>
        <capability name="Safe area layout guides" minToolsVersion="9.0"/>
        <capability name="documents saved in the Xcode 8 format" minToolsVersion="8.0"/>
    </dependencies>
    <scenes>
        <!--View Controller-->
        <scene sceneID="EHf-IW-A2E">
            <objects>
                <viewController id="01J-lp-oVM" sceneMemberID="viewController">
                    <view key="view" contentMode="scaleToFill" id="Ze5-6b-2t3">
                        <rect key="frame" x="0.0" y="0.0" width="393" height="852"/>
                        <autoresizingMask key="autoresizingMask" widthSizable="YES" heightSizable="YES"/>
                        <subviews>
                            <imageView clipsSubviews="YES" userInteractionEnabled="NO" contentMode="scaleAspectFit" horizontalHuggingPriority="251" verticalHuggingPriority="251" fixedFrame="YES" translatesAutoresizingMaskIntoConstraints="NO" id="YZ7-Ue-iBH">
                                <rect key="frame" x="76" y="301" width="240" height="250"/>
                                <autoresizingMask key="autoresizingMask" flexibleMinX="YES" widthSizable="YES" flexibleMaxX="YES" flexibleMinY="YES" heightSizable="YES" flexibleMaxY="YES"/>
                            </imageView>
                        </subviews>
                        <viewLayoutGuide key="safeArea" id="Bcu-3y-fUS"/>
                        <color key="backgroundColor" red="0.96078431372549022" green="0.96078431372549022" blue="0.96078431372549022" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>
                    </view>
                </viewController>
                <placeholder placeholderIdentifier="IBFirstResponder" id="iYj-Kq-Ea1" userLabel="First Responder" sceneMemberID="firstResponder"/>
            </objects>
            <point key="canvasLocation" x="53" y="375"/>
        </scene>
    </scenes>
</document>
EOF

# Create package the IPA
echo -e "${YELLOW}Creating IPA package...${NC}"

# Convert our largest icon to the app icon
if [ -f "$ICON_DIR/icon-1024x1024.png" ]; then
    cp "$ICON_DIR/icon-1024x1024.png" "$APP_DIR/AppIcon.png"
fi

# Create IPA by zipping the Payload directory
cd build/altstore
zip -qr BulletJournal.ipa Payload
cd ../..

# Move IPA to distribution directory
echo -e "${YELLOW}Moving IPA to distribution directory...${NC}"
cp build/altstore/BulletJournal.ipa "$DIST_DIR/BulletJournal_altstore.ipa"

# Get file size for manifest
SIZE=$(stat -f%z "$DIST_DIR/BulletJournal_altstore.ipa")

echo -e "${GREEN}IPA created successfully!${NC}"
echo "Location: $DIST_DIR/BulletJournal_altstore.ipa"
echo "Size: $SIZE bytes"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Update the 'size' field in manifest.json with: $SIZE"
echo "2. Host the IPA and icons on your web server"
echo "3. Update the URLs in the manifest to point to your hosted files"
echo "4. Submit the manifest URL to AltStore PAL"

# Make this script executable
chmod +x "$0"

