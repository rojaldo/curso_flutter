import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Demo de Cloud Firestore.
///
/// Muestra:
/// - Subcolección por usuario (`users/{uid}/notes`) — aislamiento por sesión.
/// - Inserción (`add`) y borrado (`delete`) de documentos.
/// - Suscripción en tiempo real con `snapshots()` vía [StreamBuilder]:
///   cualquier cambio en Firestore se refleja al instante sin recargar.
///
/// Requisito previo: tener Auth habilitado (la página pide login si no lo hay)
/// y Firestore en modo de prueba o con reglas que permitan leer/escribir
/// al usuario autenticado.
class FirestorePage extends StatefulWidget {
  const FirestorePage({super.key});

  @override
  State<FirestorePage> createState() => _FirestorePageState();
}

class _FirestorePageState extends State<FirestorePage> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  CollectionReference<Map<String, dynamic>> _notesRef(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notes');
  }

  Future<void> _add(String uid) async {
    final text = _text.text.trim();
    if (text.isEmpty) return;
    await _notesRef(uid).add({
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
    _text.clear();
  }

  Future<void> _delete(String uid, String docId) async {
    await _notesRef(uid).doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Cloud Firestore')),
      body: user == null
          ? const Center(
              child: Text('Inicia sesión en Auth para usar Firestore.'),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _text,
                          decoration: const InputDecoration(
                            labelText: 'Nueva nota',
                          ),
                          onSubmitted: (_) => _add(user.uid),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _add(user.uid),
                        icon: const Icon(Icons.add_circle),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _notesRef(user.uid)
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (context, snap) {
                        if (snap.hasError) {
                          return Center(child: Text('Error: ${snap.error}'));
                        }
                        if (snap.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final docs = snap.data?.docs ?? const [];
                        if (docs.isEmpty) {
                          return const Center(
                            child: Text('Sin notas. Añade la primera.'),
                          );
                        }
                        return ListView.separated(
                          itemCount: docs.length,
                          separatorBuilder: (_, _) =>
                              const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final doc = docs[i];
                            final text = (doc.data()['text'] ?? '') as String;
                            return ListTile(
                              title: Text(text),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _delete(user.uid, doc.id),
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