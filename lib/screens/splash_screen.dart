import 'dart:async';
import 'package:alertmecel/screens/login_screen.dart';
import 'package:alertmecel/screens/register_screen.dart';
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

    // Esperar 4 segundos y luego navegar a WelcomeScreen
    Timer(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) =>  LoginScreen(onLoginSuccess: (String uid) {  },)),
      );
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
