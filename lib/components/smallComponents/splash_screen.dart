// ignore_for_file: library_private_types_in_public_api

import 'package:eroswatch/auth/localAuthChecker.dart';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    // Call the navigateToSecondScreen function after five seconds
    Future.delayed(const Duration(seconds: 5), navigateToSecondScreen);
  }

  // Function to navigate to the second screen
  void navigateToSecondScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LocalAuthChecker(),
      ),
    );
  }

  text(String text, double size, Color color) {
    return Text(
      text,
      style: TextStyle(color: color, fontSize: size),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // const double size = 30;
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
            // Row(
            //   children: [
            //     text('E', size, Colors.blue[300]!),
            //     text('r', size, Colors.blue[300]!),
            //     text('o', size, Colors.blue[300]!),
            //     text('s', size, Colors.blue[300]!),
            //     text('', size, Colors.blue[300]!),
            //     text('W', size, Colors.blue[300]!),
            //     text('a', size, Colors.blue[300]!),
            //     text('t', size, Colors.blue[300]!),
            //     text('c', size, Colors.blue[300]!),
            //     text('h', size, Colors.blue[300]!),
            //   ],
            // ),
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
