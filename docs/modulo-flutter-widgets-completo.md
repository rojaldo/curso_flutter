# Módulo Completo: Widgets en Flutter

## Índice

1. [Introducción a los Widgets](#introducción-a-los-widgets)
2. [Ciclo de Vida de los Widgets](#ciclo-de-vida-de-los-widgets)
3. [StatelessWidget](#statelesswidget)
4. [StatefulWidget](#statefulwidget)
5. [Comunicación entre Widgets](#comunicación-entre-widgets)
6. [Listeners y Elementos Interactivos](#listeners-y-elementos-interactivos)
7. [Animaciones de Widgets](#animaciones-de-widgets)
8. [Estructura de una Aplicación Flutter](#estructura-de-una-aplicación-flutter)
9. [Patrones de Diseño con Widgets](#patrones-de-diseño-con-widgets)
10. [Widgets Personalizados](#widgets-personalizados)
11. [Ejemplos Prácticos Completos](#ejemplos-prácticos-completos)
12. [Mejores Prácticas](#mejores-prácticas)

---

## Introducción a los Widgets

### ¿Qué es un Widget?

En Flutter, todo es un widget. Un widget es la unidad básica de construcción de la interfaz de usuario que describe una parte de la UI. Los widgets son inmutables: una vez creados, no pueden cambiar.

```dart
// Un widget simple
Text('Hola Mundo')

// Un widget con configuración
Text(
  'Hola Mundo',
  style: TextStyle(fontSize: 24, color: Colors.blue),
)

// Composición de widgets
Container(
  padding: EdgeInsets.all(16),
  child: Text('Hola Mundo'),
)
```

### Tipos de Widgets

Flutter clasifica los widgets en tres categorías:

1. **Widgets de Estado (Stateful/Stateless)**: Manejan datos y estado
2. **Widgets de Layout**: Organizan otros widgets (Row, Column, Stack)
3. **Widgets de Presentación**: Muestran contenido (Text, Image, Icon)

### Árbol de Widgets

```
MaterialApp (Widget raíz)
├── Scaffold (Estructura)
│   ├── AppBar (Navegación)
│   │   └── Text (Título)
│   └── body: Center (Centrado)
│       └── Column (Layout)
│           ├── Text (Contenido)
│           └── ElevatedButton (Interacción)
```

### Inmutabilidad de los Widgets

```dart
// Los widgets son inmutables
class MyWidget extends StatelessWidget {
  final String title;  // ← Debe ser final
  final int count;     // ← Debe ser final
  
  const MyWidget({
    super.key,
    required this.title,
    required this.count,
  });
  
  @override
  Widget build(BuildContext context) {
    return Text('$title: $count');
  }
}

// ❌ Incorrecto - Intentar modificar
// widget.title = 'Nuevo título'; // Error de compilación

// ✅ Correcto - Crear nuevo widget con nuevos datos
MyWidget(title: 'Nuevo título', count: 10)
```

---

## Ciclo de Vida de los Widgets

### Ciclo de Vida de StatelessWidget

```
Creación → build() → Destrucción
```

El StatelessWidget es simple:
1. Se crea el widget
2. Se llama a `build()` para renderizar
3. Se destruye cuando ya no se necesita

```dart
class SimpleWidget extends StatelessWidget {
  const SimpleWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    print('build() llamado');  // Solo se llama una vez (generalmente)
    return Text('Widget estático');
  }
}
```

### Ciclo de Vida de StatefulWidget

```
Creación → createState() → initState() → build() → didUpdateWidget()
                                                    ↓
                                            setState() → build()
                                                    ↓
                                            dispose()
```

El StatefulWidget tiene un ciclo de vida más complejo:

```dart
class LifecycleWidget extends StatefulWidget {
  const LifecycleWidget({super.key});
  
  @override
  State<LifecycleWidget> createState() => _LifecycleWidgetState();
}

class _LifecycleWidgetState extends State<LifecycleWidget> {
  int _counter = 0;
  
  @override
  void initState() {
    super.initState();
    print('1. initState() - Inicialización');
    // Se llama una vez cuando el State se crea
    // Ideal para:
    // - Suscripciones
    // - Controladores de animación
    // - Streams
    // - Llamadas a API iniciales
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('2. didChangeDependencies() - Dependencias cambiaron');
    // Se llama cuando cambian las dependencias del widget
    // Por ejemplo: Theme, MediaQuery, Provider
  }
  
  @override
  void didUpdateWidget(LifecycleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('3. didUpdateWidget() - Widget padre actualizado');
    // Se llama cuando el widget padre se reconstruye con nuevos datos
    // Comparar oldWidget con widget para cambios
  }
  
  @override
  Widget build(BuildContext context) {
    print('4. build() - Construyendo UI');
    // Se llama cada vez que se necesita (re)renderizar
    // Debe ser puro y rápido
    return Column(
      children: [
        Text('Counter: $_counter'),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _counter++;
              print('setState() - Estado actualizado');
            });
          },
          child: Text('Incrementar'),
        ),
      ],
    );
  }
  
  @override
  void deactivate() {
    super.deactivate();
    print('5. deactivate() - Widget desactivado');
    // Se llama cuando el widget se remueve del árbol temporalmente
    // Pero puede ser reinsertado
  }
  
  @override
  void dispose() {
    print('6. dispose() - Widget destruido');
    // Se llama cuando el widget se elimina permanentemente
    // IMPORTANTE: Limpiar recursos aquí
    // - Controladores
    // - Streams
    // - Animaciones
    // - Focus nodes
    super.dispose();
  }
}
```

### Orden de Ejecución

```
Primer render:
┌─────────────────────────────────────────────────┐
│ createState()                                    │
│       ↓                                          │
│ initState()                                      │
│       ↓                                          │
│ didChangeDependencies()                          │
│       ↓                                          │
│ build()                                          │
└─────────────────────────────────────────────────┘

Actualización (setState):
┌─────────────────────────────────────────────────┐
│ setState() llamado                               │
│       ↓                                          │
│ build()                                          │
└─────────────────────────────────────────────────┘

Actualización (nuevos datos del padre):
┌─────────────────────────────────────────────────┐
│ didUpdateWidget(oldWidget)                       │
│       ↓                                          │
│ build()                                          │
└─────────────────────────────────────────────────┘

Destrucción:
┌─────────────────────────────────────────────────┐
│ deactivate()                                     │
│       ↓                                          │
│ dispose()                                        │
└─────────────────────────────────────────────────┘
```

---

## StatelessWidget

### Concepto

Un `StatelessWidget` es un widget que no tiene estado mutable. Una vez construido, su apariencia no cambia a menos que se proporcione nueva información desde su padre.

### Cuándo Usar StatelessWidget

- Contenido estático (textos, iconos)
- Widgets que reciben datos solo desde el padre
- Widgets de presentación pura
- Widgets que no manejan interacción compleja

### Ejemplo Básico

```dart
class UserCard extends StatelessWidget {
  // Propiedades inmutables
  final String name;
  final String email;
  final String? avatarUrl;
  final VoidCallback? onTap;
  
  // Constructor const para rendimiento
  const UserCard({
    super.key,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    // El método build debe ser puro (sin efectos secundarios)
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                backgroundImage: avatarUrl != null 
                  ? NetworkImage(avatarUrl!)
                  : null,
                child: avatarUrl == null
                  ? Text(name[0].toUpperCase())
                  : null,
              ),
              SizedBox(width: 16),
              
              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 4),
                    Text(
                      email,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              
              // Icono de acción
              Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

// Uso
UserCard(
  name: 'Juan García',
  email: 'juan@email.com',
  avatarUrl: 'https://example.com/avatar.jpg',
  onTap: () => print('Card tapped'),
)
```

### Mejores Prácticas para StatelessWidget

```dart
// ✅ Bueno: Constructor const
class MyWidget extends StatelessWidget {
  final String title;
  
  const MyWidget({super.key, required this.title}); // const aquí
  
  @override
  Widget build(BuildContext context) {
    return Text(title);
  }
}

// ✅ Bueno: Métodos helper privados
class ProductCard extends StatelessWidget {
  final Product product;
  
  const ProductCard({super.key, required this.product});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _buildHeader(),
          _buildContent(),
          _buildFooter(),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Image.network(product.imageUrl);
  }
  
  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Text(product.name),
    );
  }
  
  Widget _buildFooter() {
    return ButtonBar(
      children: [
        TextButton(child: Text('Cancelar')),
        ElevatedButton(child: Text('Comprar')),
      ],
    );
  }
}

// ✅ Bueno: Extraer widgets
class ArticleWidget extends StatelessWidget {
  final Article article;
  
  const ArticleWidget({super.key, required this.article});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ArticleHeader(title: article.title, author: article.author),
        ArticleContent(content: article.content),
        ArticleFooter(tags: article.tags),
      ],
    );
  }
}
```

### StatelessWidget con Parámetros Opcionales

```dart
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final IconData? icon;
  final bool isLoading;
  
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.icon,
    this.isLoading = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? theme.primaryColor,
      ),
      child: isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(textColor ?? Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: fontSize ?? 16),
                SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  color: textColor,
                ),
              ),
            ],
          ),
    );
  }
}

// Uso
CustomButton(
  text: 'Guardar',
  onPressed: () => save(),
  icon: Icons.save,
  backgroundColor: Colors.green,
)

CustomButton(
  text: 'Cargando...',
  onPressed: () {},
  isLoading: true,
)
```

---

## StatefulWidget

### Concepto

Un `StatefulWidget` es un widget que tiene estado mutable. El estado puede cambiar durante la vida del widget, y cuando cambia, el widget se reconstruye.

### Estructura Básica

```dart
// 1. El Widget (inmutable)
class CounterWidget extends StatefulWidget {
  final int initialValue;
  
  const CounterWidget({
    super.key,
    this.initialValue = 0,
  });
  
  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

// 2. El State (mutable)
class _CounterWidgetState extends State<CounterWidget> {
  late int _counter;
  
  @override
  void initState() {
    super.initState();
    _counter = widget.initialValue;
  }
  
  void _increment() {
    setState(() {
      _counter++;
    });
  }
  
  void _decrement() {
    setState(() {
      _counter--;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.remove),
          onPressed: _decrement,
        ),
        Text('$_counter', style: TextStyle(fontSize: 24)),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: _increment,
        ),
      ],
    );
  }
}
```

### setState() - Actualización de Estado

```dart
class CounterExample extends StatefulWidget {
  @override
  _CounterExampleState createState() => _CounterExampleState();
}

class _CounterExampleState extends State<CounterExample> {
  int _counter = 0;
  String _message = 'Presiona el botón';
  bool _isLoading = false;
  
  void _incrementCounter() {
    // ✅ Correcto: setState envuelve el cambio
    setState(() {
      _counter++;
      _message = 'Contador: $_counter';
    });
  }
  
  // ❌ Incorrecto: Llamar setState incorrectamente
  void _wrongWay() {
    _counter++; // Cambio sin setState
    setState(() {}); // setState vacío
  }
  
  // ✅ Forma asíncrona correcta
  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final data = await fetchData();
      
      if (mounted) { // Verificar si sigue montado
        setState(() {
          _message = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _message = 'Error: $e';
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isLoading)
          CircularProgressIndicator()
        else
          Text(_message),
        ElevatedButton(
          onPressed: _incrementCounter,
          child: Text('Incrementar'),
        ),
      ],
    );
  }
}
```

### Gestión de Estado Complejo

```dart
class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  // Estado
  final List<Todo> _todos = [];
  final TextEditingController _controller = TextEditingController();
  TodoFilter _filter = TodoFilter.all;
  
  @override
  void initState() {
    super.initState();
    _loadTodos();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  // Métodos de estado
  Future<void> _loadTodos() async {
    final todos = await TodoService.getTodos();
    setState(() {
      _todos.addAll(todos);
    });
  }
  
  void _addTodo(String title) {
    setState(() {
      _todos.add(Todo(
        id: DateTime.now().millisecondsSinceEpoch,
        title: title,
        completed: false,
      ));
    });
    _controller.clear();
  }
  
  void _toggleTodo(int id) {
    setState(() {
      final index = _todos.indexWhere((t) => t.id == id);
      if (index != -1) {
        _todos[index] = _todos[index].copyWith(
          completed: !_todos[index].completed,
        );
      }
    });
  }
  
  void _deleteTodo(int id) {
    setState(() {
      _todos.removeWhere((t) => t.id == id);
    });
  }
  
  void _setFilter(TodoFilter filter) {
    setState(() {
      _filter = filter;
    });
  }
  
  // Getters computados
  List<Todo> get _filteredTodos {
    switch (_filter) {
      case TodoFilter.all:
        return _todos;
      case TodoFilter.active:
        return _todos.where((t) => !t.completed).toList();
      case TodoFilter.completed:
        return _todos.where((t) => t.completed).toList();
    }
  }
  
  int get _activeCount => _todos.where((t) => !t.completed).length;
  int get _completedCount => _todos.where((t) => t.completed).length;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Input
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Nueva tarea',
                  ),
                  onSubmitted: _addTodo,
                ),
              ),
              SizedBox(width: 8),
              FloatingActionButton(
                mini: true,
                onPressed: () => _addTodo(_controller.text),
                child: Icon(Icons.add),
              ),
            ],
          ),
        ),
        
        // Filtros
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFilterButton('Todos', TodoFilter.all),
            _buildFilterButton('Activos', TodoFilter.active),
            _buildFilterButton('Completados', TodoFilter.completed),
          ],
        ),
        
        // Lista
        Expanded(
          child: ListView.builder(
            itemCount: _filteredTodos.length,
            itemBuilder: (context, index) {
              final todo = _filteredTodos[index];
              return ListTile(
                leading: Checkbox(
                  value: todo.completed,
                  onChanged: (_) => _toggleTodo(todo.id),
                ),
                title: Text(
                  todo.title,
                  style: TextStyle(
                    decoration: todo.completed
                      ? TextDecoration.lineThrough
                      : null,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteTodo(todo.id),
                ),
              );
            },
          ),
        ),
        
        // Contador
        Padding(
          padding: EdgeInsets.all(16),
          child: Text('$_activeCount pendientes, $_completedCount completados'),
        ),
      ],
    );
  }
  
  Widget _buildFilterButton(String label, TodoFilter filter) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: _filter == filter,
        onSelected: (_) => _setFilter(filter),
      ),
    );
  }
}

// Modelos
enum TodoFilter { all, active, completed }

class Todo {
  final int id;
  final String title;
  final bool completed;
  
  Todo({
    required this.id,
    required this.title,
    required this.completed,
  });
  
  Todo copyWith({int? id, String? title, bool? completed}) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }
}
```

### Limpieza de Recursos en dispose()

```dart
class AnimationWidget extends StatefulWidget {
  @override
  _AnimationWidgetState createState() => _AnimationWidgetState();
}

class _AnimationWidgetState extends State<AnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textController = TextEditingController();
  StreamSubscription? _subscription;
  
  @override
  void initState() {
    super.initState();
    
    // Controlador de animación
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    // Escuchar cambios de foco
    _focusNode.addListener(_onFocusChange);
    
    // Escuchar cambios de texto
    _textController.addListener(_onTextChange);
    
    // Suscribirse a stream
    _subscription = someStream.listen(_onData);
    
    // Iniciar animación
    _controller.forward();
  }
  
  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      print('Campo enfocado');
    } else {
      print('Campo perdió foco');
    }
  }
  
  void _onTextChange() {
    print('Texto: ${_textController.text}');
  }
  
  void _onData(dynamic data) {
    // Manejar datos del stream
  }
  
  @override
  void dispose() {
    // IMPORTANTE: Limpiar todos los recursos
    
    // Detener y eliminar animación
    _controller.dispose();
    
    // Eliminar focus node
    _focusNode.dispose();
    
    // Eliminar controlador de texto
    _textController.dispose();
    
    // Cancelar suscripción
    _subscription?.cancel();
    
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Opacity(
              opacity: _animation.value,
              child: Container(
                width: 100 * _animation.value,
                height: 100,
                color: Colors.blue,
              ),
            );
          },
        ),
        TextField(
          focusNode: _focusNode,
          controller: _textController,
        ),
      ],
    );
  }
}
```

---

## Comunicación entre Widgets

### Comunicación Padre → Hijo

```dart
// El padre pasa datos al hijo via constructor
class ParentWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChildWidget(
      title: 'Título desde el padre',
      count: 42,
      onButtonPressed: () => print('Botón presionado'),
    );
  }
}

class ChildWidget extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback? onButtonPressed;
  
  const ChildWidget({
    super.key,
    required this.title,
    required this.count,
    this.onButtonPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title),
        Text('Count: $count'),
        ElevatedButton(
          onPressed: onButtonPressed,
          child: Text('Presionar'),
        ),
      ],
    );
  }
}
```

### Comunicación Hijo → Padre (Callbacks)

```dart
class ParentWidget extends StatefulWidget {
  @override
  _ParentWidgetState createState() => _ParentWidgetState();
}

class _ParentWidgetState extends State<ParentWidget> {
  int _counter = 0;
  
  void _handleCounterChange(int newCount) {
    setState(() {
      _counter = newCount;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Total: $_counter'),
        ChildWidget(
          initialValue: 0,
          onCountChanged: _handleCounterChange,
        ),
      ],
    );
  }
}

class ChildWidget extends StatefulWidget {
  final int initialValue;
  final ValueChanged<int>? onCountChanged;
  
  const ChildWidget({
    super.key,
    this.initialValue = 0,
    this.onCountChanged,
  });
  
  @override
  _ChildWidgetState createState() => _ChildWidgetState();
}

class _ChildWidgetState extends State<ChildWidget> {
  late int _counter;
  
  @override
  void initState() {
    super.initState();
    _counter = widget.initialValue;
  }
  
  void _increment() {
    setState(() {
      _counter++;
    });
    // Notificar al padre
    widget.onCountChanged?.call(_counter);
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Hijo: $_counter'),
        ElevatedButton(
          onPressed: _increment,
          child: Icon(Icons.add),
        ),
      ],
    );
  }
}
```

### Comunicación entre Hermanos (Lifting State Up)

```dart
// Elevar el estado al ancestro común
class ParentWidget extends StatefulWidget {
  @override
  _ParentWidgetState createState() => _ParentWidgetState();
}

class _ParentWidgetState extends State<ParentWidget> {
  String _selectedItem = '';
  
  void _handleSelection(String item) {
    setState(() {
      _selectedItem = item;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Hermano 1 - Selector
        ItemSelector(
          items: ['Item 1', 'Item 2', 'Item 3'],
          onItemSelected: _handleSelection,
        ),
        
        // Hermano 2 - Display
        ItemDisplay(selectedItem: _selectedItem),
      ],
    );
  }
}

class ItemSelector extends StatelessWidget {
  final List<String> items;
  final ValueChanged<String> onItemSelected;
  
  const ItemSelector({
    super.key,
    required this.items,
    required this.onItemSelected,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) {
        return ListTile(
          title: Text(item),
          onTap: () => onItemSelected(item),
        );
      }).toList(),
    );
  }
}

class ItemDisplay extends StatelessWidget {
  final String selectedItem;
  
  const ItemDisplay({
    super.key,
    required this.selectedItem,
  });
  
  @override
  Widget build(BuildContext context) {
    return Text(
      selectedItem.isEmpty
        ? 'Ningún item seleccionado'
        : 'Seleccionado: $selectedItem',
    );
  }
}
```

### Comunicación Global con InheritedWidget

```dart
// InheritedWidget personalizado
class AppState extends InheritedWidget {
  final AppStateData data;
  final Function(AppStateData) updateState;
  
  const AppState({
    super.key,
    required this.data,
    required this.updateState,
    required super.child,
  });
  
  static AppState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppState>();
  }
  
  @override
  bool updateShouldNotify(AppState oldWidget) {
    return data != oldWidget.data;
  }
}

class AppStateData {
  final String username;
  final int score;
  final bool isDarkMode;
  
  AppStateData({
    required this.username,
    this.score = 0,
    this.isDarkMode = false,
  });
  
  AppStateData copyWith({
    String? username,
    int? score,
    bool? isDarkMode,
  }) {
    return AppStateData(
      username: username ?? this.username,
      score: score ?? this.score,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

// Wrapper que maneja el estado
class AppStateWrapper extends StatefulWidget {
  final Widget child;
  
  const AppStateWrapper({super.key, required this.child});
  
  @override
  _AppStateWrapperState createState() => _AppStateWrapperState();
}

class _AppStateWrapperState extends State<AppStateWrapper> {
  AppStateData _data = AppStateData(username: 'Usuario');
  
  void _updateState(AppStateData newData) {
    setState(() {
      _data = newData;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return AppState(
      data: _data,
      updateState: _updateState,
      child: widget.child,
    );
  }
}

// Acceso desde cualquier widget descendiente
class DeepChildWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = AppState.of(context);
    
    return Column(
      children: [
        Text('Usuario: ${appState?.data.username}'),
        Text('Puntuación: ${appState?.data.score}'),
        ElevatedButton(
          onPressed: () {
            appState?.updateState(
              appState.data.copyWith(score: appState.data.score + 10),
            );
          },
          child: Text('+10 puntos'),
        ),
      ],
    );
  }
}
```

### Comunicación con Provider (Recomendado)

```dart
// Model
class CounterModel extends ChangeNotifier {
  int _count = 0;
  
  int get count => _count;
  
  void increment() {
    _count++;
    notifyListeners();
  }
  
  void decrement() {
    _count--;
    notifyListeners();
  }
  
  void reset() {
    _count = 0;
    notifyListeners();
  }
}

// Provider setup
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CounterModel(),
      child: MyApp(),
    ),
  );
}

// Consumir el estado
class CounterDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Forma 1: Provider.of
    final counter = Provider.of<CounterModel>(context);
    
    return Text('Count: ${counter.count}');
  }
}

class CounterControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Forma 2: Consumer
    return Consumer<CounterModel>(
      builder: (context, counter, child) {
        return Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: counter.decrement,
            ),
            Text('${counter.count}'),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: counter.increment,
            ),
          ],
        );
      },
    );
  }
}

// Forma 3: Selector para optimización
class OptimizedCounter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<CounterModel, int>(
      selector: (context, counter) => counter.count,
      builder: (context, count, child) {
        return Text('Count: $count');
      },
    );
  }
}
```

### Comunicación con Callbacks Múltiples

```dart
// Widget con múltiples callbacks
class FormWidget extends StatefulWidget {
  final Function(String) onNameChanged;
  final Function(String) onEmailChanged;
  final Function(bool) onTermsAccepted;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  
  const FormWidget({
    super.key,
    required this.onNameChanged,
    required this.onEmailChanged,
    required this.onTermsAccepted,
    required this.onSubmit,
    required this.onCancel,
  });
  
  @override
  _FormWidgetState createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormWidget> {
  final _formKey = GlobalKey<FormState>();
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Nombre'),
            onChanged: widget.onNameChanged,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Email'),
            onChanged: widget.onEmailChanged,
          ),
          CheckboxListTile(
            title: Text('Acepto términos'),
            onChanged: (value) => widget.onTermsAccepted(value ?? false),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: widget.onSubmit,
                child: Text('Enviar'),
              ),
              TextButton(
                onPressed: widget.onCancel,
                child: Text('Cancelar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Uso
class ParentForm extends StatefulWidget {
  @override
  _ParentFormState createState() => _ParentFormState();
}

class _ParentFormState extends State<ParentForm> {
  String _name = '';
  String _email = '';
  bool _termsAccepted = false;
  
  void _handleSubmit() {
    if (_name.isNotEmpty && _email.isNotEmpty && _termsAccepted) {
      // Procesar formulario
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return FormWidget(
      onNameChanged: (name) => setState(() => _name = name),
      onEmailChanged: (email) => setState(() => _email = email),
      onTermsAccepted: (accepted) => setState(() => _termsAccepted = accepted),
      onSubmit: _handleSubmit,
      onCancel: () => Navigator.of(context).pop(),
    );
  }
}
```

---

## Listeners y Elementos Interactivos

### GestureDetector - Detección de Gestos

```dart
class GestureExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Tap simple
      onTap: () => print('Tap simple'),
      onDoubleTap: () => print('Doble tap'),
      onLongPress: () => print('Long press'),
      
      // Gestos verticales
      onVerticalDragStart: (details) => print('Drag start: ${details.globalPosition}'),
      onVerticalDragUpdate: (details) => print('Drag update: ${details.delta}'),
      onVerticalDragEnd: (details) => print('Drag end: ${details.velocity}'),
      
      // Gestos horizontales
      onHorizontalDragStart: (details) => print('Drag start'),
      onHorizontalDragUpdate: (details) => print('Drag update'),
      onHorizontalDragEnd: (details) => print('Drag end'),
      
      // Escala (pinch)
      onScaleStart: (details) => print('Scale start'),
      onScaleUpdate: (details) => print('Scale: ${details.scale}'),
      onScaleEnd: (details) => print('Scale end'),
      
      child: Container(
        width: 200,
        height: 200,
        color: Colors.blue,
        child: Center(child: Text('Tócame')),
      ),
    );
  }
}
```

### InkWell y InkResponse - Efecto Ripple

```dart
class InkWellExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // InkWell - Rectangular con ripple
        InkWell(
          onTap: () => print('InkWell tapped'),
          splashColor: Colors.blue.shade200,
          highlightColor: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            child: Text('InkWell con ripple'),
          ),
        ),
        
        SizedBox(height: 16),
        
        // InkResponse - Forma personalizada
        InkResponse(
          onTap: () => print('InkResponse tapped'),
          containedInkWell: true, // Ripple contenido
          highlightShape: BoxShape.circle,
          radius: 50,
          splashColor: Colors.green.shade200,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
            ),
            child: Icon(Icons.add, color: Colors.white),
          ),
        ),
        
        SizedBox(height: 16),
        
        // Con Material
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => print('Material InkWell'),
            child: Container(
              padding: EdgeInsets.all(16),
              child: Text('Con Material'),
            ),
          ),
        ),
      ],
    );
  }
}
```

### Widgets Interactivos Básicos

```dart
class InteractiveWidgetsExample extends StatefulWidget {
  @override
  _InteractiveWidgetsExampleState createState() => _InteractiveWidgetsExampleState();
}

class _InteractiveWidgetsExampleState extends State<InteractiveWidgetsExample> {
  bool _switchValue = false;
  bool _checkboxValue = false;
  String _radioValue = 'option1';
  double _sliderValue = 50;
  RangeValues _rangeValues = RangeValues(25, 75);
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Switch
          SwitchListTile(
            title: Text('Notificaciones'),
            subtitle: Text('Recibir notificaciones push'),
            value: _switchValue,
            onChanged: (value) {
              setState(() {
                _switchValue = value;
              });
            },
          ),
          
          // Checkbox
          CheckboxListTile(
            title: Text('Acepto términos y condiciones'),
            subtitle: Text('Lee nuestros términos'),
            value: _checkboxValue,
            onChanged: (value) {
              setState(() {
                _checkboxValue = value ?? false;
              });
            },
          ),
          
          // Radio buttons
          Text('Selecciona una opción:'),
          RadioListTile<String>(
            title: Text('Opción 1'),
            value: 'option1',
            groupValue: _radioValue,
            onChanged: (value) {
              setState(() {
                _radioValue = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: Text('Opción 2'),
            value: 'option2',
            groupValue: _radioValue,
            onChanged: (value) {
              setState(() {
                _radioValue = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: Text('Opción 3'),
            value: 'option3',
            groupValue: _radioValue,
            onChanged: (value) {
              setState(() {
                _radioValue = value!;
              });
            },
          ),
          
          // Slider
          Text('Valor: ${_sliderValue.round()}'),
          Slider(
            value: _sliderValue,
            min: 0,
            max: 100,
            divisions: 10,
            label: _sliderValue.round().toString(),
            onChanged: (value) {
              setState(() {
                _sliderValue = value;
              });
            },
          ),
          
          // RangeSlider
          Text('Rango: ${_rangeValues.start.round()} - ${_rangeValues.end.round()}'),
          RangeSlider(
            values: _rangeValues,
            min: 0,
            max: 100,
            divisions: 10,
            labels: RangeLabels(
              _rangeValues.start.round().toString(),
              _rangeValues.end.round().toString(),
            ),
            onChanged: (values) {
              setState(() {
                _rangeValues = values;
              });
            },
          ),
          
          // Dropdown
          DropdownButton<String>(
            value: _radioValue,
            items: [
              DropdownMenuItem(value: 'option1', child: Text('Opción 1')),
              DropdownMenuItem(value: 'option2', child: Text('Opción 2')),
              DropdownMenuItem(value: 'option3', child: Text('Opción 3')),
            ],
            onChanged: (value) {
              setState(() {
                _radioValue = value!;
              });
            },
          ),
        ],
      ),
    );
  }
}
```

### Botones y sus Callbacks

```dart
class ButtonsExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // ElevatedButton
          ElevatedButton(
            onPressed: () => print('Elevated pressed'),
            onLongPress: () => print('Elevated long press'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Elevated Button'),
          ),
          
          SizedBox(height: 16),
          
          // OutlinedButton
          OutlinedButton(
            onPressed: () => print('Outlined pressed'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              side: BorderSide(color: Colors.blue, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Outlined Button'),
          ),
          
          SizedBox(height: 16),
          
          // TextButton
          TextButton(
            onPressed: () => print('Text pressed'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
            child: Text('Text Button'),
          ),
          
          SizedBox(height: 16),
          
          // IconButton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.favorite),
                onPressed: () => print('Favorite'),
                color: Colors.red,
              ),
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () => print('Share'),
                color: Colors.blue,
              ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () => print('Settings'),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // FloatingActionButton
          FloatingActionButton(
            onPressed: () => print('FAB pressed'),
            child: Icon(Icons.add),
            backgroundColor: Colors.blue,
          ),
          
          SizedBox(height: 16),
          
          // Botón deshabilitado
          ElevatedButton(
            onPressed: null,  // null deshabilita el botón
            child: Text('Deshabilitado'),
          ),
        ],
      ),
    );
  }
}
```

### TextField y Formularios

```dart
class FormExample extends StatefulWidget {
  @override
  _FormExampleState createState() => _FormExampleState();
}

class _FormExampleState extends State<FormExample> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Formulario válido
      print('Nombre: ${_nameController.text}');
      print('Email: ${_emailController.text}');
      print('Password: ${_passwordController.text}');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Campo de nombre
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre',
                hintText: 'Introduce tu nombre',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor introduce tu nombre';
                }
                if (value.length < 3) {
                  return 'El nombre debe tener al menos 3 caracteres';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            
            SizedBox(height: 16),
            
            // Campo de email
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'ejemplo@email.com',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor introduce tu email';
                }
                if (!value.contains('@') || !value.contains('.')) {
                  return 'Email no válido';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            
            SizedBox(height: 16),
            
            // Campo de contraseña
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                hintText: 'Mínimo 8 caracteres',
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(Icons.visibility),
                  onPressed: () {
                    // Toggle password visibility
                  },
                ),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor introduce tu contraseña';
                }
                if (value.length < 8) {
                  return 'La contraseña debe tener al menos 8 caracteres';
                }
                return null;
              },
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submitForm(),
            ),
            
            SizedBox(height: 24),
            
            // Botón de envío
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitForm,
                child: Text('Enviar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Focus y FocusNode

```dart
class FocusExample extends StatefulWidget {
  @override
  _FocusExampleState createState() => _FocusExampleState();
}

class _FocusExampleState extends State<FocusExample> {
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  
  @override
  void initState() {
    super.initState();
    
    // Escuchar cambios de foco
    _nameFocus.addListener(() {
      if (_nameFocus.hasFocus) {
        print('Name field focused');
      } else {
        print('Name field lost focus');
      }
    });
  }
  
  @override
  void dispose() {
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }
  
  void _submitName() {
    _nameFocus.unfocus();
    FocusScope.of(context).requestFocus(_emailFocus);
  }
  
  void _submitEmail() {
    _emailFocus.unfocus();
    FocusScope.of(context).requestFocus(_passwordFocus);
  }
  
  void _submitPassword() {
    _passwordFocus.unfocus();
    // Enviar formulario
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          focusNode: _nameFocus,
          decoration: InputDecoration(labelText: 'Nombre'),
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _submitName(),
        ),
        TextFormField(
          focusNode: _emailFocus,
          decoration: InputDecoration(labelText: 'Email'),
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _submitEmail(),
        ),
        TextFormField(
          focusNode: _passwordFocus,
          decoration: InputDecoration(labelText: 'Contraseña'),
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submitPassword(),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => FocusScope.of(context).requestFocus(_nameFocus),
          child: Text('Focus Name'),
        ),
      ],
    );
  }
}
```

---

## Animaciones de Widgets

### Animaciones Implícitas (Animated Widgets)

```dart
class ImplicitAnimations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // AnimatedContainer
        AnimatedContainerExample(),
        
        SizedBox(height: 24),
        
        // AnimatedOpacity
        AnimatedOpacityExample(),
        
        SizedBox(height: 24),
        
        // AnimatedAlign
        AnimatedAlignExample(),
      ],
    );
  }
}

class AnimatedContainerExample extends StatefulWidget {
  @override
  _AnimatedContainerExampleState createState() => _AnimatedContainerExampleState();
}

class _AnimatedContainerExampleState extends State<AnimatedContainerExample> {
  bool _isExpanded = false;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        width: _isExpanded ? 300 : 100,
        height: _isExpanded ? 300 : 100,
        decoration: BoxDecoration(
          color: _isExpanded ? Colors.blue : Colors.red,
          borderRadius: BorderRadius.circular(_isExpanded ? 20 : 8),
        ),
        child: Center(
          child: Text(
            _isExpanded ? 'Expandido' : 'Normal',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class AnimatedOpacityExample extends StatefulWidget {
  @override
  _AnimatedOpacityExampleState createState() => _AnimatedOpacityExampleState();
}

class _AnimatedOpacityExampleState extends State<AnimatedOpacityExample> {
  bool _isVisible = true;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedOpacity(
          opacity: _isVisible ? 1.0 : 0.0,
          duration: Duration(milliseconds: 500),
          child: Container(
            width: 100,
            height: 100,
            color: Colors.purple,
          ),
        ),
        ElevatedButton(
          onPressed: () => setState(() => _isVisible = !_isVisible),
          child: Text('Toggle Opacity'),
        ),
      ],
    );
  }
}

class AnimatedAlignExample extends StatefulWidget {
  @override
  _AnimatedAlignExampleState createState() => _AnimatedAlignExampleState();
}

class _AnimatedAlignExampleState extends State<AnimatedAlignExample> {
  Alignment _alignment = Alignment.topLeft;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() {
        _alignment = _alignment == Alignment.topLeft
          ? Alignment.bottomRight
          : Alignment.topLeft;
      }),
      child: Container(
        width: 200,
        height: 200,
        color: Colors.grey.shade200,
        child: AnimatedAlign(
          alignment: _alignment,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          child: Container(
            width: 50,
            height: 50,
            color: Colors.orange,
          ),
        ),
      ),
    );
  }
}
```

### Animaciones con AnimationController

```dart
class ControllerAnimationExample extends StatefulWidget {
  @override
  _ControllerAnimationExampleState createState() => _ControllerAnimationExampleState();
}

class _ControllerAnimationExampleState extends State<ControllerAnimationExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    
    // Iniciar animación
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              width: 200 * _animation.value,
              height: 200 * _animation.value,
              color: Colors.blue.withOpacity(_animation.value),
              child: child,
            );
          },
          child: Center(child: Text('Animado')),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _controller.forward(),
              child: Text('Play'),
            ),
            ElevatedButton(
              onPressed: () => _controller.reverse(),
              child: Text('Reverse'),
            ),
            ElevatedButton(
              onPressed: () => _controller.reset(),
              child: Text('Reset'),
            ),
          ],
        ),
      ],
    );
  }
}
```

### Animaciones Múltiples

```dart
class MultiAnimationExample extends StatefulWidget {
  @override
  _MultiAnimationExampleState createState() => _MultiAnimationExampleState();
}

class _MultiAnimationExampleState extends State<MultiAnimationExample>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<BorderRadius?> _borderAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    _sizeAnimation = Tween<double>(begin: 50, end: 200).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.75, curve: Curves.easeIn),
      ),
    );
    
    _colorAnimation = ColorTween(begin: Colors.red, end: Colors.blue).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.25, 1.0, curve: Curves.easeInOut),
      ),
    );
    
    _borderAnimation = BorderRadiusTween(
      begin: BorderRadius.circular(0),
      end: BorderRadius.circular(50),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              width: _sizeAnimation.value,
              height: _sizeAnimation.value,
              decoration: BoxDecoration(
                color: _colorAnimation.value,
                borderRadius: _borderAnimation.value,
              ),
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Center(child: Text('Multi-animación')),
              ),
            );
          },
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.status == AnimationStatus.completed) {
              _controller.reverse();
            } else {
              _controller.forward();
            }
          },
          child: Text('Animar'),
        ),
      ],
    );
  }
}
```

### Hero Animations

```dart
// Pantalla de lista
class ProductListScreen extends StatelessWidget {
  final List<Product> products = [
    Product(id: 1, name: 'Producto 1', image: 'image1.jpg'),
    Product(id: 2, name: 'Producto 2', image: 'image2.jpg'),
  ];
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            );
          },
          child: Hero(
            tag: 'product-${product.id}',
            child: Image.network(product.image),
          ),
        );
      },
    );
  }
}

// Pantalla de detalle
class ProductDetailScreen extends StatelessWidget {
  final Product product;
  
  const ProductDetailScreen({super.key, required this.product});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Hero(
            tag: 'product-${product.id}',
            child: Image.network(product.image),
          ),
          Text(product.name),
        ],
      ),
    );
  }
}
```

---

## Estructura de una Aplicación Flutter

### Estructura de Archivos

```
lib/
├── main.dart                 # Punto de entrada
├── app.dart                  # Configuración de la app
├── core/                     # Core functionality
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── app_values.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── text_styles.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── formatters.dart
│   │   └── extensions.dart
│   └── errors/
│       ├── exceptions.dart
│       └── failures.dart
├── data/                     # Capa de datos
│   ├── models/
│   │   ├── user_model.dart
│   │   └── product_model.dart
│   ├── repositories/
│   │   ├── user_repository.dart
│   │   └── product_repository.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── storage_service.dart
│   │   └── auth_service.dart
│   └── datasources/
│       ├── local/
│       │   └── local_db.dart
│       └── remote/
│           └── api_client.dart
├── domain/                   # Capa de dominio
│   ├── entities/
│   │   ├── user.dart
│   │   └── product.dart
│   ├── repositories/
│   │   └── interfaces/
│   └── usecases/
│       ├── get_user.dart
│       └── get_products.dart
├── presentation/             # Capa de presentación
│   ├── screens/
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   ├── home_controller.dart
│   │   │   └── widgets/
│   │   │       ├── product_card.dart
│   │   │       └── category_chip.dart
│   │   ├── product_detail/
│   │   │   ├── product_detail_screen.dart
│   │   │   └── widgets/
│   │   └── profile/
│   │       ├── profile_screen.dart
│   │       └── widgets/
│   ├── widgets/              # Widgets compartidos
│   │   ├── buttons/
│   │   │   └── custom_button.dart
│   │   ├── cards/
│   │   │   └── info_card.dart
│   │   ├── inputs/
│   │   │   └── custom_text_field.dart
│   │   └── dialogs/
│   │       └── confirmation_dialog.dart
│   └── providers/            # Estado global
│       ├── auth_provider.dart
│       └── cart_provider.dart
├── routes/                   # Navegación
│   ├── app_router.dart
│   └── route_names.dart
└── injection/                # Inyección de dependencias
    └── injection.dart
```

### main.dart

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/cart_provider.dart';
import 'injection/injection.dart';

void main() async {
  // Asegurar que Flutter está inicializado
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar dependencias
  await initializeDependencies();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
```

### app.dart

```dart
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/home/home_screen.dart';
import 'routes/app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App',
      debugShowCheckedModeBanner: false,
      
      // Tema
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      
      // Navegación
      initialRoute: AppRouter.home,
      onGenerateRoute: AppRouter.generateRoute,
      
      // Home
      home: const HomeScreen(),
    );
  }
}
```

### Widget Principal con Navegación

```dart
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    HomeScreen(),
    SearchScreen(),
    CartScreen(),
    ProfileScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
```

### Arquitectura de Widgets por Pantalla

```dart
// home_screen.dart - Pantalla principal
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFAB(),
    );
  }
  
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Mi App'),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {},
        ),
      ],
    );
  }
  
  Widget _buildBody() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildHeader(),
        ),
        SliverToBoxAdapter(
          child: _buildCategories(),
        ),
        SliverToBoxAdapter(
          child: _buildPromotions(),
        ),
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => ProductCard(product: products[index]),
            childCount: products.length,
          ),
        ),
      ],
    );
  }
  
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenido',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Descubre nuestros productos',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategories() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) => CategoryChip(
          category: categories[index],
          isSelected: index == 0,
          onTap: () {},
        ),
      ),
    );
  }
  
  Widget _buildPromotions() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      child: PageView.builder(
        itemCount: promotions.length,
        itemBuilder: (context, index) => PromotionCard(
          promotion: promotions[index],
        ),
      ),
    );
  }
  
  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () {},
      child: const Icon(Icons.add),
    );
  }
}
```

---

## Patrones de Diseño con Widgets

### Patrón BLoC (Business Logic Component)

```dart
// Events
abstract class CounterEvent {}

class CounterIncrement extends CounterEvent {}
class CounterDecrement extends CounterEvent {}
class CounterReset extends CounterEvent {}

// State
class CounterState {
  final int count;
  
  const CounterState({required this.count});
  
  CounterState copyWith({int? count}) {
    return CounterState(count: count ?? this.count);
  }
}

// Bloc
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterState(count: 0)) {
    on<CounterIncrement>(_onIncrement);
    on<CounterDecrement>(_onDecrement);
    on<CounterReset>(_onReset);
  }
  
  void _onIncrement(CounterIncrement event, Emitter<CounterState> emit) {
    emit(state.copyWith(count: state.count + 1));
  }
  
  void _onDecrement(CounterDecrement event, Emitter<CounterState> emit) {
    emit(state.copyWith(count: state.count - 1));
  }
  
  void _onReset(CounterReset event, Emitter<CounterState> emit) {
    emit(const CounterState(count: 0));
  }
}

// UI
class CounterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: Scaffold(
        appBar: AppBar(title: Text('Counter BLoC')),
        body: BlocBuilder<CounterBloc, CounterState>(
          builder: (context, state) {
            return Center(
              child: Text(
                'Count: ${state.count}',
                style: TextStyle(fontSize: 48),
              ),
            );
          },
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () => context.read<CounterBloc>().add(CounterIncrement()),
              child: Icon(Icons.add),
            ),
            SizedBox(height: 8),
            FloatingActionButton(
              onPressed: () => context.read<CounterBloc>().add(CounterDecrement()),
              child: Icon(Icons.remove),
            ),
            SizedBox(height: 8),
            FloatingActionButton(
              onPressed: () => context.read<CounterBloc>().add(CounterReset()),
              child: Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Patrón Provider con ChangeNotifier

```dart
// Model
class ProductModel extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final products = await ProductService.getProducts();
      _products = products;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }
  
  void removeProduct(int id) {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}

// Provider setup
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ProductModel(),
      child: MyApp(),
    ),
  );
}

// UI
class ProductListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Productos')),
      body: Consumer<ProductModel>(
        builder: (context, model, child) {
          if (model.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (model.error != null) {
            return Center(child: Text('Error: ${model.error}'));
          }
          
          if (model.products.isEmpty) {
            return Center(child: Text('No hay productos'));
          }
          
          return ListView.builder(
            itemCount: model.products.length,
            itemBuilder: (context, index) {
              final product = model.products[index];
              return ProductTile(product: product);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<ProductModel>().fetchProducts(),
        child: Icon(Icons.refresh),
      ),
    );
  }
}
```

### Patrón MVVM (Model-View-ViewModel)

```dart
// Model
class User {
  final String id;
  final String name;
  final String email;
  
  const User({
    required this.id,
    required this.name,
    required this.email,
  });
}

// ViewModel
class UserViewModel extends ChangeNotifier {
  final UserService _userService;
  
  User? _user;
  bool _isLoading = false;
  String? _error;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  UserViewModel(this._userService);
  
  Future<void> loadUser(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _user = await _userService.getUser(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> updateUser(User updatedUser) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _user = await _userService.updateUser(updatedUser);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}

// View
class UserScreen extends StatelessWidget {
  final String userId;
  
  const UserScreen({super.key, required this.userId});
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserViewModel(context.read<UserService>())..loadUser(userId),
      child: Scaffold(
        appBar: AppBar(title: Text('Usuario')),
        body: Consumer<UserViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return Center(child: CircularProgressIndicator());
            }
            
            if (viewModel.error != null) {
              return Center(child: Text('Error: ${viewModel.error}'));
            }
            
            final user = viewModel.user;
            if (user == null) {
              return Center(child: Text('Usuario no encontrado'));
            }
            
            return UserDetailView(user: user);
          },
        ),
      ),
    );
  }
}
```

---

## Widgets Personalizados

### Widget Personalizado Básico

```dart
class CustomCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double elevation;
  
  const CustomCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.backgroundColor,
    this.elevation = 2,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      color: backgroundColor ?? Theme.of(context).cardColor,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 16),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Uso
CustomCard(
  title: 'Juan García',
  subtitle: 'Desarrollador Flutter',
  leading: CircleAvatar(child: Text('JG')),
  trailing: Icon(Icons.chevron_right),
  onTap: () => print('Card tapped'),
)
```

### Widget con Estado Interno

```dart
class ExpandableCard extends StatefulWidget {
  final String title;
  final String summary;
  final Widget content;
  final bool initiallyExpanded;
  
  const ExpandableCard({
    super.key,
    required this.title,
    required this.summary,
    required this.content,
    this.initiallyExpanded = false,
  });
  
  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;
  
  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          InkWell(
            onTap: _toggleExpanded,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.summary,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  RotationTransition(
                    turns: _expandAnimation,
                    child: const Icon(Icons.expand_more),
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: widget.content,
            ),
          ),
        ],
      ),
    );
  }
}

// Uso
ExpandableCard(
  title: 'Más información',
  summary: 'Toca para ver detalles',
  content: Text('Contenido expandido con más información...'),
)
```

### Widget Compuesto

```dart
class UserProfileCard extends StatelessWidget {
  final User user;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onFollow;
  final bool showActions;
  
  const UserProfileCard({
    super.key,
    required this.user,
    this.onEdit,
    this.onDelete,
    this.onFollow,
    this.showActions = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildHeader(context),
          _buildStats(context),
          if (showActions) _buildActions(context),
        ],
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColorDark,
          ],
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: user.avatarUrl != null
              ? NetworkImage(user.avatarUrl!)
              : null,
            child: user.avatarUrl == null
              ? Text(user.name[0].toUpperCase(), style: TextStyle(fontSize: 32))
              : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStats(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(context, '${user.posts}', 'Posts'),
          _buildStatItem(context, '${user.followers}', 'Seguidores'),
          _buildStatItem(context, '${user.following}', 'Siguiendo'),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
  
  Widget _buildActions(BuildContext context) {
    return ButtonBar(
      alignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (onEdit != null)
          TextButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('Editar'),
            onPressed: onEdit,
          ),
        if (onFollow != null)
          ElevatedButton.icon(
            icon: const Icon(Icons.person_add),
            label: const Text('Seguir'),
            onPressed: onFollow,
          ),
        if (onDelete != null)
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
      ],
    );
  }
}

// Uso
UserProfileCard(
  user: User(
    id: '1',
    name: 'Juan García',
    email: 'juan@email.com',
    posts: 150,
    followers: 1200,
    following: 89,
  ),
  onEdit: () => print('Edit'),
  onFollow: () => print('Follow'),
  onDelete: () => print('Delete'),
)
```

---

## Ejemplos Prácticos Completos

### Ejemplo 1: Contador Complejo

```dart
class ComplexCounter extends StatefulWidget {
  const ComplexCounter({super.key});
  
  @override
  State<ComplexCounter> createState() => _ComplexCounterState();
}

class _ComplexCounterState extends State<ComplexCounter> {
  int _count = 0;
  int _step = 1;
  List<int> _history = [];
  
  void _increment() {
    setState(() {
      _count += _step;
      _history.add(_count);
    });
  }
  
  void _decrement() {
    setState(() {
      _count -= _step;
      _history.add(_count);
    });
  }
  
  void _reset() {
    setState(() {
      _count = 0;
      _history.clear();
    });
  }
  
  void _changeStep(int newStep) {
    setState(() {
      _step = newStep;
    });
  }
  
  void _undo() {
    if (_history.isNotEmpty) {
      setState(() {
        _history.removeLast();
        _count = _history.isNotEmpty ? _history.last : 0;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contador Complejo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _history.isNotEmpty ? _undo : null,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reset,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$_count',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Paso: $_step',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _decrement,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('$_count'),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _increment,
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text('Seleccionar paso:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [1, 5, 10, 100].map((step) {
                return ChoiceChip(
                  label: Text('$step'),
                  selected: _step == step,
                  onSelected: (_) => _changeStep(step),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Ejemplo 2: Lista con Filtrado

```dart
class FilterableList extends StatefulWidget {
  const FilterableList({super.key});
  
  @override
  State<FilterableList> createState() => _FilterableListState();
}

class _FilterableListState extends State<FilterableList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Todos';
  
  final List<Product> _products = [
    Product(id: 1, name: 'Laptop', category: 'Electrónica', price: 999),
    Product(id: 2, name: 'Smartphone', category: 'Electrónica', price: 699),
    Product(id: 3, name: 'Camiseta', category: 'Ropa', price: 29),
    Product(id: 4, name: 'Pantalón', category: 'Ropa', price: 49),
    Product(id: 5, name: 'Libro', category: 'Libros', price: 19),
  ];
  
  List<String> get _categories {
    return ['Todos', ...{_products.map((p) => p.category)}}];
  }
  
  List<Product> get _filteredProducts {
    return _products.where((product) {
      final matchesSearch = product.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'Todos' || product.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
      ),
      body: Column(
        children: [
          // Buscador
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Filtros
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          
          // Contador
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${_filteredProducts.length} productos encontrados',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          
          // Lista
          Expanded(
            child: _filteredProducts.isEmpty
              ? Center(
                  child: Text('No se encontraron productos'),
                )
              : ListView.builder(
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(product.name[0]),
                      ),
                      title: Text(product.name),
                      subtitle: Text(product.category),
                      trailing: Text('\$${product.price}'),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}
```

---

## Mejores Prácticas

### 1. Mantener Widgets Pequeños

```dart
// ❌ Malo: Widget gigante
class HugeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 100+ líneas de código
      ],
    );
  }
}

// ✅ Bueno: Widgets pequeños y enfocados
class UserProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserAvatar(),
        UserInfo(),
        UserStats(),
        UserActions(),
      ],
    );
  }
}
```

### 2. Usar const Cuando Sea Posible

```dart
// ❌ Malo: Sin const
Widget build(BuildContext context) {
  return Container(
    child: Text('Estático'),
  );
}

// ✅ Bueno: Con const
Widget build(BuildContext context) {
  return const Text('Estático');
}
```

### 3. Extraer Métodos de Build

```dart
// ❌ Malo: Todo en un método
Widget build(BuildContext context) {
  return Column(
    children: [
      Container(
        // 50 líneas
      ),
      Container(
        // 50 líneas
      ),
    ],
  );
}

// ✅ Bueno: Métodos separados
Widget build(BuildContext context) {
  return Column(
    children: [
      _buildHeader(),
      _buildBody(),
      _buildFooter(),
    ],
  );
}

Widget _buildHeader() {
  return Container(
    // código del header
  );
}
```

### 4. Evitar Lógica en build()

```dart
// ❌ Malo: Lógica compleja en build
Widget build(BuildContext context) {
  final now = DateTime.now();
  final isMorning = now.hour < 12;
  final greeting = isMorning ? 'Buenos días' : 'Buenas tardes';
  final userName = 'Usuario';
  
  return Text('$greeting, $userName');
}

// ✅ Bueno: Lógica separada
class GreetingWidget extends StatelessWidget {
  final DateTime dateTime;
  
  const GreetingWidget({super.key, required this.dateTime});
  
  String get _greeting {
    final isMorning = dateTime.hour < 12;
    return isMorning ? 'Buenos días' : 'Buenas tardes';
  }
  
  @override
  Widget build(BuildContext context) {
    return Text(_greeting);
  }
}
```

### 5. Gestionar Estado Local vs Global

```dart
// ✅ Estado local para UI simple
class LocalStateExample extends StatefulWidget {
  @override
  State<LocalStateExample> createState() => _LocalStateExampleState();
}

class _LocalStateExampleState extends State<LocalStateExample> {
  bool _isExpanded = false;  // Estado local simple
  
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: _isExpanded,
      onExpansionChanged: (expanded) => setState(() => _isExpanded = expanded),
    );
  }
}

// ✅ Estado global para datos compartidos
// Usar Provider, Riverpod, BLoC, etc.
```

### 6. Usar Keys Correctamente

```dart
// ✅ Key para widgets en lista
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(
      key: ValueKey(items[index].id),  // Key estable
      title: Text(items[index].name),
    );
  },
)

// ✅ GlobalKey para acceso a State
final _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  child: TextFormField(...),
);

// Validar
if (_formKey.currentState!.validate()) {
  // Formulario válido
}
```

### 7. Limpiar Recursos

```dart
class ExampleWidget extends StatefulWidget {
  @override
  State<ExampleWidget> createState() => _ExampleWidgetState();
}

class _ExampleWidgetState extends State<ExampleWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  AnimationController? _animationController;
  StreamSubscription? _subscription;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _subscription = someStream.listen(_onData);
  }
  
  @override
  void dispose() {
    // ✅ Siempre limpiar recursos
    _controller.dispose();
    _focusNode.dispose();
    _animationController?.dispose();
    _subscription?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

---

## Conclusión

Los widgets son el corazón de Flutter. Entender su ciclo de vida, comunicación y patrones de diseño es esencial para construir aplicaciones robustas:

1. **StatelessWidget**: Para contenido estático
2. **StatefulWidget**: Para estado mutable
3. **setState()**: Para actualizaciones locales
4. **Callbacks**: Para comunicación hijo → padre
5. **Provider/BLoC**: Para estado global
6. **Animaciones**: Implicit o con AnimationController
7. **Estructura**: Organizar por capas y responsabilidades

---

**Versión del documento**: 1.0  
**Flutter versión**: 3.24.0  
**Última actualización**: Julio 2025