import 'dart:convert';

class APIResult {
  int status;
  String message;
  List<dynamic> result;

  APIResult({
    required this.status,
    required this.message,
    required this.result
  });

  factory APIResult.fromJson(Map<String, dynamic> json) {
    return APIResult(
      status: json['status'],
      message: json['message'],
      result: json['result'],
    );
  }

  static APIResult apiresultFromJson(String input) {
    final jsonData = json.decode(input);
    return APIResult.fromJson(jsonData);
  }
}