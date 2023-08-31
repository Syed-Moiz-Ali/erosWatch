import 'package:flutter/material.dart';
import '../model/pages/pages.dart';

class StarContainer extends StatefulWidget {
  final String passedData;
  final String name;

  const StarContainer({Key? key, required this.passedData, required this.name})
      : super(key: key);

  @override
  State<StarContainer> createState() => _ContainerState();
}

class _ContainerState extends State<StarContainer> {
  int pageIndex = 0;
  double iconSize = 25.0;
  Key? _pageKey = UniqueKey();

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

  @override
  Widget build(BuildContext context) {
    final pages = [
      PageScreen(id: widget.passedData, key: _pageKey, type: 'trending'),
      PageScreen(id: widget.passedData, key: _pageKey, type: 'popular'),
      PageScreen(id: widget.passedData, key: _pageKey, type: 'upcoming'),
      PageScreen(id: widget.passedData, key: _pageKey, type: 'new'),
    ];

    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
          size: 30, // Set the color of the back button
        ),
        shadowColor: Colors.transparent,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Text(
            widget.name,
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
                                _pageKey = UniqueKey();
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
                                _pageKey = UniqueKey();
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
                                _pageKey = UniqueKey();
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
                                _pageKey = UniqueKey();
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
                            _pageKey = UniqueKey();
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
                            _pageKey = UniqueKey();
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
                            _pageKey = UniqueKey();
                          });
                        },
                      ),
                      buildIconButtonWithText(
                        Icons.new_releases_outlined,
                        pageIndex == 3,
                        'New',
                        () {
                          setState(() {
                            pageIndex = 3;
                            _pageKey = UniqueKey();
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
