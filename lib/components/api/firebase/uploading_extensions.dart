import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'database.dart';

class YourFormWidget extends StatefulWidget {
  @override
  _YourFormWidgetState createState() => _YourFormWidgetState();
}

class _YourFormWidgetState extends State<YourFormWidget> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController baseUrlController = TextEditingController();
  XFile? iconFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                // Call the image picker to select an icon
                XFile? pickedFile =
                    await ImagePicker().pickImage(source: ImageSource.gallery);
                setState(() {
                  iconFile = pickedFile;
                });
              },
              child: Text('Pick Icon'),
            ),
            SizedBox(height: 16.0),
            // Display the selected icon if available
            iconFile != null
                ? Image.file(
                    File(iconFile!.path),
                    height: 100.0,
                    width: 100.0,
                    fit: BoxFit.cover,
                  )
                : Container(),
            SizedBox(height: 16.0),
            TextField(
              controller: baseUrlController,
              decoration: InputDecoration(labelText: 'Base URL'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Call your saveExtension method with the entered data
                saveExtension();
              },
              child: Text('Save'),
            ),
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
