import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Demo de Supabase Storage.
///
/// Muestra:
/// - Selección de imagen local con `image_picker`.
/// - Subida a un bucket público (`demo-uploads`) con `upload()`.
/// - Obtención de la URL pública (`getPublicUrl`).
///
/// Nota: a diferencia de Firebase Storage, el cliente de Supabase no expone
/// un callback de progreso de subida en esta versión; se muestra un spinner
/// indeterminado mientras sube.
///
/// Requisito previo: Auth habilitado y bucket `demo-uploads` con políticas
/// que permitan al usuario autenticado subir y a cualquiera leer (creados
/// en la migración inicial).
class SupabaseStoragePage extends StatefulWidget {
  const SupabaseStoragePage({super.key});

  @override
  State<SupabaseStoragePage> createState() => _SupabaseStoragePageState();
}

class _SupabaseStoragePageState extends State<SupabaseStoragePage> {
  XFile? _picked;
  String? _publicUrl;
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
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || _picked == null) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    final path = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    try {
      await Supabase.instance.client.storage.from('demo-uploads').upload(
            path,
            File(_picked!.path),
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: false,
            ),
          );
      final url = Supabase.instance.client.storage
          .from('demo-uploads')
          .getPublicUrl(path);
      if (mounted) {
        setState(() {
          _publicUrl = url;
          _busy = false;
          _message = 'Subida completada';
        });
      }
    } on StorageException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _message = e.message;
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
    final user = Supabase.instance.client.auth.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Supabase Storage')),
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
                    'Bucket destino: demo-uploads/${user.id}/…',
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
                        onPressed: (_busy || _picked == null) ? null : _upload,
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text('Subir'),
                      ),
                    ],
                  ),
                  if (_busy) ...[
                    const SizedBox(height: 12),
                    const Center(child: CircularProgressIndicator()),
                  ],
                  if (_publicUrl != null) ...[
                    const SizedBox(height: 16),
                    const Text('URL pública:'),
                    Text(
                      _publicUrl!,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Image.network(_publicUrl!, height: 200),
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
