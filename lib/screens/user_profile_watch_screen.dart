import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileWatchScreen extends StatefulWidget {
  const UserProfileWatchScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileWatchScreen> createState() => _UserProfileWatchScreenState();
}

class _UserProfileWatchScreenState extends State<UserProfileWatchScreen> {
  bool isLoading = true;
  String nombre = '';
  String tipoSangre = '';
  String alergias = '';
  String direccion = '';
  String edad = '';
  String sexo = '';
  List<dynamic> contactosEmergencia = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          nombre = data['nombre'] ?? '';
          tipoSangre = data['tipo_sangre'] ?? '';
          alergias = data['alergias'] ?? '';
          direccion = data['direccion1'] ?? '';
          edad = data['edad']?.toString() ?? '';
          sexo = data['sexo'] ?? '';
          contactosEmergencia = data['contactos_emergencia'] ?? [];
          isLoading = false;
        });
      }
    }
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : 'No especificado',
                  style: const TextStyle(fontSize: 16),
                ),
                const Divider(color: Colors.green, thickness: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactoTile(Map<String, dynamic> contacto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.contact_phone, color: Colors.green, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contacto['nombre'] ?? 'Sin nombre',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  contacto['telefono'] ?? 'Sin teléfono',
                  style: const TextStyle(fontSize: 14),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Colors.green,
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoTile(Icons.person, 'Nombre', nombre),
                  _infoTile(Icons.cake, 'Edad', edad),
                  _infoTile(Icons.male, 'Sexo', sexo),
                  _infoTile(Icons.bloodtype, 'Tipo de sangre', tipoSangre),
                  _infoTile(Icons.warning_amber_rounded, 'Alergias', alergias),
                  _infoTile(Icons.location_on, 'Dirección', direccion),
                  const SizedBox(height: 20),
                  const Text(
                    'Contactos de emergencia',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const Divider(color: Colors.green, thickness: 1),
                  contactosEmergencia.isEmpty
                      ? const Text('No hay contactos de emergencia registrados.')
                      : Column(
                          children: contactosEmergencia
                              .map<Widget>((c) => _contactoTile(Map<String, dynamic>.from(c)))
                              .toList(),
                        ),
                ],
              ),
            ),
    );
  }
}
