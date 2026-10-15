# Deep Linking Guide — Geography Geyser

This document is the complete guide and reference for the **Deep Linking** and **GoRouter** implementation in the Geography Geyser Flutter application.

---

## 1. Architecture Overview

The app uses **[GoRouter](https://pub.dev/packages/go_router)** (v18.1.0) as the single source of truth for routing. Every screen is mapped to a declarative URL path and supports:

1. **Custom Scheme Links**: `geographygeyser://<path>?<query_params>` (instant app open without server verification).
2. **Universal / App Links**: `https://geographygeyser.com/<path>?<query_params>` and `https://api.geographygeyser.com/<path>?<query_params>`.
3. **Dual Parameter Parsing**: Routes extract data from both `state.uri.queryParameters` (deep links) and `state.extra` (internal programmatic navigation).

```
                      ┌──────────────────────────────────────────────┐
                      │                 Inbound Link                 │
                      │  geographygeyser://quiz?moduleId=605&...    │
                      └──────────────────────┬───────────────────────┘
                                             │
                                             ▼
                      ┌──────────────────────────────────────────────┐
                      │            OS Intent / Universal Link         │
                      │   (AndroidManifest.xml / Info.plist)         │
                      └──────────────────────┬───────────────────────┘
                                             │
                                             ▼
                      ┌──────────────────────────────────────────────┐
                      │              MaterialApp.router              │
                      │               (lib/app.dart)                 │
                      └──────────────────────┬───────────────────────┘
                                             │
                                             ▼
                      ┌──────────────────────────────────────────────┐
                      │                  appRouter                   │
                      │          (lib/routes/app_router.dart)        │
                      └──────────────────────┬───────────────────────┘
                                             │
                       Parses Query Parameters & Extra
                                             │
                                             ▼
                      ┌──────────────────────────────────────────────┐
                      │                Target Screen                 │
                      │              (e.g., QuizScreen)              │
                      └──────────────────────────────────────────────┘
```

---

## 2. Platform Configuration

### A. Android Configuration

The Android configuration is located in `android/app/src/main/AndroidManifest.xml` inside `<activity android:name=".MainActivity">`:

```xml
<!-- Enable Flutter deep linking support -->
<meta-data
    android:name="flutter_deeplinking_enabled"
    android:value="true" />

<!-- Deep Linking: Custom URI Scheme (geographygeyser://) -->
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="geographygeyser" />
</intent-filter>

<!-- Deep Linking: HTTPS App Links (https://geographygeyser.com) -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https" android:host="geographygeyser.com" />
    <data android:scheme="https" android:host="api.geographygeyser.com" />
</intent-filter>
```

#### Android App Link Verification (`assetlinks.json`)
For `https://` App Links to bypass the browser disambiguation dialog and open the app directly, host this JSON file at:
`https://geographygeyser.com/.well-known/assetlinks.json`

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.geographygeyser.app",
      "sha256_cert_fingerprints": [
        "YOUR_RELEASE_KEYSTORE_SHA256_FINGERPRINT"
      ]
    }
  }
]
```

---

### B. iOS Configuration

To enable deep links on iOS:

#### 1. Custom URL Scheme (`ios/Runner/Info.plist`)
Add the `CFBundleURLTypes` entry inside the `<dict>` tag:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.geographygeyser.app</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>geographygeyser</string>
        </array>
    </dict>
</array>

<!-- Enable Flutter deep linking -->
<key>FlutterDeepLinkingEnabled</key>
<true/>
```

#### 2. Universal Links (`ios/Runner/Runner.entitlements`)
Add Associated Domains:

```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:geographygeyser.com</string>
    <string>applinks:api.geographygeyser.com</string>
</array>
```

#### Apple App Site Association (`apple-app-site-association`)
Host this file at `https://geographygeyser.com/.well-known/apple-app-site-association` (with `Content-Type: application/json` and no `.json` extension):

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "<TEAM_ID>.com.geographygeyser.app",
        "paths": ["*"]
      }
    ]
  }
}
```

---

## 3. Complete Deep Link & Route Catalog

| Route Constant | Path | Name | Query Parameters / Payload | Sample Deep Link |
| :--- | :--- | :--- | :--- | :--- |
| `AppRoutes.splash` | `/` | `splash` | *None* | `geographygeyser:///` |
| `AppRoutes.login` | `/login` | `login` | *None* | `geographygeyser://login` |
| `AppRoutes.signup` | `/signup` | `signup` | *None* | `geographygeyser://signup` |
| `AppRoutes.verifyOtp` | `/verify-otp` | `verifyOtp` | `email` (String) | `geographygeyser://verify-otp?email=student@example.com` |
| `AppRoutes.registrationSuccess` | `/registration-success` | `registrationSuccess` | *None* | `geographygeyser://registration-success` |
| `AppRoutes.forgotPassword` | `/forgot-password` | `forgotPassword` | *None* | `geographygeyser://forgot-password` |
| `AppRoutes.forgotPasswordVerify` | `/forgot-password-verify` | `forgotPasswordVerify` | `email` (String) | `geographygeyser://forgot-password-verify?email=student@example.com` |
| `AppRoutes.resetPassword` | `/reset-password` | `resetPassword` | `email`, `token` | `geographygeyser://reset-password?email=student@example.com&token=123456` |
| `AppRoutes.passwordResetSuccess` | `/password-reset-success` | `passwordResetSuccess` | *None* | `geographygeyser://password-reset-success` |
| `AppRoutes.home` | `/home` | `home` | *None* | `geographygeyser://home` |
| `AppRoutes.optionalModules` | `/optional-modules` | `optionalModules` | `firstLogin` (bool, default `false`) | `geographygeyser://optional-modules?firstLogin=true` |
| `AppRoutes.modules` | `/modules` | `modules` | `hideback` (bool) | `geographygeyser://modules` |
| `AppRoutes.selectTime` | `/select-time` | `selectTime` | `moduleId` (String), `moduleName` (String), `selectedQuantityIndex` (int) | `geographygeyser://select-time?moduleId=synoptic&moduleName=Synoptic` |
| `AppRoutes.selectQuantity` | `/select-quantity` | `selectQuantity` | `moduleId` (String), `selectedTimeInMinutes` (int) | `geographygeyser://select-quantity?moduleId=605&selectedTimeInMinutes=15` |
| `AppRoutes.quiz` | `/quiz` | `quiz` | `moduleId` (String), `moduleName` (String), `timeInMinutes` (int), `totalQuestions` (int) | `geographygeyser://quiz?moduleId=605&moduleName=Europe&timeInMinutes=15` |
| `AppRoutes.quizResult` | `/quiz-result` | `quizResult` | *None* | `geographygeyser://quiz-result` |
| `AppRoutes.quizComplete` | `/quiz-complete` | `quizComplete` | *None* | `geographygeyser://quiz-complete` |
| `AppRoutes.profile` | `/profile` | `profile` | `hideSettingsCard` (bool) | `geographygeyser://profile?hideSettingsCard=true` |
| `AppRoutes.editProfileOption` | `/edit-profile-option` | `editProfileOption` | *None* | `geographygeyser://edit-profile-option` |
| `AppRoutes.generalSettings` | `/general-settings` | `generalSettings` | *None* | `geographygeyser://general-settings` |
| `AppRoutes.privacySettings` | `/privacy-settings` | `privacySettings` | *None* | `geographygeyser://privacy-settings` |
| `AppRoutes.aboutApp` | `/about-app` | `aboutApp` | *None* | `geographygeyser://about-app` |
| `AppRoutes.accountDelete` | `/account-delete` | `accountDelete` | *None* | `geographygeyser://account-delete` |

---

## 4. In-App Navigation Usage

### A. Navigate to a Screen

```dart
import 'package:go_router/go_router.dart';
import 'package:geography_geyser/routes/app_routes.dart';

// 1. Push a new screen on top of the stack (shows back button)
context.push(AppRoutes.modules);

// 2. Replace current screen
context.pushReplacement(AppRoutes.home);

// 3. Clear stack and go to a screen (e.g., after login or quiz finish)
context.go(AppRoutes.home);

// 4. Pop current screen
context.pop();
```

### B. Passing Parameters

#### Method 1: Using Type-Safe Helper Path Builders (Best for Deep Links)
```dart
// Navigating to OTP with email
context.push(AppRoutes.verifyOtpPath(email: 'user@example.com'));

// Navigating to Quiz with full parameters
context.push(AppRoutes.quizPath(
  moduleId: '605',
  moduleName: 'Europe Geography',
  timeInMinutes: 15,
));

// Navigating to Profile with settings hidden
context.push(AppRoutes.profilePath(hideSettingsCard: true));
```

#### Method 2: Using `extra` Payloads (In-App Objects)
```dart
context.push(
  AppRoutes.selectTime,
  extra: {
    'moduleId': subject.id,
    'moduleName': subject.moduleName,
  },
);
```

### C. Accessing Navigation from Outside BuildContext (e.g. Services / Interceptors)

The router is exposed globally via:
```dart
import 'package:geography_geyser/routes/app_router.dart';

// Redirect to login on token expiration
appRouter.go(AppRoutes.login);
```

---

## 5. How to Test Deep Links

### Testing on Android via ADB

Connect your Android phone or start an emulator, then execute:

```powershell
# 1. Open Home Screen
adb shell am start -W -a android.intent.action.VIEW -d "geographygeyser://home" com.geographygeyser.app

# 2. Open Verify OTP Screen with Email
adb shell am start -W -a android.intent.action.VIEW -d "geographygeyser://verify-otp?email=test%40gmail.com" com.geographygeyser.app

# 3. Open Quiz directly with module parameters
adb shell am start -W -a android.intent.action.VIEW -d "geographygeyser://quiz?moduleId=synoptic&moduleName=Synoptic&timeInMinutes=15" com.geographygeyser.app

# 4. Open Profile Screen (Stats view)
adb shell am start -W -a android.intent.action.VIEW -d "geographygeyser://profile?hideSettingsCard=true" com.geographygeyser.app

# 5. Open General Settings
adb shell am start -W -a android.intent.action.VIEW -d "geographygeyser://general-settings" com.geographygeyser.app

# 6. Test App Link (HTTPS)
adb shell am start -W -a android.intent.action.VIEW -d "https://geographygeyser.com/quiz?moduleId=synoptic" com.geographygeyser.app
```

### Testing on iOS Simulator

Launch the iOS simulator and run:

```bash
# Custom Scheme
xcrun simctl openurl booted "geographygeyser://quiz?moduleId=synoptic&moduleName=Synoptic"

# Universal Link
xcrun simctl openurl booted "https://geographygeyser.com/home"
```

---

## 6. Error Handling & 404 Page

If an unmapped or malformed URL is received (e.g., `geographygeyser://unknown-route`), GoRouter invokes the custom `errorBuilder` defined in `lib/routes/app_router.dart`:

- Displays a user-friendly "Page Not Found" screen.
- Shows the attempted path.
- Provides a **Go to Home** button that brings the user safely back to `AppRoutes.home`.

---

## 7. Adding New Routes

When adding a new feature or screen:

1. **Add Route Constant & Name in `lib/routes/app_routes.dart`**:
   ```dart
   static const String leaderboard = '/leaderboard';
   static const String leaderboardName = 'leaderboard';
   ```

2. **Add Optional Path Builder** (if it accepts query parameters):
   ```dart
   static String leaderboardPath({String? period}) {
     return period != null ? '$leaderboard?period=$period' : leaderboard;
   }
   ```

3. **Register Route in `lib/routes/app_router.dart`**:
   ```dart
   GoRoute(
     path: AppRoutes.leaderboard,
     name: AppRoutes.leaderboardName,
     pageBuilder: (context, state) {
       final period = state.uri.queryParameters['period'] ?? 
                      (state.extra as Map?)?['period'] ?? 'all-time';
       return _buildSlideTransition(
         key: state.pageKey,
         child: LeaderboardScreen(period: period),
       );
     },
   ),
   ```
