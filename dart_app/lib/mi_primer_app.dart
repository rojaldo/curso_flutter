int calculate() {
  return 6 * 7;
}

void run_sample() {
Iterable<int> numeros = [3, 1, 4, 1, 5, 9, 2, 6];

// reduce: combina elementos en uno
var suma = numeros.fold(2, (a, b) => a + b);
print('Suma: $suma');
}


