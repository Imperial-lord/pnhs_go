import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ionicons/ionicons.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:pnhs_go/helpers/misc_helpers.dart';
import 'package:pnhs_go/main.dart';
import 'package:pnhs_go/screens/navigate_screen.dart';

class PreviewScreen extends StatefulWidget {
  final Map sourceMap;
  final Map destinationMap;
  final Map directionsApiInfo;

  const PreviewScreen(
      {super.key,
      required this.sourceMap,
      required this.destinationMap,
      required this.directionsApiInfo});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class AnnotationClickListener extends OnPolylineAnnotationClickListener {
  @override
  void onPolylineAnnotationClick(PolylineAnnotation annotation) {
    debugPrint("onAnnotationClick, id: ${annotation.id}");
  }
}

class _PreviewScreenState extends State<PreviewScreen> {
  MapboxMap? mapboxMap;
  PolylineAnnotation? polylineAnnotation;
  PolylineAnnotationManager? polylineAnnotationManager;

  static double lat = prefs.getDouble('latitude')!;
  static double long = prefs.getDouble('longitude')!;

  Point _getMapCenter() {
    List centerPoint = widget.directionsApiInfo['geometry']['coordinates']
        [widget.directionsApiInfo['geometry']['coordinates'].length ~/ 2];
    double centerLat = centerPoint[1];
    double centerLon = centerPoint[0];
    Point center = Point(coordinates: Position(centerLon, centerLat));
    return center;
  }

  _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;
    mapboxMap.location.updateSettings(LocationComponentSettings(
      enabled: true,
      pulsingEnabled: true,
    ));
    mapboxMap.annotations.createPolylineAnnotationManager().then((value) {
      polylineAnnotationManager = value;
      _createSchoolNavAnnotation();
    });
  }

  _createSchoolNavAnnotation() {
    // Get all coordinates from the directions API
    List<Position> coordinates = widget.directionsApiInfo['geometry']
            ['coordinates']
        .map<Position>((coordinate) => Position(coordinate[0], coordinate[1]))
        .toList();
    // Create a line string for polyline
    LineString lineString = LineString(coordinates: coordinates);
    polylineAnnotationManager
        ?.create(PolylineAnnotationOptions(
            geometry: lineString.toJson(),
            lineColor: Colors.purple.value,
            lineWidth: 2))
        .then((value) => polylineAnnotation = value);
    polylineAnnotationManager
        ?.addOnPolylineAnnotationClickListener(AnnotationClickListener());
  }

  @override
  Widget build(BuildContext context) {
    String distance = widget.directionsApiInfo['distance'].toString();
    String dropOffTime = getDropOffTime(widget.directionsApiInfo['duration']);
    String startAddressName = widget.sourceMap['name'];
    String endAddressName = widget.destinationMap['name'];
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: SafeArea(
        child: Stack(
          children: [
            MapWidget(
              onMapCreated: _onMapCreated,
              styleUri: MapboxStyles.MAPBOX_STREETS,
              cameraOptions: CameraOptions(
                center: _getMapCenter().toJson(),
                zoom: 18,
              ),
              resourceOptions: ResourceOptions(
                  accessToken: dotenv.env['MAPBOX_ACCESS_TOKEN']!),
            ),
            // Add a back button at top left corner
            Positioned(
              top: 0,
              left: 0,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  mini: true,
                  child: const Icon(Ionicons.arrow_back),
                ),
              ),
            ),
            Positioned(
                bottom: 0,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                      margin: const EdgeInsets.all(15),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(startAddressName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple)),
                                const Spacer(),
                                const Icon(Ionicons.arrow_forward_circle),
                                const Spacer(),
                                Text(endAddressName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Ionicons.walk),
                                const SizedBox(width: 5),
                                const Text('Walk'),
                                const Spacer(),
                                const Icon(Ionicons.trail_sign),
                                const SizedBox(width: 5),
                                Text('$distance m'),
                                const Spacer(),
                                const Icon(Ionicons.time),
                                const SizedBox(width: 5),
                                Text(dropOffTime),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.all(10),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NavigateScreen(
                                        source: widget.sourceMap['location'],
                                        destination:
                                            widget.destinationMap['location'],
                                        sourceAddress: startAddressName,
                                        destinationAddress: endAddressName,
                                        tripDistance: distance,
                                      ),
                                    ),
                                  );
                                },
                                label: const Text('Navigate'),
                                icon: const Icon(Ionicons.navigate),
                              ),
                            ),
                          ],
                        ),
                      )),
                ))
          ],
        ),
      ),
    );
  }
}
