import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';

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

  void onLoginOrRegisterSuccess(String userId) {
    setState(() {
      uid = userId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Teléfono',
      home: uid == null
          ? LoginScreen(onLoginSuccess: onLoginOrRegisterSuccess)
          : HomeScreen(userId: uid!),
    );
  }
}
