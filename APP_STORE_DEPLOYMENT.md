# Deploying Bullet Journal to the App Store

This guide will walk you through the process of deploying the Bullet Journal web app to the Apple App Store.

## Prerequisites

- A Mac computer with macOS
- Xcode installed (latest version recommended)
- An Apple Developer account ($99/year)
- Node.js and npm installed

## Step 1: Install Capacitor

Capacitor is a tool that allows you to wrap web applications in a native container for iOS.

```bash
# Navigate to the bullet-journal directory
cd bullet-journal

# Initialize npm if not already done
npm init -y

# Install Capacitor
npm install @capacitor/core @capacitor/cli @capacitor/ios

# Initialize Capacitor
npx cap init BulletJournal io.yourcompany.bulletjournal
```

## Step 2: Configure Capacitor

Create a `capacitor.config.json` file in the bullet-journal directory:

```json
{
  "appId": "io.yourcompany.bulletjournal",
  "appName": "Bullet Journal",
  "webDir": ".",
  "bundledWebRuntime": false,
  "ios": {
    "contentInset": "always"
  }
}
```

## Step 3: Add iOS Platform

```bash
# Add iOS platform
npx cap add ios
```

This will create an `ios` directory with a native Xcode project.

## Step 4: Update App Icons and Splash Screens

1. Open the Xcode project:
   ```bash
   npx cap open ios
   ```

2. In Xcode, select the project in the navigator, then select the app target.

3. Go to the "General" tab and scroll down to "App Icons Source" and "Launch Screen File".

4. Use Xcode's built-in asset catalog to add your app icons and splash screens.

## Step 5: Configure App Settings

While in Xcode:

1. Update the Bundle Identifier to match your `appId` in the Capacitor config.
2. Set the Version and Build numbers.
3. Configure signing with your Apple Developer account.
4. Update the app's display name, privacy descriptions, and other required settings.

## Step 6: Test on a Device or Simulator

Before submitting to the App Store, test your app thoroughly:

```bash
# Build and sync web code to iOS project
npx cap copy ios
npx cap sync ios

# Open in Xcode to run on simulator or device
npx cap open ios
```

In Xcode, select a simulator or connected device and click the Run button.

## Step 7: Prepare for App Store Submission

1. In Xcode, go to Product > Archive to create an app archive.
2. Once the archive is created, the Organizer window will open.
3. Select your archive and click "Distribute App".
4. Choose "App Store Connect" and follow the prompts.
5. Complete all required information including:
   - App Store screenshots (for different device sizes)
   - App description
   - Keywords
   - Support URL
   - Privacy policy URL
   - App Review Information

## Step 8: Submit for Review

1. Log in to [App Store Connect](https://appstoreconnect.apple.com/).
2. Navigate to "My Apps" and select your app.
3. Complete all required metadata, pricing, and availability information.
4. Upload app screenshots for all required device sizes.
5. Submit for review.

## Common Issues and Solutions

### App Rejection Reasons

- **Missing Privacy Policy**: Ensure you have a comprehensive privacy policy.
- **Incomplete Metadata**: Make sure all required fields in App Store Connect are filled out.
- **Crashes or Bugs**: Test thoroughly before submission.
- **Poor Performance**: Optimize your web app for iOS.

### Performance Optimization

- Minimize JavaScript and CSS
- Optimize images
- Implement efficient caching strategies
- Test on older iPad models

## Additional Resources

- [Apple App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Capacitor Documentation](https://capacitorjs.com/docs)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)

## Updating Your App

When you make changes to your web app:

1. Update your web code
2. Run:
   ```bash
   npx cap copy ios
   npx cap sync ios
   ```
3. Open Xcode, increment the build number
4. Archive and submit the new version

## App Store Optimization

- Use relevant keywords in your app title and description
- Create compelling screenshots and app previews
- Respond to user reviews
- Update your app regularly