import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pnhs_go/main.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late List trips;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchTrips();
  }

  Future<void> fetchTrips() async {
    // Get the userId from shared preferences
    String userId = prefs.getString('userId') ?? '';

    // Fetch trips from Firestore
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('trips')
        .where('userId', isEqualTo: userId)
        .get();

    // Extract trip data from query snapshot
    List tripList =
        querySnapshot.docs.map((DocumentSnapshot doc) => doc.data()).toList();

    setState(() {
      trips = tripList;
      loading = false;
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
              if (loading) const LinearProgressIndicator(),
              if (loading) const SizedBox(height: 10),
              const Text(
                'Your Trips',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Here are the trips you have taken with PNHS Go.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              if (loading)
                const Center(child: Text('Loading your trips...'))
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: trips.length,
                    itemBuilder: (BuildContext context, int index) {
                      debugPrint(trips.toString());
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10),
                          tileColor: Colors.purple.shade50,
                          title: Text(
                              '${trips[index]['sourceAddress']}  to  ${trips[index]['destinationAddress']}'),
                          subtitle: Text(DateFormat('yyyy-MM-dd kk:mm')
                              .format(trips[index]['timestamp'].toDate())),
                          trailing: Text('${trips[index]['distance']}  metres'),
                        ),
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
