import 'package:flutter/material.dart';
import 'package:mi_app/calculator/calculator.dart';
import 'package:mi_app/heroes/heroes_page.dart';
import 'package:mi_app/heroes/heroes_provider.dart';
import 'package:mi_app/apod/apod_page.dart';
import 'package:mi_app/tetris/tetris_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => HeroesProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Examples',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 166, 31, 49),
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Examples Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // expand the buttons to fill the width of the screen
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CalculatorPage(),
                      ),
                    );
                  },
                  child: const Text('Calculator'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HeroesPage(),
                      ),
                    );
                  },
                  child: const Text('Heroes'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ApodPage()),
                    );
                  },
                  child: const Text('Apod'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TetrisPage(),
                      ),
                    );
                  },
                  child: const Text('Tetris'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
