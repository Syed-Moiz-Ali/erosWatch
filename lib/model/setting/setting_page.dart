// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool isLoading = false;
  bool isSubscribed = false;
  late bool isTextFieldEnabled;
  Uint8List? avatarImage;
  bool isNSFWEnabled = false;
  bool isLocked = false;
  bool isNSFWToggled = false; // New variable to track NSFW switch toggle
  bool isLockedToggled = false; // New variable to track NSFW switch toggle
  late final PackageInfo packageInfo;
  final String contactEmail = 'shinten812@gmail.com';
  late double getSpeed = 1.0;
  dynamic speed = 1.0;
  double steps = 0.05;
  TextEditingController speedController = TextEditingController(text: '1.0');
  String selectedQuality = '240p';
  @override
  void initState() {
    super.initState();
    name = 'test';
    email = "test@example.com";
    phoneNumber = "+919876543210";
    isTextFieldEnabled = false;
    fetchPackageInfoAndCheckForUpdates();
    _loadPreferences();
    _loadSelectedQuality();
    // loadUsers();
  }

  Future<void> fetchPackageInfoAndCheckForUpdates() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      packageInfo = info;
    });
  }

  _loadSelectedQuality() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? quality = sharedPreferences.getString('settingSelectedQuality');
    if (quality != null) {
      setState(() {
        selectedQuality = quality;
      });
    }
  }
  // void loadUsers() async {
  //   try {
  //     var promise = await account.get();
  //     var userEmail = promise.email;
  //     var userName = promise.name;

  //     setState(() {
  //       name = userName;
  //       email = userEmail;
  //       isLoading = false;
  //     });
  //     fetchAvatar();
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Error fetching users: $e');
  //     }
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  // Future<void> updateName() async {
  //   try {
  //     await account.updateName(name: name);

  //     if (kDebugMode) {
  //       print('name update to $name successfully');
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Authentication failed: $e');
  //     }
  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: const Text('Name Update Failed'),
  //         content: const Text('Please check your name format'),
  //         actions: <Widget>[
  //           ElevatedButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //             child: const Text('OK'),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  // }

  // Future<void> fetchAvatar() async {
  //   var avatar = await avatars.getInitials(
  //     name: name,
  //     width: 120,
  //     height: 120,
  //   );

  //   setState(() {
  //     avatarImage = avatar;
  //   });
  // }

  void _toggleTextFieldEnabled() {
    setState(() {
      isTextFieldEnabled = !isTextFieldEnabled;
    });
  }

  // Future<void> _verifyEmail() async {
  //   // Email verification logic

  //   await account
  //       .createVerification(
  //     url: 'https://cloud.appwrite.io/v1',
  //   )
  //       .then((response) {
  //     if (kDebugMode) {
  //       print(response);
  //     }
  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: const Text('Email Verification'),
  //         content: const Text('Verification link sent to your email.'),
  //         actions: <Widget>[
  //           ElevatedButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //             child: const Text('OK'),
  //           ),
  //         ],
  //       ),
  //     );
  //   }).catchError((error) {
  //     if (kDebugMode) {
  //       print(error.response);
  //     }
  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: const Text('Error'),
  //         content: const Text('Verification Link Not Sent'),
  //         actions: <Widget>[
  //           ElevatedButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //             child: const Text('OK'),
  //           ),
  //         ],
  //       ),
  //     );
  //   });
  // }

// void deleteAccount() async {

//   try {
//     await account();
//     print('Account deleted successfully.');
//   } catch (e) {
//     print('Error deleting account: $e');
//   }
// }
  Future<void> toggleLock(bool newValue) async {
    try {
      // Update the Appwrite document with the new NSFW status
      // await account.updatePrefs(prefs: {
      //   'isLocked': isLocked,
      // });
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        isLocked = prefs.setBool('enableProtection', newValue) as bool;
      });
      // if (kDebugMode) {
      //   print('isLocked updated to $isLocked successfully');
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content:
      //           Text('Please restart the app for the changes to take effect.'),
      //       duration: Duration(
      //           seconds: 5), // Optional: Set the duration of the SnackBar
      //     ),
      //   );
      // }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update isNSFW: $e');
      }
      // Show an error dialog
      // showDialog(
      //   context: context,
      //   builder: (context) => AlertDialog(
      //     title: const Text('Update Failed'),
      //     content: const Text('Failed to update isLocked. Please try again.'),
      //     actions: <Widget>[
      //       ElevatedButton(
      //         onPressed: () {
      //           Navigator.pop(context);
      //         },
      //         child: const Text('OK'),
      //       ),
      //     ],
      //   ),
      // );
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLocked = prefs.getBool('enableProtection') ?? false;
      getSpeed = prefs.getDouble('settingSpeed')!;
      speedController.text =
          prefs.getDouble('settingSpeed')!.toStringAsFixed(2);
    });
    // final data = await account.getPrefs();
    // setState(() {
    //   isSubscribed = data.data['isSubscribed'] ?? false;

    // });
  }

  setSpeed(double val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('settingSpeed', val);
    setState(() {
      speedController.text =
          prefs.getDouble('settingSpeed')!.toStringAsFixed(2);
      getSpeed = prefs.getDouble('settingSpeed')!;
    });
  }

  Widget conditionalChanger() {
    if (name == 'test' &&
        email == "test@example.com" &&
        phoneNumber == "+919876543210") {
      // Conditionally render an empty widget
      return sayLoginToUser(); // You can also use Text('') if you prefer
    } else {
      // Return the Card widget with form fields
      return const SizedBox.shrink();
      // return usersDataInfo(avatarWidget);
    }
  }

  Widget sayLoginToUser() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          // constraints: const BoxConstraints(minHeight: 150),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
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
                toggleLock(newValue);
              },
            ),
          ),
        ),
        const SizedBox(height: 22),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Qality',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButton<String>(
                value: selectedQuality,
                onChanged: (newValue) async {
                  SharedPreferences sharedPreferences =
                      await SharedPreferences.getInstance();
                  await sharedPreferences.setString(
                      'settingSelectedQuality', newValue!);
                  setState(() {
                    selectedQuality = newValue;
                    print('newValue is $newValue');
                  });
                  // Perform action based on selected quality
                  // For example: updatePreferences(newValue);
                },
                items: <String>['240p', '360p', '480p', '720p', '1080p', '4K']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        speedCard(),

        // const SizedBox(height: 200.0), // Add spacing
        // const Align(
        //   // Center the coming soon message and icon
        //   alignment: Alignment.center,
        //   child: Column(
        //     children: [
        //       Text(
        //         'Login and Register Coming Soon!',
        //         style: TextStyle(
        //           fontSize: 18,
        //           fontWeight: FontWeight.bold,
        //         ),
        //       ),
        //       SizedBox(height: 10.0), // Add spacing
        //       Icon(
        //         Icons.hourglass_empty, // You can change the icon
        //         size: 50,
        //         color: Colors.orange, // Customize icon color
        //       ),
        //       SizedBox(height: 20.0), // Add spacing
        //       // GestureDetector(
        //       //   onTap: () {
        //       //     _launchEmailApp(contactEmail);
        //       //   },
        //       //   child: Image.asset(
        //       //     'assets/images/gmail.png',
        //       //     width: 50,
        //       //     height: 50,
        //       //   ),
        //       // ),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  Widget speedCard() {
    return Container(
      constraints: const BoxConstraints(minHeight: 150),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: const Row(
              children: [
                Icon(
                  Icons.speed,
                  size: 24.0,
                  color: Colors.black,
                ),
                SizedBox(width: 8.0),
                Text(
                  'Set Playback Speed',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      double newSpeed = getSpeed - steps;
                      if (newSpeed < steps) {
                        newSpeed = steps;
                      } else if (newSpeed < 0.5) {
                        newSpeed = 0.5;
                      }
                      setState(() {
                        setSpeed(newSpeed);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.remove,
                        size: 24.0,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.blue.withOpacity(0.1),
                      ),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: speedController.text,
                          border: InputBorder.none,
                        ),
                        readOnly: true,
                        controller: speedController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      double newSpeed = getSpeed + steps;
                      if (newSpeed > 3.0) {
                        newSpeed = 3.0;
                      }
                      setState(() {
                        setSpeed(newSpeed);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 24.0,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              setSpeed(1.0);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue, // Text color

              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16)), // Button border radius
              ),
              elevation: 8, // Button shadow
            ),
            child: Container(
              // padding: const EdgeInsets.symmetric(
              //     horizontal: 24, vertical: 16), // Button padding
              margin: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 16), // Button padding
              child: const Center(
                child: Text(
                  'Reset',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Column usersDataInfo(Widget avatarWidget) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.stretch,
  //     children: <Widget>[
  //       const SizedBox(height: 16.0),
  //       Center(child: avatarWidget),
  //       const SizedBox(height: 32.0),
  //       Card(
  //         elevation: 2.0,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(10.0),
  //         ),
  //         child: Padding(
  //           padding: const EdgeInsets.all(16.0),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.stretch,
  //             children: [
  //               const Text(
  //                 'Personal Information',
  //                 style: TextStyle(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //               const SizedBox(height: 16.0),
  //               TextField(
  //                 enabled: isTextFieldEnabled,
  //                 keyboardType: TextInputType.name,
  //                 decoration: InputDecoration(
  //                   labelText: name,
  //                   prefixIcon: const Icon(Icons.person),
  //                   suffixIcon: IconButton(
  //                     icon: Icon(
  //                       isTextFieldEnabled ? Icons.lock_open : Icons.lock,
  //                       color: Colors.black,
  //                     ),
  //                     onPressed: () {},
  //                   ),
  //                   enabledBorder: OutlineInputBorder(
  //                     borderSide: const BorderSide(
  //                       color: Colors.grey,
  //                       width: 1.5,
  //                     ),
  //                     borderRadius: BorderRadius.circular(10.0),
  //                   ),
  //                   focusedBorder: OutlineInputBorder(
  //                     borderSide: const BorderSide(
  //                       color: Colors.black,
  //                       width: 1.5,
  //                     ),
  //                     borderRadius: BorderRadius.circular(10.0),
  //                   ),
  //                   labelStyle: const TextStyle(
  //                     color: Colors.black,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //                 onChanged: (value) {
  //                   setState(() {
  //                     updatename = value;
  //                   });
  //                 },
  //               ),
  //               const SizedBox(height: 16.0),
  //               TextField(
  //                 enabled: isTextFieldEnabled,
  //                 keyboardType: TextInputType.phone,
  //                 decoration: InputDecoration(
  //                   labelText: phoneNumber,
  //                   prefixIcon: const Icon(Icons.phone),
  //                   suffixIcon: IconButton(
  //                     icon: Icon(
  //                       isTextFieldEnabled ? Icons.lock_open : Icons.lock,
  //                       color: Colors.black,
  //                     ),
  //                     onPressed: () {},
  //                   ),
  //                   enabledBorder: OutlineInputBorder(
  //                     borderSide: const BorderSide(
  //                       color: Colors.grey,
  //                       width: 1.5,
  //                     ),
  //                     borderRadius: BorderRadius.circular(10.0),
  //                   ),
  //                   focusedBorder: OutlineInputBorder(
  //                     borderSide: const BorderSide(
  //                       color: Colors.black,
  //                       width: 1.5,
  //                     ),
  //                     borderRadius: BorderRadius.circular(10.0),
  //                   ),
  //                   labelStyle: const TextStyle(
  //                     color: Colors.black,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //                 onChanged: (value) {
  //                   setState(() {
  //                     updatephoneNumber = value;
  //                   });
  //                 },
  //               ),
  //               const SizedBox(height: 16.0),
  //               Row(
  //                 children: [
  //                   Expanded(
  //                     child: TextField(
  //                       enabled: isTextFieldEnabled,
  //                       keyboardType: TextInputType.emailAddress,
  //                       decoration: InputDecoration(
  //                         labelText: email,
  //                         prefixIcon: const Icon(Icons.email),
  //                         suffixIcon: IconButton(
  //                           icon: Icon(
  //                             isTextFieldEnabled ? Icons.lock_open : Icons.lock,
  //                             color: Colors.black,
  //                           ),
  //                           onPressed: () {},
  //                         ),
  //                         enabledBorder: OutlineInputBorder(
  //                           borderSide: const BorderSide(
  //                             color: Colors.grey,
  //                             width: 1.5,
  //                           ),
  //                           borderRadius: BorderRadius.circular(10.0),
  //                         ),
  //                         focusedBorder: OutlineInputBorder(
  //                           borderSide: const BorderSide(
  //                             color: Colors.black,
  //                             width: 1.5,
  //                           ),
  //                           borderRadius: BorderRadius.circular(10.0),
  //                         ),
  //                         labelStyle: const TextStyle(
  //                           color: Colors.black,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                       onChanged: (value) {
  //                         setState(() {
  //                           updateemail = value;
  //                         });
  //                       },
  //                     ),
  //                   ),
  //                   const SizedBox(width: 8.0),
  //                   ElevatedButton(
  //                     onPressed: _verifyEmail,
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: Colors.blue,
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(10.0),
  //                       ),
  //                     ),
  //                     child: const Text(
  //                       'Verify',
  //                       style: TextStyle(fontSize: 16),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //       const SizedBox(height: 32.0),
  //       ElevatedButton(
  //         onPressed: () {},
  //         style: ElevatedButton.styleFrom(
  //           backgroundColor: Colors.blue,
  //           padding: const EdgeInsets.symmetric(vertical: 16.0),
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(10.0),
  //           ),
  //         ),
  //         child: const Text(
  //           'Save Changes',
  //           style: TextStyle(
  //             fontSize: 16,
  //             color: Colors.white,
  //           ),
  //         ),
  //       ),
  //       const SizedBox(height: 16.0),
  //       ElevatedButton(
  //         onPressed: () {},
  //         style: ElevatedButton.styleFrom(
  //           backgroundColor: Colors.black,
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(3.0),
  //           ),
  //         ),
  //         child: const Text(
  //           'Delete Account',
  //           style: TextStyle(
  //             color: Colors.red,
  //             fontSize: 16,
  //           ),
  //         ),
  //       ),

  //       const SizedBox(height: 16.0),
  //       Align(
  //         alignment: Alignment.centerLeft,
  //         child: Column(
  //           children: [
  //             const Text(
  //               'Contact Us',
  //               style: TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             const SizedBox(height: 7.0),
  //             GestureDetector(
  //               onTap: () {
  //                 _launchEmailApp(contactEmail);
  //               },
  //               child: Image.asset(
  //                 'assets/images/gmail.png',
  //                 width: 50,
  //                 height: 50,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       const SizedBox(height: 16.0),
  //       // ListTile(
  //       //   title: const Text(
  //       //     'NSFW Content',
  //       //     style: TextStyle(
  //       //       fontSize: 18,
  //       //       fontWeight: FontWeight.bold,
  //       //     ),
  //       //   ),
  //       //   trailing: Switch(
  //       //     value: isNSFWEnabled,
  //       //     onChanged: (newValue) {
  //       //       setState(() {
  //       //         isNSFWEnabled = newValue;
  //       //       });

  //       //       // Toggle the NSFW status
  //       //       toggleNSFW();
  //       //     },
  //       //   ),
  //       // ),
  //       ListTile(
  //         title: const Text(
  //           'Set Screen lock',
  //           style: TextStyle(
  //             fontSize: 18,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         trailing: Switch(
  //           value: isLocked,
  //           onChanged: (newValue) {
  //             setState(() {
  //               isLocked = newValue;
  //             });

  //             // Toggle the NSFW status
  //             toggleLock(newValue);
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    // print(isSubscribed);
    // final result = avatars.getInitials();
    // if (kDebugMode) {
    //   print(result);
    // }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          // isLoading ? 'Loading...' : '$name\'s Profile',
          'Profile',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        shadowColor: Colors.transparent,
        // backgroundColor: Colors.white,

        // actions: <Widget>[
        //   GestureDetector(
        //     onTap: _toggleTextFieldEnabled,
        //     child: Icon(
        //       isTextFieldEnabled ? Icons.lock_open : Icons.edit,
        //       color: Colors.black,
        //     ),
        //   ),
        // ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: conditionalChanger(),
              ),
            ),
      // bottomNavigationBar: BottomAppBar(
      //   child: Padding(
      //     padding: const EdgeInsets.all(16.0),
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: [
      //         const Icon(
      //           Icons.info,
      //           color: Colors.grey,
      //         ),
      //         const SizedBox(width: 8.0),
      //         Text(
      //           'version: ${packageInfo.version}',
      //           style: const TextStyle(
      //             color: Colors.grey,
      //             fontSize: 14,
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}
