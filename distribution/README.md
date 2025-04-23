# BulletJournal Distribution Guide

This directory contains all the files necessary for distributing the BulletJournal app to various alternative app stores.

## Directory Structure

```
distribution/
├── altstore/              # AltStore PAL distribution
│   ├── manifest.json      # AltStore app manifest
│   ├── ipa/               # Directory for IPA files
│   ├── icons/             # App icons for AltStore
│   └── screenshots/       # App screenshots
├── setapp/                # Setapp Mobile distribution
│   ├── metadata.json      # Setapp metadata
│   ├── ipa/               # Directory for IPA files
│   ├── icons/             # App icons for Setapp
│   └── screenshots/       # App screenshots
└── aptoide/               # Aptoide iOS distribution
    ├── metadata.json      # Aptoide metadata
    ├── apk/               # Directory for APK files
    ├── icons/             # App icons for Aptoide
    └── screenshots/       # App screenshots
```

## Hosting Instructions

### AltStore PAL

1. Upload all files in the `altstore` directory to your web server
2. Update the URLs in `manifest.json` to match your hosting location
3. Ensure your server is configured with HTTPS
4. Set the correct MIME types:
   - `.ipa`: `application/octet-stream`
   - `.json`: `application/json`
   - `.png`: `image/png`

### Setapp Mobile

Follow the specific Setapp Mobile submission guidelines in `DEPLOYMENT_STEPS.md`.

### Aptoide iOS

Follow the specific Aptoide iOS submission guidelines in `DEPLOYMENT_STEPS.md`.

## Update Procedure

When updating the app:
1. Increment the version number in the appropriate manifest/metadata files
2. Update the IPA/APK files
3. Update the versionDate field
4. Add new changelog/versionDescription
5. Re-upload all changed files to your hosting

## Submission Links

- AltStore PAL: https://altstore.io/pal/submit
- Setapp Mobile: https://setapp.com/developers
- Aptoide iOS: https://www.aptoide.com/developer

