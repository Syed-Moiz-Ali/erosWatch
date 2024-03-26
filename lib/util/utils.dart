// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:math';
import 'package:eroswatch/helper/videos.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/spankbang.dart';
import '../providers/cardProvider.dart';

ChromeSafariBrowser? openBrowser;
Future<void> launchAdsUrl(
    BuildContext context, ChromeSafariBrowser browser) async {
  if (openBrowser != null) {
    await openBrowser!.close(); // Close the previously opened browser if any
  }
  List<String> adLinks = [
    'https://alterassumeaggravate.com/vxzhm5ur2?key=67878f8f4b7b02dba995a675709106f1',
    'https://alterassumeaggravate.com/k7idg1w309?key=4fd88d34214c0b3f55a623c70791caaa',
    'https://www.liquidfire.mobi/redirect?sl=16&t=dr&track=193280_291760&siteid=291760'
  ];
  final String randomAdLink = adLinks[Random().nextInt(adLinks.length)];
  final Uri url = Uri.parse(randomAdLink);
  openBrowser = browser;
  await browser.open(
    url: url,
    options: ChromeSafariBrowserClassOptions(
      android: AndroidChromeCustomTabsOptions(
        showTitle: true,
        displayMode: TrustedWebActivityImmersiveDisplayMode(
            isSticky: true,
            layoutInDisplayCutoutMode: AndroidLayoutInDisplayCutoutMode.ALWAYS),
        noHistory: true,
      ),
      ios: IOSSafariOptions(
        barCollapsingEnabled: true,
        dismissButtonStyle: IOSSafariDismissButtonStyle.DONE,
      ),
    ),
  );
}

Future<void> inVideoAddLaunch(
    BuildContext context, ChromeSafariBrowser browser, String link) async {
  // List<String> adLinks = [
  //   'https://alterassumeaggravate.com/vxzhm5ur2?key=67878f8f4b7b02dba995a675709106f1',
  //   'https://alterassumeaggravate.com/k7idg1w309?key=4fd88d34214c0b3f55a623c70791caaa',
  //   'https://www.liquidfire.mobi/redirect?sl=16&t=dr&track=193280_291760&siteid=291760'
  // ];
  // final String randomAdLink = adLinks[Random().nextInt(adLinks.length)];
  if (openBrowser != null) {
    await openBrowser!.close(); // Close the previously opened browser if any
  }

  final String trimmedLink = link.trim();
  final Uri url = Uri.parse(trimmedLink);
  openBrowser = browser;
  await browser.open(
    url: url,
    options: ChromeSafariBrowserClassOptions(
      android: AndroidChromeCustomTabsOptions(
        showTitle: true,
        displayMode: TrustedWebActivityImmersiveDisplayMode(
            isSticky: true,
            layoutInDisplayCutoutMode: AndroidLayoutInDisplayCutoutMode.ALWAYS),
        noHistory: true,
      ),
      ios: IOSSafariOptions(
        barCollapsingEnabled: true,
        dismissButtonStyle: IOSSafariDismissButtonStyle.DONE,
      ),
    ),
  );
}

class ErosWatchDatabase {
  dynamic storageKey;
  dynamic context;
  late Database _database;
  ErosWatchDatabase({this.storageKey, required this.context});
  ErosWatchDatabase._privateConstructor();
  static final ErosWatchDatabase instance =
      ErosWatchDatabase._privateConstructor();

  int totalItems = 0;
  Future<void> open() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'eros$storageKey.db');

      _database = await openDatabase(path, version: 1,
          onCreate: (Database db, int version) async {
        await db.execute(
            'CREATE TABLE $storageKey (Id INTEGER PRIMARY KEY AUTOINCREMENT,${storageKey}Data TEXT NOT NULL)');
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error opening database: $e');
      }
    }
  }

  Future<int> insertVideo(VideoItem video) async {
    try {
      await open();
      final List<Map<String, dynamic>> existingVideos = await _database.query(
        storageKey,
        where: '${storageKey}Data = ?',
        whereArgs: [video.toJsonString()],
      );

      if (existingVideos.isNotEmpty) {
        // Video with the same ID already exists, do not insert again
        return -2; // You can use a different error code to indicate existing data
      }
      var value = {'${storageKey}Data': video.toJsonString()};
      return await _database.insert(
        storageKey,
        value,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      // Handle the error, e.g., show an error message
      if (kDebugMode) {
        print('Error inserting video: $e');
      }
      return -1; // Return an error code or throw an exception as needed
    }
  }

  Future<int> insertStars(Stars video) async {
    try {
      await open();
      final List<Map<String, dynamic>> existingStars = await _database.query(
        storageKey,
        where: '${storageKey}Data = ?',
        whereArgs: [video.toJsonString()],
      );

      if (existingStars.isNotEmpty) {
        // Video with the same ID already exists, do not insert again
        return -2; // You can use a different error code to indicate existing data
      }
      var value = {'${storageKey}Data': video.toJsonString()};
      return await _database.insert(
        storageKey,
        value,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      // Handle the error, e.g., show an error message
      if (kDebugMode) {
        print('Error inserting video: $e');
      }
      return -1; // Return an error code or throw an exception as needed
    }
  }

  Future<int> insertChannels(Channels video) async {
    try {
      await open();
      final List<Map<String, dynamic>> existingChannels = await _database.query(
        storageKey,
        where: '${storageKey}Data = ?',
        whereArgs: [video.toJsonString()],
      );

      if (existingChannels.isNotEmpty) {
        // Video with the same ID already exists, do not insert again
        return -2; // You can use a different error code to indicate existing data
      }
      var value = {'${storageKey}Data': video.toJsonString()};
      return await _database.insert(
        storageKey,
        value,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      // Handle the error, e.g., show an error message
      if (kDebugMode) {
        print('Error inserting video: $e');
      }
      return -1; // Return an error code or throw an exception as needed
    }
  }

  Future<int> updateVideo(video) async {
    try {
      await open();
      return await _database.update(
        '${storageKey}Data',
        video.toMap(),
        where: 'id = ?',
        whereArgs: [video.id],
      );
    } catch (e) {
      // Handle the error, e.g., show an error message
      if (kDebugMode) {
        print('Error updating video: $e');
      }
      return -1; // Return an error code or throw an exception as needed
    }
  }

  Future<List<VideoItem>> getAllVideos() async {
    try {
      await open();
      List<Map<String, dynamic>> maps = await _database.query(storageKey);
      var cardProvider = Provider.of<CardProvider>(context, listen: false);
      if (!storageKey.contains('history')) {
        cardProvider.setTotalLength(maps.length, 'video');
      }
      return List.generate(maps.length, (i) {
        final String jsonData = maps[i]['${storageKey}Data'];
        return VideoItem.fromJson(json.decode(jsonData));
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving videos: $e');
      }
      return [];
    }
  }

  Future<List<Stars>> getAllStars() async {
    try {
      await open();
      List<Map<String, dynamic>> maps = await _database.query(storageKey);
      var cardProvider = Provider.of<CardProvider>(context, listen: false);
      if (!storageKey.contains('history')) {
        cardProvider.setTotalLength(maps.length, 'star');
      }

      return List.generate(maps.length, (i) {
        final String jsonData = maps[i]['${storageKey}Data'];
        return Stars.fromJson(json.decode(jsonData));
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving videos: $e');
      }
      return [];
    }
  }

  Future<List<Channels>> getAllChannels() async {
    try {
      await open();
      List<Map<String, dynamic>> maps = await _database.query(storageKey);
      var cardProvider = Provider.of<CardProvider>(context, listen: false);
      if (!storageKey.contains('history')) {
        cardProvider.setTotalLength(maps.length, 'channel');
      }
      return List.generate(maps.length, (i) {
        final String jsonData = maps[i]['${storageKey}Data'];
        return Channels.fromJson(json.decode(jsonData));
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving videos: $e');
      }
      return [];
    }
  }

  Future<int> deleteVideo(Videos video) async {
    try {
      await open();
      return await _database.delete(
        storageKey,
        where: '${storageKey}Data = ?',
        whereArgs: [video.toJsonString()],
      );
    } catch (e) {
      // Handle the error, e.g., show an error message
      if (kDebugMode) {
        print('Error deleting video: $e');
      }
      return -1; // Return an error code or throw an exception as needed
    }
  }

  Future<int> deleteStar(Stars video) async {
    try {
      await open();
      return await _database.delete(
        storageKey,
        where: '${storageKey}Data = ?',
        whereArgs: [video.toJsonString()],
      );
    } catch (e) {
      // Handle the error, e.g., show an error message
      if (kDebugMode) {
        print('Error deleting video: $e');
      }
      return -1; // Return an error code or throw an exception as needed
    }
  }

  Future<int> deleteChannel(Channels video) async {
    try {
      await open();
      return await _database.delete(
        storageKey,
        where: '${storageKey}Data = ?',
        whereArgs: [video.toJsonString()],
      );
    } catch (e) {
      // Handle the error, e.g., show an error message
      if (kDebugMode) {
        print('Error deleting video: $e');
      }
      return -1; // Return an error code or throw an exception as needed
    }
  }

  Future<void> close() async {
    await _database.close();
  }
}
