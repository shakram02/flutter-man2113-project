import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:untitled2/university.dart';

class LocationDetailPage extends StatefulWidget {
  const LocationDetailPage({required this.pointOfInterest, Key? key})
      : super(key: key);
  final PointOfInterest pointOfInterest;

  @override
  LocationDetailPageState createState() {
    return LocationDetailPageState();
  }
}

class LocationDetailPageState extends State<LocationDetailPage> {
  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: widget.pointOfInterest.location,
          zoom: 17.0,
        ),
        markers: {
          Marker(
              markerId: MarkerId(widget.pointOfInterest.name),
              position: widget.pointOfInterest.location)
        });
  }
}
