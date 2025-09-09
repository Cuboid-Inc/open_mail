# Changelog

#

## [1.2.0] - 2025-09-09

### Breaking Changes

- OpenMail.openMailApp: removed the nativePickerTitle parameter. Android now uses the system default chooser title.
- OpenMail.openSpecificMailApp: signature changed to openSpecificMailApp(String name). It now opens the target app’s inbox only and returns OpenMailAppResult, similar to openMailApp.

### Changed

- iOS: Apple Mail inbox scheme switched from mailto:// to message:// for opening the inbox reliably.
- Android: native implementation for openMailApp ignores custom titles and uses Intent chooser with default title.
- Example and tests updated to match new APIs.

### Fixed

- iOS detection of Gmail and other apps: clarified and enforced LSApplicationQueriesSchemes requirements so canOpenURL works and Gmail appears in the list when installed.

### iOS Setup Notes

- Ensure these URL schemes are added to your app’s Info.plist under LSApplicationQueriesSchemes for detection:
  - googlegmail, x-dispatch, readdle-spark, airmail, ms-outlook, ymail, fastmail, superhuman, protonmail, message

### Migration

- Replace OpenMail.openMailApp(nativePickerTitle: '...') with OpenMail.openMailApp().
- Replace OpenMail.openSpecificMailApp(name, emailContent) with OpenMail.openSpecificMailApp(name).

## [1.1.0] - 2025-05-26

### Added

- Robust fallback logic for Apple Mail on iOS: always uses `mailto:` for compose, ensuring pre-filled fields work reliably.
- Improved compose URL generation for Gmail and other supported apps.
- Comprehensive error handling and fallback to `mailto:` for all mail apps if custom scheme fails.

### Changed

- Cleaned up and productionized code: removed all debug/print statements and development-only code.
- Ready for production release.

All notable changes to this project will be documented in this file.

## [1.0.1] - 2025-05-25

### Bug Fixes

- Fixed mail app detection in Android release builds.
- Resolved "Abstract classes can't be instantiated!" error caused by GSON serialization issues in release mode.
- Updated the JSON serialization for app data to use JSONObject directly instead of GSON to prevent ProGuard/R8 obfuscation problems.
- Added proper null safety handling in native code for email content fields.
- Updated ProGuard rules to correctly keep necessary classes and their members.
- Ensured consistent creation of `App` objects in Kotlin code.

## [1.0.0] - 2025-05-15

### Major Upgrade

- Migrated Android plugin to v2 embedding and modern APIs.
- Updated Android build to use AGP 8.2.2, Kotlin 1.8.22, compileSdk 35, and minSdk 26.
- Improved compatibility with latest Flutter and Android versions.
- Fixed platform channel and plugin registration issues.

## [0.0.7] - 2025-01-04

### Fix and Improve Documentation

- Fix some deprecated dependency and update documentaiton.

## [0.0.6] - 2025-01-04

### Improvement

- Downgrade platform version from 3.1.6 to 3.1.0 to remove conflict dependecies.

## [0.0.5] - 2024-11-19

### Added

- Improved documentation for better clarity on package usage.

### Fixed

- Minor typos and formatting issues in the README file.

## [0.0.4] - 2024-11-19

### Updated

- Enhanced documentation with additional examples.

## [0.0.3] - 2024-11-19

### Changed

- Updated README with clearer instructions and added Key Features section.

### Fixed

- Resolved minor inconsistencies in the example code.

## [0.0.2] - 2024-11-19

### Updated

- Improved documentation with better usage guidelines.

## [0.0.1] - 2024-11-19

### Initial Release

- First release of `open_mail`, providing basic functionality to open mail applications on supported platforms.
