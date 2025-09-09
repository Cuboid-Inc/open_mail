import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_mail/open_mail.dart';

void main() {
  const MethodChannel channel = MethodChannel('open_mail');
  final List<MethodCall> log = [];
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
    log.add(methodCall);
    switch (methodCall.method) {
      case 'openMailApp':
        return true; // Simulate success for opening mail apps
      case 'getMailApps':
        return '[{"name": "Gmail", "iosLaunchScheme": "googlegmail://"}]'; // Mock email app list
      case 'composeNewEmailInMailApp':
        if (methodCall.arguments['emailContent'] != null) {
          return true; // Simulate success for composing email
        }
        return false; // Simulate failure if no email content provided
      default:
        return null;
    }
  });

  setUp(() {
    log.clear();
  });

  group('OpenMail', () {
    test('openMailApp successfully opens mail app', () async {
      final result = await OpenMail.openMailApp();
      expect(result.didOpen, isTrue);
      expect(log.last.method, 'openMailApp');
      expect(log.last.arguments, isNull);
    });

    // Removed: picker title behavior no longer applicable

    test('getMailApps retrieves a list of installed mail apps', () async {
      final apps = await OpenMail.getMailApps();
      expect(apps.length, 1);
      expect(apps.first.name, 'Gmail');
      expect(apps.first.iosLaunchScheme, 'googlegmail://');
      expect(log.last.method, 'getMailApps');
    });

    test('composeNewEmailInMailApp successfully composes an email', () async {
      final emailContent = EmailContent(
        to: ['test@example.com'],
        subject: 'Test Subject',
        body: 'Test Body',
      );

      final result = await OpenMail.composeNewEmailInMailApp(
        nativePickerTitle: 'Choose Email App',
        emailContent: emailContent,
      );

      expect(result.didOpen, isTrue);
      expect(log.last.method, 'composeNewEmailInMailApp');
      expect(log.last.arguments['emailContent'],
          contains('"to":["test@example.com"]'));
    });

    test('composeNewEmailInMailApp fails without email content', () async {
      final result = await OpenMail.composeNewEmailInMailApp(
        nativePickerTitle: 'Choose Email App',
        emailContent: EmailContent(), // Empty email content
      );

      expect(result.didOpen, isFalse);
      expect(log.last.method, 'composeNewEmailInMailApp');
    });

    test('setFilterList updates the filter list', () async {
      OpenMail.setFilterList(['Gmail', 'Yahoo']);
      final apps = await OpenMail.getMailApps();

      // Mocked Gmail app is filtered out
      expect(apps, isEmpty);
    });

    test('getMailApps filters excluded apps', () async {
      OpenMail.setFilterList(['Gmail']); // Exclude Gmail
      final apps = await OpenMail.getMailApps();

      expect(apps, isEmpty); // Gmail should be filtered out
    });
  });
}
