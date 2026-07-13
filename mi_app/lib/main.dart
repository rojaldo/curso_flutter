import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:mi_app/calculator/calculator.dart';
import 'package:mi_app/calculator/calculator_provider.dart';
import 'package:mi_app/heroes/heroes_page.dart';
import 'package:mi_app/heroes/heroes_provider.dart';
import 'package:mi_app/apod/apod_page.dart';
import 'package:mi_app/tetris/tetris_page.dart';
import 'package:mi_app/firebase/firebase_menu_page.dart';
import 'package:mi_app/firebase/firebase_options.dart';
import 'package:mi_app/supabase/supabase_menu_page.dart';
import 'package:mi_app/supabase/supabase_config.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Firebase solo tiene plugin nativo en Android, iOS, macOS y Web.
/// En Linux/Windows lo saltamos y la sección Firebase avisa al usuario.
/// Supabase funciona en todas las plataformas (incluida Linux/Windows).
bool get kFirebaseSupported =>
    kIsWeb || Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kFirebaseSupported) {
    // En web hay que pasar FirebaseOptions explícitas (no hay
    // google-services.json / GoogleService-Info.plist). En nativo los
    // configs ya colocados se leen automáticamente sin argumentos.
    await Firebase.initializeApp(
      options: kIsWeb ? DefaultFirebaseOptions.currentPlatform : null,
    );
  }
  // Supabase: inicialización única con URL + publishable key. Funciona en
  // web, móvil, escritorio — no requiere configs nativos por plataforma.
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HeroesProvider()),
        ChangeNotifierProvider(create: (_) => CalculatorProvider()),
      ],
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
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FirebaseMenuPage(),
                      ),
                    );
                  },
                  child: Text(
                    kFirebaseSupported ? 'Firebase' : 'Firebase (no disponible en esta plataforma)',
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SupabaseMenuPage(),
                      ),
                    );
                  },
                  child: const Text('Supabase'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
