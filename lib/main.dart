import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:eroswatch/components/smallComponents/splash_screen.dart';
import 'package:http_proxy/http_proxy.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/bottom_navigator_provider.dart';
import 'providers/cardProvider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  await prefs.setString('baseUrl', 'https://spankbang.party');
  Permission.storage.request();
  Permission.manageExternalStorage.request();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: SystemUiOverlay.values);

  HttpProxy httpProxy = await HttpProxy.createHttpProxy();
  // httpProxy.host = "39.115.217.197";
  // httpProxy.port = "1792";
  HttpOverrides.global = httpProxy;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

// This method initializes the notifications plugin.

  const InitializationSettings initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('ic_launcher'),
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const VideoApp());
}

class VideoApp extends StatelessWidget {
  const VideoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BottomNavigatorProvider>(
          create: (context) => BottomNavigatorProvider(),
        ),
        ChangeNotifierProvider<CardProvider>(
          create: (context) => CardProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'ErosWatch',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: Colors.blue,
          primaryIconTheme: const IconThemeData(color: Colors.blue),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.blue, size: 25),
            elevation: 0,
            // shape: CustomShapeBorder(),
          ),
          dialogTheme: DialogTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            backgroundColor: Colors.white,
            titleTextStyle: const TextStyle(
              color: Colors.blue,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
            contentTextStyle: const TextStyle(
              color: Colors.black,
              fontSize: 16.0,
            ),
          ),
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
