// ignore_for_file: library_private_types_in_public_api, must_be_immutable

import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:eroswatch/model/pages/pages.dart';

class TabBarContainer extends StatefulWidget {
  const TabBarContainer({
    Key? key,
  }) : super(key: key);

  @override
  _TabBarContainerState createState() => _TabBarContainerState();
}

class _TabBarContainerState extends State<TabBarContainer> {
  String _selectedType = 'trending_videos';
  Key? _pageKey = UniqueKey(); // Key to force page refresh

  // final List<Widget> _pages = [
  //   const PageScreen(type: 'trending'),
  //   const PageScreen(type: 'popular'),
  //   const PageScreen(type: 'upcoming'),
  //   const PageScreen(type: 'new'),
  // ];

  @override
  void initState() {
    super.initState();
    // Initialize the _pages list based on _selectedType
    // _pages[0] = const PageScreen(type: 'trending');
    // _pages[1] = const PageScreen(type: 'popular');
    // _pages[2] = const PageScreen(type: 'upcoming');
    // _pages[3] = const PageScreen(type: 'new');
  }

  switchCase(text) {
    switch (text) {
      case 'Trending':
        return 'trending_videos';

      case 'Popular':
        return 'most_popular';
      case 'Upcoming':
        return 'upcoming';
      case 'New':
        return 'new_videos';

      default:
        return 'trending_videos';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageScreen(
              type: _selectedType,
              key: _pageKey,
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(
          bottom: 60,
          right: 10,
        ),
        decoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        child: FloatingActionButton(
          // heroTag: 'float',
          onPressed: _openMenu,
          backgroundColor: Colors.blue,
          child: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _openMenu() {
    showModalBottomSheet(
      useSafeArea: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTab(0, Icons.label_outline, 'Trending'),
              _buildTab(1, Icons.local_fire_department, 'Popular'),
              _buildTab(2, Icons.upcoming_outlined, 'Upcoming'),
              _buildTab(3, Icons.new_releases_outlined, 'New'),
            ],
          ),
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedType = switchCase(value); // Update the selected type
          _pageKey = UniqueKey();
        });
        if (kDebugMode) {
          print('Selected option: $value');
        }
      }
    });
  }

  Widget _buildTab(int index, IconData icon, String title) {
    final isSelected = index == _selectedTabIndex;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = title.toLowerCase();
          Navigator.pop(context, title); // Pass the selected title
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[200] : Colors.transparent,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            size: 24,
            color: isSelected ? Colors.blue : Colors.grey[600],
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  int get _selectedTabIndex {
    switch (_selectedType) {
      case 'trending_videos':
        return 0;
      case 'most_popular':
        return 1;
      case 'upcoming':
        return 2;
      case 'new_videos':
        return 3;
      default:
        return 0; // Default to the first tab
    }
  }
}
