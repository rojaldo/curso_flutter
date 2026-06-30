// ── Estado ──────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserFormState extends Equatable {
  const UserFormState({this.name = '', this.surname = '', this.age = ''});

  final String name;
  final String surname;
  final String age;

  @override
  List<Object> get props => [name, surname, age];

  UserFormState copyWith({String? name, String? surname, String? age}) =>
      UserFormState(
        name: name ?? this.name,
        surname: surname ?? this.surname,
        age: age ?? this.age,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'surname': surname,
        'age': age,
      };

  static UserFormState fromJson(Map<String, dynamic> json) => UserFormState(
        name: json['name'] as String? ?? '',
        surname: json['surname'] as String? ?? '',
        age: json['age'] as String? ?? '',
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

  void reset() {
    emit(const UserFormState());
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
