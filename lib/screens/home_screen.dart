import 'package:alertmecel/screens/emergency_contact.dart';
import 'package:alertmecel/screens/user_profile_screen.dart';
import 'package:alertmecel/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  final VoidCallback onLogout;

  const HomeScreen({
    Key? key,
    required this.userId,
    required this.onLogout,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool _menuOpen = false;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _toggleMenu(bool open) {
    setState(() => _menuOpen = open);
    if (open) {
      _rotationController.forward();
    } else {
      _rotationController.reverse();
    }
  }

  Future<void> _deleteAllReadings() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar borrado'),
        content: const Text(
            '¿Estás seguro de que quieres borrar todo el historial de lecturas? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            child: const Text('Borrar'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final batch = FirebaseFirestore.instance.batch();
    final readingsCollection = FirebaseFirestore.instance
        .collection('vital_signs')
        .doc(widget.userId)
        .collection('readings');

    final snapshot = await readingsCollection.get();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    final uid = widget.userId;
    final double buttonHeight = 80;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 2,
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('usuarios')
              .doc(uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Cargando...');
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text('Hola, Usuario');
            }
            final data = snapshot.data!.data() as Map<String, dynamic>?;
            final username = data?['username'] ?? 'Usuario';
            return Text(
              'Hola, $username',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            );
          },
        ),
        centerTitle: true,
        actions: [
          Theme(
            data: Theme.of(context).copyWith(
              popupMenuTheme: PopupMenuThemeData(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.white,
              ),
              splashColor: Colors.green.withOpacity(0.2),
              highlightColor: Colors.green.withOpacity(0.1),
              hoverColor: Colors.green.withOpacity(0.1),
            ),
            child: PopupMenuButton<String>(
              icon: AnimatedBuilder(
                animation: _rotationController,
                builder: (_, child) => Transform.rotate(
                  angle: _rotationController.value * 0.5 * 3.14,
                  child: child,
                ),
                child: const Icon(Icons.more_vert, color: Colors.white),
              ),
              onOpened: () => _toggleMenu(true),
              onCanceled: () => _toggleMenu(false),
              onSelected: (value) async {
                _toggleMenu(false);

                if (value == 'perfil') {
                  final user = FirebaseAuth.instance.currentUser;
                  final userDoc = await FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(uid)
                      .get();

                  final username = userDoc.data()?['username'] ?? 'Usuario';
                  final email = user?.email ?? 'No disponible';

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      contentPadding: const EdgeInsets.all(20),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.green,
                            child: Icon(Icons.person, size: 30, color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            username,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.email, size: 16, color: Colors.grey),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  email,
                                  style: const TextStyle(color: Colors.black54),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      actions: [
                        TextButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close, color: Colors.green),
                          label: const Text(
                            'Cerrar',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (value == 'logout') {
                  await FirebaseAuth.instance.signOut();
                  if (!mounted) return;
                  widget.onLogout();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem<String>(
                  value: 'perfil',
                  child: Text('Ver perfil'),
                ),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Cerrar sesión'),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido a AlertMe',
              style: AppTheme.subtitleText.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('usuarios')
                  .doc(uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(color: Colors.green);
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Text(
                    'Usuario',
                    style: AppTheme.titleText.copyWith(
                      color: AppTheme.primaryColor,
                      fontSize: 20,
                    ),
                  );
                }
                final data = snapshot.data!.data() as Map<String, dynamic>?;
                final username = data?['username'] ?? 'Usuario';
                return Text(
                  username,
                  style: AppTheme.titleText.copyWith(
                    color: AppTheme.primaryColor,
                    fontSize: 20,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: buttonHeight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserProfileScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.person, size: 20),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Información personal',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: buttonHeight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EmergencyContactsPage(userId: uid),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.contact_phone, size: 20),
                          SizedBox(height: 6),
                          Text(
                            'Contactos de emergencia',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lecturas recientes',
                    style: AppTheme.subtitleText.copyWith(fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    tooltip: 'Borrar todo el historial',
                    onPressed: _deleteAllReadings,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
  child: StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('vital_signs')
        .doc(uid)
        .collection('readings')
        .orderBy('timestamp', descending: true)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator(color: Colors.green));
      }

      final docs = snapshot.data?.docs ?? [];

      if (docs.isEmpty) {
        return Center(
          child: Text(
            'Sin datos aún.',
            style: AppTheme.bodyText.copyWith(color: Colors.grey[600]),
          ),
        );
      }

      return ListView.separated(
        itemCount: docs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final data = docs[index].data() as Map<String, dynamic>;
          final pulso = data['ritmo_cardiaco'] ?? 'N/A';
          final oxigeno = data['oxigenacion'] ?? 'N/A';
          final fecha = (data['timestamp'] as Timestamp?)?.toDate();

          return Dismissible(
            key: Key(docs[index].id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: Colors.red,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              return await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmar borrado'),
                  content: const Text('¿Eliminar esta lectura?'),
                  actions: [
                    TextButton(
                      child: const Text('Cancelar'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    ElevatedButton(
                      child: const Text('Eliminar'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (_) async {
              await FirebaseFirestore.instance
                  .collection('vital_signs')
                  .doc(uid)
                  .collection('readings')
                  .doc(docs[index].id)
                  .delete();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Lectura eliminada')),
              );
            },
            child: Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: const Icon(Icons.favorite, color: AppTheme.primaryColor),
                ),
                title: Text(
                  'Pulso: $pulso bpm',
                  style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Oxígeno: $oxigeno%',
                  style: AppTheme.bodyText.copyWith(color: Colors.grey[700]),
                ),
                trailing: Text(
                  fecha != null
                      ? '${fecha.day.toString().padLeft(2, '0')}/'
                        '${fecha.month.toString().padLeft(2, '0')}/'
                        '${fecha.year} '
                        '${fecha.hour.toString().padLeft(2, '0')}:'
                        '${fecha.minute.toString().padLeft(2, '0')}'
                      : '',
                  style: AppTheme.captionText,
                ),
              ),
            ),
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
}
