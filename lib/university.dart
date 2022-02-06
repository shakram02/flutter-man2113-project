import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PointOfInterest {
  final String name;
  final String address;
  final LatLng location;

  PointOfInterest(this.name, this.address, this.location);

  static PointOfInterest fromJson(Map<String, dynamic> data) {
    GeoPoint location = data['location'];
    return PointOfInterest(data['name'], data['address'],
        LatLng(location.latitude, location.longitude));
  }
}

class University {
  late LatLng location;
  final String name;
  final String address;
  final String placeId;
  final Iterable<PointOfInterest> pointsOfInterest;

  University(
    this.name,
    this.placeId,
    this.address,
    this.pointsOfInterest,
    GeoPoint geoPoint,
  ) {
    location = LatLng(geoPoint.latitude, geoPoint.longitude);
  }

  static University fromJson(Map<String, dynamic> data) {
    return University(
      data['name'],
      data['placeId'],
      data['address'],
      (data['pois'] as List<dynamic>).map((e) => PointOfInterest.fromJson(e)),
      data['location'],
    );
  }

  @override
  String toString() {
    return "$name @ [${location.latitude},${location.longitude}]: $address";
  }
}
