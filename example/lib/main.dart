// ignore_for_file: use_build_context_synchronously

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
                //TODO: open default mail inbox only
                var result = await OpenMail.openMailApp(
                  nativePickerTitle: 'Select email app to open',
                );

                // If no mail apps are installed
                if (!result.didOpen && !result.canOpen) {
                  showNoMailAppsDialog(context);
                }
                // If multiple mail apps are available on iOS, show a picker
                else if (!result.didOpen && result.canOpen) {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return MailAppPickerDialog(
                        mailApps: result.options,
                      );
                    },
                  );
                }
              },
            ),

            // Button to test mail app detection
            ElevatedButton(
              child: const Text("Debug Mail App Detection (Custom Picker)"),
              onPressed: () async {
                try {
                  var options = await OpenMail.getMailApps();
                  showDialog(
                    context: context,
                    builder: (_) => MailAppPickerDialog(
                      mailApps: options,
                      itemBuilder: (context, app, fn) => ListTile(
                        onTap: () async {
                          // TODO: open specific mail app inbox only
                          await OpenMail.openSpecificMailApp(
                              app.name, emailContent);
                        },
                        leading:
                            const Icon(Icons.email), // Placeholder for icon
                        title: Text(app.name),
                        subtitle: Text(app.iosLaunchScheme ?? "No ID"),
                      ),
                    ),
                  );
                } catch (e) {
                  // Debug print removed
                  debugPrint('Error: $e');
                }
              },
            ),

            // Button to compose an email in the mail app
            ElevatedButton(
              child: const Text('Open mail app, with email already composed'),
              onPressed: () async {
                OpenMailAppResult result;

                try {
                  result = await OpenMail.composeNewEmailInMailApp(
                      nativePickerTitle: 'Select email app to compose',
                      emailContent: emailContent);

                  if (!result.didOpen && !result.canOpen) {
                    showNoMailAppsDialog(context);
                  } else if (!result.didOpen && result.canOpen) {
                    showDialog(
                      context: context,
                      builder: (_) => MailAppPickerDialog(
                        mailApps: result.options,
                        emailContent: emailContent,
                      ),
                    );
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

            // Button to get the list of installed mail apps
            ElevatedButton(
              child: const Text("Get Mail Apps"),
              onPressed: () async {
                try {
                  // Retrieve the list of installed mail apps
                  var apps = await OpenMail.getMailApps();

                  // Debug print removed
                  // Debug print removed

                  // If no mail apps are installed
                  if (apps.isEmpty) {
                    showNoMailAppsDialog(context);
                  }
                  // Show a dialog listing all available mail apps
                  else {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return MailAppPickerDialog(
                          mailApps: apps,
                          emailContent: EmailContent(
                            to: ['user@domain.com'], // Pre-filled recipient
                            subject: 'Hello!', // Pre-filled subject
                            body: 'How are you doing?', // Pre-filled body
                            cc: [
                              'user2@domain.com',
                              'user3@domain.com'
                            ], // Pre-filled CC
                            bcc: ['boss@domain.com'], // Pre-filled BCC
                          ),
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
