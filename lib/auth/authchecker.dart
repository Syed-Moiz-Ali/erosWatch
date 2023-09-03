import 'package:eroswatch/auth/signIn_auth.dart';
import 'package:eroswatch/components/inapp_update.dart';
import 'package:eroswatch/helper/localauth.dart';
import 'package:eroswatch/services/appwrite.dart';
import 'package:eroswatch/videos_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  bool isSignIn = false;
  Future<bool>? _userSessionFuture;

  bool isLocked = false;
  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _userSessionFuture = checkUserSession();
  }

  Future<void> _loadPreferences() async {
    // _prefs = await SharedPreferences.getInstance();
    // setState(() {
    //   isLocked = _prefs.getBool('enableProtection') ?? false;
    // });
    final data = await account.getPrefs();
    setState(() {
      isLocked = data.data['isLocked'] ?? false;
    });
  }

  Future<bool> checkUserSession() async {
    try {
      // Check if the user session exists
      await account.get();

      // Successfully retrieved account data
      return true;
    } catch (error) {
      // Handle any errors that occurred while checking the user session
      if (kDebugMode) {
        print('Error is at user session: $error');
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<bool>(
        future: _userSessionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while checking the user session
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            if (snapshot.hasError) {
              // Handle any errors that occurred while checking the user session
              return Scaffold(
                body: Center(
                  child: Text('Error: ${snapshot.error}'),
                ),
              );
            } else {
              // User session exists, navigate to the home screen
              if (snapshot.data == true) {
                if (kDebugMode) {
                  print('video: ${snapshot.data}');
                }
                if (isLocked) {
                  return const AuthPage();
                } else {
                  return const VideoScreen();
                }
              }
              // User session does not exist, navigate to the login screen
              else {
                if (kDebugMode) {
                  print('sginIn :${snapshot.data}');
                }
                return const SignInAuthPage();
                // const WallpaperScreen();
              }
            }
          }
        },
      ),
    );
  }
}
