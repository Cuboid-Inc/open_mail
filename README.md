# Open Mail

![Flutter 3.24.4](https://img.shields.io/badge/Flutter-3.24.4-blue)
[![pub package](https://img.shields.io/pub/v/open_mail.svg?label=open_mail&color=blue)](https://pub.dev/packages/open_mail)

### Open Mail is a Flutter package designed to simplify the process of querying installed email apps on a device and allowing users to open the email app of their choice.

This package is especially useful for developers who want to provide users with more control over which email app to use, unlike url_launcher, which typically opens only the default email app.

If you just want to compose an email or open any app with a `mailto:` link, you are looking for [url_launcher](https://pub.dev/packages/url_launcher).

This Flutter package allows users to open their installed mail app effortlessly. It draws inspiration from similar packages, particularly [open_mail_app](https://pub.dev/packages/open_mail_app), and builds upon that foundation to provide an improved and streamlined experience.

## Why Use Open Mail?

- `url_launcher` allows you to open `mailto:` links but does not let you:
  - Choose a specific email app.
  - Query the list of available email apps.
- On iOS, `url_launcher` will always open the default **Mail App**, even if the user prefers another app like Gmail or Outlook.
- With **Open Mail**, you can:
  - Identify all installed email apps.
  - Allow users to select their preferred email app (if multiple options are available).

## Setup

### Android

No additional configuration is required for Android. The package works out of the box.

### iOS Configuration

For iOS, you need to list the URL schemes of the email apps you want to query in your `Info.plist` file. Add the following code:

```
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>googlegmail</string>
    <string>x-dispatch</string>
    <string>readdle-spark</string>
    <string>airmail</string>
    <string>ms-outlook</string>
    <string>ymail</string>
    <string>fastmail</string>
    <string>superhuman</string>
    <string>protonmail</string>
</array>
```

Feel free to file an issue on GitHub for adding more popular email apps you would like to see supported. These apps must be added to both your app’s `Info.plist` and the source code of this library.
Please file issues to add popular email apps you would like to see on iOS. They need to be added to both your app's `Info.plist` and in the source of this library.

## Installation

Add the following to your `pubspec.yaml`:

```
dependencies:
  open_mail: ^1.2.1
```

Then, run the following command:

```
flutter pub get
```

## Usage

### Basic Usage - Open First Available Mail App

```dart
import 'package:flutter/material.dart';
import 'package:open_mail/open_mail.dart';

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Open Mail App Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final result = await OpenMail.openMailApp();
            
            if (!result.didOpen) {
              showNoMailAppsDialog(context);
            }
          },
          child: const Text("Open Mail App"),
        ),
      ),
    );
  }

  void showNoMailAppsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("No Mail Apps Found"),
        content: const Text("There are no email apps installed on your device."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
```

### Advanced Usage - Show Mail App Picker

To allow users to select from multiple installed mail apps, follow this pattern:

```dart
import 'package:flutter/material.dart';
import 'package:open_mail/open_mail.dart';

class MailAppPickerExample extends StatefulWidget {
  const MailAppPickerExample({super.key});

  @override
  State<MailAppPickerExample> createState() => _MailAppPickerExampleState();
}

class _MailAppPickerExampleState extends State<MailAppPickerExample> {
  List<MailApp> _availableApps = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMailApps();
  }

  Future<void> _loadMailApps() async {
    setState(() => _isLoading = true);
    final apps = await OpenMail.getMailApps();
    setState(() {
      _availableApps = apps;
      _isLoading = false;
    });
  }

  Future<void> _openMailAppWithPicker() async {
    if (_availableApps.isEmpty) {
      showNoMailAppsDialog(context);
      return;
    }

    // If only one app is available, open it directly
    if (_availableApps.length == 1) {
      await OpenMail.openMailApp();
      return;
    }

    // Show custom picker dialog
    final selectedApp = await showDialog<MailApp>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Email App'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _availableApps.length,
            itemBuilder: (context, index) {
              final app = _availableApps[index];
              return ListTile(
                leading: const Icon(Icons.email),
                title: Text(app.name),
                onTap: () => Navigator.of(context).pop(app),
              );
            },
          ),
        ),
      ),
    );

    if (selectedApp != null) {
      await OpenMail.openSpecificMailApp(selectedApp.name);
    }
  }

  void showNoMailAppsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("No Mail Apps Found"),
        content: const Text("There are no email apps installed on your device."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mail App Picker Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _openMailAppWithPicker,
                child: Text(_availableApps.length == 1
                    ? "Open Mail App"
                    : "Pick Mail App"),
              ),
            const SizedBox(height: 16),
            Text(
              'Available Apps: ${_availableApps.length}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
```

### Migration Guide (v1.1.0 → v1.2.0)

If you're upgrading from v1.1.0, here's how to migrate your code:

#### Before (v1.1.0):
```dart
// OLD: Using the now-removed MailAppPickerDialog
var result = await OpenMail.openMailApp();
if (!result.didOpen && result.canOpen) {
  showDialog(
    context: context,
    builder: (_) {
      return MailAppPickerDialog(  // This no longer exists!
        mailApps: result.options,
      );
    },
  );
}
```

#### After (v1.2.0):
```dart
// NEW: Custom picker implementation
final apps = await OpenMail.getMailApps();
if (apps.isEmpty) {
  showNoMailAppsDialog(context);
} else if (apps.length == 1) {
  await OpenMail.openMailApp();
} else {
  final selectedApp = await showDialog<MailApp>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Select Email App'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: apps.map((app) => ListTile(
          leading: const Icon(Icons.email),
          title: Text(app.name),
          onTap: () => Navigator.of(context).pop(app),
        )).toList(),
      ),
    ),
  );
  
  if (selectedApp != null) {
    await OpenMail.openSpecificMailApp(selectedApp.name);
  }
}
```

### API Changes in v1.2.0

- **Removed**: `MailAppPickerDialog` widget (replaced with custom dialog pattern)
- **Changed**: `OpenMail.openMailApp()` no longer accepts `nativePickerTitle` parameter on Android
- **Changed**: `OpenMail.openSpecificMailApp(name, emailContent)` → `OpenMail.openSpecificMailApp(name)`
- **New**: `OpenMail.getMailApps()` - Get list of available mail apps

### Opening Specific Mail Apps

```dart
// Get available apps first
final apps = await OpenMail.getMailApps();

// Open a specific app by name
await OpenMail.openSpecificMailApp('Gmail');

// Open Apple Mail
await OpenMail.openSpecificMailApp('Apple Mail');
```
## Version 1.2.0 Changes and Feedback

### What Changed in v1.2.0

The v1.2.0 release introduced several breaking changes to improve the package's API design and remove deprecated functionality:

1. **Removed MailAppPickerDialog**: The built-in picker dialog was removed in favor of a more flexible custom dialog pattern
2. **Simplified API**: Removed the `nativePickerTitle` parameter and streamlined the `openSpecificMailApp` method
3. **Improved iOS Support**: Switched to using `message://` scheme for Apple Mail inbox access

### Addressing Versioning Concerns

We acknowledge that the removal of `MailAppPickerDialog` in a minor version (1.2.0) may seem inconsistent with semantic versioning principles. However, this change was made for the following reasons:

- **API Simplification**: The MailAppPickerDialog was a minimal wrapper that didn't provide significant value over a custom dialog
- **Flexibility**: Custom dialogs allow developers full control over styling and functionality
- **Reduced Dependencies**: Removing the widget reduces the package's footprint and potential conflicts
- **Clean Architecture**: Encourages developers to implement their own UI patterns that match their app's design system

### Migration Benefits

The v1.2.0 changes provide several benefits:

- **Better Performance**: Custom dialogs can be optimized for your specific use case
- **Enhanced Customization**: Full control over dialog appearance and behavior
- **Simplified API**: Fewer parameters and clearer method signatures
- **Platform Consistency**: More predictable behavior across iOS and Android
- **Design System Alignment**: Use your app's native dialog components for consistency

For most use cases, the migration requires minimal changes - typically just replacing the `MailAppPickerDialog` with a custom `AlertDialog` or `SimpleDialog` using the list of apps returned by `OpenMail.getMailApps()`.

### Complete Migration Example

Here's a complete before/after comparison showing how to migrate from v1.1.0 to v1.2.0:

```dart
// v1.1.0 Code (Broken in v1.2.0)
class OldMailPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        var result = await OpenMail.openMailApp();
        if (!result.didOpen && result.canOpen) {
          showDialog(
            context: context,
            builder: (_) {
              return MailAppPickerDialog(  // ❌ No longer exists!
                mailApps: result.options,
              );
            },
          );
        }
      },
      child: Text('Open Mail App'),
    );
  }
}

// v1.2.0 Code (Recommended)
class NewMailPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _openMailApp(context),
      child: Text('Open Mail App'),
    );
  }

  Future<void> _openMailApp(BuildContext context) async {
    final apps = await OpenMail.getMailApps();
    
    if (apps.isEmpty) {
      _showNoAppsDialog(context);
      return;
    }
    
    if (apps.length == 1) {
      // Single app - open directly
      await OpenMail.openMailApp();
      return;
    }
    
    // Multiple apps - show picker
    final selectedApp = await showDialog<MailApp>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Email App'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              return ListTile(
                leading: const Icon(Icons.email, color: Colors.blue),
                title: Text(app.name),
                onTap: () => Navigator.of(context).pop(app),
              );
            },
          ),
        ),
      ),
    );
    
    if (selectedApp != null) {
      await OpenMail.openSpecificMailApp(selectedApp.name);
    }
  }
  
  void _showNoAppsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Email Apps Found'),
        content: const Text('Please install an email app to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
```

This migration provides a more robust and customizable solution while maintaining the same core functionality.

## Key Features

1. Detect Installed Email Apps

- Automatically identifies email apps installed on the device.

2. Open Specific Email App

- Open a specific app based on user selection or app configuration.

3. Native Dialog Support

- On iOS, displays a dialog to let users pick their preferred app when multiple apps are installed.

## Support

Feel free to file issues on the [GitHub](https://github.com/Cuboid-Inc/open_mail) repository for:

- Adding support for additional email apps.
- Reporting bugs or suggesting improvements.

## Contributors

<table>
  <tr>
   <td align="center"><a href="https://github.com/mrcse"><img src="https://avatars.githubusercontent.com/u/73348512?v=4" width="100px;" alt=""/><br /><sub><b>Jamshid Ali</b></sub></a><br /><a href="https://github.com/mrcse" title="Code">💻</a></td>
  <td align="center"><a href="https://github.com/Mubashir-Saeed1"><img src="https://avatars.githubusercontent.com/u/58908265?v=4" width="100px;" alt=""/><br /><sub><b>Mubashir Saeed</b></sub></a><br />
  <a href="https://github.com/Mubashir-Saeed1" title="Code">💻</a></td>
   
  </tr>
</table>

## License

This package is distributed under the MIT License. See the [LICENSE](https://raw.githubusercontent.com/Cuboid-Inc/open_mail/main/LICENSE) file for details.
