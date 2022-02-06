// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:untitled2/locations/list.dart';
import 'package:untitled2/university.dart';

// Import the generated file
import 'firebase_options.dart';

// import 'place_tracker_app.dart';
import 'locations/list.dart';

import 'api_key.dart';

// Center of the Google Map
const initialPosition = LatLng(1.5633, 103.6382);
// Hue used by the Google Map Markers to match the theme
const _pinkHue = 350.0;
// Places API client used for Place Photos
final _placesApiClient = GoogleMapsPlaces(apiKey: googleMapsApiKey);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UTM Locations',
      home: const HomePage(title: 'UTM Locations'),
      routes: {
        "list": (context) => const LocationListPage(),
      },
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({required this.title, Key? key}) : super(key: key);
  final String title;

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> _mapController = Completer();

  Future<Iterable<University>> getUniversities() async {
    var universitySnapshots = await FirebaseFirestore.instance
        .collection('campuses')
        .orderBy('name')
        .withConverter<University>(
            fromFirestore: (snapshot, _) =>
                University.fromJson(snapshot.data()!),
            toFirestore: (university, _) => throw UnimplementedError())
        .get();
    return universitySnapshots.docs.map((e) => e.data());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed("list");
              },
              icon: Icon(Icons.star),
              color: Colors.yellow
          ),
        ],
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text("MAN2113 Bahaa/Hamdy/Sadia"),
              accountEmail: Text("man2113@utm.kl"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.orange,
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<Iterable<University>>(
        future: getUniversities(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Loading...'));
          }

          List<University> items = snapshot.data!.toList();
          return Stack(
            children: [
              StoreMap(
                universities: items,
                initialPosition: initialPosition,
                mapController: _mapController,
              ),
              StoreCarousel(
                mapController: _mapController,
                universities: items,
              ),
            ],
          );
        },
      ),
    );
  }
}

class StoreCarousel extends StatelessWidget {
  const StoreCarousel({
    Key? key,
    required this.universities,
    required this.mapController,
  }) : super(key: key);

  final List<University> universities;
  final Completer<GoogleMapController> mapController;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: SizedBox(
          height: 90,
          child: StoreCarouselList(
            universities: universities,
            mapController: mapController,
          ),
        ),
      ),
    );
  }
}

class StoreCarouselList extends StatelessWidget {
  const StoreCarouselList({
    Key? key,
    required this.universities,
    required this.mapController,
  }) : super(key: key);

  final List<University> universities;
  final Completer<GoogleMapController> mapController;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: universities.length,
      itemBuilder: (context, index) {
        return SizedBox(
          width: 340,
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Card(
              child: Center(
                child: UniversityListTile(
                  university: universities[index],
                  mapController: mapController,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class UniversityListTile extends StatefulWidget {
  const UniversityListTile({
    Key? key,
    required this.university,
    required this.mapController,
  }) : super(key: key);

  final University university;
  final Completer<GoogleMapController> mapController;

  @override
  State<StatefulWidget> createState() {
    return _UniversityListTileState();
  }
}

class _UniversityListTileState extends State<UniversityListTile> {

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.university.name),
      subtitle: Text(widget.university.address),
      onTap: () async {
        final controller = await widget.mapController.future;

        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: widget.university.location,
              zoom: 10,
            ),
          ),
        );
      },
    );
  }
}

class StoreMap extends StatelessWidget {
  const StoreMap({
    Key? key,
    required this.universities,
    required this.initialPosition,
    required this.mapController,
  }) : super(key: key);

  final List<University> universities;
  final LatLng initialPosition;
  final Completer<GoogleMapController> mapController;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: 7,
      ),
      markers: universities
          .map((university) => Marker(
                markerId: MarkerId(university.name),
                icon: BitmapDescriptor.defaultMarkerWithHue(_pinkHue),
                position: university.location,
                infoWindow: InfoWindow(
                  title: university.name,
                  snippet: university.address,
                ),
              ))
          .toSet(),
      onMapCreated: (mapController) {
        this.mapController.complete(mapController);
      },
    );
  }
}
