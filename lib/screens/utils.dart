// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:share_plus/share_plus.dart';

class Utils {
  static Future<File?> pickImage(ImageSource imageSource) async {
    XFile? file = await ImagePicker().pickImage(source: imageSource);
    if (file != null) {
      return File(file.path);
    }
    return null;
  }

  // messages
  static showSnackbar(
      {required BuildContext context,
      required String text,
      bool isError = false}) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text,
          style:
              TextStyle(color: Theme.of(context).colorScheme.errorContainer)),
      backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
    ));
  }

  //

  static Padding smallheading(
      {required BuildContext context, required String title}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
          alignment: Alignment.centerLeft,
          child: Text(title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ))),
    );
  }

  //maps
  static Future<void> openMaps(
      {required BuildContext context, GeoPoint? geoPoint}) async {
    if (geoPoint == null) {
      showSnackbar(context: context, text: "no location found");
      return;
    }
    try {
      await MapsLauncher.launchCoordinates(
          geoPoint.latitude, geoPoint.longitude);
    } catch (e) {
      print(e);
      showSnackbar(context: context, text: "Unable to open maps");
    }
  }

  static Future<void> makeCall(
      {required BuildContext context, required String number}) async {
    if (number == '') {
      showSnackbar(context: context, text: "no location found");
      return;
    }
    try {
      var url = Uri.parse("tel:$number");
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        showSnackbar(context: context, text: "Unable to make call");
      }
    } catch (e) {
      print(e);
      showSnackbar(context: context, text: "Unable to open maps");
    }
  }

  //maps
  static Future<void> shareMsgTo({
    required BuildContext context,
  }) async {
    try {
      String text = 'check out my website https://pavankumar.vercel.app/';
      String link = 'Look what I made!';
      final box = context.findRenderObject() as RenderBox?;
      await Share.share(text,
          subject: link,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    } catch (e) {
      showSnackbar(context: context, text: "Unable to open maps");
    }
  }

  static Future<void> shareProfile({
    required BuildContext context,
    required String uid,
  }) async {
    try {
      String text = 'uid : $uid';
      String link = 'Look at this profile!';
      final box = context.findRenderObject() as RenderBox?;
      await Share.share(text,
          subject: link,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    } catch (e) {
      showSnackbar(context: context, text: "Unable to open launch");
    }
  }
}
