import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:heavenhunt/models/accomodation_model.dart';
import 'package:heavenhunt/models/other_service.dart';

class FirebaseServices {
  static Future<bool> uploadPost(
      {required List<File> images,
      required AccommodationListing postModel}) async {
    try {
      //uploading images
      List<String> imageUrls = [];
      for (File image in images) {
        final Reference storageReference = FirebaseStorage.instance.ref().child(
            'posts/${postModel.ownerId}/${DateTime.now().millisecondsSinceEpoch}');
        final UploadTask uploadTask = storageReference.putFile(image);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
        if (taskSnapshot.state == TaskState.success) {
          final downloadURL = await taskSnapshot.ref.getDownloadURL();
          imageUrls.add(downloadURL);
        }
      }
      postModel = postModel.copyWith(
        images: imageUrls,
      );

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postModel.postId)
          .set(postModel.toMap());
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> uploadOtherServices(
      {required List<File> images, required OtherService postModel}) async {
    try {
      //uploading images
      List<String> imageUrls = [];
      for (File image in images) {
        final Reference storageReference = FirebaseStorage.instance.ref().child(
            'otherServices/${postModel.serviceId}/${DateTime.now().millisecondsSinceEpoch}');
        final UploadTask uploadTask = storageReference.putFile(image);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
        if (taskSnapshot.state == TaskState.success) {
          final downloadURL = await taskSnapshot.ref.getDownloadURL();
          imageUrls.add(downloadURL);
        }
      }
      postModel = postModel.copyWith(
        images: imageUrls,
      );

      await FirebaseFirestore.instance
          .collection('otherServices')
          .doc(postModel.serviceId)
          .set(postModel.toMap());
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<List<AccommodationListing>> searchPosts({
    String? type,
    String? location,
    double? minRent,
    double? maxRent,
  }) async {
    try {
      // Reference to the "posts" collection
      CollectionReference postsCollection =
          FirebaseFirestore.instance.collection('posts');

      // Query to filter posts based on criteria
      Query query = postsCollection;

      if (type != null || type != '') {
        query = query.where('type', isEqualTo: type);
      }

      if (location != null || location != '') {
        query = query.where('location', isEqualTo: location);
      }

      if (minRent != null || minRent != '') {
        query = query.where('rent', isGreaterThanOrEqualTo: minRent);
      }

      if (maxRent != null || maxRent != '') {
        query = query.where('rent', isLessThanOrEqualTo: maxRent);
      }

      // Execute the query and get the documents
      QuerySnapshot querySnapshot = await query.get();

      // Convert the documents to a list of AccommodationListing objects
      List<AccommodationListing> results = querySnapshot.docs
          .map((doc) =>
              AccommodationListing.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      return results;
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future<List<OtherService>> searchOtherServices({
    String? type,
    String? location,
    double? minRating,
  }) async {
    try {
      // Reference to the "otherServices" collection
      CollectionReference otherServicesCollection =
          FirebaseFirestore.instance.collection('otherServices');

      // Query to filter OtherService based on criteria
      Query query = otherServicesCollection;

      if (type != null && type.isNotEmpty) {
        query = query.where('type', isEqualTo: type);
      }

      if (location != null && location.isNotEmpty) {
        query = query.where('location', isEqualTo: location);
      }

      if (minRating != null) {
        query = query.where('rating', isGreaterThanOrEqualTo: minRating);
      }

      // Execute the query and get the documents
      QuerySnapshot querySnapshot = await query.get();

      // Convert the documents to a list of OtherService objects
      List<OtherService> results = querySnapshot.docs
          .map(
              (doc) => OtherService.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      return results;
    } catch (e, s) {
      print(e);
      print(s);
      return [];
    }
  }

  static Future<List<OtherService>> fetchMostRatedServices() async {
    try {
      CollectionReference otherServicesCollection =
          FirebaseFirestore.instance.collection('otherServices');

      Query query = otherServicesCollection.orderBy('rating', descending: true);

      QuerySnapshot querySnapshot = await query.get();
      List<OtherService> results = querySnapshot.docs
          .map(
              (doc) => OtherService.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      return results;
    } catch (e, s) {
      print(s);
      return [];
    }
  }

 
  static Future<List<AccommodationListing>> fetchNearbyAccommodationListings(
    String location,
  ) async {
    try {
      // Reference to the "posts" collection
      CollectionReference postsCollection =
          FirebaseFirestore.instance.collection('posts');

      // Query to filter nearby AccommodationListings based on location
      Query query = postsCollection.where('location', isEqualTo: location);

      // Execute the query and get the documents
      QuerySnapshot querySnapshot = await query.get();

      // Convert the documents to a list of AccommodationListing objects
      List<AccommodationListing> results = querySnapshot.docs
          .map((doc) =>
              AccommodationListing.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      return results;
    } catch (e, s) {
      print(s);
      return [];
    }
  }

  static Future<List<OtherService>> fetchNearbyOtherServices(
    String location,
  ) async {
    try {
      // Reference to the "otherServices" collection
      CollectionReference otherServicesCollection =
          FirebaseFirestore.instance.collection('otherServices');

      // Query to filter nearby OtherServices based on location
      Query query = otherServicesCollection.where('location', isEqualTo: location);

      // Execute the query and get the documents
      QuerySnapshot querySnapshot = await query.get();

      // Convert the documents to a list of OtherService objects
      List<OtherService> results = querySnapshot.docs
          .map((doc) =>
              OtherService.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      return results;
    } catch (e, s) {
      print(s);
      return [];
    }
  }

  // static Future<List<AccommodationListing>> fetchNearbyAccommodationListings(
  //   double latitude,
  //   double longitude,
  //   double maxDistanceRadius,
  // ) async {
  //   try {
  //     // Reference to the "posts" collection
  //     CollectionReference postsCollection =
  //         FirebaseFirestore.instance.collection('posts');

  //     // Create a GeoPoint representing the user's location
  //     final userLocation = GeoPoint(latitude, longitude);

  //     // Query to filter nearby AccommodationListings
  //     Query query = postsCollection.where(
  //       'location',
  //       isGreaterThan: _calculateBounds(userLocation, maxDistanceRadius)['min'],
  //       isLessThan: _calculateBounds(userLocation, maxDistanceRadius)['max'],
  //     );

  //     // Execute the query and get the documents
  //     QuerySnapshot querySnapshot = await query.get();

  //     // Convert the documents to a list of AccommodationListing objects
  //     List<AccommodationListing> results = querySnapshot.docs
  //         .map((doc) =>
  //             AccommodationListing.fromMap(doc.data() as Map<String, dynamic>))
  //         .toList();

  //     return results;
  //   } catch (e, s) {
  //     print(s);
  //     return [];
  //   }
  // }

  // static Future<List<OtherService>> fetchNearbyOtherServices(
  //   double latitude,
  //   double longitude,
  //   double maxDistanceRadius,
  // ) async {
  //   try {
  //     // Reference to the "otherServices" collection
  //     CollectionReference otherServicesCollection =
  //         FirebaseFirestore.instance.collection('otherServices');

  //     // Create a GeoPoint representing the user's location
  //     final userLocation = GeoPoint(latitude, longitude);

  //     // Query to filter nearby OtherServices
  //     Query query = otherServicesCollection.where(
  //       'location',
  //       isGreaterThan: _calculateBounds(userLocation, maxDistanceRadius)['min'],
  //       isLessThan: _calculateBounds(userLocation, maxDistanceRadius)['max'],
  //     );

  //     // Execute the query and get the documents
  //     QuerySnapshot querySnapshot = await query.get();

  //     // Convert the documents to a list of OtherService objects
  //     List<OtherService> results = querySnapshot.docs
  //         .map((doc) =>
  //             OtherService.fromMap(doc.data() as Map<String, dynamic>))
  //         .toList();

  //     return results;
  //   } catch (e, s) {
  //     print(s);
  //     return [];
  //   }
  // }

 
  // static Map<String, GeoPoint> _calculateBounds(
  //     GeoPoint center, double radiusInKm) {
  //   // Earth's radius in kilometers
  //   const double earthRadius = 6371.0;

  //   // Angular distance in radians
  //   final double radiusInRadians = radiusInKm / earthRadius;

  //   // Latitude and longitude bounds
  //   final double minLat =
  //       center.latitude - (radiusInRadians * 180.0 / pi);
  //   final double maxLat =
  //       center.latitude + (radiusInRadians * 180.0 / pi);
  //   final double minLng =
  //       center.longitude - (radiusInRadians * 180.0 / pi);
  //   final double maxLng =
  //       center.longitude + (radiusInRadians * 180.0 / pi);

  //   return {
  //     'min': GeoPoint(minLat, minLng),
  //     'max': GeoPoint(maxLat, maxLng),
  //   };
  // }
}
