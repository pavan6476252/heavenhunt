import 'package:flutter/material.dart';
import 'package:heavenhunt/screens/utils.dart';
import 'package:heavenhunt/services/firebase_services.dart';
import 'package:heavenhunt/utils/Loading.dart';

import '../../models/other_service.dart';

class OtherServiceFilterScreen extends StatefulWidget {
  OtherServiceFilterScreen({required this.locationController, super.key});
  TextEditingController locationController;
  @override
  _OtherServiceFilterScreenState createState() =>
      _OtherServiceFilterScreenState();
}

class _OtherServiceFilterScreenState extends State<OtherServiceFilterScreen> {
  // Define filter options and selected filters
  String? selectedType;
  String? selectedLocation;
  double? minRating;

  // List of possible service types (you can populate this list as needed)
  List<String> serviceTypes = [
    'Restaurant',
    'Grocery Store',
    'Laundry',
    'Cafeteria',
    'Stationery Shop',
    'Tuition Center',
    'Bookstore',
    'Printing Service',
    'Bike Rental',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filter by Service Type:'),
          DropdownButton<String>(
            value: selectedType,
            onChanged: (newValue) {
              setState(() {
                selectedType = newValue;
              });
            },
            items: serviceTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
          ),
          SizedBox(height: 16.0),
          Text('Filter by Location:'),
          TextField(
            controller: TextEditingController(text: selectedLocation),
            onChanged: (value) {
              selectedLocation = value;
            },
          ),
          SizedBox(height: 16.0),
          Text('Filter by Minimum Rating:'),
          Slider(
            value: minRating ?? 0,
            onChanged: (value) {
              setState(() {
                minRating = value;
              });
            },
            min: 0,
            max: 5,
            divisions: 5,
            label: minRating?.toStringAsFixed(1) ?? '0.0',
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              fetchFilteredServices();
            },
            child: Text('Apply Filters'),
          ),
        ],
      ),
    );
  }

  // Implement this function to fetch filtered services
  void fetchFilteredServices() async {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchPostsViewScr(
              type: selectedType,
              location: selectedLocation,
              minRating: minRating),
        ));
  }
}

class SearchPostsViewScr extends StatefulWidget {
  SearchPostsViewScr(
      {super.key,
      required this.type,
      required this.location,
      required this.minRating});
  String? type;
  String? location;
  double? minRating;

  @override
  State<SearchPostsViewScr> createState() => _SearchPostsViewScrState();
}

class _SearchPostsViewScrState extends State<SearchPostsViewScr> {
  bool isLoading = true;
  List<OtherService> data = [];
  @override
  void initState() {
    // TODO: implement initState
    fetch();
    super.initState();
  }

  fetch() async {
    try {
      data = await FirebaseServices.searchOtherServices(
          type: widget.type,
          location: widget.location,
          minRating: widget.minRating);
      print(data);
    } catch (e) {
      print(e);
      Utils.showSnackbar(
          context: context, text: "Failed to fetch search posts");
    }
    isLoading = false;
    setState(() {});
  }

  Widget build(BuildContext context) {
    return isLoading
        ? const LoadingAnimation()
        : Scaffold(
            appBar: AppBar(
              title: const Text("Post Search Results"),
            ),
            body: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // You can change this value as needed
              ),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return OtherServicesCard(
                  otherService: item,
                );
              },
            ));
  }
}

class OtherServicesCard extends StatelessWidget {
  OtherServicesCard({super.key, required this.otherService});
  OtherService otherService;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          otherService.images.length > 0
              ? Image.network(
                  otherService.images[0],
                  height: 120.0, // Adjust the image height as needed
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : SizedBox.shrink(),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  otherService.type,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.0),
                Text(
                  otherService.description,
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
