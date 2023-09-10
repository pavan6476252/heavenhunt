// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:heavenhunt/screens/utils.dart';
import 'package:heavenhunt/services/firebase_services.dart';
import 'package:heavenhunt/services/location_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../models/other_service.dart';

class PostServiceScreen extends StatefulWidget {
  @override
  _PostServiceScreenState createState() => _PostServiceScreenState();
}

class _PostServiceScreenState extends State<PostServiceScreen> {
  void initState() {
    // TODO: implement initState
    super.initState();
    // fetchLocationData();
    _getCurrentLocation();
  }

  Position? _currentPosition;
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
        _currentPosition!.latitude, _currentPosition!.longitude);

    Placemark place = placemarks[0];
    _currentCity = place.locality;
    locationController.text = _currentCity ?? "Unkown";
    setState(() {});
  }

  // void fetchLocationData() async {
  //   // Request location permission
  //   final LocationPermission permission = await Geolocator.requestPermission();

  //   try {
  //     if (permission == LocationPermission.always ||
  //         permission == LocationPermission.whileInUse) {
  //       final Position position = await Geolocator.getCurrentPosition(
  //         desiredAccuracy: LocationAccuracy.high,
  //       );

  //       _getCurrentPosition();
  //     }
  //   } catch (err) {
  //     Utils.showSnackbar(context: context, text: "Erro fetching location");
  //   }
  // }

  // Future<void> _getCurrentPosition() async {
  //   final hasPermission =
  //       await LocationServices.handleLocationPermission(context);
  //   if (!hasPermission) return;
  //   await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
  //       .then((Position position) {
  //     setState(() => _currentPosition = position);
  //     _getAddressFromLatLng(position);
  //   }).catchError((e) {
  //     Utils.showSnackbar(
  //         context: context, text: "Error while getting Location");
  //   });
  // }

  // Future<void> _getAddressFromLatLng(Position position) async {
  //   await placemarkFromCoordinates(
  //           _currentPosition!.latitude, _currentPosition!.longitude)
  //       .then((List<Placemark> placemarks) {
  //     Placemark place = placemarks[0];
  //     setState(() {
  //       locationController.text =
  //           '${place.street}, ${place.subLocality},${place.subAdministrativeArea}, ${place.postalCode}';
  //     });
  //   }).catchError((e) {
  //     Utils.showSnackbar(
  //         context: context, text: "Error while getting address name");
  //     print(e);
  //   });
  // }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? selectedType;
  // Text editing controllers for input fields
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController =
      TextEditingController(text: "Unkown");

  bool setLoading = false;
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

  List<File> images = [];
  void pickImage(int index) async {
    File? image = await Utils.pickImage(ImageSource.gallery);
    if (image != null && index != -1) {
      images.removeAt(index);
      images.insert(index, image);
      setState(() {});
    } else if (image != null) {
      images.add(image);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Post Services',
          style: TextStyle(
            fontSize: 24.0, // Adjust the font size as needed
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),

              SizedBox(height: 15),
              // Replace TextFormField with DropdownButtonFormField for "Type"
              DropdownButton<String>(
                value: selectedType,
                onChanged: (newValue) {
                  setState(() {
                    selectedType = newValue;
                  });
                },
                items: OtherServiceTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
              ),
              SizedBox(height: 15),
              Text("Images"),
              SizedBox(
                height: 300,
                width: double.maxFinite,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length + 1,
                  itemBuilder: (context, index) {
                    if (index == images.length) {
                      return Card(
                        child: SizedBox(
                          height: 300,
                          width: 280,
                          child: Center(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                pickImage(-1);
                              },
                              icon: const Icon(Icons.camera_alt_outlined),
                              label: const Text('Add Image'),
                            ),
                          ),
                        ),
                      );
                    }
                    return Card(
                      child: SizedBox(
                        height: 300,
                        width: 280,
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Image.file(
                                images.elementAt(index),
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CircleAvatar(
                                    child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          images.removeAt(index);
                                        });
                                      },
                                      icon: const Icon(Icons.delete),
                                    ),
                                  ),
                                  CircleAvatar(
                                    child: IconButton(
                                      onPressed: () {
                                        pickImage(index);
                                      },
                                      icon: const Icon(Icons.edit),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 15),

              TextFormField(
                controller: _contactNumberController,
                decoration: InputDecoration(
                  labelText: 'Contact Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty || value.length < 10) {
                    return 'Please enter a Number';
                  }
                  return null;
                },
              ),

              SizedBox(height: 15),

              TextFormField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: TextEditingController(
                        text: _currentPosition != null
                            ? _currentPosition!.longitude.toString()
                            : '', // Convert double to string
                      ),
                      decoration: InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      controller: TextEditingController(
                        text: _currentPosition != null
                            ? _currentPosition!.latitude.toString()
                            : '', // Convert double to string
                      ),
                      decoration: InputDecoration(
                        labelText: 'Latitude',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Text("Give Rating :"),
              RatingBar.builder(
                initialRating: selectedRating, // Set the initial rating value
                minRating: 1,
                wrapAlignment: WrapAlignment.spaceEvenly,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: (MediaQuery.of(context).size.width - 15) / 6,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    selectedRating = rating;
                  });
                },
              ),

              const SizedBox(height: 16.0),
              const Text(
                'Description :',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Enter some thing about post',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'about  is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setLoading = true;
                    setState(() {});
                    try {
                      final OtherService newService = OtherService(
                          userId: FirebaseAuth.instance.currentUser!.uid,
                          latitude: double.parse(_currentPosition != null
                              ? _currentPosition!.latitude.toString()
                              : '0.0'),
                          longitude: double.parse(_currentPosition != null
                              ? _currentPosition!.longitude.toString()
                              : '0.0'),
                          serviceId: const Uuid().v4(),
                          name: _nameController.text,
                          type: selectedType ?? "",
                          location: locationController.text,
                          contactNumber: _contactNumberController.text,
                          rating: selectedRating,
                          images: [],
                          reviews: [],
                          description: descriptionController.text);

                      // print(newService.toString());
                      // return;
                      bool isUploaded =
                          await FirebaseServices.uploadOtherServices(
                              images: images, postModel: newService);
                      if (isUploaded) {
                        Utils.showSnackbar(
                            context: context, text: "Upload Successful");
                        // Navigator.of(context).pop();
                      } else {
                        Utils.showSnackbar(
                            context: context,
                            text: "Upload failed",
                            isError: true);
                      }
                    } catch (e) {
                      print(e);
                      Utils.showSnackbar(
                          context: context, text: "Error While uploading");
                    }
                    setLoading = false;
                    setState(() {});
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double selectedRating = 0.0; // Initialize with the default rating (0.0)

  @override
  void dispose() {
    _nameController.dispose();

    locationController.dispose();
    _contactNumberController.dispose();
    _ratingController.dispose();
    super.dispose();
  }
}
