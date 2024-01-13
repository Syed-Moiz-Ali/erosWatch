import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:eroswatch/model/Channels/channel_screen.dart';

class ChannelContainer extends StatefulWidget {
  const ChannelContainer({
    Key? key,
  }) : super(key: key);

  @override
  State<ChannelContainer> createState() => _ContainerState();
}

class _ContainerState extends State<ChannelContainer> {
  String _selectedType = 'popular';
  Key? _pageKey = UniqueKey(); // Key to force page refresh

  @override
  void initState() {
    super.initState();
    // final APIService apiService = APIService(params: widget.passedData);

    // if (kDebugMode) {
    //   print(widget.passedData);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ChannelScreen(
              param: _selectedType,
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
              _buildTab(0, Icons.local_fire_department, 'Popular'),
              _buildTab(1, Icons.hotel_class, 'Hot'),
              _buildTab(2, Icons.new_releases_outlined, 'New'),
              _buildTab(3, Icons.sort_by_alpha_rounded, 'Name'),
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
      case 'popular':
        return 0;
      case 'hot':
        return 1;
      case 'new':
        return 2;
      case 'name':
        return 3;
      default:
        return 0; // Default to the first tab
    }
  }
}
