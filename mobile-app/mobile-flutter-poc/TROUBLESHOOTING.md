# Troubleshooting Guide

## CocoaPods Permission Errors

If you see errors like:
- `Operation not permitted @ dir_s_mkdir`
- `Error running pod install`

### Quick Fix:

```bash
# 1. Fix permissions
sudo chown -R $(whoami) ~/.cocoapods

# 2. Set UTF-8 encoding
export LANG=en_US.UTF-8

# 3. Clean and reinstall
cd mobile/ios
rm -rf Pods Podfile.lock
pod repo update
pod install
```

### Alternative: Use Flutter's built-in pod install

Flutter can handle CocoaPods automatically:

```bash
cd mobile
flutter clean
flutter pub get
flutter build ios --no-codesign
```

This will automatically run `pod install` with proper permissions.

## Minimum Deployment Target Error

If you see:
- `required a higher minimum deployment target`

**Solution**: The project is already configured for iOS 13.0. If errors persist:

1. Check Podfile has: `platform :ios, '13.0'`
2. Verify Xcode project settings:
   - Open `Runner.xcworkspace` in Xcode
   - Select Runner target
   - Go to Build Settings
   - Search for "iOS Deployment Target"
   - Set to 13.0

## Google Sign-In Not Working

1. **Verify GoogleService-Info.plist exists:**
   ```bash
   ls mobile/ios/Runner/GoogleService-Info.plist
   ```

2. **Check URL Scheme in Info.plist:**
   - Open `mobile/ios/Runner/Info.plist`
   - Look for `CFBundleURLTypes`
   - Should include the reversed client ID from GoogleService-Info.plist

3. **Verify Bundle ID matches Firebase:**
   - Firebase Console: Should be `com.leafylanka.pinpotha`
   - Xcode: Runner → Signing & Capabilities → Bundle Identifier

## Build Errors

### "No such module 'Firebase'"
```bash
cd mobile/ios
pod install
```

### "Swift version mismatch"
- Open Xcode
- Select Runner target
- Build Settings → Swift Language Version
- Set to Swift 5

### "Code signing error"
- Open Xcode
- Select Runner target
- Signing & Capabilities
- Select your development team
- Ensure "Automatically manage signing" is checked

## Flutter Dependencies

If Flutter packages aren't found:

```bash
cd mobile
flutter clean
flutter pub get
flutter pub upgrade
```

## Network Issues

If CocoaPods can't download specs:

```bash
# Use CDN instead of git
pod repo remove trunk
pod setup
pod install
```

## Still Having Issues?

1. Check Flutter doctor:
   ```bash
   flutter doctor -v
   ```

2. Verify Xcode command line tools:
   ```bash
   xcode-select --print-path
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   ```

3. Clean everything and start fresh:
   ```bash
   cd mobile
   flutter clean
   rm -rf ios/Pods ios/Podfile.lock
   flutter pub get
   cd ios
   pod install
   ```

