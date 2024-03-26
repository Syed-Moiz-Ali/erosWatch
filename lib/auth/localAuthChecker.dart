// ignore_for_file: file_names

import 'package:eroswatch/auth/localauth.dart';
import 'package:eroswatch/view/mainScreen/mainScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthChecker extends StatefulWidget {
  const LocalAuthChecker({super.key});

  @override
  State<LocalAuthChecker> createState() => _LocalAuthCheckerState();
}

class _LocalAuthCheckerState extends State<LocalAuthChecker> {
  bool enableProtection = false;
  late SharedPreferences _prefs;
  @override
  void initState() {
    super.initState();
    _loadPreferences().then(
      (value) => navigateToSecondScreen(),
    );
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      enableProtection = _prefs.getBool('enableProtection') ?? false;
    });
  }

  void navigateToSecondScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              enableProtection ? const AuthPage() : MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
          child: SizedBox(
        height: 40,
        width: 40,
        child: CircularProgressIndicator(),
      ) // Show loader while checking for updates

          ),
    );
  }
}
