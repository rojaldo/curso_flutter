# Módulo Completo: Maquetación de Aplicaciones en Flutter

## Índice

1. [Introducción a la Maquetación en Flutter](#introducción-a-la-maquetación-en-flutter)
2. [Conceptos Fundamentales](#conceptos-fundamentales)
3. [Widgets Básicos de Layout](#widgets-básicos-de-layout)
4. [Filas y Columnas](#filas-y-columnas)
5. [Contenedores y Decoración](#contenedores-y-decoración)
6. [Material Design en Flutter](#material-design-en-flutter)
7. [El Widget Scaffold](#el-widget-scaffold)
8. [Componentes Material Esenciales](#componentes-material-esenciales)
9. [Widgets de Desplazamiento](#widgets-de-desplazamiento)
10. [Layouts Responsivos](#layouts-responsivos)
11. [Buenas Prácticas de Maquetación](#buenas-prácticas-de-maquetación)
12. [Ejemplos Prácticos Completos](#ejemplos-prácticos-completos)
13. [Errores Comunes y Soluciones](#errores-comunes-y-soluciones)

---

## Introducción a la Maquetación en Flutter

### ¿Qué es la Maquetación?

La maquetación (o layout) es el proceso de organizar y posicionar elementos visuales en una interfaz de usuario. En Flutter, todo es un widget, y la maquetación se logra mediante la composición de widgets que definen cómo se distribuyen los elementos en pantalla.

### Filosofía de Flutter

Flutter sigue el principio de **"Everything is a Widget"**:
- Los elementos visuales son widgets (`Text`, `Image`, `Icon`)
- Los elementos de layout son widgets (`Row`, `Column`, `Container`)
- Los elementos estructurales son widgets (`Scaffold`, `AppBar`, `Drawer`)

### Árbol de Widgets

```
MaterialApp
└── Scaffold
    ├── AppBar
    │   └── Text (título)
    └── body: Center
        └── Column
            ├── Text
            ├── Row
            │   ├── Icon
            │   └── Text
            └── ElevatedButton
```

---

## Conceptos Fundamentales

### Restricciones (Constraints)

Flutter utiliza un sistema de restricciones que pasa de padre a hijo:

1. **Padre pasa restricciones al hijo**: "Puedes ser tan ancho como X y tan alto como Y"
2. **Hijo decide su tamaño**: Dentro de esas restricciones, el hijo decide
3. **Padre posiciona al hijo**: El padre coloca al hijo en su posición final

```dart
// Ejemplo de restricciones
Container(
  constraints: BoxConstraints(
    minWidth: 100,
    maxWidth: 300,
    minHeight: 50,
    maxHeight: 200,
  ),
  child: Text('Texto con restricciones'),
)
```

### Tipos de Restricciones

| Tipo | Descripción | Uso |
|------|-------------|-----|
| `tight` | Tamaño fijo exacto | Forzar tamaño específico |
| `loose` | Tamaño mínimo, sin máximo | Flexible |
| `bounded` | Máximo definido | Limitar expansión |
| `unbounded` | Sin límites | Scroll, listas infinitas |

### Modelo de Box

Flutter usa el modelo de caja CSS-like:

```
┌─────────────────────────────────┐
│           Margin                │
│  ┌───────────────────────────┐  │
│  │        Border             │  │
│  │  ┌─────────────────────┐  │  │
│  │  │      Padding        │  │  │
│  │  │  ┌───────────────┐  │  │  │
│  │  │  │    Content    │  │  │  │
│  │  │  └───────────────┘  │  │  │
│  │  └─────────────────────┘  │  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘
```

```dart
Container(
  margin: EdgeInsets.all(20),      // Espacio externo
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  decoration: BoxDecoration(
    border: Border.all(color: Colors.blue, width: 2),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text('Contenido'),
)
```

---

## Widgets Básicos de Layout

### Container

El widget más versátil para maquetación:

```dart
Container({
  Key? key,
  AlignmentGeometry? alignment,      // Alineación del hijo
  EdgeInsetsGeometry? padding,      // Espacio interno
  Color? color,                     // Color de fondo
  Decoration? decoration,           // Decoración compleja
  Decoration? foregroundDecoration, // Decoración sobre el contenido
  double? width,                    // Ancho
  double? height,                   // Alto
  BoxConstraints? constraints,      // Restricciones
  EdgeInsetsGeometry? margin,       // Espacio externo
  Matrix4? transform,               // Transformaciones
  AlignmentGeometry? transformAlignment,
  Widget? child,                    // Contenido
  Clip? clipBehavior,               // Recorte
})
```

#### Ejemplos de Container

```dart
// Container básico
Container(
  width: 200,
  height: 100,
  color: Colors.blue,
  child: Center(child: Text('Container básico')),
)

// Container con padding y margin
Container(
  margin: EdgeInsets.all(16),
  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: Text('Container con sombra'),
)

// Container con gradiente
Container(
  width: double.infinity,
  height: 200,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.purple, Colors.blue],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  child: Center(
    child: Text(
      'Gradiente',
      style: TextStyle(color: Colors.white, fontSize: 24),
    ),
  ),
)

// Container con imagen de fondo
Container(
  width: 300,
  height: 200,
  decoration: BoxDecoration(
    image: DecorationImage(
      image: NetworkImage('https://example.com/image.jpg'),
      fit: BoxFit.cover,
    ),
    borderRadius: BorderRadius.circular(16),
  ),
  child: Center(
    child: Text(
      'Con imagen de fondo',
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        shadows: [Shadow(color: Colors.black, blurRadius: 10)],
      ),
    ),
  ),
)

// Container con bordes complejos
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    border: Border(
      top: BorderSide(color: Colors.blue, width: 4),
      left: BorderSide(color: Colors.green, width: 2),
      right: BorderSide(color: Colors.green, width: 2),
      bottom: BorderSide(color: Colors.red, width: 4),
    ),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text('Bordes personalizados'),
)
```

### Padding

Aplica espaciado interno de forma simple:

```dart
// Padding con valores uniformes
Padding(
  padding: EdgeInsets.all(16),
  child: Text('Con padding uniforme'),
)

// Padding asimétrico
Padding(
  padding: EdgeInsets.only(
    left: 24,
    top: 8,
    right: 24,
    bottom: 8,
  ),
  child: Text('Padding específico por lado'),
)

// Padding simétrico
Padding(
  padding: EdgeInsets.symmetric(
    horizontal: 16,  // Izquierda y derecha
    vertical: 8,      // Arriba y abajo
  ),
  child: Text('Padding simétrico'),
)

// Padding con fromLTRB
Padding(
  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
  child: Text('Padding con fromLTRB'),
)
```

### Center y Align

```dart
// Center: Centra al hijo en ambos ejes
Center(
  child: Container(
    width: 100,
    height: 100,
    color: Colors.red,
    child: Text('Centrado'),
  ),
)

// Align: Control preciso de alineación
Align(
  alignment: Alignment.topLeft,
  child: Text('Arriba a la izquierda'),
)

Align(
  alignment: Alignment(0.5, 0.5), // Offset personalizado (-1 a 1)
  child: Text('Posición personalizada'),
)

Align(
  alignment: Alignment.bottomRight,
  child: Container(
    padding: EdgeInsets.all(8),
    color: Colors.blue,
    child: Text('Esquina inferior derecha'),
  ),
)
```

### SizedBox y ConstrainedBox

```dart
// SizedBox: Tamaño fijo
SizedBox(
  width: 200,
  height: 100,
  child: Container(color: Colors.green),
)

// SizedBox para espaciado
Column(
  children: [
    Text('Elemento 1'),
    SizedBox(height: 16),  // Espacio vertical
    Text('Elemento 2'),
    SizedBox(width: 16),   // Espacio horizontal (no visible en Column)
    // Pero útil en Row
  ],
)

// SizedBox.expand: Ocupa todo el espacio disponible
SizedBox.expand(
  child: Container(
    color: Colors.purple,
    child: Text('Ocupa todo'),
  ),
)

// ConstrainedBox: Restricciones
ConstrainedBox(
  constraints: BoxConstraints(
    minWidth: 100,
    maxWidth: 200,
    minHeight: 50,
    maxHeight: 100,
  ),
  child: Container(
    color: Colors.orange,
    child: Text('Con restricciones'),
  ),
)

// ConstrainedBox.tightFor: Tamaño mínimo
ConstrainedBox(
  constraints: BoxConstraints.tightFor(
    width: 200,
    height: 100,
  ),
  child: Container(color: Colors.cyan),
)
```

### AspectRatio

```dart
// Mantiene proporción de aspecto
AspectRatio(
  aspectRatio: 16 / 9,  // Formato widescreen
  child: Container(
    color: Colors.indigo,
    child: Center(child: Text('16:9')),
  ),
)

AspectRatio(
  aspectRatio: 1,  // Cuadrado
  child: Container(
    color: Colors.teal,
    child: Center(child: Text('1:1')),
  ),
)

// Útil para tarjetas de video
Card(
  child: Column(
    children: [
      AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network('video_thumbnail.jpg', fit: BoxFit.cover),
      ),
      Padding(
        padding: EdgeInsets.all(8),
        child: Text('Título del video'),
      ),
    ],
  ),
)
```

### FittedBox

```dart
// Escala el hijo para que quepa
FittedBox(
  fit: BoxFit.contain,  // Mantiene proporción, cabe completo
  child: Container(
    width: 400,
    height: 300,
    color: Colors.amber,
    child: Text('Se escala automáticamente'),
  ),
)

// BoxFit.cover: Cubre todo, puede recortar
FittedBox(
  fit: BoxFit.cover,
  child: Image.network('image.jpg'),
)

// BoxFit.fill: Estira para llenar
FittedBox(
  fit: BoxFit.fill,
  child: Container(
    width: 100,
    height: 50,
    color: Colors.lime,
  ),
)

// Opciones de BoxFit:
// - contain: Mantiene proporción, cabe completo
// - cover: Mantiene proporción, cubre todo
// - fill: Estira para llenar exactamente
// - fitWidth: Ancho coincide, alto ajustado
// - fitHeight: Alto coincide, ancho ajustado
// - none: Sin escalado
// - scaleDown: Como contain pero no escala hacia arriba
```

### FractionallySizedBox

```dart
// Tamaño como fracción del padre
FractionallySizedBox(
  widthFactor: 0.8,   // 80% del ancho del padre
  heightFactor: 0.5,  // 50% del alto del padre
  child: Container(
    color: Colors.deepOrange,
    child: Center(child: Text('80% x 50%')),
  ),
)

// Útil para botones a ancho completo
FractionallySizedBox(
  widthFactor: 1,  // 100% del ancho
  child: ElevatedButton(
    onPressed: () {},
    child: Text('Botón a ancho completo'),
  ),
)

// Combinado con Center
Center(
  child: FractionallySizedBox(
    widthFactor: 0.6,
    child: Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Tarjeta centrada al 60%'),
      ),
    ),
  ),
)
```

### LimitedBox

```dart
// Limita el tamaño cuando no tiene restricciones
LimitedBox(
  maxWidth: 200,
  maxHeight: 100,
  child: Container(
    color: Colors.pink,
    child: Text('Limitado si no tiene restricciones'),
  ),
)

// Útil en listas horizontales sin límite
ListView(
  scrollDirection: Axis.horizontal,
  children: List.generate(10, (index) {
    return LimitedBox(
      maxWidth: 150,
      child: Container(
        margin: EdgeInsets.all(8),
        color: Colors.primaries[index % Colors.primaries.length],
        child: Center(child: Text('Item $index')),
      ),
    );
  }),
)
```

### OffStage y Visibility

```dart
// Offstage: Oculta el widget pero mantiene su lugar
Offstage(
  offstage: isVisible,  // true = oculto
  child: Container(
    color: Colors.brown,
    child: Text('Oculto pero presente'),
  ),
)

// Visibility: Más opciones de control
Visibility(
  visible: isVisible,
  maintainSize: true,      // Mantiene tamaño
  maintainAnimation: true, // Mantiene animaciones
  maintainState: true,     // Mantiene estado
  maintainInteractivity: true, // Mantiene interactividad
  child: Container(
    color: Colors.grey,
    child: Text('Visibilidad controlada'),
  ),
)

// Ejemplo práctico: Mostrar/ocultar con animación
AnimatedOpacity(
  opacity: isVisible ? 1.0 : 0.0,
  duration: Duration(milliseconds: 300),
  child: Container(
    height: 100,
    color: Colors.purple,
    child: Text('Fade in/out'),
  ),
)
```

---

## Filas y Columnas

### Conceptos Básicos

- **Row**: Organiza widgets horizontalmente
- **Column**: Organiza widgets verticalmente
- Ambos heredan de `Flex`

### Propiedades Principales

```dart
Row({
  Key? key,
  MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
  MainAxisSize mainAxisSize = MainAxisSize.max,
  CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  TextDirection? textDirection,
  VerticalDirection verticalDirection = VerticalDirection.down,
  TextBaseline? textBaseline,
  List<Widget> children = const <Widget>[],
})
```

### MainAxisAlignment

Controla la distribución en el eje principal (horizontal en Row, vertical en Column):

```dart
// MainAxisAlignment.spaceEvenly - Espacio uniforme
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    Icon(Icons.star),
    Icon(Icons.star),
    Icon(Icons.star),
  ],
)

// MainAxisAlignment.spaceBetween - Entre elementos
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text('Izquierda'),
    Text('Derecha'),
  ],
)

// MainAxisAlignment.spaceAround - Espacio alrededor
Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: [
    Container(width: 50, height: 50, color: Colors.red),
    Container(width: 50, height: 50, color: Colors.green),
    Container(width: 50, height: 50, color: Colors.blue),
  ],
)

// MainAxisAlignment.center - Centrado
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Text('Centrado horizontalmente'),
  ],
)

// MainAxisAlignment.start - Al inicio
Row(
  mainAxisAlignment: MainAxisAlignment.start,
  children: [
    Text('Al inicio'),
  ],
)

// MainAxisAlignment.end - Al final
Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    Text('Al final'),
  ],
)
```

### CrossAxisAlignment

Controla la alineación en el eje transversal (vertical en Row, horizontal en Column):

```dart
// CrossAxisAlignment.start - Alineado arriba (Row) o izquierda (Column)
Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Container(width: 50, height: 100, color: Colors.red),
    Container(width: 50, height: 50, color: Colors.green),
    Container(width: 50, height: 75, color: Colors.blue),
  ],
)

// CrossAxisAlignment.end - Alineado abajo (Row) o derecha (Column)
Row(
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
    Container(width: 50, height: 100, color: Colors.red),
    Container(width: 50, height: 50, color: Colors.green),
    Container(width: 50, height: 75, color: Colors.blue),
  ],
)

// CrossAxisAlignment.center - Centrado (default)
Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Container(width: 50, height: 100, color: Colors.red),
    Container(width: 50, height: 50, color: Colors.green),
    Container(width: 50, height: 75, color: Colors.blue),
  ],
)

// CrossAxisAlignment.stretch - Estira para llenar
Row(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    Expanded(child: Container(color: Colors.red)),
    Expanded(child: Container(color: Colors.green)),
    Expanded(child: Container(color: Colors.blue)),
  ],
)

// CrossAxisAlignment.baseline - Alinea por línea base de texto
Row(
  crossAxisAlignment: CrossAxisAlignment.baseline,
  textBaseline: TextBaseline.alphabetic,  // Requerido cuando se usa baseline
  children: [
    Text('Grande', style: TextStyle(fontSize: 32)),
    Text('Mediano', style: TextStyle(fontSize: 16)),
    Text('Pequeño', style: TextStyle(fontSize: 12)),
  ],
)
```

### MainAxisSize

```dart
// MainAxisSize.max - Ocupa todo el espacio (default)
Row(
  mainAxisSize: MainAxisSize.max,
  children: [
    Container(width: 50, height: 50, color: Colors.red),
    Container(width: 50, height: 50, color: Colors.green),
  ],
)

// MainAxisSize.min - Solo el espacio necesario
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Container(width: 50, height: 50, color: Colors.red),
    Container(width: 50, height: 50, color: Colors.green),
  ],
)
```

### Expanded y Flexible

Controlan cómo los hijos comparten espacio disponible:

```dart
// Expanded: Ocupa todo el espacio disponible
Row(
  children: [
    Expanded(
      child: Container(
        color: Colors.red,
        child: Text('Ocupa todo el espacio'),
      ),
    ),
    Container(width: 100, color: Colors.blue),
  ],
)

// Expanded con flex
Row(
  children: [
    Expanded(
      flex: 2,  // 2/3 del espacio
      child: Container(color: Colors.red),
    ),
    Expanded(
      flex: 1,  // 1/3 del espacio
      child: Container(color: Colors.blue),
    ),
  ],
)

// Flexible: Ocupa espacio disponible pero resperta tamaño mínimo
Row(
  children: [
    Flexible(
      child: Container(
        width: 100,
        color: Colors.red,
        child: Text('Flexible'),
      ),
    ),
    Container(width: 100, color: Colors.blue),
  ],
)

// Diferencia Expanded vs Flexible:
Row(
  children: [
    // Expanded: Siempre expande al máximo
    Expanded(
      child: Container(
        width: 50,  // Ignorado, se expande
        color: Colors.red,
        child: Text('Expanded'),
      ),
    ),
    // Flexible: Usa 50 si hay espacio, sino se adapta
    Flexible(
      child: Container(
        width: 50,  // Respetado si hay espacio
        color: Colors.green,
        child: Text('Flexible'),
      ),
    ),
  ],
)
```

### Ejemplos Prácticos de Filas y Columnas

#### Lista de Elementos

```dart
Column(
  children: [
    // Item 1
    Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage('avatar1.jpg'),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Juan García', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Desarrollador Flutter'),
              ],
            ),
          ),
          Icon(Icons.chevron_right),
        ],
      ),
    ),
    // Más items...
  ],
)
```

#### Barra de Navegación

```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 16),
  height: 56,
  decoration: BoxDecoration(
    color: Colors.blue,
    boxShadow: [
      BoxShadow(color: Colors.black26, blurRadius: 8),
    ],
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Icon(Icons.menu, color: Colors.white),
          SizedBox(width: 16),
          Text('Mi App', style: TextStyle(color: Colors.white, fontSize: 20)),
        ],
      ),
      Row(
        children: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    ],
  ),
)
```

#### Tarjeta de Producto

```dart
Card(
  elevation: 4,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Imagen
      AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          child: Image.network(
            'product.jpg',
            fit: BoxFit.cover,
          ),
        ),
      ),
      // Contenido
      Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Producto Premium',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(Icons.favorite_border),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Descripción corta del producto',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$99.99',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Comprar'),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  ),
)
```

#### Grid de Iconos

```dart
Column(
  children: [
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildIconButton(Icons.home, 'Inicio'),
        _buildIconButton(Icons.search, 'Buscar'),
        _buildIconButton(Icons.favorite, 'Favoritos'),
      ],
    ),
    SizedBox(height: 16),
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildIconButton(Icons.person, 'Perfil'),
        _buildIconButton(Icons.settings, 'Ajustes'),
        _buildIconButton(Icons.exit, 'Salir'),
      ],
    ),
  ],
)

Widget _buildIconButton(IconData icon, String label) {
  return Column(
    children: [
      Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.blue),
      ),
      SizedBox(height: 8),
      Text(label, style: TextStyle(fontSize: 12)),
    ],
  );
}
```

### Anidamiento de Filas y Columnas

```dart
// Layout complejo con múltiples niveles
Container(
  padding: EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Header
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Título Principal', style: TextStyle(fontSize: 24)),
              Text('Subtítulo', style: TextStyle(color: Colors.grey)),
            ],
          ),
          CircleAvatar(
            backgroundImage: NetworkImage('avatar.jpg'),
          ),
        ],
      ),
      SizedBox(height: 16),
      
      // Stats
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('150', 'Posts'),
          _buildStat('1.2K', 'Seguidores'),
          _buildStat('89', 'Siguiendo'),
        ],
      ),
      SizedBox(height: 16),
      
      // Content grid
      Row(
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.image, size: 40),
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.video_library, size: 40),
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.article, size: 40),
              ),
            ),
          ),
        ],
      ),
    ],
  ),
)

Widget _buildStat(String value, String label) {
  return Column(
    children: [
      Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      Text(label, style: TextStyle(color: Colors.grey)),
    ],
  );
}
```

---

## Contenedores y Decoración

### BoxDecoration

Permite decorar containers con bordes, sombras, gradientes y más:

```dart
Container(
  decoration: BoxDecoration(
    // Color de fondo
    color: Colors.blue,
    
    // Borde
    border: Border.all(
      color: Colors.blue.shade700,
      width: 2,
    ),
    
    // Bordes redondeados
    borderRadius: BorderRadius.circular(12),
    
    // Gradiente (alternativa a color)
    gradient: LinearGradient(
      colors: [Colors.blue, Colors.purple],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    
    // Sombra
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 10,
        spreadRadius: 2,
        offset: Offset(0, 4),
      ),
    ],
    
    // Imagen de fondo
    image: DecorationImage(
      image: NetworkImage('background.jpg'),
      fit: BoxFit.cover,
    ),
    
    // Forma
    shape: BoxShape.rectangle,  // rectangle o circle
  ),
)
```

### Tipos de Gradientes

```dart
// LinearGradient - Gradiente lineal
Container(
  width: 200,
  height: 100,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.red, Colors.yellow],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      stops: [0.0, 1.0],  // Opcional: puntos de parada
    ),
  ),
)

// RadialGradient - Gradiente radial
Container(
  width: 200,
  height: 200,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    gradient: RadialGradient(
      colors: [Colors.yellow, Colors.orange, Colors.red],
      center: Alignment.center,
      radius: 0.8,  // 0 a 1
    ),
  ),
)

// SweepGradient - Gradiente de barrido
Container(
  width: 200,
  height: 200,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    gradient: SweepGradient(
      colors: [Colors.red, Colors.yellow, Colors.green, Colors.blue, Colors.red],
      center: Alignment.center,
    ),
  ),
)

// Gradiente con múltiples paradas
Container(
  width: 200,
  height: 100,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.purple, Colors.blue, Colors.cyan, Colors.green],
      stops: [0.0, 0.3, 0.7, 1.0],
    ),
  ),
)
```

### Bordes Personalizados

```dart
// Borde con diferentes lados
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    border: Border(
      top: BorderSide(color: Colors.red, width: 4),
      left: BorderSide(color: Colors.green, width: 2),
      right: BorderSide(color: Colors.blue, width: 2),
      bottom: BorderSide(color: Colors.yellow, width: 4),
    ),
  ),
  child: Text('Bordes personalizados por lado'),
)

// Borde con gradiente
Container(
  padding: EdgeInsets.all(2),  // Grosor del borde
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.red, Colors.purple, Colors.blue],
    ),
    borderRadius: BorderRadius.circular(16),
  ),
  child: Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text('Borde con gradiente'),
  ),
)

// Borde discontinuo (dash)
// Requiere paquete: dashed_border o implementación custom
CustomPaint(
  size: Size(200, 100),
  painter: DashedBorderPainter(
    color: Colors.blue,
    strokeWidth: 2,
    dashWidth: 5,
    dashGap: 3,
  ),
)
```

### Sombras y Elevación

```dart
// Sombra simple
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: Text('Sombra simple'),
)

// Múltiples sombras
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.red.withOpacity(0.3),
        blurRadius: 10,
        offset: Offset(-5, -5),
      ),
      BoxShadow(
        color: Colors.blue.withOpacity(0.3),
        blurRadius: 10,
        offset: Offset(5, 5),
      ),
    ],
  ),
  child: Text('Sombras múltiples'),
)

// Sombra interior
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.grey[100],
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 8,
        spreadRadius: -4,  // Negativo para sombra interior
        offset: Offset(0, 0),
      ),
    ],
  ),
  child: Text('Sombra interior'),
)
```

### Formas y Recorte

```dart
// ClipRRect - Recorte rectangular con bordes redondeados
ClipRRect(
  borderRadius: BorderRadius.circular(16),
  child: Image.network('image.jpg'),
)

// ClipOval - Recorte ovalado/circular
ClipOval(
  child: Image.network(
    'avatar.jpg',
    width: 100,
    height: 100,
    fit: BoxFit.cover,
  ),
)

// ClipRect - Recorte rectangular
ClipRect(
  child: Container(
    width: 200,
    height: 100,
    color: Colors.blue,
    child: Text('Recorte rectangular'),
  ),
)

// ClipPath - Recorte personalizado
ClipPath(
  clipper: TriangleClipper(),
  child: Container(
    width: 200,
    height: 100,
    color: Colors.red,
  ),
)

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(TriangleClipper oldClipper) => false;
}

// PhysicalModel - Sombra con recorte
PhysicalModel(
  elevation: 8,
  color: Colors.white,
  shadowColor: Colors.black26,
  borderRadius: BorderRadius.circular(12),
  child: Container(
    padding: EdgeInsets.all(16),
    child: Text('Con elevación y sombra'),
  ),
)
```

---

## Material Design en Flutter

### Principios de Material Design

Material Design es un sistema de diseño creado por Google que se basa en:

1. **Material**: Superficies con elevación y sombras
2. **Movimiento**: Animaciones significativas
3. **Tipografía**: Escalas y estilos consistentes
4. **Color**: Paletas coherentes y accesibles
5. **Iconografía**: Iconos claros y consistentes

### ThemeData y Personalización

```dart
MaterialApp(
  theme: ThemeData(
    // Brillo general
    brightness: Brightness.light,  // o Brightness.dark
    
    // Colores principales
    primaryColor: Colors.blue,
    primaryColorLight: Colors.blue.shade200,
    primaryColorDark: Colors.blue.shade700,
    
    // Color de acento
    accentColor: Colors.orange,  // Deprecated, usar colorScheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    
    // Fondo
    backgroundColor: Colors.grey[100],
    scaffoldBackgroundColor: Colors.white,
    
    // Tipografía
    fontFamily: 'Roboto',
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16),
      bodyMedium: TextStyle(fontSize: 14),
      bodySmall: TextStyle(fontSize: 12),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
    ),
    
    // AppBar
    appBarTheme: AppBarTheme(
      color: Colors.blue,
      elevation: 4,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // Botones
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(88, 36),
        padding: EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    
    // Inputs
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: Colors.grey[100],
    ),
    
    // Tarjetas
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  home: HomeScreen(),
)
```

### Esquemas de Color

```dart
// ColorScheme.fromSeed - Genera paleta completa desde un color
ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.light,
  ),
)

// ColorScheme.fromSeed con personalización
ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.purple,
    brightness: Brightness.dark,
    primary: Color(0xFF6750A4),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFFCCC2DC),
    onSecondary: Color(0xFF332D41),
    surface: Color(0xFF1C1B1F),
    onSurface: Color(0xFFE6E1E5),
  ),
)

// ColorScheme personalizado completo
ThemeData(
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: Colors.blue,
    onPrimary: Colors.white,
    primaryContainer: Colors.blue.shade100,
    onPrimaryContainer: Colors.blue.shade900,
    secondary: Colors.orange,
    onSecondary: Colors.white,
    secondaryContainer: Colors.orange.shade100,
    onSecondaryContainer: Colors.orange.shade900,
    tertiary: Colors.green,
    onTertiary: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    errorContainer: Colors.red.shade100,
    onErrorContainer: Colors.red.shade900,
    background: Colors.white,
    onBackground: Colors.black,
    surface: Colors.white,
    onSurface: Colors.black,
    surfaceVariant: Colors.grey.shade100,
    onSurfaceVariant: Colors.grey.shade700,
    outline: Colors.grey.shade500,
    outlineVariant: Colors.grey.shade300,
    shadow: Colors.black,
    inverseSurface: Colors.grey.shade900,
    onInverseSurface: Colors.grey.shade100,
    inversePrimary: Colors.blue.shade200,
  ),
)

// Tema oscuro
MaterialApp(
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
  ),
  darkTheme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
  ),
  themeMode: ThemeMode.system,  // system, light, o dark
)
```

---

## El Widget Scaffold

### Estructura del Scaffold

El Scaffold proporciona la estructura básica de una pantalla Material Design:

```dart
Scaffold({
  Key? key,
  PreferredSizeWidget? appBar,          // Barra superior
  Widget? body,                          // Contenido principal
  Widget? floatingActionButton,          // Botón flotante
  FloatingActionButtonLocation? floatingActionButtonLocation,
  FloatingActionButtonAnimator? floatingActionButtonAnimator,
  List<Widget>? persistentFooterButtons, // Botones persistentes
  Widget? drawer,                        // Menú lateral izquierdo
  Widget? endDrawer,                     // Menú lateral derecho
  Widget? bottomNavigationBar,           // Navegación inferior
  Widget? bottomSheet,                   // Sheet inferior
  Color? backgroundColor,                // Color de fondo
  bool? resizeToAvoidBottomInset,        // Evitar teclado
  bool primary = true,
  bool extendBody = false,               // Extender bajo FAB/bottom nav
  bool extendBodyBehindAppBar = false,   // Extender detrás del appbar
  bool drawerEnableDragGesture = true,
  bool endDrawerEnableDragGesture = true,
  double? drawerEdgeDragWidth,
  bool drawerScrimColor,
})
```

### AppBar - Barra de Aplicación

```dart
Scaffold(
  appBar: AppBar(
    // Título
    title: Text('Mi Aplicación'),
    centerTitle: true,  // Centrar título
    
    // Color y elevación
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    elevation: 4,
    
    // Acciones
    actions: [
      IconButton(
        icon: Icon(Icons.search),
        onPressed: () {
          // Acción de búsqueda
        },
        tooltip: 'Buscar',
      ),
      IconButton(
        icon: Icon(Icons.notifications),
        onPressed: () {},
      ),
      PopupMenuButton<String>(
        itemBuilder: (context) => [
          PopupMenuItem(value: 'settings', child: Text('Ajustes')),
          PopupMenuItem(value: 'logout', child: Text('Cerrar sesión')),
        ],
        onSelected: (value) {
          // Manejar selección
        },
      ),
    ],
    
    // Botón de retroceso
    leading: IconButton(
      icon: Icon(Icons.menu),
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
    ),
    
    // Flexible space (para personalizar)
    flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.purple],
        ),
      ),
    ),
    
    // Bottom (para tabs)
    bottom: TabBar(
      tabs: [
        Tab(icon: Icon(Icons.home), text: 'Inicio'),
        Tab(icon: Icon(Icons.person), text: 'Perfil'),
        Tab(icon: Icon(Icons.settings), text: 'Ajustes'),
      ],
    ),
  ),
  body: TabBarView(
    children: [
      HomeTab(),
      ProfileTab(),
      SettingsTab(),
    ],
  ),
)
```

### Drawer - Menú Lateral

```dart
Scaffold(
  drawer: Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        // Header del drawer
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage('avatar.jpg'),
              ),
              SizedBox(height: 8),
              Text(
                'Usuario',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              Text(
                'usuario@email.com',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        // Opciones del menú
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Inicio'),
          onTap: () {
            Navigator.pop(context);
            // Navegar a inicio
          },
        ),
        ListTile(
          leading: Icon(Icons.person),
          title: Text('Perfil'),
          onTap: () {
            Navigator.pop(context);
            // Navegar a perfil
          },
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Ajustes'),
          onTap: () {
            Navigator.pop(context);
            // Navegar a ajustes
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.logout),
          title: Text('Cerrar sesión'),
          onTap: () {
            Navigator.pop(context);
            // Cerrar sesión
          },
        ),
      ],
    ),
  ),
  body: Center(child: Text('Contenido principal')),
)
```

### FloatingActionButton - Botón Flotante

```dart
Scaffold(
  floatingActionButton: FloatingActionButton(
    onPressed: () {
      // Acción
    },
    child: Icon(Icons.add),
    tooltip: 'Agregar',
    elevation: 8,
    highlightElevation: 12,
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
  body: Center(child: Text('Contenido')),
)

// FloatingActionButton.extended - Con texto
FloatingActionButton.extended(
  onPressed: () {},
  icon: Icon(Icons.add),
  label: Text('Agregar'),
  backgroundColor: Colors.blue,
)

// FloatingActionButton.mini - Tamaño pequeño
FloatingActionButton.small(
  onPressed: () {},
  child: Icon(Icons.add),
)

// FloatingActionButton con animación
AnimatedFloatingActionButton(
  onPressed: () {},
  child: Icon(Icons.add),
  animate: _isAnimating,
)

// Múltiples FAB con SpeedDial (paquete: flutter_speed_dial)
// O implementación custom:
SpeedDial(
  animatedIcon: AnimatedIcons.menu_close,
  children: [
    SpeedDialChild(
      child: Icon(Icons.share),
      label: 'Compartir',
      onTap: () {},
    ),
    SpeedDialChild(
      child: Icon(Icons.mail),
      label: 'Email',
      onTap: () {},
    ),
  ],
)
```

### BottomNavigationBar - Navegación Inferior

```dart
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    HomeScreen(),
    SearchScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,  // fixed o shifting
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
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
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
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

// BottomNavigationBar con badges
BottomNavigationBarItem(
  icon: Badge(
    label: Text('3'),
    child: Icon(Icons.notifications),
  ),
  label: 'Notificaciones',
)
```

### BottomAppBar con FAB

```dart
Scaffold(
  floatingActionButton: FloatingActionButton(
    onPressed: () {},
    child: Icon(Icons.add),
  ),
  floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
  bottomNavigationBar: BottomAppBar(
    shape: CircularNotchedRectangle(),
    notchMargin: 8,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: Icon(Icons.home),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {},
        ),
        SizedBox(width: 48),  // Espacio para el FAB
        IconButton(
          icon: Icon(Icons.favorite),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.person),
          onPressed: () {},
        ),
      ],
    ),
  ),
  body: Center(child: Text('Contenido')),
)
```

---

## Componentes Material Esenciales

### Botones

```dart
// ElevatedButton - Botón con elevación
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    elevation: 4,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  child: Text('Elevated Button'),
)

// OutlinedButton - Botón con borde
OutlinedButton(
  onPressed: () {},
  style: OutlinedButton.styleFrom(
    foregroundColor: Colors.blue,
    side: BorderSide(color: Colors.blue, width: 2),
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  child: Text('Outlined Button'),
)

// TextButton - Botón plano
TextButton(
  onPressed: () {},
  style: TextButton.styleFrom(
    foregroundColor: Colors.blue,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  ),
  child: Text('Text Button'),
)

// IconButton - Botón de icono
IconButton(
  onPressed: () {},
  icon: Icon(Icons.favorite),
  color: Colors.red,
  iconSize: 32,
  tooltip: 'Añadir a favoritos',
)

// FloatingActionButton - Botón flotante
FloatingActionButton(
  onPressed: () {},
  child: Icon(Icons.add),
  backgroundColor: Colors.blue,
)

// ButtonBar - Barra de botones
ButtonBar(
  alignment: MainAxisAlignment.spaceAround,
  children: [
    TextButton(child: Text('Cancelar')),
    ElevatedButton(child: Text('Aceptar')),
  ],
)

// ToggleButtons - Botones de conmutación
ToggleButtons(
  isSelected: [_isSelected1, _isSelected2, _isSelected3],
  onPressed: (index) {
    setState(() {
      if (index == 0) _isSelected1 = !_isSelected1;
      if (index == 1) _isSelected2 = !_isSelected2;
      if (index == 2) _isSelected3 = !_isSelected3;
    });
  },
  children: [
    Icon(Icons.format_bold),
    Icon(Icons.format_italic),
    Icon(Icons.format_underlined),
  ],
)
```

### Inputs y Formularios

```dart
// TextField - Campo de texto básico
TextField(
  decoration: InputDecoration(
    labelText: 'Nombre',
    hintText: 'Introduce tu nombre',
    prefixIcon: Icon(Icons.person),
    suffixIcon: Icon(Icons.clear),
    border: OutlineInputBorder(),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
    ),
  ),
  onChanged: (value) {
    // Manejar cambio
  },
  onSubmitted: (value) {
    // Manejar envío
  },
)

// TextFormField - Campo con validación
TextFormField(
  decoration: InputDecoration(
    labelText: 'Email',
    prefixIcon: Icon(Icons.email),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Por favor introduce tu email';
    }
    if (!value.contains('@')) {
      return 'Email no válido';
    }
    return null;
  },
  onSaved: (value) {
    // Guardar valor
  },
)

// DropdownButtonFormField - Selector
DropdownButtonFormField<String>(
  decoration: InputDecoration(
    labelText: 'País',
    border: OutlineInputBorder(),
  ),
  value: _selectedCountry,
  items: [
    DropdownMenuItem(value: 'es', child: Text('España')),
    DropdownMenuItem(value: 'mx', child: Text('México')),
    DropdownMenuItem(value: 'ar', child: Text('Argentina')),
  ],
  onChanged: (value) {
    setState(() {
      _selectedCountry = value;
    });
  },
)

// Checkbox - Casilla de verificación
Checkbox(
  value: _isChecked,
  onChanged: (value) {
    setState(() {
      _isChecked = value!;
    });
  },
)

// Checkbox con texto
CheckboxListTile(
  title: Text('Acepto los términos'),
  subtitle: Text('Lee nuestros términos y condiciones'),
  value: _isChecked,
  onChanged: (value) {
    setState(() {
      _isChecked = value!;
    });
  },
)

// Radio - Botón de radio
Radio<String>(
  value: 'option1',
  groupValue: _selectedOption,
  onChanged: (value) {
    setState(() {
      _selectedOption = value;
    });
  },
)

// Radio con texto
RadioListTile<String>(
  title: Text('Opción 1'),
  subtitle: Text('Descripción de la opción 1'),
  value: 'option1',
  groupValue: _selectedOption,
  onChanged: (value) {
    setState(() {
      _selectedOption = value;
    });
  },
)

// Switch - Interruptor
Switch(
  value: _isSwitched,
  onChanged: (value) {
    setState(() {
      _isSwitched = value;
    });
  },
)

// Switch con texto
SwitchListTile(
  title: Text('Notificaciones'),
  subtitle: Text('Recibir notificaciones push'),
  value: _isSwitched,
  onChanged: (value) {
    setState(() {
      _isSwitched = value;
    });
  },
)

// Slider - Deslizador
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
)

// RangeSlider - Deslizador de rango
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
)
```

### Tarjetas y Diálogos

```dart
// Card - Tarjeta básica
Card(
  elevation: 4,
  margin: EdgeInsets.all(8),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Título', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Contenido de la tarjeta'),
      ],
    ),
  ),
)

// Card con imagen
Card(
  clipBehavior: Clip.antiAlias,
  child: Column(
    children: [
      Image.network('image.jpg'),
      Padding(
        padding: EdgeInsets.all(16),
        child: Text('Descripción de la imagen'),
      ),
    ],
  ),
)

// AlertDialog - Diálogo de alerta
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Confirmar acción'),
    content: Text('¿Estás seguro de que quieres continuar?'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('Cancelar'),
      ),
      ElevatedButton(
        onPressed: () {
          // Acción
          Navigator.pop(context);
        },
        child: Text('Aceptar'),
      ),
    ],
  ),
)

// SimpleDialog - Diálogo simple
showDialog(
  context: context,
  builder: (context) => SimpleDialog(
    title: Text('Selecciona una opción'),
    children: [
      SimpleDialogOption(
        onPressed: () => Navigator.pop(context, 'option1'),
        child: Text('Opción 1'),
      ),
      SimpleDialogOption(
        onPressed: () => Navigator.pop(context, 'option2'),
        child: Text('Opción 2'),
      ),
    ],
  ),
)

// BottomSheet - Hoja inferior
showModalBottomSheet(
  context: context,
  builder: (context) => Container(
    padding: EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Acciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ListTile(
          leading: Icon(Icons.share),
          title: Text('Compartir'),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.delete),
          title: Text('Eliminar'),
          onTap: () {},
        ),
      ],
    ),
  ),
)

// SnackBar - Mensaje temporal
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Mensaje guardado'),
    action: SnackBarAction(
      label: 'Deshacer',
      onPressed: () {
        // Acción
      },
    ),
    duration: Duration(seconds: 3),
    behavior: SnackBarBehavior.floating,
  ),
)
```

### Listas y Dividers

```dart
// ListTile - Elemento de lista
ListTile(
  leading: CircleAvatar(
    child: Icon(Icons.person),
  ),
  title: Text('Título del elemento'),
  subtitle: Text('Descripción secundaria'),
  trailing: Icon(Icons.chevron_right),
  onTap: () {
    // Acción al tocar
  },
  onLongPress: () {
    // Acción al mantener presionado
  },
)

// ListTile con checkbox
CheckboxListTile(
  title: Text('Elemento seleccionable'),
  subtitle: Text('Subtítulo'),
  secondary: Icon(Icons.star),
  value: _isChecked,
  onChanged: (value) {
    setState(() {
      _isChecked = value!;
    });
  },
)

// ListTile con switch
SwitchListTile(
  title: Text('Activar función'),
  subtitle: Text('Descripción de la función'),
  secondary: Icon(Icons.settings),
  value: _isSwitched,
  onChanged: (value) {
    setState(() {
      _isSwitched = value;
    });
  },
)

// ExpansionTile - Elemento expandible
ExpansionTile(
  leading: Icon(Icons.info),
  title: Text('Más información'),
  subtitle: Text('Toca para expandir'),
  children: [
    ListTile(title: Text('Detalle 1')),
    ListTile(title: Text('Detalle 2')),
    ListTile(title: Text('Detalle 3')),
  ],
)

// Divider - Separador
Column(
  children: [
    Text('Elemento 1'),
    Divider(
      color: Colors.grey,
      height: 20,
      thickness: 1,
      indent: 20,
      endIndent: 20,
    ),
    Text('Elemento 2'),
  ],
)

// VerticalDivider - Separador vertical
Row(
  children: [
    Text('Izquierda'),
    VerticalDivider(
      color: Colors.grey,
      width: 20,
      thickness: 1,
    ),
    Text('Derecha'),
  ],
)
```

### Chips y Etiquetas

```dart
// Chip - Etiqueta básica
Chip(
  label: Text('Etiqueta'),
  avatar: CircleAvatar(child: Text('E')),
  onDeleted: () {
    // Eliminar chip
  },
)

// InputChip - Chip seleccionable
InputChip(
  label: Text('Seleccionar'),
  avatar: Icon(Icons.person),
  selected: _isSelected,
  onSelected: (selected) {
    setState(() {
      _isSelected = selected;
    });
  },
)

// ChoiceChip - Chip de elección
ChoiceChip(
  label: Text('Opción'),
  selected: _isSelected,
  onSelected: (selected) {
    setState(() {
      _isSelected = selected;
    });
  },
)

// FilterChip - Chip de filtro
FilterChip(
  label: Text('Filtro'),
  selected: _isSelected,
  onSelected: (selected) {
    setState(() {
      _isSelected = selected;
    });
  },
)

// ActionChip - Chip de acción
ActionChip(
  label: Text('Acción'),
  avatar: Icon(Icons.add),
  onPressed: () {
    // Acción
  },
)

// Chip con多条选择
Wrap(
  spacing: 8,
  children: [
    Chip(label: Text('Tag 1')),
    Chip(label: Text('Tag 2')),
    Chip(label: Text('Tag 3')),
    Chip(label: Text('Tag 4')),
  ],
)
```

---

## Widgets de Desplazamiento

### SingleChildScrollView

```dart
// Scroll vertical simple
SingleChildScrollView(
  child: Column(
    children: List.generate(50, (index) {
      return ListTile(title: Text('Elemento $index'));
    }),
  ),
)

// Scroll horizontal
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: List.generate(20, (index) {
      return Container(
        width: 150,
        margin: EdgeInsets.all(8),
        color: Colors.primaries[index % Colors.primaries.length],
        child: Center(child: Text('Item $index')),
      );
    }),
  ),
)

// Scroll con padding y física personalizada
SingleChildScrollView(
  padding: EdgeInsets.all(16),
  physics: BouncingScrollPhysics(),  // iOS-like
  child: Column(
    children: [
      // Contenido largo
    ],
  ),
)

// Controlador de scroll
final ScrollController _controller = ScrollController();

SingleChildScrollView(
  controller: _controller,
  child: Column(
    children: [
      // Contenido
    ],
  ),
)

// Scroll programático
_controller.animateTo(
  0,
  duration: Duration(milliseconds: 500),
  curve: Curves.easeInOut,
)
```

### ListView

```dart
// ListView básico
ListView(
  children: [
    ListTile(title: Text('Elemento 1')),
    ListTile(title: Text('Elemento 2')),
    ListTile(title: Text('Elemento 3')),
  ],
)

// ListView.builder - Construcción bajo demanda
ListView.builder(
  itemCount: 100,
  itemBuilder: (context, index) {
    return ListTile(
      leading: CircleAvatar(child: Text('$index')),
      title: Text('Elemento $index'),
      subtitle: Text('Descripción del elemento'),
    );
  },
)

// ListView.builder con separadores
ListView.separated(
  itemCount: 20,
  separatorBuilder: (context, index) => Divider(),
  itemBuilder: (context, index) {
    return ListTile(
      title: Text('Elemento $index'),
    );
  },
)

// ListView con tipos mixtos
ListView(
  children: [
    // Header
    Container(
      padding: EdgeInsets.all(16),
      child: Text('Header', style: TextStyle(fontSize: 24)),
    ),
    Divider(),
    // Items
    ...List.generate(10, (index) {
      return ListTile(
        title: Text('Elemento $index'),
      );
    }),
    Divider(),
    // Footer
    Container(
      padding: EdgeInsets.all(16),
      child: Text('Footer'),
    ),
  ],
)

// ListView con sticky headers (paquete: sticky_headers)
ListView.builder(
  itemCount: _sections.length,
  itemBuilder: (context, index) {
    return StickyHeader(
      header: Container(
        color: Colors.blue,
        child: Text('Sección $index'),
      ),
      content: Column(
        children: _sections[index].items,
      ),
    );
  },
)
```

### GridView

```dart
// GridView.count - Grid con número fijo de columnas
GridView.count(
  crossAxisCount: 2,  // Número de columnas
  mainAxisSpacing: 10,  // Espacio vertical
  crossAxisSpacing: 10, // Espacio horizontal
  childAspectRatio: 1,  // Proporción ancho/alto
  children: List.generate(20, (index) {
    return Container(
      color: Colors.primaries[index % Colors.primaries.length],
      child: Center(child: Text('Item $index')),
    );
  }),
)

// GridView.extent - Grid con ancho máximo
GridView.extent(
  maxCrossAxisExtent: 200,  // Ancho máximo de cada item
  mainAxisSpacing: 10,
  crossAxisSpacing: 10,
  childAspectRatio: 1,
  children: List.generate(20, (index) {
    return Container(
      color: Colors.primaries[index % Colors.primaries.length],
      child: Center(child: Text('Item $index')),
    );
  }),
)

// GridView.builder - Construcción bajo demanda
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
    childAspectRatio: 0.75,  // Proporción más alta que ancha
  ),
  itemCount: 20,
  itemBuilder: (context, index) {
    return Card(
      child: Column(
        children: [
          Expanded(
            child: Image.network('image_$index.jpg', fit: BoxFit.cover),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Text('Producto $index'),
          ),
        ],
      ),
    );
  },
)

// GridView con layout personalizado
GridView.custom(
  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 200,
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
  ),
  childrenDelegate: SliverChildBuilderDelegate(
    (context, index) {
      return Container(
        color: Colors.primaries[index % Colors.primaries.length],
        child: Center(child: Text('Item $index')),
      );
    },
    childCount: 20,
  ),
)
```

### CustomScrollView y Slivers

```dart
// CustomScrollView con múltiples slivers
CustomScrollView(
  slivers: [
    // AppBar que se colapsa
    SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text('Título'),
        background: Image.network('header.jpg', fit: BoxFit.cover),
      ),
    ),
    
    // Lista de items
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return ListTile(title: Text('Item $index'));
        },
        childCount: 50,
      ),
    ),
    
    // Grid
    SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Container(
            color: Colors.primaries[index % Colors.primaries.length],
          );
        },
        childCount: 20,
      ),
    ),
    
    // Padding
    SliverPadding(
      padding: EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Text('Con padding'),
        ]),
      ),
    ),
    
    // Persistent header
    SliverPersistentHeader(
      delegate: _SliverAppBarDelegate(
        TabBar(
          tabs: [
            Tab(text: 'Tab 1'),
            Tab(text: 'Tab 2'),
          ],
        ),
      ),
      pinned: true,
    ),
  ],
)
```

---

## Layouts Responsivos

### LayoutBuilder

```dart
// Adaptar layout según tamaño de pantalla
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      // Tablet o desktop
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: MenuWidget(),
          ),
          Expanded(
            flex: 3,
            child: ContentWidget(),
          ),
        ],
      );
    } else {
      // Móvil
      return Column(
        children: [
          MenuWidget(),
          Expanded(child: ContentWidget()),
        ],
      );
    }
  },
)
```

### MediaQuery

```dart
// Obtener información del dispositivo
Widget build(BuildContext context) {
  final mediaQuery = MediaQuery.of(context);
  final size = mediaQuery.size;
  final orientation = mediaQuery.orientation;
  final padding = mediaQuery.padding;
  
  return Container(
    width: size.width,
    height: size.height - padding.top - padding.bottom,
    child: Text(
      orientation == Orientation.portrait
        ? 'Vertical'
        : 'Horizontal',
    ),
  );
}

// Usar MediaQuery para responsive
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  
  int crossAxisCount;
  if (screenWidth < 400) {
    crossAxisCount = 1;
  } else if (screenWidth < 600) {
    crossAxisCount = 2;
  } else if (screenWidth < 900) {
    crossAxisCount = 3;
  } else {
    crossAxisCount = 4;
  }
  
  return GridView.count(
    crossAxisCount: crossAxisCount,
    children: _buildGridItems(),
  );
}
```

### Breakpoints

```dart
// Definir breakpoints
enum DeviceType { mobile, tablet, desktop }

DeviceType getDeviceType(double width) {
  if (width < 600) return DeviceType.mobile;
  if (width < 900) return DeviceType.tablet;
  return DeviceType.desktop;
}

// Widget responsivo
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  const ResponsiveLayout({
    required this.mobile,
    this.tablet,
    this.desktop,
  });
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = getDeviceType(constraints.maxWidth);
        
        switch (deviceType) {
          case DeviceType.desktop:
            return desktop ?? tablet ?? mobile;
          case DeviceType.tablet:
            return tablet ?? mobile;
          case DeviceType.mobile:
          default:
            return mobile;
        }
      },
    );
  }
}

// Uso
ResponsiveLayout(
  mobile: MobileLayout(),
  tablet: TabletLayout(),
  desktop: DesktopLayout(),
)
```

### OrientationBuilder

```dart
// Adaptar a orientación
OrientationBuilder(
  builder: (context, orientation) {
    return GridView.count(
      crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
      children: _buildGridItems(),
    );
  },
)
```

---

## Buenas Prácticas de Maquetación

### 1. Evitar el "Widget Nesting"

```dart
// ❌ Malo - Demasiado anidamiento
Container(
  child: Padding(
    padding: EdgeInsets.all(8),
    child: Center(
      child: Container(
        child: Column(
          children: [
            Container(
              child: Text('Texto'),
            ),
          ],
        ),
      ),
    ),
  ),
)

// ✅ Bueno - Simplificado
Padding(
  padding: EdgeInsets.all(8),
  child: Center(
    child: Column(
      children: [
        Text('Texto'),
      ],
    ),
  ),
)
```

### 2. Usar const Widgets

```dart
// ❌ Malo - Se recrea en cada build
Widget build(BuildContext context) {
  return Container(
    padding: EdgeInsets.all(8),
    child: Text('Estático'),
  );
}

// ✅ Bueno - Widget constante
Widget build(BuildContext context) {
  return const Padding(
    padding: EdgeInsets.all(8),
    child: Text('Estático'),
  );
}
```

### 3. Separar en Widgets Reutilizables

```dart
// ❌ Malo - Todo en un widget gigante
Widget build(BuildContext context) {
  return Column(
    children: [
      Container(
        // ... 50 líneas de código
      ),
      Container(
        // ... 50 líneas de código
      ),
      Container(
        // ... 50 líneas de código
      ),
    ],
  );
}

// ✅ Bueno - Widgets separados
Widget build(BuildContext context) {
  return Column(
    children: [
      _buildHeader(),
      _buildContent(),
      _buildFooter(),
    ],
  );
}

Widget _buildHeader() {
  return Container(
    // ...
  );
}

Widget _buildContent() {
  return Container(
    // ...
  );
}

Widget _buildFooter() {
  return Container(
    // ...
  );
}
```

### 4. Usar SizedBox para Espaciado

```dart
// ❌ Malo - Container solo para espacio
Column(
  children: [
    Text('Elemento 1'),
    Container(height: 16),
    Text('Elemento 2'),
  ],
)

// ✅ Bueno - SizedBox es más eficiente
Column(
  children: [
    Text('Elemento 1'),
    SizedBox(height: 16),
    Text('Elemento 2'),
  ],
)
```

### 5. Keys para Listas Dinámicas

```dart
// ❌ Malo - Sin keys
ListView(
  children: items.map((item) {
    return ListTile(title: Text(item.name));
  }).toList(),
)

// ✅ Bueno - Con keys
ListView(
  children: items.map((item) {
    return ListTile(
      key: ValueKey(item.id),
      title: Text(item.name),
    );
  }).toList(),
)
```

### 6. Evitar Overflow

```dart
// ❌ Malo - Puede causar overflow
Row(
  children: [
    Text('Texto muy largo que puede causar problemas de overflow en pantallas pequeñas'),
  ],
)

// ✅ Bueno - Flexible o Expanded
Row(
  children: [
    Flexible(
      child: Text(
        'Texto largo que se adapta',
        overflow: TextOverflow.ellipsis,
      ),
    ),
  ],
)

// ✅ También bueno - FittedBox
FittedBox(
  child: Text('Texto que se escala'),
)
```

### 7. Usar Theme Correctamente

```dart
// ❌ Malo - Colores hardcoded
Container(
  color: Colors.blue,
  child: Text('Texto', style: TextStyle(color: Colors.white)),
)

// ✅ Bueno - Usar Theme
Container(
  color: Theme.of(context).primaryColor,
  child: Text(
    'Texto',
    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: Theme.of(context).colorScheme.onPrimary,
    ),
  ),
)
```

### 8. Gestionar Estado en Listas

```dart
// ❌ Malo - ListView dentro de Column sin límites
Column(
  children: [
    Text('Header'),
    ListView(
      children: items,
    ),
  ],
)

// ✅ Bueno - Expanded o Flexible
Column(
  children: [
    Text('Header'),
    Expanded(
      child: ListView(
        children: items,
      ),
    ),
  ],
)

// ✅ También bueno - shrinkWrap
Column(
  children: [
    Text('Header'),
    ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: items,
    ),
  ],
)
```

---

## Ejemplos Prácticos Completos

### Ejemplo 1: Pantalla de Login

```dart
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(height: 24),
                
                // Título
                Text(
                  'Iniciar Sesión',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                
                // Subtítulo
                Text(
                  'Introduce tus credenciales para continuar',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 48),
                
                // Email
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                
                // Contraseña
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: Icon(Icons.visibility),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 8),
                
                // Olvidé contraseña
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text('¿Olvidaste tu contraseña?'),
                  ),
                ),
                SizedBox(height: 24),
                
                // Botón de login
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Iniciar Sesión'),
                ),
                SizedBox(height: 16),
                
                // Separador
                Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('O continúa con'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                SizedBox(height: 16),
                
                // Botones sociales
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSocialButton(Icons.facebook, 'Facebook'),
                    _buildSocialButton(Icons.email, 'Google'),
                    _buildSocialButton(Icons.apple, 'Apple'),
                  ],
                ),
                SizedBox(height: 24),
                
                // Registro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('¿No tienes cuenta?'),
                    TextButton(
                      onPressed: () {},
                      child: Text('Regístrate'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSocialButton(IconData icon, String label) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon),
      ),
    );
  }
}
```

### Ejemplo 2: Pantalla de Perfil

```dart
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar con fondo
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Mi Perfil'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          
          // Contenido
          SliverList(
            delegate: SliverChildListDelegate([
              // Avatar y datos
              Container(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage('avatar.jpg'),
                    ),
                    SizedBox(height: 16),
                    
                    // Nombre
                    Text(
                      'Juan García',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 4),
                    
                    // Email
                    Text(
                      'juan@email.com',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: 24),
                    
                    // Estadísticas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStat('150', 'Posts'),
                        _buildStat('1.2K', 'Seguidores'),
                        _buildStat('89', 'Siguiendo'),
                      ],
                    ),
                  ],
                ),
              ),
              
              Divider(),
              
              // Opciones
              _buildListTile(Icons.person, 'Editar Perfil', () {}),
              _buildListTile(Icons.lock, 'Privacidad', () {}),
              _buildListTile(Icons.notifications, 'Notificaciones', () {}),
              _buildListTile(Icons.language, 'Idioma', () {}),
              _buildListTile(Icons.help, 'Ayuda', () {}),
              _buildListTile(Icons.info, 'Acerca de', () {}),
              
              Divider(),
              
              // Cerrar sesión
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
                onTap: () {},
              ),
            ]),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey)),
      ],
    );
  }
  
  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
```

### Ejemplo 3: Pantalla de Lista con Filtros

```dart
class ProductsScreen extends StatefulWidget {
  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _selectedCategory = 'Todos';
  final List<String> _categories = ['Todos', 'Electrónica', 'Ropa', 'Hogar'];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos'),
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
          IconButton(icon: Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: Theme.of(context).primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Grid de productos
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.75,
              ),
              itemCount: 20,
              itemBuilder: (context, index) {
                return _buildProductCard(index);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildProductCard(int index) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              'https://picsum.photos/200?random=$index',
              fit: BoxFit.cover,
            ),
          ),
          
          // Contenido
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Producto $index',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Descripción breve del producto',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${(index * 10 + 9.99).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Icon(Icons.favorite_border, size: 20),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Errores Comunes y Soluciones

### Error: "RenderFlex overflowed"

**Causa:** Un widget Row o Column intenta ocupar más espacio del disponible.

**Solución:**

```dart
// ❌ Causa overflow
Row(
  children: [
    Text('Texto muy largo que no cabe en la pantalla'),
  ],
)

// ✅ Solución 1: Usar Flexible
Row(
  children: [
    Flexible(
      child: Text(
        'Texto muy largo que no cabe',
        overflow: TextOverflow.ellipsis,
      ),
    ),
  ],
)

// ✅ Solución 2: Usar Expanded
Row(
  children: [
    Expanded(
      child: Text(
        'Texto muy largo',
        overflow: TextOverflow.ellipsis,
      ),
    ),
  ],
)

// ✅ Solución 3: Usar FittedBox
Row(
  children: [
    FittedBox(
      child: Text('Texto que se escala'),
    ),
  ],
)
```

### Error: "Incorrect use of ParentDataWidget"

**Causa:** Usar Expanded o Flexible fuera de Row o Column.

**Solución:**

```dart
// ❌ Incorrecto
Container(
  child: Expanded(
    child: Text('Error'),
  ),
)

// ✅ Correcto
Row(
  children: [
    Expanded(
      child: Text('Correcto'),
    ),
  ],
)
```

### Error: "No Material widget found"

**Causa:** Usar widgets Material (Scaffold, AppBar, etc.) sin un ancestro Material.

**Solución:**

```dart
// ❌ Incorrecto
Scaffold(
  appBar: AppBar(title: Text('Error')),
)

// ✅ Correcto
MaterialApp(
  home: Scaffold(
    appBar: AppBar(title: Text('Correcto')),
  ),
)

// ✅ O usando Material widget
Material(
  child: Scaffold(
    appBar: AppBar(title: Text('Correcto')),
  ),
)
```

### Error: "Vertical viewport was given unbounded height"

**Causa:** ListView dentro de Column sin altura definida.

**Solución:**

```dart
// ❌ Causa error
Column(
  children: [
    Text('Header'),
    ListView(
      children: items,
    ),
  ],
)

// ✅ Solución 1: Expanded
Column(
  children: [
    Text('Header'),
    Expanded(
      child: ListView(
        children: items,
      ),
    ),
  ],
)

// ✅ Solución 2: shrinkWrap
Column(
  children: [
    Text('Header'),
    ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: items,
    ),
  ],
)

// ✅ Solución 3: SizedBox con altura fija
Column(
  children: [
    Text('Header'),
    SizedBox(
      height: 300,
      child: ListView(
        children: items,
      ),
    ),
  ],
)
```

### Error: "setState() called after dispose()"

**Causa:** Llamar setState después de que el widget se ha eliminado.

**Solución:**

```dart
// ❌ Incorrecto
class _MyState extends State<MyWidget> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      setState(() {});  // Error si widget se eliminó
    });
  }
}

// ✅ Correcto
class _MyState extends State<MyWidget> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {  // Verificar si sigue montado
        setState(() {});
      }
    });
  }
}
```

---

## Conclusión

La maquetación en Flutter se basa en la composición de widgets y la comprensión del sistema de restricciones. Los puntos clave son:

1. **Widgets de Layout**: Container, Row, Column, Stack son los fundamentales
2. **Restricciones**: Entender cómo pasan de padre a hijo
3. **Material Design**: Usar componentes Material para interfaces consistentes
4. **Responsive**: Adaptar layouts a diferentes tamaños de pantalla
5. **Buenas prácticas**: Evitar nesting excesivo, usar const, separar widgets

Para continuar tu aprendizaje:

- Practica con diferentes combinaciones de widgets
- Estudia el catálogo de widgets oficial
- Experimenta con layouts responsivos
- Usa Flutter Inspector para entender el árbol de widgets

---

**Versión del documento**: 1.0  
**Flutter versión**: 3.24.0  
**Última actualización**: Julio 2025