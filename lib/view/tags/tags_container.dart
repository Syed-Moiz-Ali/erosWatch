import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:eroswatch/view/tags/tags_card.dart';

class TagsContainer extends StatefulWidget {
  const TagsContainer({super.key});

  @override
  State<TagsContainer> createState() => _TagsContainerState();
}

class _TagsContainerState extends State<TagsContainer> {
  String _selectedType = 'top';
  Key? _pageKey = UniqueKey();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          TagsCard(
            param: _selectedType,
            key: _pageKey,
          ),
        ],
      ),
      // floatingActionButton: Container(
      //   margin: const EdgeInsets.only(
      //     bottom: 60,
      //     right: 10,
      //   ),
      //   decoration: const BoxDecoration(
      //     color: Colors.blue,
      //     shape: BoxShape.circle,
      //   ),
      //   child: FloatingActionButton(
      // heroTag: UniqueKey(),
      //     // heroTag: 'float',
      //     onPressed: _openMenu,
      //     backgroundColor: Colors.blue,
      //     child: const Icon(
      //       Icons.menu,
      //       color: Colors.white,
      //     ),
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
              _buildTab(0, Icons.local_fire_department, 'Top'),
              _buildTab(1, Icons.all_inbox, 'All'),
            ],
          ),
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedType = value.toLowerCase(); // Update the selected type
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
      case 'top':
        return 0;
      case 'all':
        return 1;

      default:
        return 0; // Default to the first tab
    }
  }
}
