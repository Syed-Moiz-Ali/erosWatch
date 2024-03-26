import 'package:flutter/material.dart';
// import 'package:eroswatch/components/bottom_navigatiom.dart';
import 'package:eroswatch/view/search/search_screen.dart';
import '../../helper/videos.dart';

class ViewContainer extends StatefulWidget {
  final String passedData;

  const ViewContainer({Key? key, required this.passedData}) : super(key: key);

  @override
  State<ViewContainer> createState() => _ContainerState();
}

class _ContainerState extends State<ViewContainer> {
  List<Videos> wallpapers = [];
  late Future<List<Videos>> futureWallpapers;
  List<Videos> favoriteWallpapers = [];
  int pageNumber = 1;
  bool isLoading = false;
  List<String> favorites = [];
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    // final APIService apiService = APIService(params: widget.passedData);

    // if (kDebugMode) {
    //   print(widget.passedData);
    // }
  }

  late String categTitle = widget.passedData.replaceAll("wall/", "");
  late String changeString = categTitle;
  double iconSize = 25.0;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final pages = [
      Search(
        searchText: categTitle,
        categ: 'trending',
        key: UniqueKey(),
      ),
      Search(
        searchText: categTitle,
        categ: 'popular',
        key: UniqueKey(),
      ),
      Search(
        searchText: categTitle,
        categ: 'upcoming',
        key: UniqueKey(),
      ),
      Search(
        searchText: categTitle,
        categ: 'new',
        key: UniqueKey(),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        // iconTheme: const IconThemeData(
        //   color: Colors.black,
        //   size: 30, // Set the color of the back button
        // ),
        shadowColor: Colors.transparent,
        title: Text(
          categTitle,
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Scaffold(
        body: Stack(
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
                              Icons.local_activity_rounded,
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
                              Icons.local_fire_department,
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
                              Icons.label_important,
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
                              Icons.new_releases_rounded,
                              size: iconSize,
                              color:
                                  pageIndex == 3 ? Colors.white : Colors.blue,
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
                left: 20,
                right: 20,
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
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildIconButtonWithText(
                        Icons.local_activity_rounded,
                        pageIndex == 0,
                        'Latest',
                        () {
                          setState(() {
                            pageIndex = 0;
                          });
                        },
                      ),
                      buildIconButtonWithText(
                        Icons.local_fire_department,
                        pageIndex == 1,
                        'Popular',
                        () {
                          setState(() {
                            pageIndex = 1;
                          });
                        },
                      ),
                      buildIconButtonWithText(
                        Icons.label_important,
                        pageIndex == 2,
                        'Upcoming',
                        () {
                          setState(() {
                            pageIndex = 2;
                          });
                        },
                      ),
                      buildIconButtonWithText(
                        Icons.new_releases_rounded,
                        pageIndex == 3,
                        'New',
                        () {
                          setState(() {
                            pageIndex = 3;
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
    );
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
      ),
    );
  }
}
