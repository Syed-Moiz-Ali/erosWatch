import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:appwrite/appwrite.dart';
import 'package:eroswatch/helper/videos.dart';
import 'package:eroswatch/services/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class WallpaperStorage<T> {
  final String storageKey;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;

  WallpaperStorage({
    required this.storageKey,
    required this.fromJson,
    required this.toJson,
  });

  Future<void> storeData(T data) async {
    if (kDebugMode) {
      print('Storing data...');
    }
    final dataList = await getDataList();

    dataList.add(data);

    // await prefs.setStringList(
    //     storageKey, dataList.map((e) => jsonEncode(toJson(e))).toList());
    await backupData(storageKey, dataList);
    if (kDebugMode) {
      print('Data stored.');
    }
  }

  Future<List<T>> getDataList() async {
    if (kDebugMode) {
      print('Getting data list...');
    }
    // Implement your logic to fetch data from Appwrite or external storage here.
    // Example: Fetch data from Appwrite storage or external storage directory.
    final externalDir = await getExternalStorageDirectory();
    final filePath = '${externalDir!.path}/$storageKey.json';
    final file = File(filePath);

    if (await file.exists()) {
      final dataAsString = await file.readAsString();
      final decodedData = jsonDecode(dataAsString) as List<dynamic>;

      if (kDebugMode) {
        print('Data retrieved.');
      }
      return decodedData.map((json) => fromJson(json)).cast<T>().toList();
    } else {
      if (kDebugMode) {
        print('Data not found. Restoring...');
      }
      return restoreData();
    }
  }

// Backup data in version 1.0.2
  Future<void> backupData(String key, List<T> dataList) async {
    if (kDebugMode) {
      print('Backing up data...');
    }
    final externalDir = await getExternalStorageDirectory();
    final filePath = '${externalDir!.path}/$key.json';
    final file = File(filePath);

    if (!await file.exists()) {
      await file.create();
    }

    final fileData = jsonEncode(dataList.map((data) => toJson(data)).toList());
    final promise = await account.get();

    await file.writeAsString(fileData);

    try {
      final fileMultipartFile = InputFile.fromPath(
        path: file.path,
        filename: '$key.json',
        contentType: 'application/json',
      );

      final documentList = await database.listDocuments(
        databaseId: '64f38d70472988fd536c',
        collectionId: '64f3ad4397e3c3b29210',
        queries: [
          Query.equal('name', promise.name),
          Query.equal('email', promise.email),
          Query.equal('type', key),
        ],
      );

      if (documentList.documents.isEmpty) {
        final fileDetails = await storage.createFile(
          file: fileMultipartFile,
          bucketId: '64f3a92c7ab086900e74',
          fileId: uniqueId, // Generate a unique ID
        );

        await database.createDocument(
          databaseId: '64f38d70472988fd536c',
          collectionId: '64f3ad4397e3c3b29210',
          documentId: uniqueId,
          data: {
            'name': promise.name,
            'email': promise.email,
            'type': key,
            'fileId': fileDetails.$id,
          },
        );

        if (kDebugMode) {
          print('File uploaded with file ID: ${fileDetails.$id}');
        }
      } else {
        final documentIds =
            documentList.documents.map((e) => e.data['fileId']).toList();

        for (final documentId in documentIds) {
          // await storage.updateFile(
          //   bucketId: '64f3a92c7ab086900e74',
          //   fileId: documentId,
          // );
          await storage.deleteFile(
            bucketId: '64f3a92c7ab086900e74',
            fileId: documentId,
          );
          await storage.createFile(
            file: fileMultipartFile,
            bucketId: '64f3a92c7ab086900e74',
            fileId: documentId, // Generate a unique ID
          );
          if (kDebugMode) {
            print('File updated with file ID: $documentId');
          }
        }
      }
      if (kDebugMode) {
        print('Data backed up successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error backing up data: $e');
      }
      // Handle the error as needed (e.g., log, display an error message).
    }
  }

  Future<List<T>> restoreData() async {
    try {
      final externalDir = await getExternalStorageDirectory();
      final promise = await account.get();
      final file = File('${externalDir!.path}/$storageKey.json');
      if (!await file.exists()) {
        final documentQuery = await database.listDocuments(
          databaseId: '64f38d70472988fd536c',
          collectionId: '64f3ad4397e3c3b29210',
          queries: [
            Query.equal('name', promise.name),
            Query.equal('email', promise.email),
            Query.equal('type', storageKey),
          ],
        );
        if (documentQuery.documents.isNotEmpty) {
          final documentIds =
              documentQuery.documents.map((e) => e.$id).toList();

          for (final documentId in documentIds) {
            final document = await database.getDocument(
              databaseId: '64f38d70472988fd536c',
              collectionId: '64f3ad4397e3c3b29210',
              documentId: documentId,
            );

            if (document.data['fileId'] != null) {
              final fileId = document.data['fileId'];
              final response = await storage.getFileDownload(
                bucketId: '64f3a92c7ab086900e74',
                fileId: fileId,
              );

              final file = File('${externalDir.path}/$storageKey.json');
              await file.writeAsBytes(response);
              final dataAsString = await file.readAsString();
              final decodedData = jsonDecode(dataAsString) as List<dynamic>;
              return decodedData
                  .map((json) => fromJson(json))
                  .cast<T>()
                  .toList();
            }
          }
        } else {
          final dataList = await getDataList();
          await backupData(storageKey, dataList);
        }
      } else {
        final dataAsString = await file.readAsString();
        final decodedData = jsonDecode(dataAsString) as List<dynamic>;

        return decodedData.map((json) => fromJson(json)).cast<T>().toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error restoring data: $e');
      }
    }

    return [];
  }

  Future<void> removeData(String dataId) async {
    print('Removing data...');
    final prefs = await SharedPreferences.getInstance();
    final dataList = await restoreData();

    dataList.removeWhere((data) {
      // final item = fromJson(jsonDecode(data as String));
      if (data is Videos && data.id == dataId) {
        return true;
      } else if (data is Stars && data.id == dataId) {
        return true;
      } else if (data is Channels && data.id == dataId) {
        return true;
      }
      return false;
    });

    await prefs.setStringList(
        storageKey, dataList.map((e) => jsonEncode(toJson(e))).toList());
    await backupData(storageKey, dataList);
    print('Data removed.');
  }
}
