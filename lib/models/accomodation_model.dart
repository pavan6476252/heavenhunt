import 'dart:convert'; 
class AccommodationListing {
  final String listingId; // Unique listing ID
  final String type; // Room, Hostel, Apartment, House, etc.
  final String location;
  final double rent;
  final double floor;
  final double longitude;
  final double latitude;
  final String occupancy;
  final int requirement;
  final String lookingFor;
  final List<String> images;
  final List<String> facilities;
  final double advancePaymentAmount;
  final String contactNumber;
  final DateTime postedDate;
  final String ownerId; // Owner's user ID
  final String postId; // Owner's user ID
  final String description; // Available, Filled, etc.

  AccommodationListing({
    required this.listingId,
    required this.type,
    required this.location,
    required this.longitude,
    required this.latitude,
    required this.rent,
    required this.floor,
    required this.occupancy,
    required this.requirement,
    required this.lookingFor,
    required this.images,
    required this.facilities,
    required this.advancePaymentAmount,
    required this.contactNumber,
    required this.postedDate,
    required this.ownerId,
    required this.postId,
    required this.description,
  });

  AccommodationListing copyWith({
    String? listingId,
    String? type,
    String? location,
    double? longitude,
    double? latitude,
    double? rent,
    double? floor,
    String? occupancy,
    int? requirement,
    String? lookingFor,
    List<String>? images,
    List<String>? facilities,
    double? advancePaymentAmount,
    String? contactNumber,
    DateTime? postedDate,
    String? ownerId,
    String? postId,
    String? description,
    
    //  required FieldValue timestamp,
  }) {
    return AccommodationListing(
      listingId: listingId ?? this.listingId,
      type: type ?? this.type,
      location: location ?? this.location,
      rent: rent ?? this.rent,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      floor: floor ?? this.floor,
      occupancy: occupancy ?? this.occupancy,
      lookingFor: lookingFor ?? this.lookingFor,
      requirement: requirement ?? this.requirement,
      images: images ?? this.images,
      facilities: facilities ?? this.facilities,
      advancePaymentAmount: advancePaymentAmount ?? this.advancePaymentAmount,
      contactNumber: contactNumber ?? this.contactNumber,
      postedDate: postedDate ?? this.postedDate,
      ownerId: ownerId ?? this.ownerId,
      postId: postId ?? this.postId,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'listingId': listingId,
      'type': type,
      'location': location,
      'rent': rent,
      'longitude': longitude,
      'latitude': latitude,
      'floor': floor,
      'occupancy': occupancy,
      'requirement': requirement,
      'lookingFor': lookingFor,
      'images': images,
      'facilities': facilities,
      'advancePaymentAmount': advancePaymentAmount,
      'contactNumber': contactNumber,
      'postedDate': postedDate.millisecondsSinceEpoch,
      'ownerId': ownerId,
      'postId': postId,
      'description': description,
    };
  }

  factory AccommodationListing.fromMap(Map<String, dynamic> map) {
    return AccommodationListing(
      listingId: map['listingId'] as String,
      type: map['type'] as String,
      location: map['location'] as String,
      requirement: map['requirement'] as int,
      rent: map['rent'] as double,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      floor: map['floor'] as double,
      occupancy: map['occupancy'] as String,
      lookingFor: map['lookingFor'] as String,
      images: List<String>.from(map['images'] as List<dynamic>),
      facilities: List<String>.from(map['facilities'] as List<dynamic>),
      advancePaymentAmount: map['advancePaymentAmount'] as double,
      contactNumber: map['contactNumber'] as String,
      postedDate: DateTime.fromMillisecondsSinceEpoch(map['postedDate'] as int),
      ownerId: map['ownerId'] as String,
      postId: map['postId'] as String,
      description: map['description'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory AccommodationListing.fromJson(String source) =>
      AccommodationListing.fromMap(json.decode(source) as Map<String, dynamic>);
}
