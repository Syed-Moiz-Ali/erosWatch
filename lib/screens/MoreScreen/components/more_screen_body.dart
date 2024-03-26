// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:eroswatch/components/api/firebase/uploading_extensions.dart';
import 'package:flutter/material.dart';

import '../../../components/api/firebase/database.dart';
import '../../../view/setting/setting_page.dart';

class MoreScreenBody extends StatelessWidget {
  const MoreScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildStyledListTile(
          icon: Icons.settings,
          title: 'Settings',
          onTap: () {
            // Navigate to the settings screen
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SettingScreen()));
          },
        ),
        // _buildStyledListTile(
        //   icon: Icons.add,
        //   title: 'Add Icon',
        //   onTap: () {
        //     // Navigate to the add icon screen

        //     // _showPasswordDialog(context);
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (context) => const YourFormWidget()),
        //     );
        //   },
        // ),
        // Add more ListTiles for additional settings/icons as needed
      ],
    );
  }

  Widget _buildStyledListTile(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return Card(
      elevation: 4, // Adds a shadow to the ListTile
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(
          icon,
          size: 36, // Adjust the icon size
          color: Colors.blue, // Adjust the icon color
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87, // Adjust the title color
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Future<void> _showPasswordDialog(BuildContext context) async {
    String enteredPassword = '';

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.lock,
                color: Colors.blue,
              ),
              SizedBox(width: 8),
              Text('Enter Password '),
            ],
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                obscureText: true,
                onChanged: (value) {
                  enteredPassword = value;
                },
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Check if the password is correct (Replace 'your_password' with the actual correct password)
                      if (enteredPassword ==
                          await FirebaseDatabaseService().getPassword()) {
                        Navigator.of(context).pop(); // Close the dialog
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const YourFormWidget()),
                        );
                      } else {
                        // Show an error message or handle the incorrect password case
                        // For simplicity, this example just shows a print statement
                        print('Incorrect Password');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Incorrect Password'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
