import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactoEmergencia {
  TextEditingController nombre;
  TextEditingController correo;
  bool verificado;

  ContactoEmergencia({
    required this.nombre,
    required this.correo,
    this.verificado = false,
  });

  Map<String, String> toMap() {
    return {
      'nombre': nombre.text.trim(),
      'correo': correo.text.trim(),
    };
  }

  static ContactoEmergencia fromMap(Map<String, dynamic> map) {
    return ContactoEmergencia(
      nombre: TextEditingController(text: map['nombre'] ?? ''),
      correo: TextEditingController(text: map['correo'] ?? ''),
      verificado: true,
    );
  }

  void dispose() {
    nombre.dispose();
    correo.dispose();
  }
}

class EmergencyContactsPage extends StatefulWidget {
  const EmergencyContactsPage({super.key, required String userId});

  @override
  State<EmergencyContactsPage> createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<EmergencyContactsPage> {
  List<ContactoEmergencia> contactos = [];

  @override
  void initState() {
    super.initState();
    cargarContactos();
  }

  @override
  void dispose() {
    for (var contacto in contactos) {
      contacto.dispose();
    }
    super.dispose();
  }

  void cargarContactos() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
      final data = doc.data();
      if (data != null && data['contactos_emergencia'] != null) {
        final List<dynamic> contactosFirestore = data['contactos_emergencia'];
        setState(() {
          contactos = contactosFirestore
              .map((c) => ContactoEmergencia.fromMap(c))
              .toList();
        });
      }
    }
  }

  void agregarContacto() {
    if (contactos.length < 3) {
      setState(() {
        contactos.add(ContactoEmergencia(
          nombre: TextEditingController(),
          correo: TextEditingController(),
          verificado: false,
        ));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Máximo 3 contactos permitidos')),
      );
    }
  }

  void eliminarContacto(int index) {
    setState(() {
      contactos[index].dispose();
      contactos.removeAt(index);
    });
  }

  bool validarCorreo(String correo) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(correo);
  }

  void verificarCorreo(ContactoEmergencia contacto) {
    String correo = contacto.correo.text.trim();

    if (!validarCorreo(correo)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Correo inválido: $correo')),
      );
      return;
    }

    contacto.verificado = true;
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Correo válido y registrado')),
    );
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
      String nombre = contacto.nombre.text.trim();
      String correo = contacto.correo.text.trim();

      if (nombre.isEmpty || correo.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Completa todos los campos antes de guardar')),
        );
        return;
      }

      if (!contacto.verificado) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('El correo $correo no ha sido verificado')),
        );
        return;
      }

      contactosList.add(contacto.toMap());
    }

    try {
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
        'contactos_emergencia': contactosList,
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¡Excelente!'),
          content: const Text('Los contactos fueron guardados correctamente.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
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
        backgroundColor: Colors.green,
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
                          controller: contacto.nombre,
                          decoration: const InputDecoration(
                            hintText: 'Nombre del contacto',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Correo electrónico:'),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: contacto.correo,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  hintText: 'ejemplo@correo.com',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.verified),
                              color: contacto.verificado ? Colors.green : Colors.grey,
                              onPressed: () => verificarCorreo(contacto),
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
