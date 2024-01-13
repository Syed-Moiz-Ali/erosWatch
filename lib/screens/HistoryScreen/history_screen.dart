
import 'package:flutter/material.dart';
import 'components/history_screen_body.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HistoryScreen'),
      ),
      body: HistoryScreenBody(),
    );
  }
}
    