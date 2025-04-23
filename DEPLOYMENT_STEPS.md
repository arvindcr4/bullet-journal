# Bullet Journal App Store Deployment Steps

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