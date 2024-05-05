import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pnhs_go/helpers/misc_helpers.dart';
import 'package:pnhs_go/main.dart';
import 'package:pnhs_go/screens/auth_screen.dart';
import 'package:pnhs_go/screens/management_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    doLocationRelationActions();

    if(prefs.containsKey('userId')) {
      // If the user is already logged in, redirect to the home screen
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) {
          return const ManagementScreen();
        }));
      });
    } else {
      // If the user is not logged in, redirect to the auth screen
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) {
          return const AuthScreen();
        }));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/icon/school_icon.png', height: 100.0),
          const SizedBox(height: 20.0),
          Center(
            child: Text(
              'PNHS GO',
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
