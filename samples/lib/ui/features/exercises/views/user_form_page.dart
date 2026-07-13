import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sample_app/ui/features/exercises/view_models/user_form_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Widget ───────────────────────────────────────────────────────────────────

class UserFormPage extends StatefulWidget {
  const UserFormPage({super.key, SharedPreferences? prefs}) : _prefs = prefs;

  final SharedPreferences? _prefs;

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FormCubit(prefs: widget._prefs),
      child: Scaffold(
        appBar: AppBar(title: const Text('Formulario de usuario')),
        body: BlocBuilder<FormCubit, UserFormState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _FormFields(
                    state: state,
                    onSubmit: () => _addUser(context),
                    onReset: () => _resetForm(context),
                  ),
                  if (state.users.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      'Usuarios registrados (${state.users.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(state.users.length, (i) => _UserCard(user: state.users[i], index: i + 1)),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _addUser(BuildContext context) {
    final cubit = context.read<FormCubit>();
    final s = cubit.state;
    final age = int.tryParse(s.age);
    if (age == null) return;

    final user = UserFormData(name: s.name, surname: s.surname, age: age);
    cubit.addUser(user);
    cubit.reset();
  }

  void _resetForm(BuildContext context) {
    context.read<FormCubit>().reset();
  }
}

// ── Campos del formulario ─────────────────────────────────────────────────────

class _FormFields extends StatefulWidget {
  const _FormFields({
    required this.state,
    required this.onSubmit,
    required this.onReset,
  });

  final UserFormState state;
  final VoidCallback onSubmit;
  final VoidCallback onReset;

  @override
  State<_FormFields> createState() => _FormFieldsState();
}

class _FormFieldsState extends State<_FormFields> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _ageController;
  late List<UserFormData> _users = [];
  bool _autovalidate = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.state.name);
    _surnameController = TextEditingController(text: widget.state.surname);
    _ageController = TextEditingController(text: widget.state.age);
    _users = widget.state.users;

    if (widget.state.name.isNotEmpty ||
        widget.state.surname.isNotEmpty ||
        widget.state.age.isNotEmpty) {
      _autovalidate = true;
    }
  }

  @override
  void didUpdateWidget(covariant _FormFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.name.isEmpty && _nameController.text.isNotEmpty) {
      _nameController.clear();
    }
    if (widget.state.surname.isEmpty && _surnameController.text.isNotEmpty) {
      _surnameController.clear();
    }
    if (widget.state.age.isEmpty && _ageController.text.isNotEmpty) {
      _ageController.clear();
    } if (widget.state.users != _users) {
      setState(() {
        _users = widget.state.users;
      });
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
            onPressed: () => _submit(),
            icon: const Icon(Icons.check),
            label: const Text('Enviar'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              context.read<FormCubit>().reset();
              setState(() => _autovalidate = false);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidate = true);
      return;
    }
    widget.onSubmit();
  }
}

// ── Tarjeta de usuario en la lista ────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user, required this.index});

  final UserFormData user;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(child: Text('$index')),
        title: Text('${user.name} ${user.surname}'),
        subtitle: Text('${user.age} años'),
      ),
    );
  }
}