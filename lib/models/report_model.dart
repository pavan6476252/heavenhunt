// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Report {
  final String reportId; // Unique report ID
  final String reporterUserId; // User ID of the reporter
  final String reportedUserId; // User ID of the reported user
  final String postId; // ID of the reported post
  final String reason;
  final String description;
  final DateTime timestamp;

  Report({
    required this.reportId,
    required this.reporterUserId,
    required this.reportedUserId,
    required this.postId,
    required this.reason,
    required this.description,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'reportId': reportId,
      'reporterUserId': reporterUserId,
      'reportedUserId': reportedUserId,
      'postId': postId,
      'reason': reason,
      'description': description,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      reportId: map['reportId'] as String,
      reporterUserId: map['reporterUserId'] as String,
      reportedUserId: map['reportedUserId'] as String,
      postId: map['postId'] as String,
      reason: map['reason'] as String,
      description: map['description'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory Report.fromJson(String source) => Report.fromMap(json.decode(source) as Map<String, dynamic>);
}
