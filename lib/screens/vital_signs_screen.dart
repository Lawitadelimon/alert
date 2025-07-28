import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'user_profile_watch_screen.dart';

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

      debugPrint('✅ Enviado automático: HR $heartRate, O2 $oxygen');
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

    debugPrint('📝 Enviado manual: HR $_heartRate, O2 $_oxygen');
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
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.shade400, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: Colors.green.shade700),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              valueWidget,
            ],
          ),
        ],
      ),
    );
  }

  Widget _compactButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return IconButton(
      iconSize: 14,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
      icon: Icon(icon, color: color),
      onPressed: onPressed,
      splashRadius: 14,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.green;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        centerTitle: true,
        title: const Text(
          'Signos Vitales',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          IconButton(
            iconSize: 20,
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserProfileWatchScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: const Icon(Icons.favorite, size: 40, color: Colors.redAccent),
                ),
                const SizedBox(height: 10),

                _vitalBlock(
                  icon: Icons.favorite,
                  label: 'Ritmo Cardíaco',
                  valueWidget: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _compactButton(icon: Icons.remove_circle, onPressed: _decreaseHeartRate, color: Colors.red),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: Text(
                            '$_heartRate bpm',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _compactButton(icon: Icons.add_circle, onPressed: _increaseHeartRate, color: Colors.green),
                      ],
                    ),
                  ),
                ),

                _vitalBlock(
                  icon: Icons.air,
                  label: 'Oxigenación',
                  valueWidget: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _compactButton(icon: Icons.remove_circle, onPressed: _decreaseOxygen, color: Colors.red),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: Text(
                            '${_oxygen.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _compactButton(icon: Icons.add_circle, onPressed: _increaseOxygen, color: Colors.green),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    minimumSize: const Size(100, 34),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                  onPressed: _toggleSending,
                  child: Text(
                    _isSending ? 'Pausar' : 'Reanudar',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
