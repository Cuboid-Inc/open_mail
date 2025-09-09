import 'compose_data.dart';
import 'email_content.dart';

class MailApp {
  /// The display name of the mail app.
  final String name;

  /// The underlying unique identifier of the mail app
  /// This is package name on Android and url scheme on iOS
  final String? nativeId;

  /// The iOS URL scheme for opening the app.
  final String? iosLaunchScheme;

  /// Data for composing an email in the app.
  final ComposeData? composeData;

  MailApp(
      {required this.name,
      this.nativeId,
      this.iosLaunchScheme,
      this.composeData});

  factory MailApp.fromJson(Map<String, dynamic> json) {
    return MailApp(
      name: json['name'] as String? ?? '', // Ensure name is not null
      nativeId: json['nativeId'] as String?,
      iosLaunchScheme: json['iosLaunchScheme'] as String?,
      composeData: json['composeData'] != null
          ? ComposeData.fromJson(json['composeData'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'nativeId': nativeId,
        'iosLaunchScheme': iosLaunchScheme,
        'composeData': composeData?.toJson(),
      }..removeWhere((key, value) => value == null);

  String? composeLaunchScheme(EmailContent? content) {
    if (composeData == null || content == null) {
      return null;
    }

    // Special case for Gmail
    if (name == 'Gmail') {
      // Gmail on iOS has specific format requirements
      final recipient = content.to?.join(',') ?? '';
      final subject = Uri.encodeComponent(content.subject ?? '');
      final body = Uri.encodeComponent(content.body ?? '');
      return 'googlegmail://co?to=$recipient&subject=$subject&body=$body';
    }

    // Standard implementation for other apps
    var scheme = composeData!.scheme;
    final qsSeparator = composeData!.queryStringSeparator ?? '?';
    final qsPairSeparator = composeData!.queryStringPairSeparator ?? '&';

    // Track if we've added any parameters yet
    bool firstParam = true;

    if (content.to?.isNotEmpty == true) {
      scheme +=
          '$qsSeparator${composeData!.toParameter}=${content.to!.join(',')}';
      firstParam = false;
    }
    if (content.cc?.isNotEmpty == true) {
      scheme +=
          '${firstParam ? qsSeparator : qsPairSeparator}${composeData!.ccParameter}=${content.cc!.join(',')}';
      firstParam = false;
    }
    if (content.bcc?.isNotEmpty == true) {
      scheme +=
          '${firstParam ? qsSeparator : qsPairSeparator}${composeData!.bccParameter}=${content.bcc!.join(',')}';
      firstParam = false;
    }
    if (content.subject?.isNotEmpty == true) {
      scheme +=
          '${firstParam ? qsSeparator : qsPairSeparator}${composeData!.subjectParameter}=${Uri.encodeComponent(content.subject!)}';
      firstParam = false;
    }
    if (content.body?.isNotEmpty == true) {
      scheme +=
          '${firstParam ? qsSeparator : qsPairSeparator}${composeData!.bodyParameter}=${Uri.encodeComponent(content.body!)}';
    }

    return scheme;
  }
}
