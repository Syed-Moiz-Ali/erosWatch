// part of "../videos_screen.dart";

// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class BottomNavigation extends StatefulWidget {
  int pageIndex;
  String type;
  BottomNavigation({super.key, required this.pageIndex, this.type = ''});
  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  @override
  Widget build(BuildContext context) {
    // double screenWidth = MediaQuery.of(context).size.width;
    // double iconSize = 25.0;

    return Positioned(
      bottom: 10,
      left: 15,
      right: 15,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(50.0),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        // padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
        child: widget.type == ''
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildIconButtonWithText(
                    Icons.home,
                    widget.pageIndex == 0,
                    'Home',
                    () {
                      setState(() {
                        widget.pageIndex = 0;
                      });
                    },
                  ),
                  buildIconButtonWithText(
                    Icons.chat_bubble_rounded,
                    widget.pageIndex == 1,
                    'Channels',
                    () {
                      setState(() {
                        widget.pageIndex = 1;
                      });
                    },
                  ),
                  buildIconButtonWithText(
                    Icons.star_outline_outlined,
                    widget.pageIndex == 2,
                    'Stars',
                    () {
                      setState(() {
                        widget.pageIndex = 2;
                      });
                    },
                  ),
                  buildIconButtonWithText(
                    Icons.favorite,
                    widget.pageIndex == 3,
                    'Favorites',
                    () {
                      setState(() {
                        widget.pageIndex = 3;
                      });
                    },
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildIconButtonWithText(
                    Icons.local_activity_rounded,
                    widget.pageIndex == 0,
                    'Latest',
                    () {
                      setState(() {
                        widget.pageIndex = 0;
                      });
                    },
                  ),
                  buildIconButtonWithText(
                    Icons.local_fire_department,
                    widget.pageIndex == 1,
                    'Popular',
                    () {
                      setState(() {
                        widget.pageIndex = 1;
                      });
                    },
                  ),
                  buildIconButtonWithText(
                    Icons.label_important,
                    widget.pageIndex == 2,
                    'Upcoming',
                    () {
                      setState(() {
                        widget.pageIndex = 2;
                      });
                    },
                  ),
                  buildIconButtonWithText(
                    Icons.new_releases_rounded,
                    widget.pageIndex == 3,
                    'New',
                    () {
                      setState(() {
                        widget.pageIndex = 3;
                      });
                    },
                  ),
                ],
              ),
      ),
    );
  }

  Widget buildIconButtonWithText(
      IconData icon, bool isSelected, String label, VoidCallback onPressed) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onPressed,
          
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2000),
            ),
            backgroundColor: !isSelected ? Colors.blue : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shadowColor: Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 23,
                color: !isSelected ? Colors.white : Colors.blue,
              ),
              Visibility(
                visible: isSelected,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    label,
                    style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
