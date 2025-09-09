/// Data for composing an email in a specific app.
class ComposeData {
  final String scheme;
  final String? queryStringSeparator;
  final String? queryStringPairSeparator;
  final String toParameter;
  final String ccParameter;
  final String bccParameter;
  final String subjectParameter;
  final String bodyParameter;

  ComposeData({
    required this.scheme,
    this.queryStringSeparator,
    this.queryStringPairSeparator,
    this.toParameter = 'to',
    this.ccParameter = 'cc',
    this.bccParameter = 'bcc',
    this.subjectParameter = 'subject',
    this.bodyParameter = 'body',
  });

  factory ComposeData.fromJson(Map<String, dynamic> json) {
    return ComposeData(
      scheme: json['scheme'] as String,
      queryStringSeparator: json['queryStringSeparator'] as String?,
      queryStringPairSeparator: json['queryStringPairSeparator'] as String?,
      toParameter: json['toParameter'] as String? ?? 'to',
      ccParameter: json['ccParameter'] as String? ?? 'cc',
      bccParameter: json['bccParameter'] as String? ?? 'bcc',
      subjectParameter: json['subjectParameter'] as String? ?? 'subject',
      bodyParameter: json['bodyParameter'] as String? ?? 'body',
    );
  }

  Map<String, dynamic> toJson() => {
        'scheme': scheme,
        'queryStringSeparator': queryStringSeparator,
        'queryStringPairSeparator': queryStringPairSeparator,
        'toParameter': toParameter,
        'ccParameter': ccParameter,
        'bccParameter': bccParameter,
        'subjectParameter': subjectParameter,
        'bodyParameter': bodyParameter,
      }..removeWhere((key, value) => value == null);
}
