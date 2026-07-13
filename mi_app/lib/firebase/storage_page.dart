import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Demo de Firebase Storage.
///
/// Muestra:
/// - Selección de imagen local con `image_picker`.
/// - Subida a una ruta aislada por usuario: `users/{uid}/uploads/...`.
/// - Observación del progreso de subida con `UploadTask.snapshotEvents`.
/// - Descarga de la URL pública (`getDownloadURL`) y visualización.
///
/// Requisito previo: Auth habilitado y reglas de Storage que permitan
/// al usuario autenticado leer/escribir en su prefijo `users/{uid}/*`.
class StoragePage extends StatefulWidget {
  const StoragePage({super.key});

  @override
  State<StoragePage> createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  XFile? _picked;
  double _progress = 0;
  String? _downloadUrl;
  String? _message;
  bool _busy = false;

  Future<void> _pick() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file != null) setState(() => _picked = file);
  }

  Future<void> _upload() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _picked == null) return;
    setState(() {
      _busy = true;
      _message = null;
      _progress = 0;
    });
    final ref = FirebaseStorage.instance.ref(
      'users/${user.uid}/uploads/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    final task = ref.putFile(File(_picked!.path));
    task.snapshotEvents.listen(
      (snap) {
        final total = snap.totalBytes;
        if (total > 0) {
          setState(() => _progress = snap.bytesTransferred / total);
        }
      },
      onError: (e) {
        if (mounted) {
          setState(() {
            _busy = false;
            _message = 'Error: $e';
          });
        }
      },
    );
    try {
      final url = await task;
      final downloadUrl = await url.ref.getDownloadURL();
      if (mounted) {
        setState(() {
          _downloadUrl = downloadUrl;
          _busy = false;
          _message = 'Subida completada';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _message = 'Error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Storage')),
      body: user == null
          ? const Center(
              child: Text('Inicia sesión en Auth para subir archivos.'),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Ruta destino: users/${user.uid}/uploads/…',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  if (_picked != null)
                    Image.file(File(_picked!.path), height: 220)
                  else
                    Container(
                      height: 220,
                      color: Colors.black12,
                      child: const Center(child: Text('Sin imagen seleccionada')),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _busy ? null : _pick,
                        icon: const Icon(Icons.image),
                        label: const Text('Elegir imagen'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: (_busy || _picked == null)
                            ? null
                            : _upload,
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text('Subir'),
                      ),
                    ],
                  ),
                  if (_busy) ...[
                    const SizedBox(height: 12),
                    LinearProgressIndicator(value: _progress),
                    Text('${(_progress * 100).toStringAsFixed(0)} %'),
                  ],
                  if (_downloadUrl != null) ...[
                    const SizedBox(height: 16),
                    const Text('URL pública:'),
                    Text(
                      _downloadUrl!,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Image.network(_downloadUrl!, height: 200),
                  ],
                  if (_message != null) ...[
                    const SizedBox(height: 12),
                    Text(_message!),
                  ],
                ],
              ),
            ),
    );
  }
}