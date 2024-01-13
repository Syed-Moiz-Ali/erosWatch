// ignore_for_file: avoid_print

import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseDatabaseService {
  final DatabaseReference _remindersRef =
      FirebaseDatabase.instance.ref('extensions');

  saveExtension(extensionData) async {
    try {
      await _remindersRef.push().set({
        'title': extensionData['title'],
        'icon': extensionData['icon'],
        'baseUrl': extensionData['baseUrl'],
      });

      print('extension saved to Firebase.');
    } catch (e) {
      print('Error saving extension to Firebase: $e');
    }
  }

  Future getExtension() async {
    try {
      DataSnapshot snapshot = await _remindersRef.get();

      if (snapshot.value != null) {
        var data = (snapshot.value! as Map?)?.cast<String, dynamic>();

        if (data is Map<String, dynamic>) {
          List extensions = [];

          data.forEach(
            (key, value) {
              extensions.add(value);
            },
          );

          return extensions;
        } else {
          print('Invalid data format in Firebase.');
          return [];
        }
      } else {
        print('No data found in Firebase.');
        return [];
      }
    } catch (e) {
      print('Error fetching reminders from Firebase: $e');
      return [];
    }
  }

  getBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var type = prefs.getString('selectedType');
    try {
      DataSnapshot snapshot = await _remindersRef.get();

      if (snapshot.value != null) {
        var data = (snapshot.value! as Map?)?.cast<String, dynamic>();

        print('the data is $data');

        return data!['${type}Url'];
      } else {
        print('Invalid data format in Firebase.');
        return {};
      }
    } catch (e) {
      print('Error fetching reminders from Firebase: $e');
      return {};
    }
  }
}
