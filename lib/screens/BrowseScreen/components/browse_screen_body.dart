// ignore_for_file: must_be_immutable, use_build_context_synchronously, avoid_print

import 'package:eroswatch/extensions/txxx/txxx.dart';
import 'package:eroswatch/global/globalFunctions.dart';
import 'package:eroswatch/providers/bottom_navigator_provider.dart';
import 'package:eroswatch/screens/BrowseScreen/components/demo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../components/api/firebase/database.dart';
import '../../../videos_screen.dart';

class BrowseScreenBody extends StatefulWidget {
  const BrowseScreenBody({super.key});

  @override
  State<BrowseScreenBody> createState() => _BrowseScreenBodyState();
}

class _BrowseScreenBodyState extends State<BrowseScreenBody> {
  FirebaseDatabaseService databaseService = FirebaseDatabaseService();
  bool debugValue = false;
  bool isNavigate = false;
  final Map<String, Widget> _typeToWidget = {
    'spankbang': const VideoScreen(),
    'txxx': const Txxx(),
    'vjav': const VideoScreen(),
    'tube': const VideoScreen(),
  };

  Widget handleNavigation(String type) {
    if (_typeToWidget.containsKey(type)) {
      return _typeToWidget[type]!;
    } else {
      // Handle the default case or return a default widget
      return const Txxx();
    }
  }

  @override
  void initState() {
    super.initState();
    fetch();
  }

  fetch() async {
    debugValue = await FirebaseDatabaseService().isDebug();
    isNavigate = await FirebaseDatabaseService().isNavigate();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<BottomNavigatorProvider>(context, listen: false);
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh the data when the user pulls to refresh
        await databaseService.getExtension();
      },
      child: FutureBuilder(
        future: databaseService.getExtension(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List extensions = snapshot.data ?? [];
            String baseUrl = 'https://spankbang.party';
            String title = 'Spankbang';

            return extensions.isEmpty
                ? const Center(
                    child: Text(
                    'No extensions are added',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ))
                : GestureDetector(
                    onTap: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();

                      await prefs.setString('baseUrl', baseUrl);
                      await prefs.setString('title', title);

                      provider.pageIndex = 0;
                      await SMA.navigateTo(
                          context,
                          // handleNavigation(extensionItem['data']['title'])
                          // isNavigate == true
                          //     ? MyHomePage()
                          //     :
                          const VideoScreen());
                    },
                    child: ListTile(
                      title: Text(title),
                      subtitle: Text(baseUrl),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2000),
                            border: Border.all(color: Colors.red, width: 1)),
                        child: Image.asset('assets/images/logo.png',
                            fit: BoxFit.cover),
                      ),
                      // trailing: IconButton(
                      //   icon: const Icon(Icons.delete),
                      //   onPressed: () async {
                      //     await databaseService
                      //         .deleteExtension(extensionItem['key'])
                      //         .then(
                      //           (_) => databaseService.getExtension(),
                      //         );
                      //     setState(() {});
                      //   },
                      // )
                      // You can display other fields as well
                    ),
                  );

            // ListView.builder(
            //     itemCount: extensions.length,
            //     itemBuilder: (context, index) {
            //       var extensionItem = extensions[index];
            //       print('extensionItem is $extensionItem');
            //       return
            //       GestureDetector(
            //         onTap: () async {
            //           SharedPreferences prefs =
            //               await SharedPreferences.getInstance();

            //           await prefs.setString(
            //               'baseUrl', extensionItem['data']['baseUrl']);
            //           await prefs.setString(
            //               'title', extensionItem['data']['title']);

            //           provider.pageIndex = 0;
            //           await SMA.navigateTo(
            //               context,
            //               // handleNavigation(extensionItem['data']['title'])
            //               // isNavigate == true
            //               //     ? MyHomePage()
            //               //     :
            //               VideoScreen());
            //         },
            //         child:
            //         ListTile(
            //           title: Text('${extensionItem['data']['title']}'),
            //           subtitle: Text('${extensionItem['data']['baseUrl']}'),
            //           leading: ClipRRect(
            //             borderRadius: BorderRadius.circular(2000),
            //             child: Image.network(extensionItem['data']['icon'],
            //                 width: 60, height: 60, fit: BoxFit.contain),
            //           ),
            //           // trailing: IconButton(
            //           //   icon: const Icon(Icons.delete),
            //           //   onPressed: () async {
            //           //     await databaseService
            //           //         .deleteExtension(extensionItem['key'])
            //           //         .then(
            //           //           (_) => databaseService.getExtension(),
            //           //         );
            //           //     setState(() {});
            //           //   },
            //           // )
            //           // You can display other fields as well
            //         ),
            //       );
            //     },
            //   );
          }
        },
      ),
    );
  }
}
