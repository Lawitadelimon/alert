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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : 'No especificado',
                  style: const TextStyle(fontSize: 14),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.contact_phone, color: Colors.green, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contacto['nombre'] ?? 'Sin nombre',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.email, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        contacto['correo'] ?? 'Sin correo',
                        style: const TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoTile(Icons.person, 'Nombre', nombre),
                  _infoTile(Icons.cake, 'Edad', edad),
                  _infoTile(Icons.male, 'Sexo', sexo),
                  _infoTile(Icons.bloodtype, 'Tipo de sangre', tipoSangre),
                  _infoTile(Icons.warning_amber_rounded, 'Alergias', alergias),
                  _infoTile(Icons.location_on, 'Dirección', direccion),
                  const SizedBox(height: 14),
                  const Text(
                    'Contactos de emergencia',
                    style: TextStyle(
                      fontSize: 16,
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
