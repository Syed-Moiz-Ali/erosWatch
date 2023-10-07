// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:convert';

import 'package:eroswatch/util/utils.dart';
import 'package:eroswatch/videos_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;

import 'package:package_info_plus/package_info_plus.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({Key? key}) : super(key: key);

  @override
  _UpdateScreenState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  late PackageInfo packageInfo;
  String latestVersion = '1.0.18';
  bool isLoading = true;
  late int appVersionLastInt = 0;
  late int? githubVersionInt = 0;
  ChromeSafariBrowser browser = ChromeSafariBrowser();

  @override
  void initState() {
    super.initState();
    fetchPackageInfoAndCheckForUpdates();
  }

  Future<void> fetchPackageInfoAndCheckForUpdates() async {
    packageInfo = await PackageInfo.fromPlatform();
    if (kDebugMode) {
      print('App Version: v${packageInfo.version}');
    }

    final String version = packageInfo.version;
    final List<String> versionParts = version.split('.');

    if (versionParts.isNotEmpty) {
      final String lastPart = versionParts.last;

      try {
        setState(() {
          appVersionLastInt = int.parse(lastPart);
        });
        if (kDebugMode) {
          print(appVersionLastInt);
        }
      } catch (e) {
        // Handle any parsing errors here
        if (kDebugMode) {
          print('Error parsing last version part: $lastPart');
        }
      }
    }
    const String repositoryUrl =
        'https://api.github.com/repos/MyCoding331/erosWatch/releases';
    final response = await http.get(Uri.parse(repositoryUrl));
    if (response.statusCode == 200) {
      final List<dynamic> releases = json.decode(response.body);
      if (releases.isNotEmpty) {
        final Map<String, dynamic> latestRelease = releases[0];
        final String releaseVersion = latestRelease['tag_name'];
        final List<String> versionParts =
            releaseVersion.replaceAll('v', '').split('.');
        if (versionParts.isNotEmpty) {
          final String lastVersion = versionParts.last;
          setState(() {
            githubVersionInt = int.tryParse(lastVersion);
          });
          if (githubVersionInt != null) {
            if (kDebugMode) {
              print('GitHub Version (Integer): $githubVersionInt');
            }
          } else {
            // Handle the case where the numeric part couldn't be converted to an int.
            if (kDebugMode) {
              print('Invalid GitHub Version: $releaseVersion');
            }
          }
        } else {
          // Handle the case where there are no version parts.
          if (kDebugMode) {
            print('Invalid GitHub Version Format: $releaseVersion');
          }
        }

        if (kDebugMode) {
          print('Github Version: $releaseVersion');
        }
        if (appVersionLastInt < githubVersionInt!) {
          _showUpdateDialog(latestRelease);
        } else {
          setState(() {
            isLoading =
                false; // Update the state to indicate loading is complete
          });
          // No update needed, navigate to VideoScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const VideoScreen()),
          );
        }
      }
    }
  }

  void _showUpdateDialog(Map<String, dynamic> latestRelease) {
    final List<dynamic> assets = latestRelease['assets'];

    // Find the asset with the desired APK name
    // final Map<String, dynamic>? apkAsset = assets.firstWhere(
    //   (asset) => asset['name'] == 'app-armeabi-v7a-release.apk',
    //   orElse: () => null,
    // );
    String? apkDownloadUrl;
    for (final asset in assets) {
      final String assetName = asset['name'];
      if (assetName == 'app-armeabi-v7a-release.apk') {
        setState(() {
          apkDownloadUrl = asset['browser_download_url'];
        });
        break; // Exit the loop when the first matching asset is found
      }
    }
    if (apkDownloadUrl != null) {
      // final String apkDownloadUrl = apkAsset['browser_download_url'];
      final String releaseVersion = latestRelease['tag_name'];

      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    // color: Colors.blue,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.update,
                        color: Colors.blue,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Update Available',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'A new version ($releaseVersion) of the app is available.',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => _startDownload(apkDownloadUrl!),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          backgroundColor: Colors.blue, // Text color

                          padding: const EdgeInsets.symmetric(
                              horizontal: 5.0, vertical: 5.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                80000.0), // Adjust border radius as needed
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment
                              .spaceBetween, // Align the container to the end
                          mainAxisSize: MainAxisSize.min,

                          children: [
                            Container(
                              height: 42,
                              width: 42,
                              padding: const EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                color: Colors.black, // Icon background color
                                borderRadius: BorderRadius.circular(
                                    24000.0), // Rounded shape
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.download_outlined,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(
                                width: 12), // Spacing between icon and text
                            const Text(
                              'Update Now',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Not Now',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Handle the case where the desired APK asset is not found
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Update Not Found'),
          content: const Text('The update APK was not found.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                SystemNavigator.pop(); // Exit the app
              },
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  void _startDownload(String apkDownloadUrl) {
    inVideoAddLaunch(context, browser, apkDownloadUrl);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
          child: SizedBox(
        height: 40,
        width: 40,
        child: CircularProgressIndicator(),
      ) // Show loader while checking for updates

          ),
    );
  }
}
