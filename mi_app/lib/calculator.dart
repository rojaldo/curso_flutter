import 'package:flutter/material.dart';

class CalculatorPage extends StatelessWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // stateful widget para el elemento calculator
            const CalculatorWidget(),
            
          ],
        ),
      ),
    );
  }
}

//stateful widget calculator
class CalculatorWidget extends StatefulWidget {
  
  const CalculatorWidget({super.key});

  @override
  State<CalculatorWidget> createState() => _CalculatorWidgetState();
}

class _CalculatorWidgetState extends State<CalculatorWidget> {

  String display = '';

  void _onButtonPressed(String value) {
    setState(() {
      display += value;
    });
  }

  @override
  Widget build(BuildContext context) {
    // maqueta una calculadora simple con matriz de botones 4x4 display en la parte superior con alineamiento de contenido a la derecha 
    // y un padding de 16, que se adapte al tamaño de la pantalla, con un color de fondo gris claro y un borde redondeado de 8.
    // Los botones comprenden los números del 0 al 9 y los operadores +, -, *, /, =, C, con un padding de 4 entre ellos.
    // con la maquetacion clasica de una calculadora, con los botones de los números en matriz de 3x3 y los operadores en la columna de la derecha,
    // con el boton de 0 en la parte inferior central, y el boton de C en la parte inferior izquierda.
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.all(16),
            child: Text(
              display,
              style: const TextStyle(fontSize: 32),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            // matriz de botones 4x4 con padding de 4 entre ellos con los numeros en matriz de 3x3 y los operadores en la columna de la derecha, con el boton de 0 en la parte inferior central, y el boton de C en la parte inferior izquierda.
            children: [
              Padding(
                padding: const EdgeInsets.all(4),
                child: ElevatedButton(
                  onPressed: () {
                    _onButtonPressed('7');
                  },
                  child: const Text('7'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: ElevatedButton(
                  onPressed: () {
                    _onButtonPressed('8');
                  },
                  child: const Text('8'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: ElevatedButton(
                  onPressed: () {
                    _onButtonPressed('9');
                  },
                  child: const Text('9'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: ElevatedButton(
                  onPressed: () {
                    _onButtonPressed('/');
                  },
                  child: const Text('/'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: ElevatedButton(
                  onPressed: () {
                    _onButtonPressed('4');
                  },
                  child: const Text('4'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: ElevatedButton(
                  onPressed: () {
                    _onButtonPressed('5');
                  },
                  child: const Text('5'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: ElevatedButton(
                  onPressed: () {
                    _onButtonPressed('6');
                  },
                  child: const Text('6'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: ElevatedButton(
                  onPressed: () {
                    _onButtonPressed('*');
                  },
                  child: const Text('*'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: ElevatedButton(
                  onPressed: () {
                    _onButtonPressed('1');
                  },
                  child: const Text('1'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: ElevatedButton(
                  onPressed: () {
                    _onButtonPressed('2');
                  },
                  child: const Text('2'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: ElevatedButton(
                  onPressed: () {
                    _onButtonPressed('3');
                  },
                  child: const Text('3'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: ElevatedButton(
                  onPressed: () {
                    _onButtonPressed('-');
                  },
                  child: const Text('-'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: ElevatedButton(
                  onPressed: () {
                    _onButtonPressed('');
                  },
                  child: const Text('AC'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: ElevatedButton(
                  onPressed: () {
                    _onButtonPressed('0');
                  },
                  child: const Text('0'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: ElevatedButton(
                  onPressed: () {
                    _onButtonPressed('=');
                  },
                  child: const Text('='),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: ElevatedButton(
                  onPressed: () {
                    _onButtonPressed('+');
                  },
                  child: const Text('+'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
