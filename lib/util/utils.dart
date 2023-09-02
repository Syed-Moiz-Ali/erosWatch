import 'dart:convert';
import 'dart:math';
import 'package:eroswatch/helper/videos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
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
    final prefs = await SharedPreferences.getInstance();
    final dataList = await getDataList();

    dataList.add(data);

    await prefs.setStringList(
        storageKey, dataList.map((e) => jsonEncode(toJson(e))).toList());
  }

  Future<List<T>> getDataList() async {
    final prefs = await SharedPreferences.getInstance();
    final dataList = prefs.getStringList(storageKey) ?? [];

    return dataList.map((e) => fromJson(jsonDecode(e))).toList();
  }

  Future<void> removeData(String dataId) async {
    final prefs = await SharedPreferences.getInstance();
    final dataList = await getDataList();

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
  }
}
