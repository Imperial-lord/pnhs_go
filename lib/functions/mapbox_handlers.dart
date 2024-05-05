import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:pnhs_go/requests/mapbox_reverse_geocoding.dart';

import '../requests/mapbox_directions.dart';
import '../requests/openstreet_search.dart';

// ----------------------------- Mapbox Search Query -----------------------------
String getValidatedQueryFromQuery(String query) {
  // Remove whitespaces
  String validatedQuery = query.trim();
  return validatedQuery;
}

Future<List> getParsedResponseForQuery(String value) async {
  List parsedResponses = [];

  // If empty query send blank response
  String query = getValidatedQueryFromQuery(value);
  if (query == '') return parsedResponses;

  // Else search and then send response
  List features = await getSearchResultsFromQueryUsingMapbox(query);

  for (var feature in features) {
    Map response = {
      'name': feature['name'],
      'address': feature['display_name'].split('${feature['name']}, ')[1],
      'place': feature['display_name'],
      'location': Position(num.parse(feature['lon']), num.parse(feature['lat']))
    };
    parsedResponses.add(response);
  }
  return parsedResponses;
}

// ----------------------------- Mapbox Reverse Geocoding -----------------------------
Future<Map> getParsedReverseGeocoding(Position latLng) async {
  var response = await getReverseGeocodingGivenLatLngUsingMapbox(latLng);
  Map feature = response['features'][0];
  Map revGeocode = {
    'name': feature['text'],
    'address': feature['place_name'].split('${feature['text']}, ')[0],
    'place': feature['place_name'],
    'location': latLng
  };
  return revGeocode;
}

// ----------------------------- Mapbox Directions API -----------------------------
Future<Map> getDirectionsAPIResponse(
    Position sourcePosition, Position destinationPosition) async {
  final response =
      await getCyclingRouteUsingMapbox(sourcePosition, destinationPosition);
  Map geometry = response['routes'][0]['geometry'];
  num duration = response['routes'][0]['duration'];
  num distance = response['routes'][0]['distance'];

  Map modifiedResponse = {
    "geometry": geometry,
    "duration": duration,
    "distance": distance,
  };
  return modifiedResponse;
}

Position getCenterCoordinatesForPolyline(Map geometry) {
  List coordinates = geometry['coordinates'];
  int pos = (coordinates.length / 2).round();
  return Position(coordinates[pos][0], coordinates[pos][1]);
}
