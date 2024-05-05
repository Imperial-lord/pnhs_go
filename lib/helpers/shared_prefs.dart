import 'dart:convert';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../main.dart';

Position getCurrentPositionFromSharedPrefs() {
  return Position(prefs.getDouble('longitude')!, prefs.getDouble('latitude')!);
}

String getCurrentAddressFromSharedPrefs() {
  return prefs.getString('current-address')!;
}

Position getTripPositionFromSharedPrefs(String type) {
  List sourceLocationList = json.decode(prefs.getString('source')!)['location'];
  List destinationLocationList =
      json.decode(prefs.getString('destination')!)['location'];
  Position source = Position(
      sourceLocationList[1], sourceLocationList[0]);
  Position destination = Position(
      destinationLocationList[1], destinationLocationList[0]);

  if (type == 'source') {
    return source;
  } else {
    return destination;
  }
}

String getSourceAndDestinationPlaceText(String type) {
  String sourceAddress = json.decode(prefs.getString('source')!)['name'];
  String destinationAddress =
      json.decode(prefs.getString('destination')!)['name'];

  if (type == 'source') {
    return sourceAddress;
  } else {
    return destinationAddress;
  }
}
