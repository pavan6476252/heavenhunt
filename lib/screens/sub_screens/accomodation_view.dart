import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:heavenhunt/models/accomodation_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:heavenhunt/screens/utils.dart';

class AccomodationView extends StatefulWidget {
  const AccomodationView({Key? key, required this.listing}) : super(key: key);
  final AccommodationListing listing;

  @override
  State<AccomodationView> createState() => _AccomodationViewState();
}

class _AccomodationViewState extends State<AccomodationView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Chip(label: Text(widget.listing.location)),
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
                itemCount: widget.listing.images.length,
                itemBuilder: (BuildContext context, int itemIndex, int int) =>
                    Container(
                  child: Image.network(
                    widget.listing.images[itemIndex],
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
                            number: widget.listing.contactNumber);
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
                            geoPoint: GeoPoint(widget.listing.latitude,
                                widget.listing.longitude));
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

              SizedBox(
                // height: 70,
                child: Row(
                  children: [
                    Expanded(
                        child: GestureDetector(
                      onTap: () {},
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Text(
                                widget.listing.rent.toString(),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                'Rent',
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
                              Icon(Icons.gesture_rounded),
                              Text(
                                'Gender - ${widget.listing.lookingFor}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
              // List of details (Floor, Occupancy, Looking For, Advanced Payment)
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Facilities Available:",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Wrap(
                      spacing: 8.0,
                      children: widget.listing.facilities
                          .map((facility) => Chip(label: Text(facility)))
                          .toList(),
                    ),
                  ],
                ),
              ),
              // Description

              TextFormField(
                initialValue: widget.listing.description,
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
