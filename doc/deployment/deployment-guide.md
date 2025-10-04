# Deployment Guide

Complete guide to deploying Flutter AI Agent SDK applications across different platforms.

## Platform-Specific Deployment

### iOS Deployment

#### 1. App Store Deployment

**Prerequisites:**
- Apple Developer Program membership
- Paid Apple Developer account ($99/year)

**Steps:**

1. **Archive the App**:
```bash
flutter build ios --release
```

2. **Configure App Information**:
   - Update `ios/Runner/Info.plist` with proper bundle identifier
   - Add required permissions for microphone access
   - Configure app icons and launch images

3. **Code Signing**:
```bash
# In Xcode, select your team and provisioning profile
# Ensure proper certificates are installed
```

4. **Archive and Upload**:
   - Open Xcode and select "Product > Archive"
   - Follow the distribution process
   - Upload to App Store Connect

5. **App Store Connect**:
   - Create app record in App Store Connect
   - Upload screenshots and metadata
   - Submit for review

#### 2. Enterprise Deployment

For internal company apps:

1. **Enterprise Certificate**:
   - Obtain enterprise developer certificate
   - Create enterprise provisioning profile

2. **Build with Enterprise Profile**:
```bash
flutter build ios --release \
  --dart-define=ENTERPRISE=true \
  --flavor enterprise
```

3. **Distribute via MDM**:
   - Upload IPA to MDM system
   - Deploy to enrolled devices

#### 3. Ad Hoc Deployment

For testing on specific devices:

1. **Register Device UDIDs**:
   - Add device UDIDs to developer portal
   - Create ad hoc provisioning profile

2. **Build and Distribute**:
```bash
flutter build ios --release \
  --dart-define=ADHOC=true
```

### Android Deployment

#### 1. Play Store Deployment

**Prerequisites:**
- Google Play Developer Console account ($25 one-time fee)

**Steps:**

1. **Build APK/AAB**:
```bash
# For App Bundle (recommended)
flutter build appbundle --release

# For APK
flutter build apk --release
```

2. **Configure App Information**:
   - Update `android/app/build.gradle` with proper version codes
   - Configure signing in `android/key.properties`
   - Update `android/app/src/main/AndroidManifest.xml`

3. **Generate Keystore**:
```bash
keytool -genkey -v -keystore android/app/key.jks \
  -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 \
  -alias key
```

4. **Configure Signing**:
```gradle
android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] != null ?
                file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

5. **Upload to Play Console**:
   - Create app in Google Play Console
   - Upload AAB/APK file
   - Add store listing, screenshots, and metadata
   - Submit for review

#### 2. Firebase App Distribution

For internal testing:

1. **Install Firebase CLI**:
```bash
npm install -g firebase-tools
```

2. **Configure Firebase**:
```bash
firebase init app-distribution
```

3. **Build and Distribute**:
```bash
flutter build apk --release
firebase appdistribution:distribute android/app/build/outputs/apk/release/app-release.apk \
  --app YOUR_APP_ID \
  --release-notes "Release notes here"
```

#### 3. Enterprise Deployment

For company apps:

1. **Generate Enterprise APK**:
```bash
flutter build apk --release \
  --dart-define=ENTERPRISE=true
```

2. **Distribute via EMM**:
   - Upload to Enterprise Mobility Management system
   - Deploy to managed devices

### Web Deployment

#### 1. Static Hosting (Firebase/Netlify/Vercel)

1. **Build for Web**:
```bash
flutter build web --release
```

2. **Configure for Production**:
```bash
flutter build web --release \
  --dart-define=API_URL=https://your-api.example.com \
  --web-renderer html  # or canvaskit for better performance
```

3. **Deploy to Firebase**:
```bash
firebase init hosting
firebase deploy
```

4. **Deploy to Netlify**:
```bash
# Build command: flutter build web --release
# Publish directory: build/web
```

#### 2. PWA Configuration

1. **Add PWA Manifest**:
```html
<!-- In web/index.html -->
<link rel="manifest" href="/manifest.json">
```

2. **Service Worker**:
```javascript
// Register service worker for offline support
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/flutter_service_worker.js');
  });
}
```

#### 3. Web-Specific Optimizations

1. **CanvasKit Renderer** (better for complex UIs):
```bash
flutter build web --release --web-renderer canvaskit
```

2. **Web Workers** for heavy computations:
```dart
import 'dart:html' as html;

void runInWebWorker(Function workerFunction) {
  final worker = html.Worker('worker.js');
  worker.postMessage({'function': workerFunction.toString()});
}
```

### Desktop Deployment

#### 1. Windows Deployment

1. **Build for Windows**:
```bash
flutter build windows --release
```

2. **Create Installer**:
   - Use tools like Inno Setup or NSIS
   - Package the EXE with required DLLs

3. **Distribution**:
   - Code signing (optional but recommended)
   - Upload to Microsoft Store or distribute directly

#### 2. macOS Deployment

1. **Build for macOS**:
```bash
flutter build macos --release
```

2. **Code Signing**:
```bash
# Configure signing in macOS runner
# Obtain Developer ID certificate
```

3. **Notarization** (for macOS 10.15+):
```bash
# Upload to Apple's notarization service
xcrun notarytool submit build/macos/Build/Products/Release/*.app \
  --keychain-profile "your-profile"
```

4. **Distribution**:
   - Mac App Store
   - Direct download
   - Enterprise distribution

#### 3. Linux Deployment

1. **Build for Linux**:
```bash
flutter build linux --release
```

2. **Package for Distribution**:
```bash
# Create AppImage
flutter build linux --release
# Use tools like AppImageKit

# Create Snap package
snapcraft init
# Configure snapcraft.yaml
snapcraft
```

3. **Distribution**:
   - Snap Store
   - Flathub
   - Direct download

## Environment Configuration

### Environment Variables

1. **Create Environment Files**:
```bash
# .env.production
API_KEY=your_production_key
API_URL=https://api.yourapp.com
ENVIRONMENT=production

# .env.staging
API_KEY=your_staging_key
API_URL=https://staging-api.yourapp.com
ENVIRONMENT=staging
```

2. **Flutter Configuration**:
```dart
class AppConfig {
  static String get apiKey {
    const environment = String.fromEnvironment('API_KEY');
    return environment.isNotEmpty ? environment : 'fallback_key';
  }

  static bool get isProduction {
    const env = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
    return env == 'production';
  }
}
```

3. **Build with Environment**:
```bash
# Production build
flutter build apk --release \
  --dart-define=API_KEY=${PRODUCTION_API_KEY} \
  --dart-define=ENVIRONMENT=production

# Staging build
flutter build apk --release \
  --dart-define=API_KEY=${STAGING_API_KEY} \
  --dart-define=ENVIRONMENT=staging
```

## CI/CD Pipeline

### GitHub Actions Example

```yaml
name: Flutter CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.10.0'
      - run: flutter pub get
      - run: flutter test

  build-android:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.10.0'
      - run: flutter pub get
      - run: flutter build apk --release
        env:
          API_KEY: ${{ secrets.API_KEY }}
      - uses: actions/upload-artifact@v3
        with:
          name: android-apk
          path: build/app/outputs/apk/release/app-release.apk

  build-ios:
    needs: test
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.10.0'
      - run: flutter pub get
      - run: flutter build ios --release --no-codesign
      - uses: actions/upload-artifact@v3
        with:
          name: ios-ipa
          path: build/ios/iphoneos/Runner.app
```

### Firebase Deployment

```yaml
name: Deploy to Firebase

on:
  push:
    branches: [ main ]

jobs:
  deploy-web:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.10.0'
      - run: flutter pub get
      - run: flutter build web --release
        env:
          API_URL: ${{ secrets.PRODUCTION_API_URL }}
      - uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          channelId: live
          projectId: your-project-id
```

## Security Considerations

### API Key Management

1. **Environment Variables**:
```bash
# Never commit API keys to version control
echo "API_KEY=your_key" >> .env.local
```

2. **Secure Storage**:
```dart
class SecureStorage {
  static Future<String?> getApiKey() async {
    // Use flutter_secure_storage or similar
    return await storage.read(key: 'api_key');
  }

  static Future<void> setApiKey(String key) async {
    await storage.write(key: 'api_key', value: key);
  }
}
```

3. **Runtime Configuration**:
```dart
class ApiConfig {
  static String get apiKey {
    if (Platform.isAndroid || Platform.isIOS) {
      // Mobile: use secure storage
      return await SecureStorage.getApiKey() ?? '';
    } else {
      // Web/Desktop: use environment variables
      return const String.fromEnvironment('API_KEY', defaultValue: '');
    }
  }
}
```

### Code Obfuscation

1. **Enable Obfuscation**:
```bash
flutter build apk --release --obfuscate --split-debug-info=debug-info/
```

2. **ProGuard Rules** (Android):
```proguard
# Keep Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }
```

### Network Security

1. **Certificate Pinning**:
```dart
class SecureHttpClient {
  static HttpClient createSecureClient() {
    final client = HttpClient();
    // Implement certificate pinning
    return client;
  }
}
```

2. **HTTPS Only**:
```xml
<!-- Android: Network Security Config -->
<network-security-config>
  <domain-config cleartextTrafficPermitted="false">
    <domain includeSubdomains="true">your-api.com</domain>
  </domain-config>
</network-security-config>
```

## Monitoring and Analytics

### Crash Reporting

1. **Firebase Crashlytics**:
```yaml
# pubspec.yaml
firebase_crashlytics: ^3.0.0
```

2. **Setup Crashlytics**:
```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Crashlytics
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  // Pass all uncaught errors to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  runApp(MyApp());
}
```

### Performance Monitoring

1. **Firebase Performance**:
```dart
import 'package:firebase_performance/firebase_performance.dart';

void monitorApiCall() async {
  final trace = FirebasePerformance.instance.newTrace('api_call');
  trace.start();

  try {
    // Your API call
    await http.get(Uri.parse('https://api.example.com/data'));
    trace.setMetric('success', 1);
  } catch (e) {
    trace.setMetric('error', 1);
  } finally {
    trace.stop();
  }
}
```

### Analytics

1. **Firebase Analytics**:
```dart
import 'package:firebase_analytics/firebase_analytics.dart';

void trackAgentUsage() {
  FirebaseAnalytics.instance.logEvent(
    name: 'agent_interaction',
    parameters: {
      'agent_name': 'My Assistant',
      'interaction_type': 'voice_chat',
    },
  );
}
```

## Version Management

### Semantic Versioning

Follow semantic versioning for releases:

- **Major**: Breaking changes (1.x.x → 2.x.x)
- **Minor**: New features (x.1.x → x.2.x)
- **Patch**: Bug fixes (x.x.1 → x.x.2)

### Version Configuration

```yaml
# pubspec.yaml
name: your_app
version: 1.2.3+1  # semantic version + build number

# Android version codes (must be incremented)
android:
  defaultConfig:
    versionCode: 123
    versionName: "1.2.3"

# iOS build numbers (must be incremented)
ios:
  buildSettings:
    CURRENT_PROJECT_VERSION: 123
```

### Release Process

1. **Update Version**:
```bash
# Update version in pubspec.yaml
# Update version codes in platform-specific files
```

2. **Create Release Branch**:
```bash
git checkout -b release/1.2.3
```

3. **Build and Test**:
```bash
flutter build apk --release
flutter build ios --release
flutter test
```

4. **Create Release**:
```bash
# Create Git tag
git tag -a v1.2.3 -m "Release version 1.2.3"

# Push to repositories
git push origin main --tags

# Create GitHub release
gh release create v1.2.3 \
  --title "Release 1.2.3" \
  --notes "Release notes here"
```

## Troubleshooting Deployment

### Common Issues

**Build Failures**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk --release
```

**Code Signing Issues**
- Verify certificates are valid
- Check provisioning profiles
- Ensure devices are registered

**App Store Rejection**
- Check App Store guidelines compliance
- Verify metadata completeness
- Test on actual devices

**Performance Issues**
- Enable ProGuard/R8 for Android
- Use appropriate Flutter renderer
- Optimize assets and dependencies

### Platform-Specific Issues

**iOS Issues**
- Check iOS deployment target version
- Verify architecture support (arm64)
- Test on actual devices, not just simulators

**Android Issues**
- Check minimum SDK version (21+ recommended)
- Verify ABI support (armeabi-v7a, arm64-v8a, x86, x86_64)
- Test on various device configurations

**Web Issues**
- Check browser compatibility
- Verify HTTPS setup for microphone access
- Test on different browsers and devices

## Support and Maintenance

### Regular Updates

1. **Flutter SDK Updates**:
```bash
flutter upgrade
flutter pub upgrade
```

2. **Dependency Updates**:
```bash
flutter pub outdated  # Check for updates
flutter pub upgrade   # Update dependencies
```

3. **Security Updates**:
- Monitor for security vulnerabilities
- Update dependencies regularly
- Review and update API keys periodically

### Monitoring

1. **App Performance**:
- Monitor crash rates and performance metrics
- Track user engagement and retention
- Analyze error logs and user feedback

2. **User Support**:
- Set up user feedback mechanisms
- Monitor app store reviews and ratings
- Provide clear support contact information

### Backup and Recovery

1. **Source Code Backup**:
```bash
# Regular git commits and pushes
git add .
git commit -m "Regular backup"
git push origin main
```

2. **Keystore Backup**:
- Securely backup signing keystores
- Store in encrypted, version-controlled locations
- Document recovery procedures

## Conclusion

Successful deployment requires careful attention to platform-specific requirements, security considerations, and proper configuration management. Following this guide will help ensure your Flutter AI Agent SDK application is properly deployed and maintained across all target platforms.

For additional support:
- **📧 Email**: [chief.stategist.j@gmail.com](mailto:chief.stategist.j@gmail.com)
- **🐛 Issues**: [GitHub Issues](https://github.com/Chief-Strategist-J/flutter_ai_agent_sdk/issues)
- **💬 Discussions**: [GitHub Discussions](https://github.com/Chief-Strategist-J/flutter_ai_agent_sdk/discussions)
