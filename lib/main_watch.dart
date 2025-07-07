import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/login_screen.dart';
import 'screens/vital_signs_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const WatchApp());
}

class WatchApp extends StatefulWidget {
  const WatchApp({Key? key}) : super(key: key);

  @override
  State<WatchApp> createState() => _WatchAppState();
}

class _WatchAppState extends State<WatchApp> {
  String? uid;

  void onLoginSuccess(String userId) {
    setState(() {
      uid = userId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Smartwatch',
      home: uid == null
          ? LoginScreen(onLoginSuccess: onLoginSuccess)
          : const VitalSignsScreen(), // o la pantalla que envía datos
    );
  }
}
