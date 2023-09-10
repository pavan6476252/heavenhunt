// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String uid; // Unique user ID
  final String name;
  final String profilePictureUrl;
  final String email;
  final String phoneNumber;
  final String gender;
  final String college;
  final List<String> favorites;
  final List<String> preferences;
  final String fcmToken; // Firebase Cloud Messaging token
  final List<double> coordinates; // Geo coordinates [latitude, longitude]

  UserProfile(
      {required this.uid,
      required this.name,
      required this.profilePictureUrl,
      required this.email,
      required this.phoneNumber,
      required this.gender,
      required this.college,
      required this.favorites,
      required this.preferences,
      required this.fcmToken,
      required this.coordinates});

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'profilePictureUrl': profilePictureUrl,
      'email': email,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'coordinates': coordinates,
      'favorites': favorites,
      'preferences': preferences,
      'fcmToken': fcmToken,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      college: map['college'] as String? ?? '',
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      profilePictureUrl: map['profilePictureUrl'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      gender: map['gender'] as String? ?? '',
      coordinates: (map['coordinates'] as List<dynamic>?)
              ?.map((dynamic val) => val is num ? val.toDouble() : 0.0)
              .toList() ??
          [],
      favorites: (map['favorites'] as List<dynamic>?)
              ?.map((dynamic val) => val.toString())
              .toList() ??
          [],
      preferences: (map['preferences'] as List<dynamic>?)
              ?.map((dynamic val) => val.toString())
              .toList() ??
          [],
      fcmToken: map['fcmToken'] as String? ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(json.decode(source) as Map<String, dynamic>);

  static Future<void> storeUserData(UserProfile user) async {
    final prefs = await SharedPreferences.getInstance();
    final userDataJson = user.toJson();
    await prefs.setString('user_data', userDataJson);
  }

  static Future<UserProfile?> retrieveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataJson = await prefs.getString('user_data');

    if (userDataJson != null) {
      return UserProfile.fromJson(userDataJson);
    }
    return null;
  }

  static Future<void> deleteUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  static Future<bool> checkUserAuth() async {
    UserProfile? userProfile = await retrieveUserData();

    if (userProfile == null) {
      final User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (userSnapshot.exists) {
         
          UserProfile userProfile =
              UserProfile.fromMap(userSnapshot.data() as Map<String, dynamic>);

          await UserProfile.storeUserData(userProfile);
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  static Future<void> storeNewUserData(UserProfile userProfile) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userProfile.uid)
        .set(userProfile.toMap());

    await UserProfile.storeUserData(userProfile);
  }

  static Future<void> refetchUserData(String uid) async {
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userSnapshot.exists) {
      UserProfile userProfile =
          UserProfile.fromMap(userSnapshot.data() as Map<String, dynamic>);

      await UserProfile.storeUserData(userProfile);
    }
  }

  static Future<void> logout() async {
    await UserProfile.deleteUserData();
    await FirebaseAuth.instance.signOut();
  }

  UserProfile copyWith({
    String? uid,
    String? name,
    String? email,
    String? profilePictureUrl,
    String? phoneNumber,
    String? gender,
    String? college,
    List<String>? favorites,
    List<String>? preferences,
    String? fcmToken,
    List<double>? coordinates,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      college: college ?? this.college,
      favorites: favorites ?? this.favorites,
      preferences: preferences ?? this.preferences,
      fcmToken: fcmToken ?? this.fcmToken,
      coordinates: coordinates ?? this.coordinates,
    );
  }
}
