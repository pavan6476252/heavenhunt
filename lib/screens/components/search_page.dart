// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:heavenhunt/models/accomodation_model.dart';
import 'package:heavenhunt/screens/components/accommodation_result_screen.dart';
import 'package:heavenhunt/screens/components/other_services_src.dart';
import 'package:heavenhunt/screens/utils.dart';
import 'package:heavenhunt/services/firebase_services.dart';
import 'package:heavenhunt/utils/Loading.dart';

class FilterCriteria {
  String? type;
  String? location;
  double? minRent;
  double? maxRent;
  double? minRating;
}

class FilterScreen extends StatefulWidget {
  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final FilterCriteria filterCriteria = FilterCriteria();
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentLocation();
  }

  Position? _currentPosition;
  String? _currentCity;
  final TextEditingController locationController =
      TextEditingController(text: "Unkown");

  Future<void> _getCurrentLocation() async {
    try {
      await Geolocator.requestPermission();

      LocationPermission geolocationStatus =
          await Geolocator.requestPermission();
      if (geolocationStatus == LocationPermission.denied) {
        Utils.showSnackbar(context: context, text: "Denied");
        Navigator.pop(context);
      }

      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude, _currentPosition!.longitude);

      Placemark place = placemarks[0];
      _currentCity = place.locality;
      locationController.text = _currentCity ?? "Unkown";
      setState(() {});
    } catch (e) {
      print(e);
      Utils.showSnackbar(context: context, text: "error", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Filter Screen'),
        ),
        body: Column(
          children: [
            PostFilterScreen(locationController: locationController),
            const Divider(),
            Text("Service Searching"),
            OtherServiceFilterScreen(locationController: locationController)
          ],
        ));
  }
}

class PostFilterScreen extends StatefulWidget {
  PostFilterScreen({required this.locationController, super.key});
  TextEditingController locationController;
  @override
  State<PostFilterScreen> createState() => _PostFilterScreenState();
}

class _PostFilterScreenState extends State<PostFilterScreen> {
  // Define filter options and selected filters
  String? selectedType;
  String? selectedLocation;
  RangeValues rentRange = const RangeValues(0, 10000); // Initial rent range

  // List of possible filter options
  List<String> types = [
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
          const Text('Filter by Type:'),
          DropdownButton<String>(
            value: selectedType,
            onChanged: (newValue) {
              setState(() {
                selectedType = newValue;
              });
            },
            items: types.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
          ),
          const SizedBox(height: 16.0),
          const Text('Filter by Location:'),
          TextField(
            controller: widget.locationController,
          ),
          const SizedBox(height: 16.0),
          const Text('Filter by Rent Range:'),
          RangeSlider(
            values: rentRange,
            min: 0,
            max: 10000,
            onChanged: (values) {
              setState(() {
                rentRange = values;
              });
            },
            divisions: 100, // Customize as needed
            labels: RangeLabels(
              rentRange.start.toString(),
              rentRange.end.toString(),
            ),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () async {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchPostsViewScr(
                        type: selectedType,
                        location: widget.locationController.text,
                        maxRent: rentRange.end,
                        minRent: rentRange.start),
                  ));
            },
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }
}

class SearchPostsViewScr extends StatefulWidget {
  SearchPostsViewScr(
      {super.key,
      required this.type,
      required this.location,
      required this.maxRent,
      required this.minRent});
  String? type;
  String location;
  double maxRent;
  double minRent;

  @override
  State<SearchPostsViewScr> createState() => _SearchPostsViewScrState();
}

class _SearchPostsViewScrState extends State<SearchPostsViewScr> {
  bool isLoading = true;
  List<AccommodationListing> data = [];
  @override
  void initState() {
    // TODO: implement initState
    fetch();
    super.initState();
  }

  fetch() async {
    try {
      data = await FirebaseServices.searchPosts(
          type: widget.type,
          location: widget.location,
          maxRent: widget.maxRent,
          minRent: widget.minRent);
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
                return AccommodationCard(
                  accommodationListing: item,
                );
              },
            ));
  }
}


