// ── Estado ──────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserFormData {
  UserFormData({required this.name, required this.surname, required this.age});

  final String name;
  final String surname;
  final int age;

  @override
  String toString() => '$name $surname, $age años';
}

class UserFormState extends Equatable {
  const UserFormState({this.name = '', this.surname = '', this.age = '', this.users = const []});

  final String name;
  final String surname;
  final String age;
  final List<UserFormData> users;

  @override
  List<Object> get props => [name, surname, age, users];

  UserFormState copyWith({String? name, String? surname, String? age, List<UserFormData>? users}) =>
      UserFormState(
        name: name ?? this.name,
        surname: surname ?? this.surname,
        age: age ?? this.age,
        users: users ?? this.users,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'surname': surname,
        'age': age,
        'users': users.map((u) => {'name': u.name, 'surname': u.surname, 'age': u.age}).toList(),
      };

  static UserFormState fromJson(Map<String, dynamic> json) => UserFormState(
        name: json['name'] as String? ?? '',
        surname: json['surname'] as String? ?? '',
        age: json['age'] as String? ?? '',
        users: (json['users'] as List<dynamic>?)
                ?.map((u) => UserFormData(
                      name: u['name'] as String? ?? '',
                      surname: u['surname'] as String? ?? '',
                      age: u['age'] as int? ?? 0,
                    ))
                .toList() ??
            [],
      );
}

// ── Cubit ────────────────────────────────────────────────────────────────────

class FormCubit extends Cubit<UserFormState> {
  FormCubit({SharedPreferences? prefs})
      : _prefs = prefs,
        super(const UserFormState()) {
    _restore();
  }

  final SharedPreferences? _prefs;

  void nameChanged(String value) {
    emit(state.copyWith(name: value));
    _persist();
  }

  void surnameChanged(String value) {
    emit(state.copyWith(surname: value));
    _persist();
  }

  void ageChanged(String value) {
    emit(state.copyWith(age: value));
    _persist();
  }

  void usersChanged(List<UserFormData> value) {
    emit(state.copyWith(users: value));
    _persist();
  }

  void addUser(UserFormData user) {
    final updatedUsers = List<UserFormData>.from(state.users)..add(user);
    emit(state.copyWith(users: updatedUsers));
    _persist();
  }

  void removeUser(UserFormData user) {
    final updatedUsers = List<UserFormData>.from(state.users)..remove(user);
    emit(state.copyWith(users: updatedUsers));
    _persist();
  }

  /// Limpia solo los campos del formulario (name, surname, age).
  /// Conserva la lista de usuarios registrados.
  void reset() {
    emit(state.copyWith(name: '', surname: '', age: ''));
    _persist();
  }

  void submitted() => _persist();

  void _persist() =>
      _prefs?.setString('user_form_state', jsonEncode(state.toJson()));

  void _restore() {
    final raw = _prefs?.getString('user_form_state');
    if (raw == null) return;
    try {
      emit(UserFormState.fromJson(jsonDecode(raw) as Map<String, dynamic>));
    } catch (_) {
      // Estado corrupto → se queda en el estado inicial.
    }
  }
}
