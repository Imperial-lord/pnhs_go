import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:pnhs_go/screens/preview_screen.dart';
import 'package:pnhs_go/screens/search_screen.dart';
import 'package:pnhs_go/widgets/endpoints_widget.dart';

import '../functions/mapbox_handlers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  // Declare a static function to reference setters from children
  static _HomeScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<_HomeScreenState>();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = false;
  bool isEmptyResponse = true;
  bool hasResponded = false;
  bool isResponseForDestination = false;

  String noRequest = 'Please enter an address, a place or a location to search';
  String noResponse = 'No results found for the search';

  Map sourceMap = {}, destinationMap = {};

  List responses = [];
  TextEditingController sourceController = TextEditingController();
  TextEditingController destinationController = TextEditingController();

  // Define setters to be used by children widgets
  set responsesState(List responses) {
    setState(() {
      this.responses = responses;
      hasResponded = true;
      isEmptyResponse = responses.isEmpty;
    });
    Future.delayed(
      const Duration(milliseconds: 500),
      () => setState(() {
        isLoading = false;
      }),
    );
  }

  set isLoadingState(bool isLoading) {
    setState(() {
      this.isLoading = isLoading;
    });
  }

  set isResponseForDestinationState(bool isResponseForDestination) {
    setState(() {
      this.isResponseForDestination = isResponseForDestination;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PNHS Go!',
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
                'Enter your source and destination to get directions between classes, offices, etc.'),
            const SizedBox(height: 20),
            endpointsCard(sourceController, destinationController),
            const SizedBox(height: 20),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (hasResponded)
              if (isEmptyResponse)
                Text(noResponse)
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: responses.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          ListTile(
                            title: Text(responses[index]['name']),
                            subtitle: Text(responses[index]['address']),
                            onTap: () {
                              // Get the selected place
                              String selectedPlace = responses[index]['place'];
                              // Set the text editing controller to the selected place
                              if (isResponseForDestination) {
                                destinationController.text = selectedPlace;
                                destinationMap = responses[index];
                              } else {
                                sourceController.text = selectedPlace;
                                sourceMap = responses[index];
                              }
                              // Clear the responses
                              setState(() {
                                responses = [];
                                hasResponded = false;
                              });
                            },
                          ),
                          const Divider(),
                        ],
                      );
                    },
                  ),
                )
            else if (sourceMap.isNotEmpty && destinationMap.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(15),
                  ),
                  onPressed: () async {
                    Map directionsApiInfo = await getDirectionsAPIResponse(
                        sourceMap['location'], destinationMap['location']);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PreviewScreen(
                                sourceMap: sourceMap,
                                destinationMap: destinationMap,
                                directionsApiInfo: directionsApiInfo)));
                  },
                  label: const Text('Preview your trip'),
                  icon: const Icon(Ionicons.glasses),
                ),
              )
            else
              Text(noRequest),
            const Spacer(),
            Row(children: [
              Container(
                color: Colors.black,
                height: 1,
                width: 30,
              ),
              const Spacer(),
              const Text('See where others are at PNHS'),
              const Spacer(),
              Container(
                color: Colors.black,
                height: 1,
                width: 30,
              ),
            ]),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                ),
                onPressed: () {
                  // Navigate to the search screen
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SearchScreen()));
                },
                label: const Text('Find others on the app'),
                icon: const Icon(Ionicons.search),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
