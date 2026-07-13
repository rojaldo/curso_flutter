import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum CalculatorStep { init, firstFigure, secondFigure, resolve }

class CalculatorState {
  const CalculatorState({
    this.firstNumber = 0,
    this.secondNumber = 0,
    this.result = 0,
    this.operator = '',
    this.displayText = '',
    this.step = CalculatorStep.init,
  });

  final double firstNumber;
  final double secondNumber;
  final double result;
  final String operator;
  final String displayText;
  final CalculatorStep step;

  CalculatorState copyWith({
    double? firstNumber,
    double? secondNumber,
    double? result,
    String? operator,
    String? displayText,
    CalculatorStep? step,
  }) {
    return CalculatorState(
      firstNumber: firstNumber ?? this.firstNumber,
      secondNumber: secondNumber ?? this.secondNumber,
      result: result ?? this.result,
      operator: operator ?? this.operator,
      displayText: displayText ?? this.displayText,
      step: step ?? this.step,
    );
  }

  static CalculatorState fromJson(Map<String, dynamic> json) {
    return CalculatorState(
      firstNumber: (json['firstNumber'] as num?)?.toDouble() ?? 0,
      secondNumber: (json['secondNumber'] as num?)?.toDouble() ?? 0,
      result: (json['result'] as num?)?.toDouble() ?? 0,
      operator: json['operator'] as String? ?? '',
      displayText: json['displayText'] as String? ?? '',
      step: CalculatorStep.values[json['step'] as int? ?? 0],
    );
  }

  Map<String, dynamic> toJson() => {
        'firstNumber': firstNumber,
        'secondNumber': secondNumber,
        'result': result,
        'operator': operator,
        'displayText': displayText,
        'step': step.index,
      };
}

class CalculatorCubit extends Cubit<CalculatorState> {
  CalculatorCubit({SharedPreferences? prefs})
      : _prefs = prefs,
        super(const CalculatorState()) {
    _restore();
  }

  final SharedPreferences? _prefs;

  static const _key = 'calculator_state';

  void processInput(String input) {
    if (int.tryParse(input) != null) {
      _processNumber(int.parse(input));
    } else {
      _processSymbol(input);
    }
    _persist();
  }

  void _processNumber(int number) {
    final d = number.toDouble();
    switch (state.step) {
      case CalculatorStep.init:
        emit(state.copyWith(
          firstNumber: d,
          displayText: d.toString(),
          step: CalculatorStep.firstFigure,
        ));
      case CalculatorStep.firstFigure:
        final next = state.firstNumber * 10 + d;
        emit(state.copyWith(
          firstNumber: next,
          displayText: next.toString(),
        ));
      case CalculatorStep.secondFigure:
        final next = state.secondNumber * 10 + d;
        emit(state.copyWith(
          secondNumber: next,
          displayText: '${state.firstNumber} ${state.operator} $next',
        ));
      case CalculatorStep.resolve:
        emit(state.copyWith(
          firstNumber: d,
          secondNumber: 0,
          result: 0,
          operator: '',
          displayText: d.toString(),
          step: CalculatorStep.firstFigure,
        ));
    }
  }

  void _processSymbol(String symbol) {
    if (symbol == 'AC') {
      emit(const CalculatorState());
      // _persist();
      return;
    }
    switch (state.step) {
      case CalculatorStep.init:
        break;
      case CalculatorStep.firstFigure:
        if (symbol == '+' || symbol == '-' || symbol == '*' || symbol == '/') {
          emit(state.copyWith(
            operator: symbol,
            displayText: '${state.firstNumber} $symbol',
            step: CalculatorStep.secondFigure,
          ));
        }
      case CalculatorStep.secondFigure:
        if (symbol == '=') {
          final r = _resolve();
          emit(state.copyWith(
            result: r,
            displayText:
                '${state.firstNumber} ${state.operator} ${state.secondNumber} = $r',
            step: CalculatorStep.resolve,
          ));
        }
      case CalculatorStep.resolve:
        if (symbol == '+' || symbol == '-' || symbol == '*' || symbol == '/') {
          emit(state.copyWith(
            firstNumber: state.result,
            secondNumber: 0,
            result: 0,
            operator: symbol,
            displayText: '${state.result} $symbol',
            step: CalculatorStep.secondFigure,
          ));
        }
    }
  }

  double _resolve() {
    switch (state.operator) {
      case '+':
        return state.firstNumber + state.secondNumber;
      case '-':
        return state.firstNumber - state.secondNumber;
      case '*':
        return state.firstNumber * state.secondNumber;
      case '/':
        return state.secondNumber != 0
            ? state.firstNumber / state.secondNumber
            : 0;
      default:
        return 0;
    }
  }

  // --- Persistencia ---

  void _persist() {
    _prefs?.setString(_key, jsonEncode(state.toJson()));
  }

  void _restore() {
    final raw = _prefs?.getString(_key);
    if (raw == null) return;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      emit(CalculatorState.fromJson(json));
    } catch (_) {
      // Estado corrupto: se queda en el estado inicial.
    }
  }
}