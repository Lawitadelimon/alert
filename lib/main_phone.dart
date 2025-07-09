import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
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
  bool loading = true;

  void onLoginOrRegisterSuccess(String userId) {
    setState(() {
      uid = userId;
    });
  }

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      uid = currentUser.uid;
    }
    loading = false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlertMe',
      theme: AppTheme.lightTheme, // si usas un tema
      home: loading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : uid == null
              ? LoginScreen(onLoginSuccess: onLoginOrRegisterSuccess)
              : HomeScreen(userId: uid!),
    );
  }
}
