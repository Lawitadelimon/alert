import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmailEmergencyService {
  static const String serviceId = 'service_s01ddk8';
  static const String templateId = 'template_15y6fae';
  static const String publicKey = 'DqJYznKNAuzQBDzMA';

  EmailEmergencyService(String mensaje);

  static Future<void> enviarCorreoEmergencia({
    required String mensaje,
    required String ubicacion,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("❌ Usuario no autenticado");
      return;
    }

    final uid = user.uid;

    try {
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
      final data = doc.data();

      if (data == null || !data.containsKey('contactos_emergencia')) {
        print("❌ No se encontraron contactos");
        return;
      }

      final List<dynamic> contactos = data['contactos_emergencia'];

      if (contactos.isEmpty) {
        print("❌ Lista de contactos vacía");
        return;
      }

      final nombreUsuario = data['nombre'] ?? 'Usuario desconocido';

      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

      for (final contacto in contactos) {
        final correo = contacto['correo']?.toString();
        if (correo == null || correo.isEmpty) continue;

        final response = await http.post(
          url,
          headers: {
            'origin': 'http://localhost',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'service_id': serviceId,
            'template_id': templateId,
            'user_id': publicKey,
            'template_params': {
              'to_email': correo,
              'mensaje': mensaje,
              'ubicacion': ubicacion,
              'nombre_usuario': nombreUsuario,
            },
          }),
        );

        if (response.statusCode == 200) {
          print("✅ Correo enviado correctamente a $correo");
        } else {
          print("❌ Error al enviar correo a $correo: ${response.body}");
        }
      }
    } catch (e) {
      print("❌ Error general: $e");
    }
  }
}
