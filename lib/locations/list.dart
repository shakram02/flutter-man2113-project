import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:untitled2/university.dart';

import 'detail.dart';

class LocationListPage extends StatefulWidget {
  const LocationListPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LocationListPageState();
  }
}

class LocationListPageState extends State<LocationListPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: const Text('Favorite locations'),
        ),
        body: Container(
          padding: EdgeInsets.zero,
          child: FutureBuilder<Iterable<PointOfInterest>>(
            future: getPointsOfInterest(),
            builder:
                (context, AsyncSnapshot<Iterable<PointOfInterest>> snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(child: Text('Loading...'));
              }

              // var itemCount = snapshot.data!.size;
              List<PointOfInterest> items = snapshot.data!.toList();

              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(items[index].name),
                  subtitle: Text(items[index].address),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          LocationDetailPage(pointOfInterest: items[index]))),
                ),
              );
            },
          ),
        ));
  }

  Future<Iterable<PointOfInterest>> getPointsOfInterest() async {
    var universitiesFuture = await FirebaseFirestore.instance
        .collection('campuses')
        .orderBy('name')
        .withConverter<University>(
            fromFirestore: (snapshot, _) =>
                University.fromJson(snapshot.data()!),
            toFirestore: (university, _) => throw UnimplementedError())
        .get();
    return universitiesFuture.docs
        .map((e) => e.data().pointsOfInterest)
        .reduce((value, element) => [...value, ...element]);
  }
}
