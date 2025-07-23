import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PhoneApp());
}

class PhoneApp extends StatefulWidget {
  const PhoneApp({Key? key}) : super(key: key);

  @override
  State<PhoneApp> createState() => _PhoneAppState();
}

class _PhoneAppState extends State<PhoneApp> {
  String? uid;
  bool loading = true;
  bool splashDone = false;

  void onLoginOrRegisterSuccess(String userId) {
    setState(() {
      uid = userId;
    });
  }

  void onLogout() {
    setState(() {
      uid = null;
    });
  }

  void onSplashFinished() {
    final currentUser = FirebaseAuth.instance.currentUser;
    setState(() {
      splashDone = true;
      uid = currentUser?.uid;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlertMe',
      theme: AppTheme.themeData,
      home: !splashDone
          ? SplashScreen(onSplashFinished: onSplashFinished)
          : loading
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : uid == null
                  ? LoginScreen(onLoginSuccess: onLoginOrRegisterSuccess)
                  : HomeScreen(userId: uid!, onLogout: onLogout),
    );
  }
}
