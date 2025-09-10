// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:collection/collection.dart'; // Import for firstWhereOrNull
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_mail/src/models/models.dart';
import 'package:platform/platform.dart';
import 'package:url_launcher/url_launcher.dart';

/// Launch Schemes for supported apps:
// Use message: scheme for opening Apple Mail inbox on iOS
const String _LAUNCH_SCHEME_APPLE_MAIL = 'message://';
const String _LAUNCH_SCHEME_GMAIL = 'googlegmail://';
const String _LAUNCH_SCHEME_DISPATCH = 'x-dispatch://';
const String _LAUNCH_SCHEME_SPARK = 'readdle-spark://';
const String _LAUNCH_SCHEME_AIRMAIL = 'airmail://';
const String _LAUNCH_SCHEME_OUTLOOK = 'ms-outlook://';
const String _LAUNCH_SCHEME_YAHOO = 'ymail://';
const String _LAUNCH_SCHEME_FASTMAIL = 'fastmail://';
const String _LAUNCH_SCHEME_SUPERHUMAN = 'superhuman://';
const String _LAUNCH_SCHEME_PROTONMAIL = 'protonmail://';

/// A list of mail apps that can be used to open email.
///
/// This list is not exhaustive and may not include all mail apps available on
/// the user's device.
final List<MailApp> mailApps = <MailApp>[
  MailApp(
    name: 'Apple Mail',
    iosLaunchScheme: _LAUNCH_SCHEME_APPLE_MAIL,
    composeData: ComposeData(
      scheme: 'mailto://',
    ),
  ),
  MailApp(
    name: 'Gmail',
    iosLaunchScheme: _LAUNCH_SCHEME_GMAIL,
    composeData: ComposeData(
      scheme: '$_LAUNCH_SCHEME_GMAIL/co',
    ),
  ),
  MailApp(
    name: 'Dispatch',
    iosLaunchScheme: _LAUNCH_SCHEME_DISPATCH,
    composeData: ComposeData(
      scheme: '$_LAUNCH_SCHEME_DISPATCH/compose',
    ),
  ),
  MailApp(
    name: 'Spark',
    iosLaunchScheme: _LAUNCH_SCHEME_SPARK,
    composeData: ComposeData(
      scheme: '${_LAUNCH_SCHEME_SPARK}compose',
      toParameter: 'recipient',
    ),
  ),
  MailApp(
    name: 'Airmail',
    iosLaunchScheme: _LAUNCH_SCHEME_AIRMAIL,
    composeData: ComposeData(
      scheme: '${_LAUNCH_SCHEME_AIRMAIL}compose',
      bodyParameter: 'plainBody',
    ),
  ),
  MailApp(
    name: 'Outlook',
    iosLaunchScheme: _LAUNCH_SCHEME_OUTLOOK,
    composeData: ComposeData(
      scheme: '${_LAUNCH_SCHEME_OUTLOOK}compose',
    ),
  ),
  MailApp(
    name: 'Yahoo Mail',
    iosLaunchScheme: _LAUNCH_SCHEME_YAHOO,
    composeData: ComposeData(
      scheme: '${_LAUNCH_SCHEME_YAHOO}mail/compose',
    ),
  ),
  MailApp(
    name: 'Fastmail',
    iosLaunchScheme: _LAUNCH_SCHEME_FASTMAIL,
    composeData: ComposeData(
      scheme: '${_LAUNCH_SCHEME_FASTMAIL}mail/compose',
    ),
  ),
  MailApp(
    name: 'Superhuman',
    iosLaunchScheme: _LAUNCH_SCHEME_SUPERHUMAN,
    composeData: ComposeData(scheme: _LAUNCH_SCHEME_SUPERHUMAN),
  ),
  MailApp(
    name: 'ProtonMail',
    iosLaunchScheme: _LAUNCH_SCHEME_PROTONMAIL,
    composeData: ComposeData(
      scheme: '${_LAUNCH_SCHEME_PROTONMAIL}mailto:',
    ),
  ),
];

class OpenMail {
  /// Opens the device settings page (works for both iOS and Android)
  static Future<void> openDeviceSettings() async {
    final settingsUri = _isIOS
        ? Uri.parse('App-Prefs:')
        : Uri.parse('package:com.android.settings');
    try {
      await launchUrl(settingsUri);
    } catch (_) {
      // Fallback: try generic settings URL
      if (_isIOS) {
        await launchUrl(Uri.parse('app-settings:'));
      } else {
        await launchUrl(Uri.parse('settings:'));
      }
    }
  }

  OpenMail._();

  @visibleForTesting
  static Platform platform = const LocalPlatform();

  static bool get _isAndroid => platform.isAndroid;

  static bool get _isIOS => platform.isIOS;

  static const MethodChannel _channel = MethodChannel('open_mail');
  static List<String> _filterList = <String>['paypal'];
  static final List<MailApp> _supportedMailApps = [
    MailApp(
      name: 'Apple Mail',
      iosLaunchScheme: _LAUNCH_SCHEME_APPLE_MAIL,
      composeData: ComposeData(
        scheme: 'mailto://',
      ),
    ),
    MailApp(
      name: 'Gmail',
      iosLaunchScheme: _LAUNCH_SCHEME_GMAIL,
      composeData: ComposeData(
        scheme: '$_LAUNCH_SCHEME_GMAIL/co',
      ),
    ),
    MailApp(
      name: 'Dispatch',
      iosLaunchScheme: _LAUNCH_SCHEME_DISPATCH,
      composeData: ComposeData(
        scheme: '$_LAUNCH_SCHEME_DISPATCH/compose',
      ),
    ),
    MailApp(
      name: 'Spark',
      iosLaunchScheme: _LAUNCH_SCHEME_SPARK,
      composeData: ComposeData(
        scheme: '${_LAUNCH_SCHEME_SPARK}compose',
        toParameter: 'recipient',
      ),
    ),
    MailApp(
      name: 'Airmail',
      iosLaunchScheme: _LAUNCH_SCHEME_AIRMAIL,
      composeData: ComposeData(
        scheme: '${_LAUNCH_SCHEME_AIRMAIL}compose',
        bodyParameter: 'plainBody',
      ),
    ),
    MailApp(
      name: 'Outlook',
      iosLaunchScheme: _LAUNCH_SCHEME_OUTLOOK,
      composeData: ComposeData(
        scheme: '${_LAUNCH_SCHEME_OUTLOOK}compose',
      ),
    ),
    MailApp(
      name: 'Yahoo Mail',
      iosLaunchScheme: _LAUNCH_SCHEME_YAHOO,
      composeData: ComposeData(
        scheme: '${_LAUNCH_SCHEME_YAHOO}mail/compose',
      ),
    ),
    MailApp(
      name: 'Fastmail',
      iosLaunchScheme: _LAUNCH_SCHEME_FASTMAIL,
      composeData: ComposeData(
        scheme: '${_LAUNCH_SCHEME_FASTMAIL}mail/compose',
      ),
    ),
    MailApp(
      name: 'Superhuman',
      iosLaunchScheme: _LAUNCH_SCHEME_SUPERHUMAN,
      composeData: ComposeData(scheme: _LAUNCH_SCHEME_SUPERHUMAN),
    ),
    MailApp(
      name: 'ProtonMail',
      iosLaunchScheme: _LAUNCH_SCHEME_PROTONMAIL,
      composeData: ComposeData(
        scheme: '${_LAUNCH_SCHEME_PROTONMAIL}mailto:',
      ),
    ),
  ];

  /// Attempts to open an email app installed on the device.
  ///
  /// Android: Will open mail app or show native picker if multiple.
  ///
  /// iOS: Will open mail app if single installed mail app is found. If multiple
  /// are found will return a [OpenMailAppResult] that contains list of
  /// [MailApp]s. This can be used along with [MailAppPickerDialog] to allow
  /// the user to pick the mail app they want to open.
  ///
  /// Also see [openSpecificMailApp] and [getMailApps] for other use cases.
  ///
  /// Android: shows a system chooser if needed; no custom title parameter.
  static Future<OpenMailAppResult> openMailApp() async {
    if (_isAndroid) {
      final result = await _channel.invokeMethod<bool>(
            'openMailApp',
            null,
          ) ??
          false;
      return OpenMailAppResult(didOpen: result);
    } else if (_isIOS) {
      final apps = await _getIosMailApps();
      if (apps.isNotEmpty) {
        // Ensure iosLaunchScheme is not null before parsing
        final launchScheme = apps.first.iosLaunchScheme;
        if (launchScheme != null) {
          final result = await launchUrl(
            Uri.parse(launchScheme),
          );
          return OpenMailAppResult(didOpen: result, options: apps);
        }
        return OpenMailAppResult(didOpen: false); // Fallback if scheme is null
      } else {
        return OpenMailAppResult(didOpen: false, options: apps);
      }
    } else {
      throw UnsupportedError('Platform not supported');
    }
  }

  /// Attempts to open a specific email app installed on the device.
  /// Get a [MailApp] from calling [getMailApps]
  static Future<OpenMailAppResult> openSpecificMailApp(String name) async {
    if (_isAndroid) {
      final result = await _channel.invokeMethod<bool>(
            'openSpecificMailApp',
            <String, dynamic>{'name': name},
          ) ??
          false;
      return OpenMailAppResult(didOpen: result);
    } else if (_isIOS) {
      final mailApp =
          _supportedMailApps.firstWhereOrNull((x) => x.name == name);
      final scheme = mailApp?.iosLaunchScheme;
      if (scheme == null) return OpenMailAppResult(didOpen: false);
      try {
        final uri = Uri.parse(scheme);
        final can = await canLaunchUrl(uri);
        if (!can) return OpenMailAppResult(didOpen: false);
        final did = await launchUrl(uri);
        return OpenMailAppResult(didOpen: did);
      } catch (_) {
        return OpenMailAppResult(didOpen: false);
      }
    } else {
      throw UnsupportedError('Platform currently not supported');
    }
  }

  /// Allows you to open a mail application installed on the user's device
  /// and start composing a new email with the contents in [emailContent].
  ///
  /// [EmailContent] Provides content for  the email you're composing
  /// [String] (android) sets the title of the native picker.
  /// throws an [Exception] if you're launching from an unsupported platform.
  static Future<OpenMailAppResult> composeNewEmailInMailApp({
    String nativePickerTitle = '',
    required EmailContent emailContent,
  }) async {
    if (_isAndroid) {
      final result = await _channel.invokeMethod<bool>(
            'composeNewEmailInMailApp',
            <String, dynamic>{
              'nativePickerTitle': nativePickerTitle,
              'emailContent': jsonEncode(emailContent.toJson()),
            },
          ) ??
          false;
      return OpenMailAppResult(didOpen: result);
    } else if (_isIOS) {
      List<MailApp> installedApps = await _getIosMailApps();
      if (installedApps.isNotEmpty) {
        final MailApp app = installedApps.first;
        bool result = false;
        // Always use mailto: for Apple Mail to allow pre-filled fields
        if (app.name == 'Apple Mail') {
          try {
            debugPrint(
                'DEBUG: Apple Mail detected, using mailto: fallback for compose');
            final mailtoUri = Uri(
              scheme: 'mailto',
              path: emailContent.to?.join(',') ?? '',
              queryParameters: {
                'subject': emailContent.subject ?? '',
                'body': emailContent.body ?? '',
                if (emailContent.cc?.isNotEmpty ?? false)
                  'cc': emailContent.cc!.join(','),
                if (emailContent.bcc?.isNotEmpty ?? false)
                  'bcc': emailContent.bcc!.join(','),
              },
            );
            debugPrint('DEBUG: Mailto URI for Apple Mail: $mailtoUri');
            result = await launchUrl(mailtoUri);
          } catch (e) {
            debugPrint('ERROR: Apple Mail mailto fallback failed: $e');
          }
        } else {
          String? launchScheme = app.composeLaunchScheme(emailContent);
          if (launchScheme != null) {
            try {
              final uri = Uri.parse(launchScheme);
              final canLaunch = await canLaunchUrl(uri);
              debugPrint(
                  'DEBUG: Can launch custom scheme for ${app.name}: $canLaunch');
              if (canLaunch) {
                result = await launchUrl(uri);
              } else {
                debugPrint(
                    'DEBUG: Custom scheme failed, falling back to mailto:');
                final mailtoUri = Uri(
                  scheme: 'mailto',
                  path: emailContent.to?.join(',') ?? '',
                  queryParameters: {
                    'subject': emailContent.subject ?? '',
                    'body': emailContent.body ?? '',
                    if (emailContent.cc?.isNotEmpty ?? false)
                      'cc': emailContent.cc!.join(','),
                    if (emailContent.bcc?.isNotEmpty ?? false)
                      'bcc': emailContent.bcc!.join(','),
                  },
                );
                debugPrint('DEBUG: Mailto URI fallback: $mailtoUri');
                result = await launchUrl(mailtoUri);
              }
            } catch (e) {
              debugPrint(
                  'ERROR: Custom scheme failed, trying mailto fallback: $e');
              try {
                final mailtoUri = Uri(
                  scheme: 'mailto',
                  path: emailContent.to?.join(',') ?? '',
                  queryParameters: {
                    'subject': emailContent.subject ?? '',
                    'body': emailContent.body ?? '',
                    if (emailContent.cc?.isNotEmpty ?? false)
                      'cc': emailContent.cc!.join(','),
                    if (emailContent.bcc?.isNotEmpty ?? false)
                      'bcc': emailContent.bcc!.join(','),
                  },
                );
                debugPrint(
                    'DEBUG: Mailto URI fallback (exception): $mailtoUri');
                result = await launchUrl(mailtoUri);
              } catch (e2) {
                debugPrint('ERROR: Mailto fallback also failed: $e2');
              }
            }
          }
        }
        return OpenMailAppResult(didOpen: result);
      } else {
        return OpenMailAppResult(didOpen: false, options: installedApps);
      }
    } else {
      throw UnsupportedError('Platform currently not supported.');
    }
  }

  /// Allows you to compose a new email in the specified [mailApp] witht the
  /// contents from [emailContent]
  ///
  /// [MailApp] (required) the maill app you wish to launch. Get it by calling [getMailApps]
  /// [EmailContent] provides content for the email you're composing
  /// throws an [Exception] if you're launching from an unsupported platform.
  static Future<bool> composeNewEmailInSpecificMailApp({
    required MailApp mailApp,
    required EmailContent emailContent,
  }) async {
    // Debug debugPrints removed for production

    if (_isAndroid) {
      final result = await _channel.invokeMethod<bool>(
            'composeNewEmailInSpecificMailApp',
            <String, dynamic>{
              'name': mailApp.name,
              'emailContent': jsonEncode(emailContent.toJson()),
            },
          ) ??
          false;
      // Debug debugPrint removed
      return result;
    } else if (_isIOS) {
      // Always use mailto: for Apple Mail
      if (mailApp.name == 'Apple Mail') {
        try {
          final qp = <String, String>{
            'subject': emailContent.subject ?? '',
            'body': emailContent.body ?? '',
            if (emailContent.cc?.isNotEmpty ?? false)
              'cc': emailContent.cc!.join(','),
            if (emailContent.bcc?.isNotEmpty ?? false)
              'bcc': emailContent.bcc!.join(','),
          };
          // Attachments (Apple Mail only, mailto:)
          if (emailContent.attachments != null &&
              emailContent.attachments!.isNotEmpty) {
            // Apple Mail supports 'attachment' param (file:// URLs)
            for (var i = 0; i < emailContent.attachments!.length; i++) {
              qp['attachment${i > 0 ? i + 1 : ''}'] =
                  emailContent.attachments![i];
            }
          }
          final mailtoUri = Uri(
            scheme: 'mailto',
            path: emailContent.to?.join(',') ?? '',
            queryParameters: qp,
          );
          return await launchUrl(mailtoUri);
        } catch (e) {
          return false;
        }
      }
      // Otherwise, try custom scheme, fallback to mailto if needed
      String? launchScheme = mailApp.composeLaunchScheme(emailContent);
      // Debug debugPrint removed
      if (launchScheme != null) {
        try {
          final uri = Uri.parse(launchScheme);
          final canLaunch = await canLaunchUrl(uri);
          // Debug debugPrint removed
          if (canLaunch) {
            // Special handling for Gmail
            if (mailApp.name == 'Gmail') {
              // Debug debugPrint removed
              final recipient = emailContent.to?.join(',') ?? '';
              final subject = Uri.encodeComponent(emailContent.subject ?? '');
              final body = Uri.encodeComponent(emailContent.body ?? '');
              final gmailUrl =
                  'googlegmail://co?to=$recipient&subject=$subject&body=$body';
              // Debug debugPrint removed
              try {
                return await launchUrl(
                  Uri.parse(gmailUrl),
                );
              } catch (e) {
                // Debug debugPrint removed
              }
            }
            // Standard launch for other apps
            final result = await launchUrl(
              uri,
            );
            // Debug debugPrint removed
            return result;
          } else {
            // Debug debugPrint removed
            final mailtoUri = Uri(
              scheme: 'mailto',
              path: emailContent.to?.join(',') ?? '',
              queryParameters: {
                'subject': emailContent.subject ?? '',
                'body': emailContent.body ?? '',
                if (emailContent.cc?.isNotEmpty ?? false)
                  'cc': emailContent.cc!.join(','),
                if (emailContent.bcc?.isNotEmpty ?? false)
                  'bcc': emailContent.bcc!.join(','),
              },
            );
            // Debug debugPrint removed
            return await launchUrl(mailtoUri);
          }
        } catch (e) {
          // Debug debugPrint removed
          try {
            final mailtoUri = Uri(
              scheme: 'mailto',
              path: emailContent.to?.join(',') ?? '',
              queryParameters: {
                'subject': emailContent.subject ?? '',
                'body': emailContent.body ?? '',
                if (emailContent.cc?.isNotEmpty ?? false)
                  'cc': emailContent.cc!.join(','),
                if (emailContent.bcc?.isNotEmpty ?? false)
                  'bcc': emailContent.bcc!.join(','),
              },
            );
            // Debug debugPrint removed
            return await launchUrl(mailtoUri);
          } catch (e2) {
            // Debug debugPrint removed
            return false;
          }
        }
      }
      return false;
    } else {
      throw UnsupportedError('Platform currently not supported');
    }
  }

  /// Returns a list of mail apps that can be used to open email.
  static Future<List<MailApp>> getMailApps() async {
    if (_isAndroid) {
      // Use static getter
      return await _getAndroidMailApps();
    } else if (_isIOS) {
      // Use static getter
      final List<MailApp> apps = [];
      for (final app in _supportedMailApps) {
        // Use _supportedMailApps
        if (app.iosLaunchScheme != null &&
            await canLaunchUrl(Uri.parse(app.iosLaunchScheme!))) {
          // Assert non-null after check
          apps.add(app);
        }
      }
      return apps;
    }
    return [];
  }

  static Future<List<MailApp>> _getAndroidMailApps() async {
    var appsJson = await _channel.invokeMethod<String>('getMainApps');
    var apps = <MailApp>[];

    if (appsJson != null) {
      try {
        final List<dynamic> parsedList = jsonDecode(appsJson);

        apps = parsedList
            .map((item) => MailApp(
                  name: item['name'] ?? '',
                  nativeId: item['nativeId'],
                ))
            .where((app) => !_filterList.contains(app.name.toLowerCase()))
            .toList();
      } catch (e) {
        debugPrint('Error parsing mail apps: $e');
      }
    }

    return apps;
  }

  static Future<List<MailApp>> _getIosMailApps() async {
    var installedApps = <MailApp>[];
    for (var app in _supportedMailApps) {
      // Ensure iosLaunchScheme is not null before parsing
      final launchScheme = app.iosLaunchScheme;
      if (launchScheme != null &&
          await canLaunchUrl(Uri.parse(launchScheme)) &&
          !_filterList.contains(app.name.toLowerCase())) {
        installedApps.add(app);
      }
    }
    return installedApps;
  }

  /// Clears existing filter list and sets the filter list to the passed values.
  /// Filter list is case insensitive. Listed apps will be excluded from the results
  /// of `getMailApps` by name.
  ///
  /// Default filter list includes PayPal, since it implements the mailto: intent-filter
  /// on Android, but the intention of this plugin is to provide
  /// a utility for finding and opening apps dedicated to sending/receiving email.
  static void setFilterList(List<String> filterList) {
    _filterList = filterList.map((e) => e.toLowerCase()).toList();
  }
}
