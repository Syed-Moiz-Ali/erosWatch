// ignore_for_file: avoid_print

import 'package:eroswatch/global/globalFunctions.dart';
import 'package:eroswatch/providers/bottom_navigator_provider.dart';
import 'package:eroswatch/providers/cardProvider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:eroswatch/model/Stars/stars_screen.dart';

import 'package:eroswatch/model/Channels/channel_container.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:eroswatch/components/container/container_screen.dart';
import 'package:eroswatch/model/tabBar/tab_bar.dart';
import 'package:eroswatch/model/tags/tags_container.dart';

import 'components/api/api_service.dart';
import 'components/bottomNavigator.dart';
import 'helper/videos.dart';
// part 'components/bottom_navigatiom.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen>
    with TickerProviderStateMixin {
  // int provider.pageIndex = 0;
  final ScrollController _scrollController = ScrollController();
  List<String> favorites = [];
  double iconSize = 25.0;

  @override
  void initState() {
    super.initState();
    // setUserDetails();
    _scrollController.addListener(() {
      setState(() {});
    });
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    apiTags = APITags();
    fetchTags();
  }

  // Future<void> setUserDetails() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final promise = await account.get();
  //   await prefs.setString('userEmail', promise.email);
  //   await prefs.setString('userName', promise.name);
  //   if (kDebugMode) {
  //     print('userDetails has been set sucessfully');
  //   }
  // }

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
      // _searchController.clear();
      suggestions.clear();
      _isSearching = !_isSearching;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewContainer(passedData: searchTerm),
        ),
      );
    }
  }

  late APITags apiTags;
  List<String> allSuggestions = [];
  List<String> suggestions = [];
  bool isLoading = false;
  final int extraItems = 4;

  List bottomNavigatorItmes = [
    {'title': 'Home', 'icon': Icons.home, 'index': 0},
    {'title': 'Channels', 'icon': Icons.chat_bubble_rounded, 'index': 1},
    {'title': 'Stars', 'icon': Icons.star_outline_outlined, 'index': 2},
    // {'title': 'Favorites', 'icon': Icons.favorite, 'index': 3},
    {'title': 'Tags', 'icon': Icons.tag, 'index': 3},
  ];
  Future<void> fetchTags() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      final List<Tags> suggestion = await apiTags.fetchWallpapers();

      setState(() {
        for (var sugg in suggestion) {
          allSuggestions.add(sugg.title);
        }

        isLoading = false;
      });
      // print(tags);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (kDebugMode) {
        print('Failed to load tags: $e');
      }
    }
  }

  void _updateSuggestions(String query) {
    // Filter the list based on the user's input
    List<String> data = allSuggestions
        .where((element) => element.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      if (_searchController.text.isEmpty) {
        suggestions.clear();
      } else if (_searchController.text.isNotEmpty && suggestions.isEmpty) {
        suggestions.add("No Data Found");
      } else {
        suggestions = data;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<BottomNavigatorProvider>(context, listen: true);
    var cardProvider = Provider.of<CardProvider>(context, listen: true);

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
      // FavScreen(),
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
                  onChanged: (value) {
                    _updateSuggestions(value);
                  },
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
                _getAppBarTitle(context, provider.pageIndex),
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
        // leading: IconButton(
        //   icon: const Icon(
        //       Icons.account_circle), // Replace with your profile icon
        //   color: Colors.blue,
        //   onPressed: () {
        //     Navigator.push<void>(
        //       context,
        //       MaterialPageRoute<void>(
        //         builder: (BuildContext context) => const SettingScreen(),
        //       ),
        //     );
        //     // Handle profile icon click
        //   },
        // ),
        actions: _getAppBarTitle(context, provider.pageIndex) ==
                cardProvider.selectedScreenName
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

      body: WillPopScope(
        onWillPop: () async {
          if (provider.pageIndex == 0 &&
              provider.previousPagesHistory.isEmpty) {
            SMA.navigateBack(context);
          } else if (provider.pageIndex != 0 &&
              provider.previousPagesHistory.isEmpty) {
            provider.setPageIndex(0);
          } else {
            provider.previousPagesHistory.removeLast();
            if (provider.previousPagesHistory.isEmpty) {
              provider.setPageIndex(0);
            } else {
              provider.setPageIndex(provider.previousPagesHistory.last);
            }
          }
          // return false;
          return false;
        },
        child: Stack(
          children: [
            Row(children: [
              screenWidth >= 700
                  ? Expanded(
                      child: SizedBox(
                        width: 250,
                        height: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  provider.pageIndex = 0;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                backgroundColor: provider.pageIndex == 0
                                    ? Colors.blue
                                    : Colors.white,
                                padding: const EdgeInsets.all(20),
                                shadowColor: Colors.transparent,
                              ),
                              child: Icon(
                                Icons.home,
                                size: iconSize,
                                color: provider.pageIndex == 0
                                    ? Colors.white
                                    : Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 40),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  provider.pageIndex = 1;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                backgroundColor: provider.pageIndex == 1
                                    ? Colors.blue
                                    : Colors.white,
                                padding: const EdgeInsets.all(22),
                                shadowColor: Colors.transparent,
                              ),
                              child: Icon(
                                Icons.chat_bubble_rounded,
                                size: iconSize,
                                color: provider.pageIndex == 1
                                    ? Colors.white
                                    : Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 40),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  provider.pageIndex = 2;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                backgroundColor: provider.pageIndex == 2
                                    ? Colors.blue
                                    : Colors.white,
                                padding: const EdgeInsets.all(22),
                                shadowColor: Colors.transparent,
                              ),
                              child: Icon(
                                Icons.star_outline_outlined,
                                size: iconSize,
                                color: provider.pageIndex == 2
                                    ? Colors.white
                                    : Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 40),
                            // ElevatedButton(
                            //   onPressed: () {
                            //     setState(() {
                            //       provider.pageIndex = 3;
                            //     });
                            //   },
                            //   style: ElevatedButton.styleFrom(
                            //     shape: const CircleBorder(),
                            //     backgroundColor: provider.pageIndex == 3
                            //         ? Colors.blue
                            //         : Colors.white,
                            //     padding: const EdgeInsets.all(22),
                            //     shadowColor: Colors.transparent,
                            //   ),
                            //   child: Icon(
                            //     Icons.favorite,
                            //     size: iconSize,
                            //     color: provider.pageIndex == 3
                            //         ? Colors.white
                            //         : Colors.blue,
                            //   ),
                            // ),
                            const SizedBox(height: 40),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  provider.pageIndex = 3;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                backgroundColor: provider.pageIndex == 3
                                    ? Colors.blue
                                    : Colors.white,
                                padding: const EdgeInsets.all(22),
                                shadowColor: Colors.transparent,
                              ),
                              child: Icon(
                                Icons.tag,
                                size: iconSize,
                                color: provider.pageIndex == 3
                                    ? Colors.white
                                    : Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      flex: screenWidth >= 700 ? 7 : 1,
                      child: IndexedStack(
                        index: provider.pageIndex,
                        children: pages,
                      )),
            ]),
            if (suggestions.isNotEmpty) searchSuggestionContainer(),
            if (screenWidth <= 700) bottomNavigationBarForPhones(),
          ],
        ),
      ),

      // pages[provider.pageIndex],
    );
  }

  Widget bottomNavigationBarForPhones() {
    return Positioned(
        bottom: 10,
        left: 5,
        right: 5,
        child: BottomNavigator(items: bottomNavigatorItmes, type: 'subMain'));
  }

  Positioned searchSuggestionContainer() {
    return Positioned(
      top: 0,
      right: 0,
      left: 0,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 300, minHeight: 0),
        // height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListView.builder(
            shrinkWrap: true,
            // physics: const NeverScrollableScrollPhysics(),
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              return suggestionCard(index);
            },
          ),
        ),
      ),
    );
  }

  Widget suggestionCard(int index) {
    return GestureDetector(
      onTap: () {
        // Handle selection from suggestions
        print('Selected suggestion: ${suggestions[index]}');
        // You may want to clear the suggestions and update the TextField with the selected suggestion
        setState(() {
          _searchController.text = suggestions[index];
          suggestions.clear();
          // _isSearching = false;
        });
        _search();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(16),
        // decoration: BoxDecoration(
        //   borderRadius: BorderRadius.circular(12),
        //   gradient: const LinearGradient(
        //     begin: Alignment.topLeft,
        //     end: Alignment.bottomRight,
        //     colors: [Colors.blue, Colors.lightBlueAccent],
        //   ),
        //   boxShadow: [
        //     BoxShadow(
        //       color: Colors.grey.withOpacity(0.3),
        //       spreadRadius: 1,
        //       blurRadius: 4,
        //       offset: const Offset(0, 2),
        //     ),
        //   ],
        // ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              color: Colors.black,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                suggestions[index],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
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

String _getAppBarTitle(BuildContext context, int currentIndex) {
  var provider = Provider.of<CardProvider>(context, listen: true);
  switch (currentIndex) {
    case 0:
      return provider.selectedScreenName;
    case 1:
      return provider.selectedChannelName;
    case 2:
      return 'Stars';
    // case 3:
    //   return 'Favorites';
    case 3:
      return 'Categories';

    default:
      return 'Home';
  }
}
