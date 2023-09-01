import 'package:eroswatch/model/pages/setting_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:eroswatch/Stars/stars_screen.dart';

import 'package:eroswatch/model/Channels/channel_container.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:eroswatch/model/pages/favorites/fav_screen.dart';
import 'package:eroswatch/container_screen.dart';
import 'package:eroswatch/model/pages/tab_bar.dart';
import 'package:eroswatch/model/pages/tags/tags_container.dart';
// part 'components/bottom_navigatiom.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen>
    with TickerProviderStateMixin {
  int pageIndex = 0;
  final ScrollController _scrollController = ScrollController();
  List<String> favorites = [];
  double iconSize = 25.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {});
    });
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      favorites = prefs.getStringList('favorites') ?? [];
    });
  }

  final TextEditingController _searchController = TextEditingController();

  bool _isSearching = false;

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });
  }

  void _search() {
    String searchTerm = _searchController.text.trim();
    if (searchTerm.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewContainer(passedData: searchTerm),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    double screenWidth = MediaQuery.of(context).size.width;
    if (kDebugMode) {
      print(
        'Screen Width: ${screenSize.width.toStringAsFixed(2)}\nScreen Height: ${screenSize.height.toStringAsFixed(2)}',
      );
    }

    final pages = [
      const TabBarContainer(),
      const ChannelContainer(),
      const StarsScreen(),
      const FavScreen(),
      const TagsContainer()
    ];

    return Scaffold(
      backgroundColor: const Color(0x00000070),
      appBar: AppBar(
        title: _isSearching
            ? RawKeyboardListener(
                focusNode: FocusNode(),
                onKey: (RawKeyEvent event) {
                  if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                    _search();
                  }
                },
                child: TextField(
                  autofocus: true,
                  controller: _searchController,
                  onSubmitted: (_) => _search(),
                  decoration: InputDecoration(
                    hintText: 'Enter search term',
                    filled: false,
                    isCollapsed: true,
                    hintStyle: TextStyle(
                      color: Colors.blue.shade200,
                      fontWeight: FontWeight.w500,
                      fontSize: 18.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 16.0),
                  ),
                ),
              )
            : Text(
                _getAppBarTitle(pageIndex),
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
        leading: IconButton(
          icon: const Icon(
              Icons.account_circle), // Replace with your profile icon
          color: Colors.blue,
          onPressed: () {
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => SettingsScreen(),
              ),
            );
            // Handle profile icon click
          },
        ),
        actions: _getAppBarTitle(pageIndex) == 'Home'
            ? <Widget>[
                IconButton(
                  icon: AnimatedCrossFade(
                    firstChild: const Icon(Icons.search),
                    secondChild: const Icon(Icons.close),
                    crossFadeState: _isSearching
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 500),
                  ),
                  color: Colors.blue,
                  onPressed: () {
                    _toggleSearch();
                  },
                )
              ]
            : null,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.white,
      ),

      body: Align(
        alignment: Alignment.bottomCenter,
        child: Stack(
          children: [
            Row(
              children: [
                if (screenWidth >= 700)
                  Expanded(
                    child: SizedBox(
                      width: 250,
                      height: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                pageIndex = 0;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              backgroundColor:
                                  pageIndex == 0 ? Colors.blue : Colors.white,
                              padding: const EdgeInsets.all(20),
                              shadowColor: Colors.transparent,
                            ),
                            child: Icon(
                              Icons.home,
                              size: iconSize,
                              color:
                                  pageIndex == 0 ? Colors.white : Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 40),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                pageIndex = 1;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              backgroundColor:
                                  pageIndex == 1 ? Colors.blue : Colors.white,
                              padding: const EdgeInsets.all(22),
                              shadowColor: Colors.transparent,
                            ),
                            child: Icon(
                              Icons.chat_bubble_rounded,
                              size: iconSize,
                              color:
                                  pageIndex == 1 ? Colors.white : Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 40),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                pageIndex = 2;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              backgroundColor:
                                  pageIndex == 2 ? Colors.blue : Colors.white,
                              padding: const EdgeInsets.all(22),
                              shadowColor: Colors.transparent,
                            ),
                            child: Icon(
                              Icons.star_outline_outlined,
                              size: iconSize,
                              color:
                                  pageIndex == 2 ? Colors.white : Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 40),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                pageIndex = 3;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              backgroundColor:
                                  pageIndex == 3 ? Colors.blue : Colors.white,
                              padding: const EdgeInsets.all(22),
                              shadowColor: Colors.transparent,
                            ),
                            child: Icon(
                              Icons.favorite,
                              size: iconSize,
                              color:
                                  pageIndex == 3 ? Colors.white : Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 40),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                pageIndex = 4;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              backgroundColor:
                                  pageIndex == 4 ? Colors.blue : Colors.white,
                              padding: const EdgeInsets.all(22),
                              shadowColor: Colors.transparent,
                            ),
                            child: Icon(
                              Icons.tag,
                              size: iconSize,
                              color:
                                  pageIndex == 4 ? Colors.white : Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  flex: screenWidth >= 700 ? 7 : 1,
                  child: pages[pageIndex],
                ),
              ],
            ),
            if (screenWidth <= 700)
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildIconButtonWithText(
                        Icons.home,
                        pageIndex == 0,
                        'Home',
                        () {
                          setState(() {
                            pageIndex = 0;
                          });
                        },
                      ),
                      buildIconButtonWithText(
                        Icons.chat_bubble_rounded,
                        pageIndex == 1,
                        'Channels',
                        () {
                          setState(() {
                            pageIndex = 1;
                          });
                        },
                      ),
                      buildIconButtonWithText(
                        Icons.star_outline_outlined,
                        pageIndex == 2,
                        'Stars',
                        () {
                          setState(() {
                            pageIndex = 2;
                          });
                        },
                      ),
                      buildIconButtonWithText(
                        Icons.favorite,
                        pageIndex == 3,
                        'Favorites',
                        () {
                          setState(() {
                            pageIndex = 3;
                          });
                        },
                      ),
                      buildIconButtonWithText(
                        Icons.tag,
                        pageIndex == 4,
                        'Tags',
                        () {
                          setState(() {
                            pageIndex = 4;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),

      // pages[pageIndex],
    );
  }
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

String _getAppBarTitle(int currentIndex) {
  switch (currentIndex) {
    case 0:
      return 'Home';
    case 1:
      return 'Channels';
    case 2:
      return 'Stars';
    case 3:
      return 'Favorites';
    case 4:
      return 'Categories';

    default:
      return 'Home';
  }
}
