// ignore_for_file: avoid_print

import 'package:firebase_database/firebase_database.dart';

class FirebaseDatabaseService {
  final DatabaseReference debugRef = FirebaseDatabase.instance.ref('debug');
  final DatabaseReference _extensionsRef =
      FirebaseDatabase.instance.ref('extensions');
  final DatabaseReference _demoRef = FirebaseDatabase.instance.ref('demo');
  final DatabaseReference _passwordRef =
      FirebaseDatabase.instance.ref('passwordFolder');

  saveExtension(extensionData) async {
    try {
      bool isDebug = (await debugRef.child('isDebug').get()).value == true;
      DatabaseReference targetRef = isDebug ? _demoRef : _extensionsRef;

      await targetRef.push().set({
        'title': extensionData['title'],
        'icon': extensionData['icon'],
        'baseUrl': extensionData['baseUrl'],
      });

      print('extension saved to Firebase.');
    } catch (e) {
      print('Error saving extension to Firebase: $e');
    }
  }

  Future<bool> isDebug() async {
    DataSnapshot snapshot = await debugRef.child('isDebug').get();
    bool? isDebugValue = snapshot.value as bool?;
    return isDebugValue!; // If null, default to false
  }

  Future<bool> isNavigate() async {
    DataSnapshot snapshot = await debugRef.child('isNavigate').get();
    bool? isDebugValue = snapshot.value as bool?;
    return isDebugValue!; // If null, default to false
  }

  Future getExtension() async {
    try {
      bool isDebug = (await debugRef.child('isDebug').get()).value == true;
      DatabaseReference targetRef = isDebug ? _demoRef : _extensionsRef;

      DataSnapshot snapshot = await targetRef.get();

      if (snapshot.value != null) {
        var data = (snapshot.value! as Map?)?.cast<String, dynamic>();

        if (data is Map<String, dynamic>) {
          List extensions = [];

          data.forEach(
            (key, value) {
              extensions.add({'key': key, 'data': value});
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

  updateExtension(String key, Map<String, dynamic> updatedData) async {
    try {
      bool isDebug = (await debugRef.child('isDebug').get()).value == true;
      DatabaseReference targetRef = isDebug ? _demoRef : _extensionsRef;

      await targetRef.child(key).update(updatedData);

      print('Extension updated in Firebase.');
    } catch (e) {
      print('Error updating extension in Firebase: $e');
    }
  }

  // Delete an extension from Firebase
  Future deleteExtension(String key) async {
    try {
      bool isDebug = (await debugRef.child('isDebug').get()).value == true;
      DatabaseReference targetRef = isDebug ? _demoRef : _extensionsRef;

      await targetRef.child(key).remove();

      print('Extension deleted from Firebase.');
    } catch (e) {
      print('Error deleting extension from Firebase: $e');
    }
  }

  getPassword() async {
    try {
      DataSnapshot snapshot = await _passwordRef.get();

      if (snapshot.value != null) {
        var data = (snapshot.value! as Map?)?.cast<String, dynamic>();

        print('the data is $data');

        return data!['password'];
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
