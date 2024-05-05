// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pnhs_go/screens/home_screen.dart';

import '../functions/mapbox_handlers.dart';

class LocationFieldWidget extends StatefulWidget {
  final bool isDestination;
  final TextEditingController textEditingController;

  const LocationFieldWidget({
    super.key,
    required this.isDestination,
    required this.textEditingController,
  });

  @override
  State<LocationFieldWidget> createState() => _LocationFieldWidgetState();
}

class _LocationFieldWidgetState extends State<LocationFieldWidget> {
  Timer? searchOnStoppedTyping;
  String query = '';

  _onChangeHandler(value) {
    // Set isLoading = true in parent
    HomeScreen.of(context)?.isLoading = true;

    // Make sure that requests are not made
    // until 1 second after the typing stops
    if (searchOnStoppedTyping != null) {
      setState(() => searchOnStoppedTyping?.cancel());
    }
    setState(() => searchOnStoppedTyping =
        Timer(const Duration(milliseconds: 500), () => _searchHandler(value)));
  }

  _searchHandler(String value) async {
    // unset the maps in parent
    if (widget.isDestination) {
      HomeScreen.of(context)?.destinationMap = {};
    } else {
      HomeScreen.of(context)?.sourceMap = {};
    }

    // Get response using Mapbox Search API
    List response = await getParsedResponseForQuery(value);

    // Set responses and isDestination in parent
    HomeScreen.of(context)?.responsesState = response;
    HomeScreen.of(context)?.isResponseForDestinationState =
        widget.isDestination;
    setState(() => query = value);
  }

  _useCurrentLocationButtonHandler() async {
    // if (!widget.isDestination) {
    //   LatLng currentLocation = getCurrentLatLngFromSharedPrefs();

    //   // Get the response of reverse geocoding and do 2 things:
    //   // 1. Store encoded response in shared preferences
    //   // 2. Set the text editing controller to the address
    //   var response = await getParsedReverseGeocoding(currentLocation);
    //   prefs.setString('source', json.encode(response));
    //   String place = response['place'];
    //   widget.textEditingController.text = place;
    // }
  }

  @override
  Widget build(BuildContext context) {
    String placeholderText = widget.isDestination ? 'Where to?' : 'Where from?';
    IconData? iconData = !widget.isDestination ? Icons.my_location : null;
    return CupertinoTextField(
      padding: const EdgeInsets.all(15),
      controller: widget.textEditingController,
      placeholder: placeholderText,
      placeholderStyle: const TextStyle(color: Colors.black54),
      onChanged: _onChangeHandler,
      // suffix: IconButton(
      //   onPressed: () => _useCurrentLocationButtonHandler(),
      //   padding: const EdgeInsets.all(10),
      //   constraints: const BoxConstraints(),
      //   icon: Icon(iconData, size: 16),
      // ),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
    );
  }
}
