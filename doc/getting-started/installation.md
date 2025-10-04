# Installation Guide

Complete installation instructions for Flutter AI Agent SDK.

## Adding to Your Project

### From Local Path (Development)

```yaml
dependencies:
  flutter_ai_agent_sdk:
    path: ../flutter_ai_agent_sdk
```

### From Git Repository

```yaml
dependencies:
  flutter_ai_agent_sdk:
    git:
      url: https://github.com/Chief-Strategist-J/flutter_ai_agent_sdk.git
      ref: main
```

### From pub.dev (When Published)

```yaml
dependencies:
  flutter_ai_agent_sdk: ^1.0.0
```

## Platform-Specific Setup

### iOS Setup

#### 1. Permissions

Add the following to your `ios/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for voice features.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app uses speech recognition to understand your voice commands.</string>
```

#### 2. Microphone Usage

For iOS 10+, add this to your `Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Allow microphone access to enable voice interaction with the AI assistant.</string>
```

#### 3. Background Audio (Optional)

If you need background audio support:

```xml
<key>UIBackgroundModes</key>
<array>
  <string>audio</string>
</array>
```

### Android Setup

#### 1. Permissions

Add these permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.yourapp">

    <!-- Microphone permission -->
    <uses-permission android:name="android.permission.RECORD_AUDIO" />

    <!-- Internet permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <!-- Optional: Wake lock for background operation -->
    <uses-permission android:name="android.permission.WAKE_LOCK" />

    <application>
        <!-- Your app configuration -->
    </application>
</manifest>
```

#### 2. Speech Recognition Service

For Android 11+ (API level 30+), add this to your `AndroidManifest.xml`:

```xml
<queries>
    <!-- Allow speech recognition service -->
    <intent>
        <action android:name="android.speech.RecognitionService" />
    </intent>
</queries>
```

#### 3. Gradle Configuration

Ensure your `android/app/build.gradle` includes necessary dependencies:

```gradle
android {
    defaultConfig {
        multiDexEnabled true
        // Add any other configurations
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}
```

### Web Setup

#### 1. HTML Configuration

For web support, ensure your `web/index.html` includes:

```html
<!DOCTYPE html>
<html>
<head>
    <!-- Required for microphone access -->
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
    <script>
        // Request microphone permission on page load
        if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
            navigator.mediaDevices.getUserMedia({ audio: true })
                .then(function(stream) {
                    // Permission granted
                })
                .catch(function(err) {
                    console.warn('Microphone permission denied:', err);
                });
        }
    </script>
    <!-- Your Flutter app -->
</body>
</html>
```

#### 2. Browser Compatibility

The SDK supports:
- Chrome 25+
- Firefox 44+
- Safari 14.1+
- Edge 79+

### Desktop Setup

#### Windows

No special setup required for Windows desktop apps.

#### macOS

Add microphone permissions to `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`:

```xml
<key>com.apple.security.device.audio-input</key>
<true/>
```

#### Linux

No special setup required for Linux desktop apps.

## Dependencies Installation

After adding the dependency, install it:

```bash
flutter pub get
```

For clean installation:

```bash
flutter clean
flutter pub get
```

## Verify Installation

Check if the SDK is properly installed:

```dart
import 'package:flutter_ai_agent_sdk/flutter_ai_agent_sdk.dart';

void main() {
  // The import should work without errors
  print('Flutter AI Agent SDK is installed successfully!');
}
```

## Next Steps

- **[Quick Start](../quick-start.md)** - Get started with your first agent
- **[Configuration](./configuration.md)** - Learn about configuration options
- **[Platform Support](../platform-support/)** - Platform-specific guides
