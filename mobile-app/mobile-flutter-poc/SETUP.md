# Quick Setup Guide for PinPotha iOS App

## Prerequisites

1. **Flutter SDK** (>=3.0.0)
   ```bash
   flutter --version
   ```

2. **Xcode** (latest version from App Store)

3. **CocoaPods**
   ```bash
   sudo gem install cocoapods
   ```

## Step-by-Step Setup

### 1. Install Flutter Dependencies

```bash
cd mobile
flutter pub get
```

### 2. Firebase iOS Configuration

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **pinpotha-1295**
3. Click the iOS icon to add iOS app
4. Enter Bundle ID: `com.leafylanka.pinpotha`
5. Download `GoogleService-Info.plist`
6. Place it in: `mobile/ios/Runner/GoogleService-Info.plist`

### 3. Configure Xcode

1. Open the project:
   ```bash
   cd mobile/ios
   open Runner.xcworkspace
   ```

2. In Xcode:
   - Select **Runner** in the project navigator
   - Go to **Signing & Capabilities** tab
   - Select your development team
   - Ensure Bundle Identifier is: `com.leafylanka.pinpotha`

3. Add URL Scheme for Google Sign-In:
   - In Xcode, go to **Info** tab
   - Expand **URL Types**
   - Click **+** to add new URL Type
   - In **URL Schemes**, add the reversed client ID from `GoogleService-Info.plist`
     - Find `REVERSED_CLIENT_ID` in the plist file
     - Add it as a URL Scheme

### 4. Install CocoaPods Dependencies

**Option 1: Use the fix script (Recommended)**
```bash
cd mobile
./fix_cocoapods.sh
```

**Option 2: Manual installation**
```bash
# Fix permissions first
sudo chown -R $(whoami) ~/.cocoapods

# Then install
cd mobile/ios
export LANG=en_US.UTF-8
pod install
cd ../..
```

**Option 3: Let Flutter handle it**
```bash
cd mobile
flutter clean
flutter pub get
flutter build ios --no-codesign
```

### 5. Run the App

```bash
cd mobile
flutter run
```

Or use Xcode:
- Open `mobile/ios/Runner.xcworkspace` in Xcode
- Select a simulator or connected device
- Click Run (▶️)

## Troubleshooting

### Issue: "GoogleService-Info.plist not found"
**Solution**: Make sure the file is in `mobile/ios/Runner/GoogleService-Info.plist`

### Issue: "Sign in with Google not working"
**Solution**: 
1. Verify URL Scheme is configured in Info.plist
2. Check that Bundle ID matches Firebase configuration
3. Ensure Google Sign-In is enabled in Firebase Console

### Issue: "Pod install fails" or "Operation not permitted"
**Solution**:
```bash
# Fix CocoaPods permissions
sudo chown -R $(whoami) ~/.cocoapods

# Clean and reinstall
cd mobile/ios
rm -rf Pods Podfile.lock
export LANG=en_US.UTF-8
pod repo update
pod install
```

### Issue: "CocoaPods requires UTF-8 encoding"
**Solution**:
```bash
export LANG=en_US.UTF-8
# Then run pod install
cd mobile/ios
pod install
```

### Issue: "Minimum deployment target" error
**Solution**: The Podfile is already configured for iOS 13.0. If you see this error, ensure:
- Podfile has `platform :ios, '13.0'`
- Xcode project deployment target is set to 13.0

### Issue: "Camera/Photo permissions not working"
**Solution**: The permissions are already configured in `Info.plist`. If issues persist, verify in Xcode:
- Go to **Info** tab
- Check that `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` are present

## Building for Release

1. Update version in `pubspec.yaml`
2. Build:
   ```bash
   flutter build ios --release
   ```
3. Archive in Xcode:
   - Product → Archive
   - Distribute App

## Testing

The app includes:
- ✅ Google Sign-In authentication
- ✅ Create, edit, delete posts
- ✅ Image upload from gallery/camera
- ✅ Search and pagination
- ✅ Pull-to-refresh
- ✅ Offline support

Test all features to ensure everything works correctly!

