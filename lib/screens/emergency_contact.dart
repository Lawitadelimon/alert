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
            contactos = contactosFirestore.map((c) => ContactoEmergencia.fromMap(c)).toList();
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

    void eliminarContacto(int index) async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text('Confirmar eliminación'),
            ],
          ),
          content: const Text('¿Estás seguro de que deseas eliminar este contacto?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirm == true) {
        setState(() {
          contactos[index].dispose();
          contactos.removeAt(index);
        });

        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          final contactosList = contactos.map((c) => c.toMap()).toList();
          await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
            'contactos_emergencia': contactosList,
          });
        }
      }
    }

    bool validarCorreo(String correo) {
      final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      return regex.hasMatch(correo);
    }

    void showGreenDialog(String titulo, String mensaje) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('¡Excelente!', style: TextStyle(color: Colors.green)),
            ],
          ),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aceptar', style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
      );
    }

    void showInvalidEmailDialog(String correo) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('Correo inválido', style: TextStyle(color: Colors.red)),
            ],
          ),
          content: Text('El correo "$correo" no es válido.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aceptar', style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
      );
    }

    void verificarCorreo(ContactoEmergencia contacto) async {
      String correo = contacto.correo.text.trim();

      print("Verificando correo: $correo"); // Línea de depuración

      if (!validarCorreo(correo)) {
        showInvalidEmailDialog(correo);
        return;
      }

      contacto.verificado = true;
      setState(() {});

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        List<Map<String, String>> contactosList = contactos.map((c) => c.toMap()).toList();
        await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
          'contactos_emergencia': contactosList,
        });
      }

      showGreenDialog('Correo válido', 'Correo válido y registrado.');
    }

    void guardarContactos() async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario no autenticado')),
        );
        return;
      }

      if (contactos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agrega al menos un contacto antes de guardar')),
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

        showGreenDialog('¡Excelente!', 'Los contactos fueron guardados correctamente.');
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
                'Contactos de emergencia',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Divider(color: Colors.green),
              Expanded(
                child: ListView.builder(
                  itemCount: contactos.length,
                  itemBuilder: (context, index) {
                    final contacto = contactos[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        border: Border.all(color: Colors.green.shade700),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.shade200.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Nombre:', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: contacto.nombre,
                            decoration: InputDecoration(
                              hintText: 'Nombre del contacto',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.green.shade400),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.green.shade700),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text('Correo electrónico:', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: contacto.correo,
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (_) {
                                    setState(() {
                                      contacto.verificado = false;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'ejemplo@correo.com',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: Colors.green.shade400),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: Colors.green.shade700),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.verified),
                                color: contacto.verificado ? Colors.green : Colors.grey,
                                tooltip: contacto.verificado ? 'Correo verificado' : 'Verificar correo',
                                onPressed: () => verificarCorreo(contacto),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                tooltip: 'Eliminar contacto',
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
                    tooltip: 'Agregar contacto',
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: contactos.isEmpty ? null : guardarContactos,
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: contactos.isEmpty ? Colors.grey : Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
