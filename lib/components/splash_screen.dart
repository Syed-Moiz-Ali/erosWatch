import 'package:eroswatch/components/inapp_update.dart';
import 'package:flutter/material.dart';
import 'package:eroswatch/helper/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late SharedPreferences _prefs;
  bool enableProtection = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    // Call the navigateToSecondScreen function after five seconds
    Future.delayed(const Duration(seconds: 5), navigateToSecondScreen);
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      enableProtection = _prefs.getBool('enableProtection') ?? false;
    });
  }

  // Function to navigate to the second screen
  void navigateToSecondScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            enableProtection ? const AuthPage() : const UpdateScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: 'logo', // Add a unique tag for the Hero animation
              child: Image.asset(
                'assets/images/logo.jpg',
                width: 320,
                height: 220,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: screenWidth / 2.2,
            child: const Center(
              child: SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                  strokeWidth: 3.0,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
