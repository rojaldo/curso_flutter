import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

class FormExample extends StatefulWidget {
  const FormExample({super.key});

  @override
  State<FormExample> createState() => _FormExampleState();
}

class _FormExampleState extends State<FormExample> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSubmitted = false;
  bool _isSuccess = false;
  String _feedback = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      _isSubmitted = true;
    });

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSuccess = true;
        _feedback =
            'Enviado: ${_nameController.text}, ${_emailController.text}';
      });
    } else {
      setState(() {
        _isSuccess = false;
        _feedback = 'Corrige los errores del formulario';
      });
    }
  }

  void _reset() {
    _formKey.currentState!.reset();
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    setState(() {
      _isSubmitted = false;
      _isSuccess = false;
      _feedback = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'Formularios',
      description:
          'Ejemplo interactivo de Form y TextFormField con validaciones. '
          'Rellena los campos y pulsa Enviar para ver la validación en acción.',
      code: '''Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(
        decoration: InputDecoration(labelText: 'Nombre'),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Campo obligatorio';
          }
          return null;
        },
      ),
      TextFormField(
        decoration: InputDecoration(labelText: 'Email'),
        validator: (value) {
          if (value == null || !value.contains('@')) {
            return 'Email inválido';
          }
          return null;
        },
      ),
      TextFormField(
        decoration: InputDecoration(labelText: 'Contraseña'),
        obscureText: true,
        validator: (value) {
          if (value == null || value.length < 6) {
            return 'Mínimo 6 caracteres';
          }
          return null;
        },
      ),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Enviar datos
          }
        },
        child: Text('Enviar'),
      ),
    ],
  ),
)''',
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El email es obligatorio';
                }
                final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                if (!emailRegex.hasMatch(value)) {
                  return 'Formato de email inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'Mínimo 6 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.send),
                    label: const Text('Enviar'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.clear),
                  label: const Text('Limpiar'),
                ),
              ],
            ),
            if (_isSubmitted) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isSuccess
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  border: Border.all(
                    color: _isSuccess ? Colors.green : Colors.red,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isSuccess ? Icons.check_circle : Icons.error,
                      color: _isSuccess ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _feedback,
                        style: TextStyle(
                          color: _isSuccess ? Colors.green.shade900 : Colors.red.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Estado del formulario',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text('Nombre: ${_nameController.text.isEmpty ? "—" : _nameController.text}'),
            Text('Email: ${_emailController.text.isEmpty ? "—" : _emailController.text}'),
            Text('Contraseña: ${_passwordController.text.isEmpty ? "—" : "•" * _passwordController.text.length}'),
          ],
        ),
      ),
    );
  }
}
