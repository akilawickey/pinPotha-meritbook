# Dependency Conflict Fix

## Problem
There's a dependency conflict between:
- `firebase_database` (requires GoogleUtilities ~> 7.13)
- `google_sign_in_ios` (requires GoogleUtilities ~> 8.0)

## Solution

I've updated the Firebase packages to newer versions that support GoogleUtilities 8.0, and added a Podfile override to force GoogleUtilities 8.1.

### Steps to Fix:

1. **Update Flutter dependencies:**
   ```bash
   cd mobile
   flutter pub get
   ```

2. **Clean CocoaPods and reinstall:**
   ```bash
   cd ios
   rm -rf Pods Podfile.lock
   export LANG=en_US.UTF-8
   pod install
   ```

3. **If still having issues, try:**
   ```bash
   cd mobile
   flutter clean
   flutter pub get
   cd ios
   pod repo update
   pod install
   ```

### What Was Changed:

1. **Updated Firebase packages in `pubspec.yaml`:**
   - Firebase Core: ^3.6.0 (uses GoogleUtilities 8.x)
   - Firebase Auth: ^5.3.1
   - Firebase Database: ^11.1.3
   - Firebase Storage: ^12.3.2
   - Firebase Analytics: ^11.3.3

2. **Added Podfile override:**
   - Forces GoogleUtilities ~> 8.1 to resolve the conflict

### Alternative: Use Older Google Sign-In

If the above doesn't work, you can downgrade Google Sign-In to a version compatible with GoogleUtilities 7.x:

```yaml
google_sign_in: ^5.4.4
```

But the recommended approach is to use the newer Firebase versions with the Podfile override.

