# Bullet Journal App - Alternative iOS App Store Distribution Guide

This document provides detailed instructions for distributing the Bullet Journal iOS app to three alternative app stores: AltStore PAL, Setapp Mobile, and Aptoide iOS.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Prepare App Assets](#prepare-app-assets)
- [AltStore PAL Distribution](#altstore-pal-distribution)
- [Setapp Mobile Distribution](#setapp-mobile-distribution)
- [Aptoide iOS Distribution](#aptoide-ios-distribution)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Development Environment
- Xcode 15+ (currently using 16.3)
- Node.js 20+ (currently using 23.10.0)
- CocoaPods 1.13+ (currently using 1.16.2)
- Capacitor CLI 5+ (currently using 5.7.8)
- Python 3.12.2

### Apple Developer Account
- Active Apple Developer account
- "iOS Development" certificate (for AltStore)
- "Developer ID Application" certificate (for Setapp & Aptoide)
- Corresponding provisioning profiles

### Project Configuration
- Ensure `capacitor.config.json` has proper iOS configuration
- Version and build numbers are set correctly
- Capacitor dependencies are in sync

## Prepare App Assets

Create a `/distribution/assets` directory with the following:

```bash
mkdir -p distribution/assets/{icons,screenshots,metadata}
```

### Required Assets for All Platforms
1. **Icons**:
   - App icon (1024×1024 PNG)
   - Create all required icon sizes:
   ```bash
   ./generate_icons.sh distribution/assets/icons/app_icon_1024.png
   ```

2. **Screenshots**:
   - 5.5" iPhone screenshots (light/dark modes)
   - 6.7" iPhone screenshots (light/dark modes)
   - 11" iPad screenshots with Apple Pencil (light/dark modes)

3. **Metadata**:
   - App name: "BulletJournal"
   - Bundle ID: "io.yarvind.bulletjournal"
   - Short description (30 words max)
   - Full description (4000 chars max)
   - Keywords (comma-separated)
   - Privacy Policy URL/PDF
   - Support email
   - Marketing materials (optional)
   - Changelog/release notes

## AltStore PAL Distribution

### Step 1: Prepare Development Build
1. Configure Xcode project for development signing:
   ```bash
   cd ios/App
   open App.xcworkspace
   ```
   - In Xcode, select "App" target → Signing & Capabilities
   - Ensure "Automatically manage signing" is checked
   - Select your Developer Team
   - Build setting: Debug or Release with development signature

2. Update Info.plist:
   - Ensure proper usage descriptions for any permissions
   - Verify UIBackgroundModes if needed

### Step 2: Create AltStore-compatible IPA
1. Archive the application:
   - In Xcode: Product → Archive
   - Select "Development" distribution
   - Select "Development" signing

2. Export IPA file:
   - Save as `BulletJournal_altstore.ipa`
   - Move to `distribution/ipa/`

### Step 3: Create AltStore Manifest
1. Create a JSON manifest file:
   ```json
   {
     "apps": [
       {
         "name": "BulletJournal",
         "bundleIdentifier": "io.yarvind.bulletjournal",
         "developerName": "Your Name",
         "version": "1.0.0",
         "versionDate": "2025-04-23",
         "versionDescription": "Initial release of BulletJournal app",
         "downloadURL": "https://your-hosting.com/apps/BulletJournal_altstore.ipa",
         "size": 15000000,
         "icons": [
           {
             "size": "60x60",
             "url": "https://your-hosting.com/apps/icon-60.png"
           },
           {
             "size": "1024x1024",
             "url": "https://your-hosting.com/apps/icon-1024.png"
           }
         ],
         "tintColor": "#f5f5f5",
         "screenshotURLs": [
           "https://your-hosting.com/apps/screenshot1.png",
           "https://your-hosting.com/apps/screenshot2.png"
         ],
         "permissions": [
           {
             "type": "photos",
             "usageDescription": "Stores your journal images in your Photo Library"
           }
         ]
       }
     ],
     "news": []
   }
   ```

2. Host the IPA and manifest:
   - Upload `BulletJournal_altstore.ipa` and manifest to your HTTPS server
   - Ensure proper MIME types are configured
   - Validate with AltStore's manifest validator

### Step 4: Submit to AltStore PAL
1. Visit [AltStore PAL submission page](https://altstore.io/pal/submit)
2. Submit your app with:
   - Manifest URL
   - App category: "Productivity"
   - Additional details as requested

### Step 5: Testing
1. Install [AltStore](https://altstore.io/) on a test device
2. Add source with your manifest URL
3. Install your app and perform thorough testing
4. Verify all functionality works without App Store dependencies

## Setapp Mobile Distribution

### Step 1: Setapp SDK Integration
1. Register as a Setapp developer: [Setapp for Developers](https://setapp.com/developers)
2. Install Setapp SDK:
   ```bash
   npm install --save @setapp/mobile-sdk
   npx cap sync ios
   ```

3. Initialize SDK in your app's main JavaScript file:
   ```javascript
   import { SetappSdk } from '@setapp/mobile-sdk';
   
   // Initialize on app start
   document.addEventListener('deviceready', () => {
     SetappSdk.initialize({
       appId: 'your-setapp-app-id',
       apiKey: 'your-setapp-api-key'
     });
   }, false);
   ```

4. Replace in-app purchases with Setapp entitlement checks:
   ```javascript
   SetappSdk.checkEntitlement()
     .then(isEntitled => {
       if (isEntitled) {
         // Unlock premium features
       } else {
         // Show upgrade prompt
       }
     });
   ```

### Step 2: Create Setapp-compatible IPA
1. Configure Xcode project for Ad Hoc distribution:
   - In Xcode, select "App" target → Signing & Capabilities
   - Select Ad Hoc profile for Release configuration
   - Set "Developer ID Application" certificate

2. Archive and export:
   - Product → Archive
   - Select "Ad Hoc" distribution option
   - Export as `BulletJournal_setapp.ipa`

### Step 3: Submit to Setapp
1. Complete Setapp onboarding questionnaire:
   - App name and category ("Productivity")
   - Detailed feature list
   - Subscription value justification
   - Technical specifications

2. Upload your IPA through Setapp Developer Portal
3. Provide all metadata and assets
4. Wait for curator feedback
5. Address any feedback until accepted

### Step 4: Testing
1. Test with Setapp's TestFlight build
2. Verify entitlement checks work properly
3. Ensure the app functions within Setapp's framework

## Aptoide iOS Distribution

### Step 1: Prepare for Aptoide
1. No SDK integration is needed
2. Configure for Ad Hoc distribution
3. Ensure app is functional without App Store dependencies

### Step 2: Create Aptoide-compatible IPA
1. Configure Xcode project for Ad Hoc distribution:
   - Use same Ad Hoc profile and Developer ID certificate
   - Export as `BulletJournal_aptoide.ipa`

### Step 3: Submit to Aptoide iOS
1. Register a developer account on [Aptoide iOS](https://aptoide.com/ios)
2. Create new app submission:
   - Category: "Productivity"
   - Price tier: Free
   - Upload your IPA file
   - Provide all required metadata and assets
   - Submit certificate SHA-1 hash:
     ```bash
     openssl x509 -in your_certificate.cer -noout -fingerprint
     ```

3. Complete submission with:
   - Screenshots
   - Description
   - Privacy policy
   - Support contact

### Step 4: Review Process
1. Pass malware scan
2. Wait for review approval
3. Upon approval, your app will be live in Aptoide iOS

## Troubleshooting

### General Signing Issues
- Ensure certificates are not expired
- Validate provisioning profiles match bundle identifier
- Check entitlements match provisioning profile capabilities

### AltStore-specific Issues
- Manifest validation errors can be fixed with [AltStore's validator](https://altstore.io/validate)
- Ensure IPA is properly signed for development

### Setapp-specific Issues
- SDK initialization failures can be debugged using:
  ```javascript
  SetappSdk.initialize({ debug: true, ... });
  ```
- Verify Setapp account has proper permissions

### Aptoide-specific Issues
- If app is rejected, review for any use of private APIs
- Ensure compliance with Aptoide's policies

## Maintenance

### Regular Updates
1. Increment version and build numbers in `capacitor.config.json`
2. Update changelog
3. Create new builds for each platform
4. Submit updates through each platform's process

### Certificate Renewal
- Monitor certificate expiration dates
- Renew developer certificates as needed
- Update provisioning profiles after certificate changes

This is a quick reference guide with the exact commands to deploy the Bullet Journal app to the Apple App Store.

## Prerequisites

- Make sure you have a Mac with Xcode installed
- Sign up for an Apple Developer account ($99/year) at [developer.apple.com](https://developer.apple.com)
- Install Node.js and npm if you haven't already
- Xcode 13+ (for PencilKit support)

## Step 1: Install Dependencies

Open Terminal and run these commands:

```bash
# Navigate to the bullet-journal directory
cd path/to/bullet-journal

# Install dependencies
npm install
```

## Step 2: Initialize Capacitor for iOS

```bash
# Initialize Capacitor with your app details
npm run ios:init

# Add iOS platform
npm run ios:add
```

## Step 3: Install Custom Apple Pencil Plugin

```bash
# Navigate to the plugin directory
cd capacitor-plugins/apple-pencil

# Install plugin dependencies
npm install

# Build the plugin
npm run build

# Return to the main directory
cd ../..

# Install the plugin to your project
npm install ./capacitor-plugins/apple-pencil
```

## Step 4: Sync Web Code with iOS Project

```bash
# Copy and sync web code to iOS project
npm run ios:sync
```

## Step 5: Open in Xcode and Configure

```bash
# Open the iOS project in Xcode
npm run ios:open
```

In Xcode:

1. Select the project in the navigator (left sidebar)
2. Select the app target
3. Go to the "Signing & Capabilities" tab
4. Sign in with your Apple Developer account
5. Select your team
6. Update the Bundle Identifier if needed (must be unique)
7. Set the Version (e.g., 1.0.0) and Build (e.g., 1) numbers

## Step 6: Add App Icons and Splash Screens

In Xcode:

1. Select Assets.xcassets in the navigator
2. Add your app icons to AppIcon
3. Configure the launch screen in LaunchScreen.storyboard

## Step 7: Test on Simulator or Device

In Xcode:

1. Select a simulator or connected device from the dropdown menu at the top
2. Click the Run button (play icon)
3. Test your app thoroughly

## Step 8: Configure PencilKit in Xcode

In Xcode:

1. Select your project in the navigator
2. Go to the "Capabilities" tab
3. Scroll down and enable "PencilKit"
4. Make sure "Privacy - Apple Pencil Usage Description" is added to your Info.plist with a description like "This app uses Apple Pencil for drawing and handwriting in your journal entries."

## Step 9: Archive and Submit to App Store

In Xcode:

1. Select "Any iOS Device" from the device dropdown
2. Go to Product > Archive
3. When the archive is complete, click "Distribute App"
4. Select "App Store Connect" and follow the prompts
5. Click "Upload" to submit to App Store Connect

## Step 10: Complete App Store Listing

1. Log in to [App Store Connect](https://appstoreconnect.apple.com/)
2. Go to "My Apps" and select your app
3. Complete all required information:
   - App description
   - Screenshots for all required device sizes
   - Keywords
   - Support URL
   - Privacy Policy URL
4. Click "Submit for Review"

## Updating Your App

When you make changes to your web app:

```bash
# Sync changes to iOS project
npm run ios:sync

# Open in Xcode
npm run ios:open
```

In Xcode:
1. Increment the build number
2. Archive and submit the new version

## Apple Pencil Plugin Features

The custom Apple Pencil plugin provides the following features:

- Full PencilKit integration for natural drawing
- Pressure sensitivity for varying line thickness
- Tilt detection for shading effects
- Palm rejection for comfortable writing
- Pencil-specific gestures (double-tap)
- Drawing persistence between app launches

To use these features in your app, the JavaScript API is already integrated into the app.js file. The plugin automatically detects when running as a native app and enables the advanced Apple Pencil features.

## Troubleshooting

- If you encounter build errors, make sure Xcode is up to date
- Check that your Apple Developer account is active
- Ensure all required app information is complete in App Store Connect
- For specific error messages, consult the Xcode logs or Apple Developer forums