import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';
import 'package:ionicons/ionicons.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:pnhs_go/main.dart';
import 'package:pnhs_go/screens/management_screen.dart';

class NavigateScreen extends StatefulWidget {
  final Position source, destination;
  final String sourceAddress, destinationAddress, tripDistance;
  const NavigateScreen(
      {super.key,
      required this.source,
      required this.destination,
      required this.tripDistance,
      required this.sourceAddress,
      required this.destinationAddress});

  @override
  State<NavigateScreen> createState() => _NavigateScreenState();
}

class _NavigateScreenState extends State<NavigateScreen> {
  // Waypoints to mark trip start and end
  late WayPoint sourceWaypoint, destinationWaypoint;
  var wayPoints = <WayPoint>[];

  // Config variables for Mapbox Navigation
  late MapBoxOptions _options;
  late double? distanceRemaining, durationRemaining;
  late MapBoxNavigationViewController _controller;
  final bool isMultipleStop = false;
  String instruction = "";
  bool arrived = false;
  bool routeBuilt = false;
  bool isNavigating = false;
  bool isNavigationFinished = false;

  bool showLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        showLoading = false;
      });
    });
    initialize();
  }

  Future<void> initialize() async {
    if (!mounted) return;

    // Setup directions and options
    MapBoxNavigation.instance.registerRouteEventListener(_onRouteEvent);
    _options = MapBoxOptions(
        zoom: 24.0,
        voiceInstructionsEnabled: true,
        bannerInstructionsEnabled: true,
        mode: MapBoxNavigationMode.walking,
        isOptimized: true,
        allowsUTurnAtWayPoints: true,
        enableRefresh: true,
        units: VoiceUnits.metric,
        simulateRoute: true,
        language: "en");

    // Configure waypoints
    sourceWaypoint = WayPoint(
        name: "Source",
        latitude: widget.source.lat.toDouble(),
        longitude: widget.source.lng.toDouble());
    destinationWaypoint = WayPoint(
        name: "Destination",
        latitude: widget.destination.lat.toDouble(),
        longitude: widget.destination.lng.toDouble());
    wayPoints.add(sourceWaypoint);
    wayPoints.add(destinationWaypoint);

    // Start the trip
    await MapBoxNavigation.instance
        .startNavigation(wayPoints: wayPoints, options: _options);
  }

  void _backToHomePage() {
    // Save trip to firebase with the user UID and go back to home page

    FirebaseFirestore.instance.collection('trips').add({
      'source': {
        'latitude': widget.source.lat.toDouble(),
        'longitude': widget.source.lng.toDouble()
      },
      'destination': {
        'latitude': widget.destination.lat.toDouble(),
        'longitude': widget.destination.lng.toDouble()
      },
      'distance': widget.tripDistance,
      'sourceAddress': widget.sourceAddress,
      'destinationAddress': widget.destinationAddress,
      'timestamp': DateTime.now(),
      'userId': prefs.getString('userId')
    });

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ManagementScreen()),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: (showLoading)
              ? const Center(
                  child: Text('Starting Navigation'),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // if (isNavigationFinished)
                    Image.asset("assets/icon/positive-vote.png", height: 100),
                    // if (isNavigationFinished)
                    const SizedBox(height: 20),
                    // if (isNavigating)
                    //   const Text("Navigating...")
                    // else
                    const Text(
                      "Navigation Finished. Thank you for using the app. You may now save the trip.",
                      textAlign: TextAlign.center,
                    ),
                    // if (isNavigationFinished)
                    const SizedBox(height: 20),
                    // if (isNavigationFinished)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(15),
                        ),
                        onPressed: _backToHomePage,
                        label: const Text("Save Trip"),
                        icon: const Icon(Ionicons.save),
                      ),
                    )
                  ],
                ),
        ),
      )),
    );
  }

  Future<void> _onRouteEvent(e) async {
    distanceRemaining = await MapBoxNavigation.instance.getDistanceRemaining();
    durationRemaining = await MapBoxNavigation.instance.getDurationRemaining();

    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        arrived = progressEvent.arrived!;
        if (progressEvent.currentStepInstruction != null) {
          instruction = progressEvent.currentStepInstruction!;
        }
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        routeBuilt = true;
        break;
      case MapBoxEvent.route_build_failed:
        routeBuilt = false;
        break;
      case MapBoxEvent.navigation_running:
        isNavigating = true;
        break;
      case MapBoxEvent.on_arrival:
        arrived = true;
        if (!isMultipleStop) {
          await Future.delayed(const Duration(seconds: 3));
          await _controller.finishNavigation();
        } else {}
        break;
      case MapBoxEvent.navigation_finished:
        isNavigating = false;
        isNavigationFinished = true;
        // save new location into shared preferences
        prefs.setDouble('latitude', widget.destination.lat.toDouble());
        prefs.setDouble('longitude', widget.destination.lng.toDouble());
        break;
      case MapBoxEvent.navigation_cancelled:
        routeBuilt = false;
        isNavigating = false;
        break;
      default:
        break;
    }
    //refresh UI
    setState(() {});
  }
}
