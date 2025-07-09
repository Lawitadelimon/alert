import 'dart:async';
import 'package:alertmecel/screens/home_screen.dart';
import 'package:alertmecel/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Usuario autenticado -> HomeScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen(userId: user.uid)),
        );
      } else {
        // No autenticado -> LoginScreen, pasando callback vacío
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => LoginScreen(
              onLoginSuccess: (String userId) {
                // Aquí puedes manejar login exitoso si quieres
              },
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/logo.png',
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
