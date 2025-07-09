import 'package:alertmecel/screens/home_screen.dart';
import 'package:alertmecel/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  final void Function(String userId) onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  String? error;

  Future<void> _login() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = userCredential.user?.uid;
      if (uid != null) {
        if (!mounted) return;
        widget.onLoginSuccess(uid); // ✅ Notifica al padre (main.dart)
      } else {
        setState(() {
          error = 'No se pudo obtener el usuario.';
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

  void _showResetPasswordDialog() {
    final TextEditingController resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        bool sending = false;
        String? resetError;
        return StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            title: const Text('Restablecer contraseña'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: resetEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                if (resetError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(resetError!, style: const TextStyle(color: Colors.red)),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: sending ? null : () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: sending
                    ? null
                    : () async {
                        final email = resetEmailController.text.trim();
                        if (email.isEmpty) {
                          setStateDialog(() {
                            resetError = 'Por favor ingresa un correo.';
                          });
                          return;
                        }
                        setStateDialog(() {
                          sending = true;
                          resetError = null;
                        });
                        try {
                          await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Correo de restablecimiento enviado')),
                            );
                          }
                        } on FirebaseAuthException catch (e) {
                          setStateDialog(() {
                            resetError = e.message;
                            sending = false;
                          });
                        } catch (e) {
                          setStateDialog(() {
                            resetError = 'Error inesperado.';
                            sending = false;
                          });
                        }
                      },
                child: sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enviar'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
                    onPressed: _login,
                    child: const Text('Iniciar sesión'),
                  ),
            TextButton(
              onPressed: _showResetPasswordDialog,
              child: const Text('¿Olvidaste tu contraseña?'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RegisterScreen(
                      onRegisterSuccess: widget.onLoginSuccess, // ✅ Pasa la función también al registro
                    ),
                  ),
                );
              },
              child: const Text('Crear cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}
