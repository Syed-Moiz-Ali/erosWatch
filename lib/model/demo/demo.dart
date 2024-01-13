import 'dart:math';

import 'package:eroswatch/components/bottomNavigator.dart';
import 'package:eroswatch/components/smallComponents/image_compoenent.dart';
import 'package:eroswatch/screens/BrowseScreen/browse_screen.dart';
import 'package:eroswatch/screens/HistoryScreen/history_screen.dart';
import 'package:eroswatch/screens/LibraryScreen/library_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/api/firebase/uploading_extensions.dart';
import '../../providers/bottom_navigator_provider.dart';

class DemoPage extends StatelessWidget {
  DemoPage({Key? key});

  String generateRandomWord() {
    // List of random words
    List<String> words = [
      'apple',
      'banana',
      'chocolate',
      'dog',
      'elephant',
      'flutter',
      'giraffe',
      'happy',
      'island',
      'jazz',
      'kangaroo',
      'laptop',
      'moon',
      'notebook',
      'ocean',
      'penguin',
      'queen',
      'rainbow',
      'sunflower',
      'tiger',
      'umbrella',
      'victory',
      'watermelon',
      'xylophone',
      'yellow',
      'zeppelin',
    ];

    // Generate a random index
    Random random = Random();
    int randomIndex = random.nextInt(words.length);

    // Return the random word
    return words[randomIndex];
  }

  List bottomNavigatorItmes = [
    {'title': 'Library', 'icon': Icons.library_add, 'index': 0},
    {'title': 'History', 'icon': Icons.history, 'index': 1},
    {'title': 'Browse', 'icon': Icons.browse_gallery_outlined, 'index': 2},
    {'title': 'More', 'icon': Icons.more_vert_outlined, 'index': 3},
  ];
  final screens = [
    LibraryScreen(),
    HistoryScreen(),
    BrowseScreen(),
    YourFormWidget(),
  ];
  int pageIndex = 0;
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<BottomNavigatorProvider>(context, listen: true);
    return Scaffold(
      body: IndexedStack(
        index: provider.pageIndex,
        children: screens,
      ),
      // ListView.builder(
      //   itemCount: 14,
      //   itemBuilder: (context, index) {
      //     return Card(
      //       elevation: 2,
      //       margin: const EdgeInsets.all(8),
      //       child: Column(
      //         children: [
      //           Container(
      //             height: 200, // Set an explicit height
      //             child: const ImageComponent(
      //               imagePath:
      //                   'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTnSsLWVn6ZOrtsgl4lhc4C9DnRGk8ituA04w&usqp=CAU',
      //             ),
      //           ),
      //           Padding(
      //             padding: const EdgeInsets.all(8.0),
      //             child: Text(generateRandomWord()),
      //           ),
      //         ],
      //       ),
      //     );
      //   },
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: BottomNavigator(
        // pageIndex: pageIndex,
        items: bottomNavigatorItmes,
      ),
    );
  }
}
