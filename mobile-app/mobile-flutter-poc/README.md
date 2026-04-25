# PinPotha iOS App

A Flutter iOS application for recording and remembering good thoughts - a digital version of the traditional "Pin Potha" (පින් පොත).

## Features

- ✅ Google Sign-In authentication
- ✅ Create, edit, and delete posts (good thoughts)
- ✅ Add photos from gallery or camera
- ✅ View all posts in a beautiful grid layout
- ✅ Search functionality
- ✅ Pagination support
- ✅ Pull-to-refresh
- ✅ View posts by date
- ✅ Share posts
- ✅ Offline support with Firebase Realtime Database
- ✅ Bottom navigation for mobile
- ✅ Drawer menu

## Prerequisites

- Flutter SDK (>=3.0.0)
- Xcode (for iOS development)
- CocoaPods
- Firebase project setup
- Google Sign-In configuration

## Setup Instructions

### 1. Install Flutter Dependencies

```bash
cd mobile
flutter pub get
```

### 2. Firebase Configuration

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (pinpotha-1295)
3. Add an iOS app:
   - Click "Add app" → iOS
   - Bundle ID: `com.leafylanka.pinpotha`
   - Download `GoogleService-Info.plist`

4. Place `GoogleService-Info.plist` in:
   ```
   mobile/ios/Runner/GoogleService-Info.plist
   ```

### 3. iOS Configuration

1. Open `mobile/ios/Runner.xcworkspace` in Xcode
2. Update the Bundle Identifier to `com.leafylanka.pinpotha`
3. Configure Google Sign-In:
   - In Xcode, go to Runner → Signing & Capabilities
   - Add "Background Modes" capability
   - Add URL Scheme: Add your reversed client ID from `GoogleService-Info.plist`
     - Find `REVERSED_CLIENT_ID` in `GoogleService-Info.plist`
     - Add it as a URL Scheme in Xcode

4. Update `Info.plist`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleTypeRole</key>
       <string>Editor</string>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>YOUR_REVERSED_CLIENT_ID</string>
       </array>
     </dict>
   </array>
   ```

### 4. Install CocoaPods Dependencies

```bash
cd mobile/ios
pod install
cd ../..
```

### 5. Run the App

```bash
flutter run
```

Or open in Xcode and run from there.

## Project Structure

```
mobile/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── firebase_options.dart      # Firebase configuration
│   ├── models/
│   │   └── post.dart             # Post data model
│   ├── providers/
│   │   └── auth_provider.dart    # Authentication state management
│   ├── screens/
│   │   ├── splash_screen.dart    # Initial loading screen
│   │   ├── sign_in_screen.dart   # Google Sign-In
│   │   ├── dashboard_screen.dart # Main posts grid
│   │   ├── add_post_screen.dart  # Create/Edit post
│   │   ├── post_details_screen.dart # View post details
│   │   └── post_list_screen.dart # Posts by date
│   ├── services/
│   │   └── post_service.dart     # Firebase operations
│   ├── utils/
│   │   ├── date_utils.dart       # Date formatting
│   │   └── post_utils.dart       # Post utilities
│   └── widgets/
│       ├── bottom_navigation.dart # Bottom nav bar
│       └── mobile_drawer.dart    # Side drawer menu
├── ios/                          # iOS native configuration
└── pubspec.yaml                  # Dependencies
```

## Firebase Setup

The app uses the same Firebase project as the web version:
- Project ID: `pinpotha-1295`
- Database: Realtime Database
- Storage: Firebase Storage
- Authentication: Google Sign-In

## Key Dependencies

- `firebase_core` - Firebase initialization
- `firebase_auth` - Authentication
- `firebase_database` - Realtime Database
- `firebase_storage` - File storage
- `google_sign_in` - Google Sign-In
- `provider` - State management
- `image_picker` - Image selection
- `cached_network_image` - Image caching
- `pull_to_refresh` - Pull-to-refresh functionality
- `share_plus` - Share functionality

## Building for Production

### iOS Release Build

1. Update version in `pubspec.yaml`
2. Build the app:
   ```bash
   flutter build ios --release
   ```
3. Archive in Xcode:
   - Open `ios/Runner.xcworkspace`
   - Product → Archive
   - Distribute App

## Troubleshooting

### Google Sign-In Issues
- Ensure `GoogleService-Info.plist` is in the correct location
- Verify URL Scheme is configured in `Info.plist`
- Check that the Bundle ID matches Firebase configuration

### Firebase Connection Issues
- Verify Firebase project settings
- Check network connectivity
- Ensure Firebase rules allow read/write access

### Image Picker Issues
- Add camera and photo library permissions to `Info.plist`:
  ```xml
  <key>NSCameraUsageDescription</key>
  <string>We need access to your camera to take photos for your good thoughts.</string>
  <key>NSPhotoLibraryUsageDescription</key>
  <string>We need access to your photo library to select images for your good thoughts.</string>
  ```

## License

This project is part of the PinPotha application suite.

