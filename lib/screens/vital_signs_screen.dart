import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VitalSignsScreen extends StatefulWidget {
  const VitalSignsScreen({super.key});

  @override
  State<VitalSignsScreen> createState() => _VitalSignsScreenState();
}

class _VitalSignsScreenState extends State<VitalSignsScreen> with SingleTickerProviderStateMixin {
  Timer? _timer;
  final Random _random = Random();
  String? uid;

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      uid = user.uid;
      _startSendingData();
    }

    // Animación de corazón
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
      if (uid == null) return;

      final heartRate = 60 + _random.nextInt(40); // 60–100 bpm
      final oxygen = 95 + _random.nextDouble() * 5; // 95–100%

      FirebaseFirestore.instance
          .collection('vital_signs')
          .doc(uid)
          .collection('readings')
          .add({
        'ritmo_cardiaco': heartRate,
        'oxigenacion': oxygen,
        'timestamp': Timestamp.now(),
      });

      debugPrint('✅ Enviado: HR $heartRate, O2 $oxygen');
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.redAccent.shade100;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Signos Vitales'),
        centerTitle: true,
      ),
      body: uid == null
          ? const Center(child: Text('⚠️ Usuario no autenticado'))
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 💓 Corazón animado
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) => Transform.scale(
                      scale: _scaleAnimation.value,
                      child: const Icon(Icons.favorite, size: 48, color: Colors.redAccent),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Monitor activo',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Actualizando cada 10 seg.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  // 📈 Historial
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('vital_signs')
                          .doc(uid)
                          .collection('readings')
                          .orderBy('timestamp', descending: true)
                          .limit(5)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('Esperando datos...'));
                        }

                        return ListView.separated(
                          itemCount: snapshot.data!.docs.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final doc = snapshot.data!.docs[index];
                            final data = doc.data() as Map<String, dynamic>;

                            final heartRate = data['ritmo_cardiaco'];
                            final oxygen = data['oxigenacion'];
                            final timestamp = (data['timestamp'] as Timestamp).toDate();

                            return _vitalCard(
                              heartRate: heartRate,
                              oxygen: oxygen,
                              dateTime: timestamp,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _vitalCard({
    required int heartRate,
    required double oxygen,
    required DateTime dateTime,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.redAccent.shade100.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.shade100),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatTime(dateTime),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite, size: 16, color: Colors.redAccent),
                  const SizedBox(width: 6),
                  Text('$heartRate bpm', style: const TextStyle(fontSize: 14)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.air, size: 16, color: Colors.blueAccent),
                  const SizedBox(width: 6),
                  Text('${oxygen.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
