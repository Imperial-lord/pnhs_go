
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ionicons/ionicons.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List users = [];
  List filteredUsers = [];
  String searchQuery = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    populateUsers();
  }

  void filterUsers() {
    filteredUsers = users.where((user) {
      final name = user['name'].toString().toLowerCase();
      final email = user['email'].toString().toLowerCase();
      return name.contains(searchQuery.toLowerCase()) ||
          email.contains(searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> populateUsers() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').get();
    final List<DocumentSnapshot> documents = snapshot.docs;
    setState(() {
      users = documents.map((doc) => doc.data()).toList();
      filteredUsers = users;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Users'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isLoading) const LinearProgressIndicator(),
              if (isLoading) const SizedBox(height: 10),
              CupertinoTextField(
                padding: const EdgeInsets.all(20),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                    filterUsers();
                  });
                },
                placeholder: 'Search for users...',
                suffix: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Icon(Ionicons.search),
                ),
              ),
              const SizedBox(height: 10),
              const Text('Tap on a user to see them on the map',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return Column(
                      children: [
                        ListTile(
                          onTap: () async {
                            final ByteData bytes = await rootBundle
                                .load('assets/icon/user-pin.png');
                            final Uint8List list = bytes.buffer.asUint8List();
                            // Open map in a dialog screen
                            debugPrint(user['latitude'].toString());
                            debugPrint(user['longitude'].toString());
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                MapboxMap? mapboxMap;
                                PointAnnotationManager? pointAnnotationManager;
                                PointAnnotation? pointAnnotation;

                                void onMapCreated(MapboxMap controller) {
                                  mapboxMap = controller;
                                  mapboxMap?.location
                                      .updateSettings(LocationComponentSettings(
                                    enabled: true,
                                    pulsingEnabled: true,
                                  ));
                                  mapboxMap?.annotations
                                      .createPointAnnotationManager()
                                      .then((value) {
                                    pointAnnotationManager = value;
                                    pointAnnotationManager
                                        ?.create(PointAnnotationOptions(
                                            geometry: Point(
                                                coordinates: Position(
                                              user['longitude'],
                                              user['latitude'],
                                            )).toJson(),
                                            iconOpacity: 1,
                                            iconSize: 0.2,
                                            image: list))
                                        .then(
                                            (value) => pointAnnotation = value);
                                  });
                                }

                                return Dialog.fullscreen(
                                  child: Scaffold(
                                    appBar: AppBar(
                                      title:
                                          Text('${user['name']}\'s Location'),
                                      leading: IconButton(
                                        icon: const Icon(Ionicons.close),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                    body: MapWidget(
                                      onMapCreated: onMapCreated,
                                      styleUri: MapboxStyles.MAPBOX_STREETS,
                                      cameraOptions: CameraOptions(
                                        center: Point(
                                                coordinates:
                                                    Position(122.870, 10.369))
                                            .toJson(),
                                        zoom: 17,
                                      ),
                                      resourceOptions: ResourceOptions(
                                          accessToken: dotenv
                                              .env['MAPBOX_ACCESS_TOKEN']!),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          title: Text(user['name']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Email: ${user['email']}'),
                              Text('Grade: ${user['grade']}'),
                            ],
                          ),
                          trailing: const Icon(Ionicons.navigate_circle),
                        ),
                        const Divider(),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
