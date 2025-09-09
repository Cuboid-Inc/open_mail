// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_mail/open_mail.dart';

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  EmailContent get emailContent => EmailContent(
        to: ['user@domain.com'],
        subject: 'Hello!',
        body: 'How are you doing? [Debug: ${DateTime.now()}]',
        cc: ['user2@domain.com', 'user3@domain.com'],
        bcc: ['boss@domain.com'],
        attachments: [
          // Example file path (must be accessible and supported by the mail app)
          // 'file:///path/to/your/file.pdf',
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Open Mail Example"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            // Button to open a mail app
            ElevatedButton(
              child: const Text("Open Mail App"),
              onPressed: () async {
                var result = await OpenMail.openMailApp();

                // If no mail apps are installed
                if (!result.didOpen && !result.canOpen) {
                  showNoMailAppsDialog(context);
                }
              },
            ),

            // Button to compose an email in the mail app
            ElevatedButton(
              child: const Text('Compose Email'),
              onPressed: () async {
                OpenMailAppResult result;

                try {
                  // Compose a new email using the first available mail app
                  result = await OpenMail.composeNewEmailInMailApp(
                      nativePickerTitle: 'Select email app to compose',
                      emailContent: emailContent);

                  if (!result.didOpen && !result.canOpen) {
                    showNoMailAppsDialog(context);
                  }
                } catch (e) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Error'),
                      content: Text('Failed to compose email: $e'),
                      actions: [
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),

            // Button to get the list of installed mail apps and open a specific one
            ElevatedButton(
              child: const Text("Open Specific One Mail App"),
              onPressed: () async {
                try {
                  // Open the first available mail app directly if only one is installed
                  var apps = await OpenMail.getMailApps();

                  // If no mail apps are installed
                  if (apps.isEmpty) {
                    showNoMailAppsDialog(context);
                  }
                  // Show a dialog listing all available mail apps
                  else {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Installed Mail Apps'),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: apps.length,
                              itemBuilder: (context, index) {
                                final app = apps[index];
                                return ListTile(
                                  onTap: () async {
                                    try {
                                      await OpenMail.openSpecificMailApp(
                                          app.name);
                                    } catch (e) {
                                      log('Error: $e');
                                    }
                                  },
                                  title: Text(app.name),
                                  subtitle: Text(Platform.isIOS
                                      ? 'iOS Scheme: ${app.iosLaunchScheme}'
                                      : Platform.isAndroid
                                          ? 'Package: ${app.nativeId}'
                                          : 'Unknown Platform'),
                                );
                              },
                            ),
                          ),
                          actions: [
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        );
                      },
                    );
                  }
                } catch (e) {
                  // Debug print removed
                }
              },
            ),

            // Get Mails Apps and Compose Email in Specific One

            ElevatedButton(
              child: const Text("Compose Email in Specific Mail Apps"),
              onPressed: () async {
                try {
                  // Retrieve the list of installed mail apps
                  var apps = await OpenMail.getMailApps();

                  // If no mail apps are installed
                  if (apps.isEmpty) {
                    showNoMailAppsDialog(context);
                  }
                  // Show a dialog listing all available mail apps
                  else {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Installed Mail Apps'),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: apps.length,
                              itemBuilder: (context, index) {
                                final app = apps[index];
                                return ListTile(
                                  onTap: () async {
                                    try {
                                      await OpenMail
                                          .composeNewEmailInSpecificMailApp(
                                              mailApp: app,
                                              emailContent: emailContent);
                                    } catch (e) {
                                      log('Error: $e');
                                    }
                                  },
                                  title: Text(app.name),
                                  subtitle: Text(Platform.isIOS
                                      ? 'iOS Scheme: ${app.iosLaunchScheme}'
                                      : Platform.isAndroid
                                          ? 'Package: ${app.nativeId}'
                                          : 'Unknown Platform'),
                                );
                              },
                            ),
                          ),
                          actions: [
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        );
                      },
                    );
                  }
                } catch (e) {
                  // Debug print removed
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to show a dialog when no mail apps are found
  void showNoMailAppsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Open Mail App"),
          content: const Text("No mail apps installed"),
          actions: <Widget>[
            TextButton(
              child: const Text("Settings"),
              onPressed: () async {
                // Open device settings (works for both iOS and Android)
                await OpenMail.openDeviceSettings();
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
            )
          ],
        );
      },
    );
  }
}
