// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:eroswatch/videos_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;

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
        builder: (context) => AlertDialog(
          title: const Row(
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
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'A new version ($releaseVersion) of the app is available.',
                style: const TextStyle(
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _startDownload(apkDownloadUrl!),
                icon: const Icon(Icons.download_rounded),
                label: const Text('Update Now'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                SystemNavigator.pop(); // Exit the app
              },
              child: const Text('Not Now'),
            ),
          ],
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
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dialog dismissal on tap outside
      builder: (context) => DownloadProgressDialog(apkDownloadUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
          child: SizedBox(
        height: 30,
        width: 30,
        child: CircularProgressIndicator(),
      ) // Show loader while checking for updates

          ),
    );
  }
}

class DownloadProgressDialog extends StatefulWidget {
  final String apkDownloadUrl;

  const DownloadProgressDialog(this.apkDownloadUrl, {super.key});

  @override
  _DownloadProgressDialogState createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<DownloadProgressDialog> {
  double _downloadProgress = 0.0;
  String _downloadStatus = 'Downloading...';
  late String downloadPath = '';
  @override
  void initState() {
    super.initState();
    _startDownload(widget.apkDownloadUrl);
  }

  Future<void> _startDownload(String apkDownloadUrl) async {
    final directory =
        await getExternalStorageDirectory(); // Get download directory
    setState(() {
      downloadPath = path.join(directory!.path, 'erosWatch.apk');
    });

    final dio = Dio();
    final response = await dio.download(
      apkDownloadUrl,
      downloadPath,
      onReceiveProgress: (received, total) {
        _downloadProgress = received / total;
        setState(() {});
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _downloadStatus = 'Download Completed';
      });
      if (kDebugMode) {
        print(downloadPath);
      }
    } else {
      setState(() {
        _downloadStatus = 'Download Failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
// final path =  FlutterDocumentPicker.openDocument(params: params);
    return AlertDialog(
      title: const Text('Downloading Update'),
      content: SizedBox(
        height: 140, // Increased the height for a more appealing layout
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const Icon(
                Icons.download_rounded,
                size: 40,
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              // SliderTheme(
              //   data: SliderThemeData(
              //     thumbShape: SliderComponentShape.noThumb, // Hide the thumb
              //     activeTrackColor: Colors.blue,
              //     inactiveTrackColor: Colors.grey,
              //   ),
              //   child: Slider(
              //     value: _downloadProgress * 100,
              //     min: 0,
              //     max: 100,
              //     onChanged: null,
              //     activeColor: Colors.blue,
              //     inactiveColor: Colors.grey,
              //   ),
              // ),
              LinearProgressIndicator(
                value: _downloadProgress, minHeight: 2.0,
                // color: Colors.blueAccent,
              ),

              Text(
                '${(_downloadProgress * 100).toStringAsFixed(2)}%',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                _downloadStatus != 'Download Completed'
                    ? null
                    : Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
            if (_downloadStatus == 'Download Completed')
              TextButton(
                onPressed: () async {
                  try {
                    final result = await OpenFilex.open(downloadPath);
                    if (result.type == ResultType.done) {
                      Navigator.pop(context); // Close the dialog
                    } else {
                      print('Error opening file: ${result.message}');
                    }
                  } catch (e) {
                    print('Error opening file: $e');
                  }
                },
                child: const Row(
                  children: [
                    Icon(Icons.open_in_new, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Open', style: TextStyle(color: Colors.blue)),
                  ],
                ),
              ),
          ],
        )
      ],
    );
  }
}
