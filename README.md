# Bullet Journal App for iPad

A digital bullet journal web application with enhanced support for iPad and Apple Pencil.

## Features

- Responsive design optimized for iPad screens
- Apple Pencil support with pressure sensitivity
- Offline functionality with service worker
- Installable as a Progressive Web App (PWA)
- Handwriting mode for a more natural journaling experience
- Fullscreen writing mode for distraction-free journaling
- Local storage for saving journal entries

## Deploying to iPad

There are several ways to deploy this web app to an iPad:

### Method 1: Using GitHub Pages (Recommended)

1. Push this project to a GitHub repository
2. Enable GitHub Pages in your repository settings
3. Access the published site on your iPad using Safari
4. Follow the "Installing as a PWA" instructions below

### Method 2: Using a Local Web Server

1. Install a simple HTTP server like [http-server](https://www.npmjs.com/package/http-server)
   ```
   npm install -g http-server
   ```
2. Navigate to the bullet-journal directory
   ```
   cd path/to/bullet-journal
   ```
3. Start the server
   ```
   http-server -p 8080
   ```
4. On your iPad, make sure it's connected to the same network as your computer
5. Open Safari on your iPad and navigate to `http://[your-computer-ip]:8080`
6. Follow the "Installing as a PWA" instructions below

### Method 3: Using a Hosting Service

1. Upload the bullet-journal directory to any web hosting service (Netlify, Vercel, etc.)
2. Access the published URL on your iPad using Safari
3. Follow the "Installing as a PWA" instructions below

## Installing as a PWA on iPad

1. Open the bullet journal app in Safari on your iPad
2. Tap the Share button (square with an arrow pointing up)
3. Scroll down and tap "Add to Home Screen"
4. Customize the name if desired and tap "Add"
5. The app will now appear on your home screen as a standalone app

## Using with Apple Pencil

1. Open the bullet journal app
2. Create a new entry (Task, Note, or Event)
3. Tap the pencil icon (✎) to enable handwriting mode
4. Use your Apple Pencil to write in the entry
5. The app will respond to pressure sensitivity from your Apple Pencil

## Offline Usage

The app works offline once you've visited it at least once while online. All your journal entries are saved locally on your device, so you can access and edit them even without an internet connection.

## Creating App Icons

If you want to customize the app icons, you'll need to create icons in the following sizes:

- 72x72
- 96x96
- 128x128
- 144x144
- 152x152
- 167x167 (for iPad Pro)
- 180x180 (for iPad)
- 192x192
- 384x384
- 512x512

Place these icons in the `icons` directory and update the `manifest.json` file if necessary.

## Creating Splash Screens

For a more native-like experience, you can create splash screens for different iPad models:

- 1536x2048 (iPad)
- 1668x2224 (iPad Pro 10.5")
- 2048x2732 (iPad Pro 12.9")

Place these images in the `icons` directory.