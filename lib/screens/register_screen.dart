import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  final Function(String uid) onRegisterSuccess;

  const RegisterScreen({Key? key, required this.onRegisterSuccess}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  bool isLoading = false;
  String? error;

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _register() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final username = usernameController.text.trim();

    if (!_isValidEmail(email)) {
      setState(() {
        error = 'Ingresa un correo electrónico válido.';
        isLoading = false;
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        error = 'La contraseña debe tener al menos 6 caracteres.';
        isLoading = false;
      });
      return;
    }

    if (username.isEmpty) {
      setState(() {
        error = 'Ingresa un nombre de usuario.';
        isLoading = false;
      });
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user?.uid;

      if (uid != null) {
        await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
          'email': email,
          'username': username,
          'contactos_emergencia': [],
        });

        if (!mounted) return;

        widget.onRegisterSuccess(uid); // ✅ Redirige al HomeScreen
      } else {
        setState(() {
          error = 'No se pudo obtener el UID del usuario.';
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message;
      });
    } catch (e) {
      setState(() {
        error = 'Error inesperado.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Nombre de usuario'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Correo electrónico'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _register,
                    child: const Text('Registrarse'),
                  ),
          ],
        ),
      ),
    );
  }
}
