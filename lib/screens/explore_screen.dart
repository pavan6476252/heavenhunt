import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:heavenhunt/screens/sub_screens/accomodation_view.dart';
import 'package:heavenhunt/screens/sub_screens/other_services_view.dart';
import 'package:heavenhunt/screens/utils.dart';
import 'package:rive/rive.dart';
import '../models/accomodation_model.dart';
import '../models/other_service.dart';
import '../services/firebase_services.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController locationController = TextEditingController();

  void initState() {
    super.initState();

    _getCurrentLocation();
  }

  late Position _currentPosition;
  String? _currentCity;

  Future<void> _getCurrentLocation() async {
    await Geolocator.requestPermission();

    LocationPermission geolocationStatus = await Geolocator.requestPermission();
    if (geolocationStatus == LocationPermission.denied) {
      Utils.showSnackbar(context: context, text: "Denied");
      Navigator.pop(context);
    }

    _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition.latitude, _currentPosition.longitude);

    Placemark place = placemarks[0];
    _currentCity = place.locality;
    locationController.text = _currentCity ?? "Unkown";
    fetchData(locationController.text);
    setState(() {});
  }

  showSheet() {
    return showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Add Room Info'),
                  onTap: () {
                    Navigator.pop(context); // Close the bottom sheet
                    Navigator.pushNamed(context, '/add-room');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.food_bank),
                  title: const Text('Add Local Food service info'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/post-food-services');
                  },
                ),
              ],
            ),
          );
        });
  }

  double currentLatitude = 17.7103988;
  double currentLongitude = 83.1661565;
  double maxDistanceRadius = 10.0; // Adjust as needed

  List<AccommodationListing> nearbyAccommodationListings = [];
  List<OtherService> nearbyOtherServices = [];

  bool isLoading = true;
  // Fetch nearby data
  void fetchData(String location) async {
    try {
      nearbyAccommodationListings =
          await FirebaseServices.fetchNearbyAccommodationListings(location);

      nearbyOtherServices =
          await FirebaseServices.fetchNearbyOtherServices(location);
    } catch (e) {
      Utils.showSnackbar(
          context: context, text: "Error while fetching", isError: true);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ElevatedButton.icon(
        onPressed: () {
          showSheet();
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Room"),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nearby Accommodation Listings:'),
                  const SizedBox(height: 8.0),
                  SizedBox(
                      height: 200,
                      width: double.maxFinite,
                      child: buildAccommodationList()),
                  const SizedBox(height: 16.0),
                  const Text('Nearby Other Services:'),
                  const SizedBox(height: 8.0),
                  // buildOtherServicesList(),
                  Expanded(
                    child: YourScreen(
                      nearbyOtherServices: nearbyOtherServices,
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Widget buildAccommodationList() {
    if (nearbyAccommodationListings.isEmpty) {
      return const Text('No nearby accommodation listings found.');
    }

    return GridView.builder(
      scrollDirection: Axis.horizontal,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1, // Number of columns in the grid
        crossAxisSpacing: 8.0, // Spacing between columns
        mainAxisSpacing: 8.0, // Spacing between rows
      ),
      itemCount: nearbyAccommodationListings.length,
      itemBuilder: (context, index) {
        final listing = nearbyAccommodationListings[index];
        return InkWell(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AccomodationView(listing:listing),
              )),
        
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, //add this
              children: [
                Image.network(
                  listing.images[0], // Replace with image
                  height: 120, // Customize image height
                  width: double.infinity, // Make image full width
                  fit: BoxFit.cover, // Fit the image within the space
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.type,
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Rent: \$${listing.rent.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildOtherServicesList() {
    if (nearbyOtherServices.isEmpty) {
      return const Text('No nearby other services found.');
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Number of columns in the grid
        crossAxisSpacing: 8.0, // Spacing between columns
        mainAxisSpacing: 8.0, // Spacing between rows
      ),
      itemCount: nearbyOtherServices.length,
      itemBuilder: (context, index) {
        final service = nearbyOtherServices[index];
        return Card(
          // Customize card styling
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                service.images.first, // Replace with image
                height: 120, // Customize image height
                width: double.infinity, // Make image full width89
                fit: BoxFit.cover, // Fit the image within the space
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.type,
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Rating: ${service.rating.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class YourScreen extends StatelessWidget {
  final List<OtherService> nearbyOtherServices;

  YourScreen({required this.nearbyOtherServices});

  final List<String> OtherServiceTypes = [
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
    return DefaultTabController(
      length: OtherServiceTypes.length,
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: TabBar(
              isScrollable: true, // Make the tab bar scrollable
              tabs: OtherServiceTypes.map((type) => Tab(text: type)).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: OtherServiceTypes.map((type) {
                final servicesByType = nearbyOtherServices
                    .where((service) => service.type == type)
                    .toList();
                return buildOtherServicesList(servicesByType);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOtherServicesList(List<OtherService> services) {
    if (services.isEmpty) {
      return const RiveAnimation.asset('assets/ani404.riv');
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return InkWell(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtherServicesView(otherService:service),
              )),
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  service.images.first,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Rating: ${service.rating.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
