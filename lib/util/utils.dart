import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

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
