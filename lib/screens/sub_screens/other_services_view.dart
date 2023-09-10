import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:heavenhunt/models/accomodation_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:heavenhunt/screens/utils.dart';

import '../../models/other_service.dart';

class OtherServicesView extends StatefulWidget {
  const OtherServicesView({Key? key, required this.otherService})
      : super(key: key);
  final OtherService otherService;

  @override
  State<OtherServicesView> createState() => _OtherServicesViewState();
}

class _OtherServicesViewState extends State<OtherServicesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Chip(label: Text(widget.otherService.location)),
          SizedBox(
            width: 15,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CarouselSlider.builder(
                itemCount: widget.otherService.images.length,
                itemBuilder: (BuildContext context, int itemIndex, int int) =>
                    Container(
                  child: Image.network(
                    widget.otherService.images[itemIndex],
                    fit: BoxFit.fill,
                    width: double.infinity,
                  ),
                ),
                options: CarouselOptions(
                  autoPlay: true,
                  enlargeCenterPage: true,
                  viewportFraction: 0.9,
                  aspectRatio: 1.0,
                  initialPage: 0,
                ),
              ),
              SizedBox(height: 10),
              // Carousel for images (you can use any carousel package)
              // Horizontal list of buttons (Phone, Message, Open in Map, Rent)
              SizedBox(
                // height: 70,
                child: Row(
                  children: [
                    Expanded(
                        child: GestureDetector(
                      onTap: () {
                        Utils.makeCall(
                            context: context,
                            number: widget.otherService.contactNumber);
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Icon(Icons.call),
                              Text(
                                'Phone',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),
                    Expanded(
                        child: GestureDetector(
                      onTap: () {},
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Icon(Icons.message_rounded),
                              Text(
                                'Message',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),
                    Expanded(
                        child: GestureDetector(
                      onTap: () {
                        Utils.openMaps(
                            context: context,
                            geoPoint: GeoPoint(widget.otherService.latitude,
                                widget.otherService.longitude));
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Icon(Icons.map_outlined),
                              Text(
                                'Map',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ))
                  ],
                ),
              ),

              RatingBar.builder(
                initialRating:
                    widget.otherService.rating, // Set the initial rating value
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
                onRatingUpdate: (rating) {},
              ),

              TextFormField(
                initialValue: widget.otherService.description,
                maxLines: null,
                decoration:
                    InputDecoration(labelText: "Description", filled: true),
                keyboardType: TextInputType.multiline,
              )
            ],
          ),
        ),
      ),
    );
  }

  Card socialConnectioncount(
      {required BuildContext context,
      required String title,
      required String count}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              count,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
