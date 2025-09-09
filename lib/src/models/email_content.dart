/// Describes the content of an email to be composed.
///
/// All fields are optional.
class EmailContent {
  /// The recipient(s) of the email.
  final List<String>? to;

  /// The CC recipient(s) of the email.
  final List<String>? cc;

  /// The BCC recipient(s) of the email.
  final List<String>? bcc;

  /// The subject of the email.
  final String? subject;

  /// The body of the email.
  final String? body;

  /// List of file paths to attach (only supported by some mail apps, e.g. Apple Mail via mailto: on iOS/macOS)
  final List<String>? attachments;

  EmailContent({
    this.to,
    this.subject,
    this.body,
    this.cc,
    this.bcc,
    this.attachments,
  });

  Map<String, dynamic> toJson() {
    return {
      'to': to,
      'subject': subject,
      'body': body,
      'cc': cc,
      'bcc': bcc,
      'attachments': attachments,
    }..removeWhere((key, value) => value == null);
  }

  factory EmailContent.fromJson(Map<String, dynamic> json) {
    return EmailContent(
      to: json['to'] != null ? List<String>.from(json['to'] as List) : null,
      subject: json['subject'] as String?,
      body: json['body'] as String?,
      cc: json['cc'] != null ? List<String>.from(json['cc'] as List) : null,
      bcc: json['bcc'] != null ? List<String>.from(json['bcc'] as List) : null,
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'] as List)
          : null,
    );
  }
}
