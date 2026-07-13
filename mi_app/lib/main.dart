import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:mi_app/calculator/calculator.dart';
import 'package:mi_app/calculator/calculator_provider.dart';
import 'package:mi_app/heroes/heroes_page.dart';
import 'package:mi_app/heroes/heroes_provider.dart';
import 'package:mi_app/apod/apod_page.dart';
import 'package:mi_app/tetris/tetris_page.dart';
import 'package:mi_app/trivial/trivial_page.dart';
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
    await Firebase.initializeApp(
      options: kIsWeb ? DefaultFirebaseOptions.currentPlatform : null,
    );
  }
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
      home: const HomePage(),
    );
  }
}

class _DrawerItem {
  final String title;
  final IconData icon;
  final Widget page;
  final bool enabled;
  final String? disabledHint;

  const _DrawerItem({
    required this.title,
    required this.icon,
    required this.page,
    this.enabled = true,
    this.disabledHint,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final List<_DrawerItem> _items;

  @override
  void initState() {
    super.initState();
    _items = [
      const _DrawerItem(
        title: 'Calculator',
        icon: Icons.calculate,
        page: CalculatorPage(),
      ),
      const _DrawerItem(
        title: 'Heroes',
        icon: Icons.people,
        page: HeroesPage(),
      ),
      const _DrawerItem(
        title: 'Apod',
        icon: Icons.photo,
        page: ApodPage(),
      ),
      const _DrawerItem(
        title: 'Tetris',
        icon: Icons.grid_on,
        page: TetrisPage(),
      ),
      const _DrawerItem(
        title: 'Trivial',
        icon: Icons.quiz,
        page: TrivialPage(),
      ),
      _DrawerItem(
        title: kFirebaseSupported ? 'Firebase' : 'Firebase (no disponible)',
        icon: Icons.local_fire_department,
        page: const FirebaseMenuPage(),
        enabled: kFirebaseSupported,
        disabledHint: 'No disponible en esta plataforma',
      ),
      const _DrawerItem(
        title: 'Supabase',
        icon: Icons.cloud,
        page: SupabaseMenuPage(),
      ),
    ];
  }

  void _openPage(int i) {
    final item = _items[i];
    if (!item.enabled) return;
    Navigator.pop(context); // cierra el drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => item.page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter Examples'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 166, 31, 49),
              ),
              child: Text(
                'Ejemplos',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            for (int i = 0; i < _items.length; i++)
              ListTile(
                leading: Icon(_items[i].icon),
                title: Text(_items[i].title),
                enabled: _items[i].enabled,
                subtitle:
                    _items[i].enabled ? null : Text(_items[i].disabledHint ?? ''),
                onTap: () => _openPage(i),
              ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Abre el menú (≡) para ver los ejemplos'),
      ),
    );
  }
}