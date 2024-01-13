
import 'package:flutter/material.dart';
import 'components/browse_screen_body.dart';

class BrowseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BrowseScreen'),
      ),
      body: BrowseScreenBody(),
    );
  }
}
    