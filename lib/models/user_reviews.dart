// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserReview {
  final String reviewId; // Unique review ID
  final String reviewedUserId; // User or listing being reviewed
  final String reviewerUserId; // User who left the review
  final String type; // Accommodation, Service, Roommate, etc.
  final double rating;
  final String comment;
  final DateTime timestamp;

  UserReview({
    required this.reviewId,
    required this.reviewedUserId,
    required this.reviewerUserId,
    required this.type,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'reviewId': reviewId,
      'reviewedUserId': reviewedUserId,
      'reviewerUserId': reviewerUserId,
      'type': type,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory UserReview.fromMap(Map<String, dynamic> map) {
    return UserReview(
      reviewId: map['reviewId'] as String,
      reviewedUserId: map['reviewedUserId'] as String,
      reviewerUserId: map['reviewerUserId'] as String,
      type: map['type'] as String,
      rating: map['rating'] as double,
      comment: map['comment'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserReview.fromJson(String source) => UserReview.fromMap(json.decode(source) as Map<String, dynamic>);
}
