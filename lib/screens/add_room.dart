// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:heavenhunt/screens/utils.dart';
import 'package:heavenhunt/services/firebase_services.dart';
import 'package:heavenhunt/utils/Loading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../models/accomodation_model.dart';

class AddRoomPage extends StatefulWidget {
  @override
  _AddRoomPageState createState() => _AddRoomPageState();
}

class _AddRoomPageState extends State<AddRoomPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // fetchLocationData();
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
  //   } catch (err) {}
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

  // String? _currentAddress;
  // Position? _currentPosition;
  // Define controllers for text input fields
  final TextEditingController locationController =
      TextEditingController(text: "Unkown");
  final TextEditingController rentController = TextEditingController();
  final TextEditingController floorController = TextEditingController();
  final TextEditingController advancePaymentController =
      TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController requirementController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Define lists for images and facilities
  List<File> images = [];
  final List<String> facilities = [];

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

  // Handle form submission
  final roomTypeOptions = ['PG', 'Hostel', 'Room', 'Apartment', 'House'];
  String? selectedRoomType; // Store the selected room type

// Function to handle room type selection
  void _handleRoomTypeSelection(String? value) {
    setState(() {
      selectedRoomType = value;
    });
  }

  final availableFacilities = {
    'WiFi': Icons.wifi,
    'TV': Icons.tv,
    'AC': Icons.ac_unit,
    'Kitchen': Icons.kitchen,
    'Laundry': Icons.local_laundry_service,
    'Parking': Icons.local_parking,
  };
  List<String> selectedFacilities = []; // Store selected facilities

// Function to handle facility selection
  void _handleFacilitySelection(String facility) {
    setState(() {
      if (selectedFacilities.contains(facility)) {
        selectedFacilities.remove(facility);
      } else {
        selectedFacilities.add(facility);
      }
    });
  }

  String? selectedLookingFor; // Store the selected looking for option

  final lookingForOptions = ['Male', 'Female', 'Any'];
  void _handleLookingForSelection(String? value) {
    setState(() {
      selectedLookingFor = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return setUploading
        ? LoadingAnimation()
        : Scaffold(
            appBar: AppBar(
              title: const Text('Add Room Listing'),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey, // Form key for validation
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Room Type:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Wrap(
                      children: roomTypeOptions.map((type) {
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ChoiceChip(
                            label: Text(type),
                            selected: selectedRoomType == type,
                            onSelected: (isSelected) {
                              _handleRoomTypeSelection(
                                  isSelected ? type : null);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Location:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        hintText: 'Enter location',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Location is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Rent (per month):',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      controller: rentController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Enter rent amount',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Rent amount is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Floor:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      controller: floorController,
                      decoration: const InputDecoration(
                        hintText: 'Enter floor details',
                      ),
                      validator: (value) {
                        // You can add floor-specific validation here
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Requirement :',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      controller: requirementController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Enter Noof free beds ',
                      ),
                      validator: (value) {
                        // You can add floor-specific validation here
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Looking For:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Wrap(
                      children: lookingForOptions.map((option) {
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ChoiceChip(
                            label: Text(option),
                            selected: selectedLookingFor == option,
                            onSelected: (isSelected) {
                              _handleLookingForSelection(
                                  isSelected ? option : null);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Advance Payment Amount:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      controller: advancePaymentController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Enter advance payment amount',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Advance payment amount is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Contact Number:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      controller: contactNumberController,
                      decoration: const InputDecoration(
                        hintText: 'Enter contact number',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Contact number is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Images:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                        'Images:'), // You can add an image upload feature here
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
                                      icon:
                                          const Icon(Icons.camera_alt_outlined),
                                      label: const Text('Add Image')),
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
                                                icon: const Icon(Icons.delete)),
                                          ),
                                          CircleAvatar(
                                            child: IconButton(
                                                onPressed: () {
                                                  pickImage(index);
                                                },
                                                icon: const Icon(Icons.edit)),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Facilities:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Wrap(
                      children: availableFacilities.keys.map((facility) {
                        final isSelected =
                            selectedFacilities.contains(facility);

                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: buildFacilityChoiceChip(facility, isSelected),
                        );
                      }).toList(),
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
                    const SizedBox(height: 32.0),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                  _submitForm();
                              }
                            },
                            child: const Text('Submit'),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ));
  }

  Widget buildFacilityChoiceChip(String facility, bool isSelected) {
    return ChoiceChip(
      avatar: Icon(
        availableFacilities[facility],
        color: Colors.white,
      ),
      label: Text(facility),
      selected: isSelected,
      onSelected: (bool newValue) {
        _handleFacilitySelection(facility);
      },
    );
  }

  bool setUploading = false;
  void _submitForm() async {
    final AccommodationListing newListing = AccommodationListing(
      postId: const Uuid().v4(),
      listingId: DateTime.now().toString(),
      type: selectedRoomType ?? "",
      location: locationController.text,
      latitude: _currentPosition?.latitude ?? 0,
      longitude: _currentPosition?.longitude ?? 0,
      rent: double.parse(rentController.text),
      floor: double.parse(floorController.text),
      occupancy: '',
      requirement: int.parse(requirementController.text),
      lookingFor: selectedLookingFor ?? '',
      images: [],
      facilities: facilities,
      advancePaymentAmount: double.parse(advancePaymentController.text),
      contactNumber: contactNumberController.text,
      postedDate: DateTime.now(),
      ownerId: FirebaseAuth.instance.currentUser!.uid,
      description: descriptionController.text,
    );
    setState(() {
      setUploading = true;
    });
    bool isUploaded = await FirebaseServices.uploadPost(
        images: images, postModel: newListing);

    if (isUploaded) {
      Utils.showSnackbar(context: context, text: "Uploaded");
      setUploading = false;
      setState(() {});
    } else {
      Utils.showSnackbar(
          context: context,
          text: "Failed , some thing went wrong",
          isError: true);
    }
  }
}
