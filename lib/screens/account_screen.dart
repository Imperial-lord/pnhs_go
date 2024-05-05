import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:pnhs_go/helpers/misc_helpers.dart';
import 'package:pnhs_go/main.dart';
import 'package:pnhs_go/screens/auth_screen.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:shimmer/shimmer.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String name = prefs.getString('userName') ?? 'John Doe';
  String email = prefs.getString('userEmail') ?? 'john.doe@gmail.com';
  bool locationLoading = false;
  double latitude = prefs.getDouble('latitude') ?? 10.369;
  double longitude = prefs.getDouble('longitude') ?? 122.870;
  String lastKnownAddress =
      prefs.getString('current-address') ?? 'Pontevedra National High School';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SizedBox(
      height: MediaQuery.of(context).size.height,
      child: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (locationLoading) const LinearProgressIndicator(),
            if (locationLoading) const SizedBox(height: 10),
            Center(child: RandomAvatar(DateTime.now.toString(), height: 100)),
            const SizedBox(height: 20),
            Center(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                email,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Grade:'),
            const Text(
              'Grade 10 STE',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            const Text('Last Known Location:'),
            if (locationLoading)
              Shimmer(
                gradient: const LinearGradient(
                    colors: [Colors.grey, Colors.white, Colors.grey]),
                child: Container(height: 20, width: 200, color: Colors.grey),
              )
            else
              Text(
                'Latitude: $latitude, Longitude: $longitude',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            const SizedBox(height: 10),
            const Text('Last Known Address:'),
            if (locationLoading)
              Shimmer(
                gradient: const LinearGradient(
                    colors: [Colors.grey, Colors.white, Colors.grey]),
                child: Container(height: 60, color: Colors.grey),
              )
            else
              Text(
                lastKnownAddress,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  locationLoading = true;
                });
                doLocationRelationActions();
                Future.delayed(const Duration(seconds: 5), () {
                  setState(() {
                    locationLoading = false;
                    latitude = prefs.getDouble('latitude') ?? 10.369;
                    longitude = prefs.getDouble('longitude') ?? 122.870;
                    lastKnownAddress = prefs.getString('current-address') ??
                        'Pontevedra National High School';
                    // Also update on Firestore
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(prefs.getString('userId'))
                        .update({
                      'latitude': latitude,
                      'longitude': longitude,
                      'address': lastKnownAddress,
                    });
                  });
                });
              },
              icon: const Icon(Ionicons.locate),
              label: const Text('Update location',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
                onPressed: () {
                  prefs.remove('userName');
                  prefs.remove('userEmail');
                  prefs.remove('userId');
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                    (route) => false,
                  );
                },
                label: const Text('Sign Out',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                icon: const Icon(Ionicons.log_out),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.redAccent,
                )),
          ],
        ),
      )),
    ));
  }
}
