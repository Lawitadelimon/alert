import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VitalSignsScreen extends StatefulWidget {
  const VitalSignsScreen({super.key});

  @override
  State<VitalSignsScreen> createState() => _VitalSignsScreenState();
}

class _VitalSignsScreenState extends State<VitalSignsScreen> {
  final TextEditingController _tokenController = TextEditingController();
  String? userToken;
  Timer? _timer;

  final Random _random = Random();

  @override
  void dispose() {
    _timer?.cancel();
    _tokenController.dispose();
    super.dispose();
  }

  void _startSendingData() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (userToken == null || userToken!.isEmpty) return;

      final ritmoCardiaco = 60 + _random.nextInt(40); // 60–100 bpm
      final oxigenacion = 95 + _random.nextInt(5); // 95–99 %

      FirebaseFirestore.instance
          .collection('vital_signs')
          .doc(userToken)
          .collection('readings')
          .add({
        'ritmo_cardiaco': ritmoCardiaco,
        'oxigenacion': oxigenacion,
        'timestamp': Timestamp.now(),
      });

      debugPrint('Enviado: Pulso $ritmoCardiaco bpm, Oxígeno $oxigenacion%');
    });
  }

  void _submitToken() {
    final token = _tokenController.text.trim();
    if (token.isNotEmpty) {
      setState(() {
        userToken = token;
      });
      _startSendingData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signos Vitales'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: userToken == null
              ? Column(
                  children: [
                    const Text("Ingresa el token del usuario:"),
                    TextField(
                      controller: _tokenController,
                      decoration: const InputDecoration(labelText: 'Token/UID'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _submitToken,
                      child: const Text('Empezar'),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Enviando signos vitales...',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Usuario: $userToken',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
