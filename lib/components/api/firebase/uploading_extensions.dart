// ignore_for_file: library_private_types_in_public_api

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'database.dart';

class YourFormWidget extends StatefulWidget {
  const YourFormWidget({super.key});

  @override
  _YourFormWidgetState createState() => _YourFormWidgetState();
}

class _YourFormWidgetState extends State<YourFormWidget> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController baseUrlController = TextEditingController();
  XFile? iconFile;

  bool isSaving = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // iconTheme: const IconThemeData(
        //   color: Colors.blue,
        // ),
        shadowColor: Colors.transparent,
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: Text(
            'Add Extensions',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.blue.withOpacity(0.7), width: 1.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            // ElevatedButton(
            //   onPressed: () async {
            //     // Call the image picker to select an icon
            //     XFile? pickedFile =
            //         await ImagePicker().pickImage(source: ImageSource.gallery);
            //     setState(() {
            //       iconFile = pickedFile;
            //     });
            //   },
            //   style: ElevatedButton.styleFrom(
            //     foregroundColor: Colors.white,
            //     backgroundColor: Colors.blue,
            //     shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(10.0)),
            //   ),
            //   child: const Row(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       Icon(Icons.image),
            //       SizedBox(width: 8.0),
            //       Text('Pick Icon'),
            //     ],
            //   ),
            // ),

            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.image),
                SizedBox(width: 8.0),
                Text(
                  'Pick Icon',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            // Display the selected icon if available
            iconFile != null
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        iconFile = null;
                      });
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.file(
                        File(iconFile!.path),
                        height: 100.0,
                        width: 100.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: () async {
                      XFile? pickedFile = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      setState(() {
                        iconFile = pickedFile;
                      });
                    },
                    child: Container(
                        height: 100.0,
                        width: 100.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.grey,
                        ),
                        child: const Icon(
                          Icons.add_a_photo,
                          size: 35,
                          color: Colors.white,
                        )),
                  ),
            const SizedBox(height: 16.0),
            TextField(
              controller: baseUrlController,
              decoration: InputDecoration(
                labelText: 'Base URL',
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.blue.withOpacity(0.7), width: 1.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                // Call your saveExtension method with the entered data
                if (iconFile != null) {
                  setState(() {
                    isSaving = true;
                  });

                  await saveExtension();
                  setState(() {
                    isSaving = false;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1000.0)),
              ),
              child: SizedBox(
                height: 50,
                child: isSaving == true
                    ? const Center(
                        child: CircularProgressIndicator(
                        color: Colors.white,
                      ))
                    : const Center(
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> saveExtension() async {
    // Access the entered data using the controllers
    String title = titleController.text;
    // String icon =
    //     iconFile?.path ?? ''; // Use the file path if an icon is selected
    String baseUrl = baseUrlController.text;
    if (iconFile != null) {
      // Upload the icon to Firebase Storage
      String iconPath =
          'icons/${DateTime.now().millisecondsSinceEpoch}_${iconFile!.name}';
      Reference storageReference =
          FirebaseStorage.instance.ref().child(iconPath);
      await storageReference.putFile(File(iconFile!.path));

      // Get the download URL of the uploaded icon
      String iconDownloadURL = await storageReference.getDownloadURL();
      // Create an instance of FirebaseDatabaseService and call saveExtension
      FirebaseDatabaseService databaseService = FirebaseDatabaseService();
      Map<String, dynamic> extensionData = {
        'title': title,
        'icon': iconDownloadURL,
        'baseUrl': baseUrl,
      };
      await databaseService.saveExtension(extensionData);
      setState(() {
        titleController.clear();
        baseUrlController.clear();
        iconFile = null;
      });
    }
  }
}
