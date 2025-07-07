import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyContactsPage extends StatefulWidget {
  const EmergencyContactsPage({super.key, required String userId});

  @override
  State<EmergencyContactsPage> createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<EmergencyContactsPage> {
  final List<Map<String, TextEditingController>> contactos = [];

  @override
  void initState() {
    super.initState();
    cargarContactos();
  }

  void cargarContactos() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
      final data = doc.data();
      if (data != null && data['contactos_emergencia'] != null) {
        final List<dynamic> contactosFirestore = data['contactos_emergencia'];
        setState(() {
          contactos.clear();
          for (var contacto in contactosFirestore) {
            contactos.add({
              'nombre': TextEditingController(text: contacto['nombre']),
              'telefono': TextEditingController(text: contacto['telefono']),
            });
          }
        });
      }
    }
  }

  void agregarContacto() {
    if (contactos.length < 3) {
      setState(() {
        contactos.add({
          'nombre': TextEditingController(),
          'telefono': TextEditingController(),
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Máximo 3 contactos permitidos')),
      );
    }
  }

  void eliminarContacto(int index) {
    setState(() {
      contactos.removeAt(index);
    });
  }

void guardarContactos() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuario no autenticado')),
    );
    return;
  }

  List<Map<String, String>> contactosList = [];

  for (var contacto in contactos) {
    String nombre = contacto['nombre']!.text.trim();
    String telefono = contacto['telefono']!.text.trim();

    if (nombre.isEmpty || telefono.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos antes de guardar')),
      );
      return;
    }

    contactosList.add({
      'nombre': nombre,
      'telefono': telefono,
    });
  }

  try {
    await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
      'contactos_emergencia': contactosList,
    });

    // Mostrar cuadro de diálogo de éxito
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡Excelente!'),
        content: const Text('Los contactos fueron guardados correctamente.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo
              Navigator.of(context).pop(); // Regresa a la pantalla anterior~
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al guardar: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AlertMe'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.green[400],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Contacto de emergencia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: contactos.length,
                itemBuilder: (context, index) {
                  final contacto = contactos[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Nombre:'),
                        ),
                        TextField(
                          controller: contacto['nombre'],
                          decoration: const InputDecoration(
                            hintText: 'Nombre del contacto',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Teléfono:'),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: contacto['telefono'],
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  hintText: 'Número de teléfono',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => eliminarContacto(index),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'add_contact',
                  onPressed: agregarContacto,
                  backgroundColor: Colors.green,
                  mini: true,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: guardarContactos,
              icon: const Icon(Icons.save),
              label: const Text('Guardar'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            
          ],
        ),
      ),
    );
  }
}
