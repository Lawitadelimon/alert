import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key, required String userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final nombreController = TextEditingController();
  final alergiasController = TextEditingController();
  final direccion1Controller = TextEditingController();
  final edadController = TextEditingController();

  final List<String> tiposSangre = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> opcionesSexo = ['H', 'M'];

  String? tipoSangreSeleccionado;
  String? sexoSeleccionado;

  bool isLoading = true;

  List<dynamic> contactosEmergencia = [];

  @override
  void initState() {
    super.initState();
    cargarDatosUsuario();
  }

  Future<void> cargarDatosUsuario() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          nombreController.text = data['nombre'] ?? '';
          tipoSangreSeleccionado = tiposSangre.contains(data['tipo_sangre']) ? data['tipo_sangre'] : null;
          alergiasController.text = data['alergias'] ?? '';
          direccion1Controller.text = data['direccion1'] ?? '';
          sexoSeleccionado = opcionesSexo.contains(data['sexo']) ? data['sexo'] : null;
          edadController.text = data['edad'] ?? '';
          contactosEmergencia = data['contactos_emergencia'] ?? [];
        });
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    nombreController.dispose();
    alergiasController.dispose();
    direccion1Controller.dispose();
    edadController.dispose();
    super.dispose();
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      'Mis Datos Personales',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.green),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildTextField('Nombre *', nombreController),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<String>(
                                value: tiposSangre.contains(tipoSangreSeleccionado) ? tipoSangreSeleccionado : null,
                                decoration: const InputDecoration(
                                  labelText: 'Tipo de sangre *',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) => value == null ? 'Selecciona un tipo de sangre' : null,
                                items: tiposSangre.map((tipo) {
                                  return DropdownMenuItem(
                                    value: tipo,
                                    child: Text(tipo),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    tipoSangreSeleccionado = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 10),
                              _buildTextField('Alergias o enfermedades *', alergiasController),
                              _buildTextField('Dirección *', direccion1Controller),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: opcionesSexo.contains(sexoSeleccionado) ? sexoSeleccionado : null,
                                      decoration: const InputDecoration(
                                        labelText: 'Sexo *',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) => value == null ? 'Selecciona sexo' : null,
                                      items: opcionesSexo.map((sexo) {
                                        return DropdownMenuItem(
                                          value: sexo,
                                          child: Text(sexo),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          sexoSeleccionado = value;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField('Edad *', edadController),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              /// CONTACTOS DE EMERGENCIA
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Contactos de emergencia:',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                              const SizedBox(height: 8),
                              contactosEmergencia.isEmpty
                                  ? const Text('No hay contactos de emergencia registrados.')
                                  : Column(
                                      children: contactosEmergencia.map<Widget>((contacto) {
                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.green[100],
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.green),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.person, color: Colors.green),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  '${contacto['nombre']} - ${contacto['telefono']}',
                                                  style: const TextStyle(fontSize: 16),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),

                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: IconButton(
                                  onPressed: guardarDatosUsuario,
                                  icon: const Icon(Icons.check_circle, color: Colors.green, size: 36),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
      ),
    );
  }

  Future<void> guardarDatosUsuario() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Formulario incompleto. Revisa los campos obligatorios.')),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'nombre': nombreController.text,
        'tipo_sangre': tipoSangreSeleccionado ?? '',
        'alergias': alergiasController.text,
        'direccion1': direccion1Controller.text,
        'sexo': sexoSeleccionado ?? '',
        'edad': edadController.text,
        'actualizado': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('¡Excelente!'),
              content: const Text('Tus datos fueron guardados correctamente.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            );
          },
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: usuario no autenticado')),
      );
    }
  }
}
