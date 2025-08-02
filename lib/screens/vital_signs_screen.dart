import 'dart:async';
import 'dart:math';

import 'package:alertmecel/services/email_emergency_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'user_profile_watch_screen.dart';

// ...importaciones sin cambios...

class VitalSignsWearScreen extends StatefulWidget {
  const VitalSignsWearScreen({super.key});

  @override
  State<VitalSignsWearScreen> createState() => _VitalSignsWearScreenState();
}

class _VitalSignsWearScreenState extends State<VitalSignsWearScreen> with SingleTickerProviderStateMixin {
  Timer? _timer;
  final Random _random = Random();
  String? uid;

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  bool _isSending = true;

  int _heartRate = 80;
  double _oxygen = 97.0;

  bool _alertaMostrada = false;
  Timer? _alertaResetTimer;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      uid = user.uid;
      _startSendingData();
      _sendDataManually();
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _alertaResetTimer?.cancel();
    super.dispose();
  }

  void _startSendingData() {
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (uid == null || !_isSending) return;

      final heartRate = 60 + _random.nextInt(40);
      final oxygen = 95 + _random.nextDouble() * 5;

      FirebaseFirestore.instance
          .collection('vital_signs')
          .doc(uid)
          .collection('readings')
          .add({
        'ritmo_cardiaco': heartRate,
        'oxigenacion': oxygen,
        'timestamp': Timestamp.now(),
      });

      _verificarAlerta(heartRate, oxygen);
    });
  }

  void _sendDataManually() {
    if (uid == null) return;

    FirebaseFirestore.instance
        .collection('vital_signs')
        .doc(uid)
        .collection('readings')
        .add({
      'ritmo_cardiaco': _heartRate,
      'oxigenacion': _oxygen,
      'timestamp': Timestamp.now(),
    });

    _verificarAlerta(_heartRate, _oxygen);
  }

  void _verificarAlerta(int heartRate, double oxygen) {
    String? mensaje;

    if (heartRate < 60) {
      mensaje = "Ritmo cardíaco bajo: $heartRate bpm.";
    } else if (heartRate > 100) {
      mensaje = "Ritmo cardíaco alto: $heartRate bpm.";
    }

    if (oxygen < 90) {
      mensaje = "${mensaje != null ? "$mensaje\n" : ""}¿Estás bien? Tu oxigenación es baja: ${oxygen.toStringAsFixed(0)}%.";
    }

    if (mensaje != null) {
      _mostrarAlerta(mensaje);
    }
  }

  Future<void> _mostrarAlerta(String mensaje) async {
    if (_alertaMostrada) return;

    _alertaMostrada = true;

    _alertaResetTimer?.cancel();
    _alertaResetTimer = Timer(const Duration(seconds: 10), () {
      _alertaMostrada = false;
    });

    int secondsLeft = 10;
    Timer? countdownTimer;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            countdownTimer ??= Timer.periodic(const Duration(seconds: 1), (timer) async {
              if (secondsLeft == 0) {
                timer.cancel();
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                  await EmailEmergencyService.enviarCorreoEmergencia(
                    mensaje: mensaje,
                    ubicacion: 'https://maps.google.com/?q=LAT,LNG',
                  );
                }
              } else {
                setState(() {
                  secondsLeft--;
                });
              }
            });

            return AlertDialog(
              backgroundColor: Colors.green.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.green.shade300, width: 1),
              ),
              insetPadding: const EdgeInsets.symmetric(horizontal: 8),
              titlePadding: const EdgeInsets.only(top: 8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              actionsPadding: const EdgeInsets.only(bottom: 4),
              title: const Text(
                "⚠️ Alerta",
                style: TextStyle(fontSize: 10, color: Colors.green),
                textAlign: TextAlign.center,
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      mensaje,
                      style: const TextStyle(fontSize: 9, color: Colors.black87, height: 1.2),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Alertando en $secondsLeft s',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              actions: [
                Center(
                  child: TextButton(
                    onPressed: () {
                      countdownTimer?.cancel();
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green.shade600,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text("Estoy bien", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    _alertaMostrada = false;
  }

  void _toggleSending() {
    setState(() {
      _isSending = !_isSending;
    });
  }

  void _decreaseHeartRate() {
    if (_heartRate > 30) {
      setState(() {
        _heartRate -= 5;
      });
      _sendDataManually();
    }
  }

  void _increaseHeartRate() {
    if (_heartRate < 150) {
      setState(() {
        _heartRate += 5;
      });
      _sendDataManually();
    }
  }

  void _decreaseOxygen() {
    if (_oxygen > 50) {
      setState(() {
        _oxygen -= 1;
      });
      _sendDataManually();
    }
  }

  void _increaseOxygen() {
    if (_oxygen < 100) {
      setState(() {
        _oxygen += 1;
      });
      _sendDataManually();
    }
  }

  Widget _vitalBlock({
    required IconData icon,
    required String label,
    required Widget valueWidget,
    required double iconSize,
    required double textSizeLabel,
    required double textSizeValue,
  }) {
    Color iconColor = icon == Icons.favorite
        ? Colors.red
        : (icon == Icons.air ? Colors.blue.shade500 : Colors.black54);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        border: Border.all(color: Colors.green.shade600, width: 1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          SizedBox(width: iconSize + 6, child: Icon(icon, color: iconColor, size: iconSize)),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: textSizeLabel, fontWeight: FontWeight.w600)),
                const SizedBox(height: 1),
                DefaultTextStyle(
                  style: TextStyle(fontSize: textSizeValue, fontWeight: FontWeight.bold),
                  child: valueWidget,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    final double iconSize = screenWidth < 350 ? 18 : 22;
    final double textSizeLabel = screenWidth < 350 ? 9 : 10;
    final double textSizeValue = screenWidth < 350 ? 11 : 13;
    final double iconButtonSize = screenWidth < 350 ? 16 : 18;
    final double heartIconSize = screenWidth < 350 ? 50 : 60;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(32),
        child: AppBar(
          title: const Text('Signos Vitales', style: TextStyle(fontSize: 12)),
          backgroundColor: Colors.green,
          actions: [
            IconButton(
              icon: const Icon(Icons.person_outline, size: 16),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const UserProfileWatchScreen()));
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
            const SizedBox(width: 4),
          ],
          centerTitle: true,
          elevation: 1,
          toolbarHeight: 32,
        ),
      ),
      backgroundColor: Colors.green.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Icon(
                Icons.favorite,
                color: _heartRate < 60 || _heartRate > 100 || _oxygen < 90 ? Colors.red : Colors.green,
                size: heartIconSize,
              ),
            ),
            const SizedBox(height: 6),
            _vitalBlock(
              icon: Icons.favorite,
              label: 'Ritmo Cardiaco',
              valueWidget: Row(
                children: [
                  Text('$_heartRate', style: TextStyle(color: Colors.black)),
                  const SizedBox(width: 4),
                  Text('bpm', style: TextStyle(fontSize: textSizeLabel, color: Colors.black)),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    iconSize: iconButtonSize,
                    color: Colors.red,
                    onPressed: _decreaseHeartRate,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints.tightFor(width: iconButtonSize + 2, height: iconButtonSize + 2),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    iconSize: iconButtonSize,
                    color: Colors.green,
                    onPressed: _increaseHeartRate,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints.tightFor(width: iconButtonSize + 2, height: iconButtonSize + 2),
                  ),
                ],
              ),
              iconSize: iconSize,
              textSizeLabel: textSizeLabel,
              textSizeValue: textSizeValue,
            ),
            _vitalBlock(
              icon: Icons.air,
              label: 'Oxigenación',
              valueWidget: Row(
                children: [
                  Text('${_oxygen.toStringAsFixed(1)}%', style: TextStyle(color: Colors.black)),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    iconSize: iconButtonSize,
                    color: Colors.red,
                    onPressed: _decreaseOxygen,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints.tightFor(width: iconButtonSize + 2, height: iconButtonSize + 2),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    iconSize: iconButtonSize,
                    color: Colors.green,
                    onPressed: _increaseOxygen,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints.tightFor(width: iconButtonSize + 2, height: iconButtonSize + 2),
                  ),
                ],
              ),
              iconSize: iconSize,
              textSizeLabel: textSizeLabel,
              textSizeValue: textSizeValue,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _toggleSending,
              icon: Icon(_isSending ? Icons.pause_circle_filled_outlined : Icons.play_circle_outline),
              label: Text(_isSending ? "Pausar" : "Reanudar", style: const TextStyle(fontSize: 11)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSending ? Colors.green.shade600 : Colors.grey.shade600,
                foregroundColor: Colors.white,
                minimumSize: const Size(120, 32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
