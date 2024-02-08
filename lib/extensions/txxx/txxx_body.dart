import 'package:eroswatch/extensions/txxx/components/mainContainer.dart';
import 'package:flutter/material.dart';

import '../../components/bottomNavigator.dart';

class TxxBody extends StatefulWidget {
  const TxxBody({super.key});

  @override
  State<TxxBody> createState() => _TxxBodyState();
}

class _TxxBodyState extends State<TxxBody> {
  List bottomNavigatorItmes = [
    {'title': 'Home', 'icon': Icons.home, 'index': 0},
    {'title': 'Channels', 'icon': Icons.chat_bubble_rounded, 'index': 1},
    {'title': 'Stars', 'icon': Icons.star_outline_outlined, 'index': 2},
    {'title': 'Favorites', 'icon': Icons.favorite, 'index': 3},
    {'title': 'Tags', 'icon': Icons.tag, 'index': 4},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const MainContainer(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: BottomNavigator(
        items: bottomNavigatorItmes,
      ),
    );
  }
}
