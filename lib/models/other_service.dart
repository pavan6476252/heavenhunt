import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class OtherService {
  final String serviceId; // Unique service ID
  final String userId; // Unique service ID
  final String name;
  final String type; // Restaurant, Grocery Store, Laundry, etc.
  final String location;
  final double latitude;
  final double longitude;
  final String contactNumber;

  final double rating;
  final List<Review> reviews;
  final List<String> images;
  final String description;

  OtherService({
    required this.serviceId,
    required this.userId,
    required this.name,
    required this.type,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.contactNumber,
    required this.rating,
    required this.reviews,
    required this.images,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'userId': userId,
      'name': name,
      'type': type,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'contactNumber': contactNumber,
      'rating': rating,
      'images': images,
      'description': description,
      'reviews': reviews.map((review) => review.toJson()).toList(),
    };
  }

  OtherService copyWith({
    String? serviceId,
    String? userId,
    String? name,
    String? description,
    String? type,
    String? location,
    String? contactNumber,
    double? rating,
    double? longitude,
    double? latitude,
    List<Review>? reviews,
    List<String>? images,
  }) {
    return OtherService(
      serviceId: serviceId ?? this.serviceId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      location: location ?? this.location,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      contactNumber: contactNumber ?? this.contactNumber,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      images: images ?? this.images,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'serviceId': serviceId,
      'userId': userId,
      'name': name,
      'type': type,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'contactNumber': contactNumber,
      'rating': rating,
      'reviews': reviews.map((x) => x.toMap()).toList(),
      'images': images,
      'description': description,
    };
  }

  factory OtherService.fromJson(String source) =>
      OtherService.fromMap(json.decode(source) as Map<String, dynamic>);

factory OtherService.fromMap(Map<String, dynamic> map) {
  return OtherService(
    serviceId: map['serviceId'] as String,
    userId: map['userId'] as String,
    name: map['name'] as String,
    type: map['type'] as String,
    location: map['location'] as String,
    latitude: map['latitude'] as double,
    longitude: map['longitude'] as double,
    contactNumber: map['contactNumber'] as String,
    rating: map['rating'] as double, // Ensure 'rating' is a double in your Firestore document
    reviews: List<Review>.from(
      (map['reviews'] as List<dynamic>).map<Review>((x) => Review.fromMap(x as Map<String, dynamic>)),
    ),
    images: List<String>.from(map['images'] as List<dynamic>), // Ensure 'images' is a List<String> in your Firestore document
    description: map['description'] as String,
  );
}

  @override
  String toString() {
    return 'OtherService(serviceId: $serviceId, userId: $userId, name: $name, type: $type, location: $location, latitude: $latitude, longitude: $longitude, contactNumber: $contactNumber, rating: $rating, reviews: $reviews, images: $images, description: $description)';
  }
}

class Review {
  final String userId; // User who left the review
  final String comment;
  final double rating;
  final DateTime timestamp;

  Review({
    required this.userId,
    required this.comment,
    required this.rating,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'comment': comment,
      'rating': rating,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  Review copyWith({
    String? userId,
    String? comment,
    double? rating,
    DateTime? timestamp,
  }) {
    return Review(
      userId: userId ?? this.userId,
      comment: comment ?? this.comment,
      rating: rating ?? this.rating,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'comment': comment,
      'rating': rating,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      userId: map['userId'] as String,
      comment: map['comment'] as String,
      rating: map['rating'] as double,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }

  factory Review.fromJson(String source) =>
      Review.fromMap(json.decode(source) as Map<String, dynamic>);
}
