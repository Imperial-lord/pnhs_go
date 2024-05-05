import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:pnhs_go/main.dart';
import 'package:pnhs_go/screens/management_screen.dart';
import 'package:random_avatar/random_avatar.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String name = prefs.getString('userName') ?? 'John Doe';
  String email = prefs.getString('userEmail') ?? 'john.doe@gmail.com';
  String address =
      prefs.getString('current-address') ?? 'Pontevedra National High School';
  TextEditingController gradeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: RandomAvatar(DateTime.now.toString(), height: 100)),
              const SizedBox(height: 20),
              Text('Hi, $name!',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text(
                  'We are almost done setting up your account... We even went ahead and assigned you a random avatar!'),
              const SizedBox(height: 20),
              const Text('We found the following information about you:'),
              const SizedBox(height: 10),
              Text('Email: $email'),
              Text('Address: $address'),
              const SizedBox(height: 20),
              const Text('One last thing. Please enter your grade below.'),
              const SizedBox(height: 10),
              CupertinoTextField(
                placeholder: 'For eg. Grade 12 - STEM 1',
                padding: const EdgeInsets.all(15),
                controller: gradeController,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                    onPressed: () {
                      // Save all the information to firestore
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(prefs.getString('userUid'))
                          .set({
                        'name': name,
                        'email': email,
                        'latitude': prefs.getDouble('latitude') ?? 10.36908,
                        'longitude': prefs.getDouble('longitude') ?? 122.86964,
                        'address': address,
                        'grade': gradeController.text,
                      });
                      // Save the grade to the shared preferences
                      prefs.setString('userGrade', gradeController.text);
                      // Redirect to the home screen
                      Navigator.pushReplacement(context,
                          CupertinoPageRoute(builder: (context) {
                        return const ManagementScreen();
                      }));
                    },
                    icon: const Icon(Ionicons.checkbox),
                    label: const Text('Finish Setup'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(15),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
