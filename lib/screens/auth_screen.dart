// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pnhs_go/screens/management_screen.dart';
import 'package:pnhs_go/screens/onboarding_screen.dart';

import '../main.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential authResult =
          await _auth.signInWithCredential(credential);

      if (authResult.user != null) {
        // Store authentication information in SharedPreferences
        prefs.setString('userId', authResult.user!.uid);
        prefs.setString('userName', authResult.user!.displayName!);
        prefs.setString('userEmail', authResult.user!.email!);

        if (prefs.getString('userGrade') == null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const OnboardingScreen();
          }));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const ManagementScreen();
          }));
        }
      } else {
        throw Exception('User is null');
      }
    } catch (error) {
      debugPrint(error.toString());
      // show a banner to inform the user that an error occurred
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication error occurred. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Image(
            image: AssetImage('assets/image/auth_background.jpeg'),
            fit: BoxFit.cover,
            height: double.infinity,
          ),
          Container(
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: FractionalOffset.topCenter,
                end: FractionalOffset.bottomCenter,
                colors: [
                  Colors.black.withOpacity(1),
                  Colors.black.withOpacity(0.0),
                  Colors.white.withOpacity(0.0),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Navigate PNHS with ease!',
                      style:
                          Theme.of(context).textTheme.displayMedium!.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your one-stop app for all navigation in Pontevedra National High School.',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Colors.purple.shade100,
                          fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _signInWithGoogle(context),
                      icon: const Padding(
                        padding: EdgeInsets.all(5),
                        child: Image(
                          image: AssetImage('assets/icon/google_icon.png'),
                          height: 24,
                        ),
                      ),
                      label: const Text('Sign in with Google',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.all(10),
                        minimumSize: const Size(double.infinity, 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
