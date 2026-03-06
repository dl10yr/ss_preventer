# Publishing Guide

## 1. Prerequisites
- Flutter SDK installed.
- Pub.dev publisher account prepared.
- Repository URLs in `pubspec.yaml` updated to real URLs.

## 2. Update package metadata
- Update `version` in `pubspec.yaml`.
- Update `CHANGELOG.md`.
- Verify `LICENSE` is present.
- Verify `README.md` and example are up to date.

## 3. Validate locally
```bash
flutter pub get
flutter analyze
flutter test
flutter pub publish --dry-run
```

If `flutter pub publish --dry-run` reports warnings/errors, fix them before proceeding.

## 4. Publish
```bash
flutter pub publish
```

## 5. Post publish checklist
- Create git tag (for example `v0.1.0`).
- Push tag and release note.
- Verify package page on pub.dev.
