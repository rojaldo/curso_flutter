import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/code_dialog.dart';

class SliverExample extends StatefulWidget {
  const SliverExample({super.key});

  @override
  State<SliverExample> createState() => _SliverExampleState();
}

class _SliverExampleState extends State<SliverExample> {
  bool _floating = true;
  bool _pinned = false;
  bool _snap = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: _floating,
            pinned: _pinned,
            snap: _snap,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('SliverAppBar'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.indigo.shade400,
                      Colors.purple.shade400,
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.expand_more,
                    size: 64,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => CodeDialog.show(
                  context,
                  'SliverAppBar',
                  '''SliverAppBar(
  expandedHeight: 200,
  floating: true,
  pinned: false,
  snap: false,
  flexibleSpace: FlexibleSpaceBar(
    title: Text('Título'),
    background: Image.asset(...),
  ),
)''',
                ),
                icon: const Icon(Icons.code),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Configuración del SliverAppBar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('floating'),
                        subtitle: const Text(
                            'El AppBar aparece al hacer scroll hacia abajo'),
                        value: _floating,
                        onChanged: (value) {
                          setState(() {
                            _floating = value;
                            if (!_floating) _snap = false;
                          });
                        },
                      ),
                      SwitchListTile(
                        title: const Text('pinned'),
                        subtitle: const Text(
                            'El AppBar permanece fijo en la parte superior'),
                        value: _pinned,
                        onChanged: (value) => setState(() => _pinned = value),
                      ),
                      SwitchListTile(
                        title: const Text('snap'),
                        subtitle: const Text(
                            'El AppBar se expande/contrae completamente de golpe'),
                        value: _snap,
                        onChanged: _floating
                            ? (value) => setState(() => _snap = value)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Colors.primaries[index % Colors.primaries.length],
                    child: Text('$index',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white)),
                  ),
                  title: Text('Elemento $index'),
                  subtitle: const Text('Desplaza para ver el efecto'),
                );
              },
              childCount: 30,
            ),
          ),
        ],
      ),
    );
  }
}
