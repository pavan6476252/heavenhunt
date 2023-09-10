// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class RoommateProfile {
  final String profileId; // Unique profile ID
  final String userId; // User's ID
  final String genderPreference;
  final double budgetRange;
  final String description;

  RoommateProfile({
    required this.profileId,
    required this.userId,
    required this.genderPreference,
    required this.budgetRange,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'profileId': profileId,
      'userId': userId,
      'genderPreference': genderPreference,
      'budgetRange': budgetRange,
      'description': description,
    };
  }

  factory RoommateProfile.fromMap(Map<String, dynamic> map) {
    return RoommateProfile(
      profileId: map['profileId'] as String,
      userId: map['userId'] as String,
      genderPreference: map['genderPreference'] as String,
      budgetRange: map['budgetRange'] as double,
      description: map['description'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory RoommateProfile.fromJson(String source) => RoommateProfile.fromMap(json.decode(source) as Map<String, dynamic>);
}
