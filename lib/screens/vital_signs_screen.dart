import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VitalSignsScreen extends StatefulWidget {
  const VitalSignsScreen({super.key}); // ¡Sin userId!

  @override
  State<VitalSignsScreen> createState() => _VitalSignsScreenState();
}

class _VitalSignsScreenState extends State<VitalSignsScreen> {
  Timer? _timer;
  final Random _random = Random();
  String? uid;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      uid = user.uid;
      _startSendingData();
    } else {
      // Por si ocurre algo raro con el auth
      debugPrint('⚠️ Usuario no autenticado');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startSendingData() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (uid == null || uid!.isEmpty) return;

      final heartRate = 60 + _random.nextInt(40); // 60–100
      final temperature = 36 + _random.nextDouble(); // 36–37°C

      FirebaseFirestore.instance
          .collection('vital_signs')
          .doc(uid)
          .collection('readings')
          .add({
        'ritmo_cardiaco': heartRate,
        'oxigenacion': temperature,
        'timestamp': Timestamp.now(),
      });

      debugPrint('✅ Datos enviados: HR $heartRate, O2 $temperature');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signos Vitales'),
        centerTitle: true,
      ),
      body: Center(
        child: uid == null
            ? const Text('Error: Usuario no autenticado')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Enviando signos vitales...',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  Text('Usuario: $uid'),
                ],
              ),
      ),
    );
  }
}
