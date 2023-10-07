// ignore_for_file: library_private_types_in_public_api

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class VideoDownloadScreen extends StatefulWidget {
  final String videoUrl;
  final String title;

  const VideoDownloadScreen(
      {super.key, required this.videoUrl, required this.title});

  @override
  _VideoDownloadScreenState createState() => _VideoDownloadScreenState();
}

class _VideoDownloadScreenState extends State<VideoDownloadScreen> {
  int notificationId = 123; // Use a valid 32-bit integer ID
  late int progress = 0; // Use a valid 32-bit integer ID

  @override
  void initState() {
    super.initState();
  }

  Future<void> showDownloadNotification(String filePath) async {
    int lastProgress =
        -1; // Track the last progress to avoid duplicate notifications

    Dio dio = Dio();
    await dio.download(
      widget.videoUrl,
      filePath,
      onReceiveProgress: (received, total) async {
        if (total != -1) {
          setState(() {
            progress = (received / total * 100).toInt();
          });

          // Update the notification only if the progress value has changed
          if (progress != lastProgress) {
            // NotificationContent content = NotificationContent(
            //   id: notificationId,
            //   channelKey: 'download_notification',
            //   title: 'Downloading Video',
            //   body: 'Download in progress... $progress%',
            //   progress: progress,
            //   icon: 'download', // Use the predefined 'download' icon
            // );

            lastProgress = progress;
          }
        }

        // Create the 'videos' folder if it doesn't exist
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String videosPath = '${appDocDir.path}/videos';
        if (!Directory(videosPath).existsSync()) {
          Directory(videosPath).createSync();
        }
      },
    );

    // Show a completed download notification
  }

  @override
  Widget build(BuildContext context) {
    double size = 30;
    return IconButton(
      icon: Icon(
        Icons.download,
        size: size - 5,
        color: Colors.white,
      ),
      onPressed: () async {
        // Get the application documents directory
        Directory appDocDir = await getApplicationDocumentsDirectory();

        // Create the 'videos' folder if it doesn't exist
        String videosPath = '${appDocDir.path}/videos';
        if (!Directory(videosPath).existsSync()) {
          Directory(videosPath).createSync();
        }

        // Specify the path where the video will be saved inside the 'videos' folder
        String filePath = '$videosPath/${widget.title}.mp4';

        showDownloadNotification(filePath);
      },
    );
  }
}
