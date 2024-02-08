import 'package:flutter/material.dart';
import 'components/more_screen_body.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // iconTheme: const IconThemeData(
        //   color: Colors.blue,
        //   // size: 30, // Set the color of the back button
        // ),
        shadowColor: Colors.transparent,
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: Text(
            'More',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // backgroundColor: Colors.white,
      ),
      body: const MoreScreenBody(),
    );
  }
}
