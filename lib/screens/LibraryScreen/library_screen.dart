
import 'package:flutter/material.dart';
import 'components/library_screen_body.dart';

class LibraryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LibraryScreen'),
      ),
      body: LibraryScreenBody(),
    );
  }
}
    