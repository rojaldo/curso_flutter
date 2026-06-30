import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sample_app/ui/features/exercises/view_models/user_form_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';


// ── Widget ───────────────────────────────────────────────────────────────────

class UserFormPage extends StatelessWidget {
  const UserFormPage({super.key, SharedPreferences? prefs}) : _prefs = prefs;

  final SharedPreferences? _prefs;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FormCubit(prefs: _prefs),
      child: Scaffold(
        appBar: AppBar(title: const Text('Formulario de usuario')),
        body: BlocBuilder<FormCubit, UserFormState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _FormContent(state: state),
            );
          },
        ),
      ),
    );
  }
}

class _FormContent extends StatefulWidget {
  const _FormContent({required this.state});

  final UserFormState state;

  @override
  State<_FormContent> createState() => _FormContentState();
}

class _FormContentState extends State<_FormContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _ageController;
  bool _autovalidate = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.state.name);
    _surnameController = TextEditingController(text: widget.state.surname);
    _ageController = TextEditingController(text: widget.state.age);
    if (widget.state.name.isNotEmpty ||
        widget.state.surname.isNotEmpty ||
        widget.state.age.isNotEmpty) {
      _autovalidate = true;
    }
  }

  @override
  void didUpdateWidget(covariant _FormContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.name.isEmpty && _nameController.text.isNotEmpty) {
      _nameController.clear();
    }
    if (widget.state.surname.isEmpty && _surnameController.text.isNotEmpty) {
      _surnameController.clear();
    }
    if (widget.state.age.isEmpty && _ageController.text.isNotEmpty) {
      _ageController.clear();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FormCubit>();

    return Form(
      key: _formKey,
      autovalidateMode:
          _autovalidate ? AutovalidateMode.always : AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              hintText: 'Ej: Ana',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            onChanged: cubit.nameChanged,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'El nombre es obligatorio';
              if (v.trim().length < 2) return 'Mínimo 2 caracteres';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _surnameController,
            decoration: const InputDecoration(
              labelText: 'Apellido',
              hintText: 'Ej: García',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            onChanged: cubit.surnameChanged,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'El apellido es obligatorio';
              if (v.trim().length < 2) return 'Mínimo 2 caracteres';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _ageController,
            decoration: const InputDecoration(
              labelText: 'Edad',
              hintText: 'Ej: 25',
              prefixIcon: Icon(Icons.cake),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: cubit.ageChanged,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'La edad es obligatoria';
              final age = int.tryParse(v);
              if (age == null) return 'Introduce un número válido';
              if (age < 0 || age > 150) return 'La edad debe estar entre 0 y 150';
              return null;
            },
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => _submit(context),
            icon: const Icon(Icons.check),
            label: const Text('Enviar'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _reset(context),
            icon: const Icon(Icons.refresh),
            label: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidate = true);
      return;
    }
    final cubit = context.read<FormCubit>();
    cubit.submitted();
    final s = cubit.state;
    showDialog(
      context: context,
      builder: (_) => _ResultDialog(
        name: s.name,
        surname: s.surname,
        age: int.parse(s.age),
      ),
    );
  }

  void _reset(BuildContext context) {
    context.read<FormCubit>().reset();
    setState(() => _autovalidate = false);
  }
}

class _ResultDialog extends StatelessWidget {
  const _ResultDialog({
    required this.name,
    required this.surname,
    required this.age,
  });

  final String name;
  final String surname;
  final int age;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
      title: const Text('Usuario registrado'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Field(label: 'Nombre', value: name),
          _Field(label: 'Apellido', value: surname),
          _Field(label: 'Edad', value: '$age años'),
          const SizedBox(height: 8),
          Text(
            'Hola, $name $surname. Tienes $age años.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}