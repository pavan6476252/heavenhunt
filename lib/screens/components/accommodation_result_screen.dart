import 'package:flutter/material.dart';
import 'package:heavenhunt/models/accomodation_model.dart';

class AccommodationCard extends StatelessWidget {
  final AccommodationListing accommodationListing;

  AccommodationCard({
    required this.accommodationListing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            accommodationListing.images[0],
            height: 120.0, // Adjust the image height as needed
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  accommodationListing.type,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.0),
                Text(
                 accommodationListing. description,
                  style: TextStyle(fontSize: 14.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
