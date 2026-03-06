# ss_preventer

Flutter plugin for screenshot prevention and screenshot detection stream.

## Features
- `preventOn`: enable screenshot prevention.
- `preventOff`: disable screenshot prevention.
- `setDetectionEnabled`: enable/disable screenshot detection callbacks.
- `screenshotStream`: stream event when screenshot is detected.

## Platform support
- Android
  - `preventOn` / `preventOff`: supported (uses `FLAG_SECURE`).
  - `screenshotStream`: Android 14+ only (uses `registerScreenCaptureCallback`).
- iOS
  - `preventOn` / `preventOff`: supported.
  - `screenshotStream`: supported (`UIApplication.userDidTakeScreenshotNotification`).

## Installation
Add dependency:

```yaml
dependencies:
  ss_preventer: ^0.1.0
```

### Android permission (app side)
To use screenshot detection on Android 14+, add this permission in your app's `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.DETECT_SCREEN_CAPTURE" />
```

## Usage

```dart
import 'dart:async';

import 'package:ss_preventer/ss_preventer.dart';

StreamSubscription? subscription;

Future<void> startProtection() async {
  await SsPreventer.preventOn();
  await SsPreventer.setDetectionEnabled(true);

  subscription = SsPreventer.screenshotStream.listen((event) {
    // Handle screenshot detection.
    print('Screenshot detected at: ${event.detectedAt}');
  });
}

Future<void> stopProtection() async {
  await SsPreventer.preventOff();
  await SsPreventer.setDetectionEnabled(false);
  await subscription?.cancel();
}
```

## iOS implementation note
This plugin follows Flutter's `UISceneDelegate` migration guidance for plugins and uses scene/application lifecycle registration.

Reference:
- https://docs.flutter.dev/release/breaking-changes/uiscenedelegate#migration-guide-for-flutter-plugins

## Example
See `/example` for a full sample app.

## Publishing
See [PUBLISHING.md](PUBLISHING.md).

## License
MIT. See [LICENSE](LICENSE).
