// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:heavenhunt/models/user_model.dart';
import 'package:heavenhunt/screens/utils.dart';
import 'package:heavenhunt/utils/Loading.dart';
import 'package:image_picker/image_picker.dart';
 
import 'package:geolocator/geolocator.dart';

class UserDataScreen extends StatefulWidget {
  const UserDataScreen({super.key});

  @override
  State<UserDataScreen> createState() => _UserDataScreenState();
}

class _UserDataScreenState extends State<UserDataScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _photoController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _collegeController = TextEditingController();

  File? _image;
  String fcmToken = '';
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    initFCM();
    fetchLocationData();
    loadCollegesFromJson();
    User? user = FirebaseAuth.instance.currentUser;
    _nameController.text = user?.displayName ?? "";
    _emailController.text = user?.email ?? "";
    _photoController.text = user?.photoURL ?? "";
    _phoneNumberController.text = user?.phoneNumber ?? "";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _photoController.dispose();
    _genderController.dispose();
    _collegeController.dispose();
    super.dispose();
  }

  void fetchLocationData() async {
    // Request location permission
    final LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        // Set the latitude and longitude coordinates
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    }
  }

  double _latitude = 0.0;
  double _longitude = 0.0;

  // Other fields and methods...

  void pickImage() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text("Camera"),
              onTap: () async {
                File? file = await Utils.pickImage(ImageSource.camera);
                if (file != null) {
                  setState(() {
                    _image = file;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.browse_gallery_rounded),
              title: const Text("Gallery"),
              onTap: () async {
                File? file = await Utils.pickImage(ImageSource.gallery);
                if (file != null) {
                  setState(() {
                    _image = file;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  final List<String> genderOptions = [
    'Male',
    'Female',
    'Other'
  ]; // Add gender options here.
  String? selectedGender; // Track selected gender.

  List<String> collegeOptions = [
    'College A',
    'College B',
    'College C'
  ]; // Add college options here.
  String? selectedCollege; // Track selected college.

  Future<void> loadCollegesFromJson() async {
    try {
      final String jsonString = await DefaultAssetBundle.of(context)
          .loadString('assets/colleges.json');
      final List<dynamic> collegesData = json.decode(jsonString);

      setState(() {
        collegeOptions = collegesData
            .map((college) => college['college'] as String)
            .toList();
      });
    } catch (e) {
      print('Error loading colleges from JSON: $e');
    }
  }

  void _showCollegePickerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Set to true to make it fullscreen.
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final List<String> filteredColleges = collegeOptions
                .where((college) => college
                    .toLowerCase()
                    .contains(selectedCollege?.toLowerCase() ?? ''))
                .toList();

            return Container(
              height:
                  MediaQuery.of(context).size.height - 100, // Adjust as needed.
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          selectedCollege = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search College',
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredColleges.length,
                      itemBuilder: (context, index) {
                        final college = filteredColleges[index];
                        return ListTile(
                          title: Text(college),
                          onTap: () {
                            _collegeController.text = college;
                            setState(() {});
                            Navigator.pop(context);
                          },
                          tileColor: college == selectedCollege
                              ? Colors.blue[100]
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _uploading
        ? LoadingAnimation()
        : Scaffold(
            appBar: AppBar(
              elevation: 2,
              title: const Text("New User"),
              actions: [
                TextButton(
                  onPressed: () async {
                    await UserProfile.logout();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text("Logout"),
                )
              ],
            ),
            body: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: _photoController.text == ''
                                  ? _image == null
                                      ? null
                                      : FileImage(_image!) as ImageProvider
                                  : NetworkImage(_photoController.text),
                              child: IconButton(
                                onPressed: () {
                                  pickImage();
                                },
                                icon: const Icon(Icons.camera),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _nameController,
                              keyboardType: TextInputType.name,
                              decoration: const InputDecoration(
                                hintText: 'User Name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                              // Add validators and constraints as needed.
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _phoneNumberController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                hintText: 'Phone Number',
                                border: OutlineInputBorder(),
                              ),
                              // Add validators and constraints as needed.
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                hintText: 'Select Gender',
                                border: OutlineInputBorder(),
                              ),
                              value: selectedGender,
                              onChanged: (value) {
                                setState(() {
                                  selectedGender = value;
                                  _genderController.text = value ?? '';
                                });
                              },
                              items: genderOptions.map((option) {
                                return DropdownMenuItem<String>(
                                  value: option,
                                  child: Text(option),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _collegeController,
                              readOnly: true,
                              onTap: () {
                                _showCollegePickerModal(context);
                              },
                              decoration: const InputDecoration(
                                hintText: 'Collage Name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: 150,
                              child: ElevatedButton(
                                onPressed: () {
                                  validator();
                                },
                                child: _uploading
                                    ? const CircularProgressIndicator()
                                    : const Text("Save"),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  // Other methods...

  void validator() async {
    final FormState form = _formKey.currentState!;

    if (form.validate()) {
      if (_image == null && _photoController.text == '') {
        Utils.showSnackbar(
          context: context,
          text: "Please provide an image",
          isError: true,
        );
      } else {
        try {
          setState(() {
            _uploading = true;
          });
          UserProfile userProfile = UserProfile(
            uid: FirebaseAuth.instance.currentUser!.uid,
            name: _nameController.text,
            email: _emailController.text,
            phoneNumber: _phoneNumberController.text,
            profilePictureUrl: '',
            gender: _genderController.text,
            college: _collegeController.text,
            favorites: [],
            preferences: [],
            fcmToken: fcmToken,
            coordinates: [_latitude, _longitude],
          );

          if (_image != null) {
            String? downloadURL = await uploadImageToStorage(_image!);
            if (downloadURL != null) {
              userProfile =
                  userProfile.copyWith(profilePictureUrl: downloadURL);
            } else {
              Utils.showSnackbar(
                context: context,
                text: "Failed to upload image",
                isError: true,
              );
              return;
            }
          }
          await UserProfile.storeNewUserData(userProfile);
          await UserProfile.storeUserData(userProfile);
          setState(() {
            _uploading = false;
          });

          Navigator.pushReplacementNamed(context, '/home');
        } catch (e) {
          print(e);
          Utils.showSnackbar(
            context: context,
            text: "Network issue - try again",
            isError: true,
          );
        }
      }
    } else {
      Utils.showSnackbar(
        context: context,
        text: "Invalid Data",
        isError: true,
      );
    }
  }

  Future<void> initFCM() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.getNotificationSettings();

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      String? _fcmToken = await FirebaseMessaging.instance.getToken();

      if (_fcmToken != null) {
        // You can now use fcmToken for sending notifications to this device
        fcmToken = _fcmToken;
        setState(() {});
      }
    } else {
      Utils.showSnackbar(context: context, text: "Error while getting token");
    }
  }

  Future<String?> uploadImageToStorage(File imageFile) async {
    final storageRef = FirebaseStorage.instance.ref();
    final userUid = FirebaseAuth.instance.currentUser!.uid;
    final imagePath = 'profile/$userUid.jpg';

    final uploadTask = storageRef.child(imagePath).putFile(imageFile);
    final snapshot = await uploadTask.whenComplete(() {});

    if (snapshot.state == TaskState.success) {
      final downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    }
    return null;
  }
}
