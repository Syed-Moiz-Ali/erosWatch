import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:eroswatch/components/smallComponents/splash_screen.dart';
import 'package:http_proxy/http_proxy.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/api/firebase/database.dart';
import 'providers/bottom_navigator_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  Permission.storage.request();
  Permission.manageExternalStorage.request();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: SystemUiOverlay.values);

  HttpProxy httpProxy = await HttpProxy.createHttpProxy();
  // httpProxy.host = "39.115.217.197";
  // httpProxy.port = "1792";
  HttpOverrides.global = httpProxy;

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
      ],
      child: MaterialApp(
        title: 'ErosWatch',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
