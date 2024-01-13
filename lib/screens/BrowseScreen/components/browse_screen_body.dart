// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../components/api/firebase/database.dart';
import '../../../videos_screen.dart';

class BrowseScreenBody extends StatelessWidget {
  BrowseScreenBody({super.key});

  FirebaseDatabaseService databaseService = FirebaseDatabaseService();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: databaseService.getExtension(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          dynamic extensions = snapshot.data ?? [];

          return ListView.builder(
            itemCount: extensions.length,
            itemBuilder: (context, index) {
              var extension = extensions[index];

              return GestureDetector(
                onTap: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();

                  await prefs.setString('baseUrl', extension['baseUrl']);
                  await Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => const VideoScreen(),
                    ),
                  );
                },
                child: ListTile(
                  title: Text('Title: ${extension['title']}'),
                  subtitle: Text('Base URL: ${extension['baseUrl']}'),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(2000),
                    child: Image.network(extension['icon'],
                        width: 60, height: 60, fit: BoxFit.cover),
                  ),
                  // You can display other fields as well
                ),
              );
            },
          );
        }
      },
    );

    // ListView.builder(
    //   itemCount: extensions.length,
    //   itemBuilder: (context, index) {
    //     var item = extensions[index];
    //     return

    //     GestureDetector(
    //       onTap: () async {
    //         SharedPreferences prefs = await SharedPreferences.getInstance();
    //         await prefs.setString('selectedType', item['title']);
    //         final firebaseDatabaseService = FirebaseDatabaseService();
    //         final getBaseURL = await firebaseDatabaseService.getBaseUrl();
    //         await prefs.setString('baseUrl', getBaseURL);
    //         await Navigator.push(
    //           context,
    //           MaterialPageRoute<void>(
    //             builder: (BuildContext context) => const VideoScreen(),
    //           ),
    //         );
    //       },
    //       child: Column(
    //         children: [
    //           Container(
    //             height: 100,
    //             // color: Colors.red,
    //             child: Row(
    //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //               children: [
    //                 Row(
    //                   mainAxisAlignment: MainAxisAlignment.start,
    //                   children: [
    //                     ClipRRect(
    //                       borderRadius: BorderRadius.circular(4000),
    //                       child: Image.network(
    //                         item['icon'],
    //                         height: 60,
    //                         width: 60,
    //                         fit: BoxFit.cover,
    //                       ),
    //                     ),
    //                     const SizedBox(width: 16),
    //                     Text(item['title'])
    //                   ],
    //                 ),
    //                 const Text('version'),
    //               ],
    //             ),
    //           ),
    //           const SizedBox(
    //             height: 6,
    //           ),
    //         ],
    //       ),
    //     );
    //   },
    // );
  }
}
