// ignore_for_file: file_names, must_be_immutable

import 'package:eroswatch/components/bottomNavigator.dart';
import 'package:eroswatch/screens/BrowseScreen/browse_screen.dart';
import 'package:eroswatch/screens/HistoryScreen/history_screen.dart';
import 'package:eroswatch/screens/LibraryScreen/library_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../components/api/firebase/database.dart';
import '../../providers/bottom_navigator_provider.dart';
import '../../screens/MoreScreen/more_screen.dart';

class MainScreen extends StatefulWidget {
  MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List bottomNavigatorItmes = [
    {'title': 'Library', 'icon': Icons.library_add, 'index': 0},
    {'title': 'History', 'icon': Icons.history, 'index': 1},
    {'title': 'Browse', 'icon': Icons.browse_gallery_outlined, 'index': 2},
    {'title': 'More', 'icon': Icons.more_vert_outlined, 'index': 3},
  ];

  final screens = [
    LibraryScreen(),
    const HistoryScreen(),
    const BrowseScreen(),
    const MoreScreen(),
  ];

  bool debugValue = false;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  fetch() async {
    debugValue = await FirebaseDatabaseService().isDebug();
  }

  @override
  Widget build(BuildContext context) {
    print('debugValue is $debugValue');
    var provider = Provider.of<BottomNavigatorProvider>(context, listen: true);
    return Scaffold(
      body:
          //  debugValue == true
          //     ? BrowseScreen()
          //     :
          WillPopScope(
        onWillPop: () async {
          print(
              'mainPreviousPagesHistory is ${provider.mainPreviousPagesHistory}');
          if (provider.mainPageIndex == 0 &&
              provider.mainPreviousPagesHistory.isEmpty) {
            showExitDialog(context);
          } else if (provider.mainPageIndex != 0 &&
              provider.mainPreviousPagesHistory.isEmpty) {
            provider.setmainPageIndex(0);
          } else {
            provider.mainPreviousPagesHistory.removeLast();
            if (provider.mainPreviousPagesHistory.isEmpty) {
              provider.setmainPageIndex(0);
            } else {
              provider.setmainPageIndex(provider.mainPreviousPagesHistory.last);
            }
          }
          return false;
        },
        child: IndexedStack(
          index: provider.mainPageIndex,
          children: screens,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: debugValue == true
          ? SizedBox.shrink()
          : BottomNavigator(
              // pageIndex: pageIndex,
              items: bottomNavigatorItmes,
              type: 'main'),
    );
  }

  void showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Exit App?',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to exit the app?',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16.0,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Perform exit action here
                SystemNavigator.pop(); // Close the dialog
              },
              child: const Text(
                'Exit',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
