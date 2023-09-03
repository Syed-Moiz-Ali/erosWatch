// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:eroswatch/services/appwrite.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late String name;
  String updatename = '';
  late String email;
  String updateemail = '';
  late String phoneNumber;
  String updatephoneNumber = '';
  bool isLoading = true;
  bool isSubscribed = false;
  late bool isTextFieldEnabled;
  Uint8List? avatarImage;
  bool isNSFWEnabled = false;
  bool isLocked = false;
  bool isNSFWToggled = false; // New variable to track NSFW switch toggle
  bool isLockedToggled = false; // New variable to track NSFW switch toggle
  late final PackageInfo packageInfo;
  final String contactEmail = 'shinten812@gmail.com';

  @override
  void initState() {
    super.initState();
    name = 'test';
    email = "test@example.com";
    phoneNumber = "+919876543210";
    isTextFieldEnabled = false;
    fetchPackageInfoAndCheckForUpdates();
    _loadPreferences();
    loadUsers();
  }

  Future<void> fetchPackageInfoAndCheckForUpdates() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      packageInfo = info;
    });
  }

  void loadUsers() async {
    try {
      var promise = await account.get();
      var userEmail = promise.email;
      var userName = promise.name;

      setState(() {
        name = userName;
        email = userEmail;
        isLoading = false;
      });
      fetchAvatar();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching users: $e');
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateName() async {
    try {
      await account.updateName(name: name);

      if (kDebugMode) {
        print('name update to $name successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Authentication failed: $e');
      }
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Name Update Failed'),
          content: const Text('Please check your name format'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> fetchAvatar() async {
    var avatar = await avatars.getInitials(
      name: name,
      width: 120,
      height: 120,
    );

    setState(() {
      avatarImage = avatar;
    });
  }

  void _toggleTextFieldEnabled() {
    setState(() {
      isTextFieldEnabled = !isTextFieldEnabled;
    });
  }

  Future<void> _verifyEmail() async {
    // Email verification logic

    await account
        .createVerification(
      url: 'https://appwrite.io/',
    )
        .then((response) {
      if (kDebugMode) {
        print(response);
      }
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Email Verification'),
          content: const Text('Verification link sent to your email.'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }).catchError((error) {
      if (kDebugMode) {
        print(error.response);
      }
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Verification Link Not Sent'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

// void deleteAccount() async {

//   try {
//     await account();
//     print('Account deleted successfully.');
//   } catch (e) {
//     print('Error deleting account: $e');
//   }
// }
  Future<void> toggleLock() async {
    try {
      // Update the Appwrite document with the new NSFW status
      await account.updatePrefs(prefs: {
        'isLocked': isLocked,
      });

      if (kDebugMode) {
        print('isLocked updated to $isLocked successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Please restart the app for the changes to take effect.'),
            duration: Duration(
                seconds: 5), // Optional: Set the duration of the SnackBar
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update isNSFW: $e');
      }
      // Show an error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Update Failed'),
          content: const Text('Failed to update isNSFW. Please try again.'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _loadPreferences() async {
    // _prefs = await SharedPreferences.getInstance();
    // setState(() {
    //   isLocked = _prefs.getBool('enableProtection') ?? false;
    // });
    final data = await account.getPrefs();
    setState(() {
      isSubscribed = data.data['isSubscribed'] ?? false;
      isLocked = data.data['isLocked'] ?? false;
    });
  }

  void _launchEmailApp(String toEmail) async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: toEmail,
    );

    final emailUrl = emailUri.toString();

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      // Handle the case where launching the email app is not supported
      // Provide an alternative option, e.g., opening a web-based email service
      const webMailUrl = 'https://mail.google.com';

      if (await canLaunchUrl(Uri.parse(webMailUrl))) {
        await launchUrl(Uri.parse(webMailUrl));
      } else {
        // Handle the case where opening a web-based email service is not supported
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email service is not available on this device.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(isSubscribed);
    final result = avatars.getInitials();
    if (kDebugMode) {
      print(result);
    }

    Widget avatarWidget = CircleAvatar(
      radius: 60,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: 58,
        backgroundImage: avatarImage != null ? MemoryImage(avatarImage!) : null,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isLoading ? 'Loading...' : '$name\'s Profile',
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        shadowColor: Colors.transparent,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.blue,
          size: 30,
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: _toggleTextFieldEnabled,
            child: Icon(
              isTextFieldEnabled ? Icons.lock_open : Icons.edit,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 16.0),
                    Center(child: avatarWidget),
                    const SizedBox(height: 32.0),
                    Card(
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Personal Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            TextField(
                              enabled: isTextFieldEnabled,
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                labelText: name,
                                prefixIcon: const Icon(Icons.person),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isTextFieldEnabled
                                        ? Icons.lock_open
                                        : Icons.lock,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {},
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                labelStyle: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  updatename = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16.0),
                            TextField(
                              enabled: isTextFieldEnabled,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: phoneNumber,
                                prefixIcon: const Icon(Icons.phone),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isTextFieldEnabled
                                        ? Icons.lock_open
                                        : Icons.lock,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {},
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                labelStyle: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  updatephoneNumber = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16.0),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    enabled: isTextFieldEnabled,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      labelText: email,
                                      prefixIcon: const Icon(Icons.email),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          isTextFieldEnabled
                                              ? Icons.lock_open
                                              : Icons.lock,
                                          color: Colors.black,
                                        ),
                                        onPressed: () {},
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.grey,
                                          width: 1.5,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                          width: 1.5,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      labelStyle: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        updateemail = value;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                ElevatedButton(
                                  onPressed: _verifyEmail,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  child: const Text(
                                    'Verify',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.0),
                        ),
                      ),
                      child: const Text(
                        'Delete Account',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16.0),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        children: [
                          const Text(
                            'Contact Us',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 7.0),
                          GestureDetector(
                            onTap: () {
                              _launchEmailApp(contactEmail);
                            },
                            child: Image.asset(
                              'assets/images/gmail.png',
                              width: 50,
                              height: 50,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    // ListTile(
                    //   title: const Text(
                    //     'NSFW Content',
                    //     style: TextStyle(
                    //       fontSize: 18,
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                    //   trailing: Switch(
                    //     value: isNSFWEnabled,
                    //     onChanged: (newValue) {
                    //       setState(() {
                    //         isNSFWEnabled = newValue;
                    //       });

                    //       // Toggle the NSFW status
                    //       toggleNSFW();
                    //     },
                    //   ),
                    // ),
                    ListTile(
                      title: const Text(
                        'Set Screen lock',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Switch(
                        value: isLocked,
                        onChanged: (newValue) {
                          setState(() {
                            isLocked = newValue;
                          });

                          // Toggle the NSFW status
                          toggleLock();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.info,
                color: Colors.grey,
              ),
              const SizedBox(width: 8.0),
              Text(
                'version: ${packageInfo.version}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
