import 'package:eroswatch/model/favorites/fav_screen.dart';
import 'package:flutter/material.dart';

class HistoryScreenBody extends StatelessWidget {
  const HistoryScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FavScreen(type: 'history'),
    );
  }
}
