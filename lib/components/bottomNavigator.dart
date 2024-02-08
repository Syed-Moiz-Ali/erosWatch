// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable, file_names, avoid_print
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/bottom_navigator_provider.dart';

class BottomNavigator extends StatefulWidget {
  dynamic type;
  List items;
  BottomNavigator({
    Key? key,
    this.type,
    this.items = const [],
  }) : super(key: key);

  @override
  State<BottomNavigator> createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<BottomNavigatorProvider>(context, listen: true);
    return Container(
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
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        child:

            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     buildIconButtonWithText(
            //       Icons.home,
            //       widget.pageIndex == 0,
            //       'Home',
            //       () {
            //         setState(() {
            //           widget.pageIndex = 0;
            //         });
            //       },
            //     ),
            //     buildIconButtonWithText(
            //       Icons.chat_bubble_rounded,
            //       widget.pageIndex == 1,
            //       'Channels',
            //       () {
            //         setState(() {
            //           widget.pageIndex = 1;
            //         });
            //       },
            //     ),
            //     buildIconButtonWithText(
            //       Icons.star_outline_outlined,
            //       widget.pageIndex == 2,
            //       'Stars',
            //       () {
            //         setState(() {
            //           widget.pageIndex = 2;
            //         });
            //       },
            //     ),
            //     buildIconButtonWithText(
            //       Icons.favorite,
            //       widget.pageIndex == 3,
            //       'Favorites',
            //       () {
            //         setState(() {
            //           widget.pageIndex = 3;
            //         });
            //       },
            //     ),
            //     buildIconButtonWithText(
            //       Icons.tag,
            //       widget.pageIndex == 4,
            //       'Tags',
            //       () {
            //         setState(() {
            //           widget.pageIndex = 4;
            //         });
            //       },
            //     ),
            //   ],
            // ),

            // GridView.builder(
            //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //         crossAxisCount: widget.items.length),
            //     itemCount: widget.items.length,
            //     itemBuilder: (context, index) {
            //       var navigationItem = widget.items[index];
            //       return buildIconButtonWithText(
            //         navigationItem['icon'],
            //         widget.pageIndex == navigationItem['index'],
            //         navigationItem['title'],
            //         () {
            //           setState(() {
            //             widget.pageIndex = navigationItem['index'];
            //           });
            //         },
            //       );
            //     }),

            Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: widget.items.map((navigationItem) {
            return buildIconButtonWithText(
              navigationItem['icon'],
              widget.type == 'main'
                  ? provider.mainPageIndex == navigationItem['index']
                  : provider.pageIndex == navigationItem['index'],
              navigationItem['title'],
              () {
                setState(() {
                  widget.type == 'main'
                      ? {
                          provider.setmainPageIndex(navigationItem['index']),
                          provider.setMainPreviousPagesHistory(
                              navigationItem['index'])
                        }
                      : {
                          provider.setPageIndex(navigationItem['index']),
                          provider
                              .setPreviousPagesHistory(navigationItem['index'])
                        };
                });
                print('mainprovider is ${provider.mainPageIndex}');
                print(
                    'mainPreviousPagesHistory is ${provider.mainPreviousPagesHistory}');
                print('submainprovider is  ${provider.pageIndex}');
              },
            );
          }).toList(),
        ));
  }

  Widget buildIconButtonWithText(
      IconData icon, bool isSelected, String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2000),
              ),
              backgroundColor: !isSelected ? Colors.blue : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              shadowColor: Colors.transparent,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: !isSelected ? Colors.white : Colors.blue,
                ),
                Visibility(
                  visible: isSelected,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Text(
                      label,
                      style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
