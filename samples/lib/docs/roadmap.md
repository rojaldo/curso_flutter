# Flutter Demostrador — Roadmap de Ejemplos

## Índice

- [Filosofía: el concepto de Widget](#filosofía-el-concepto-de-widget)
- [Secciones propuestas (32–71)](#secciones-propuestas-3271)
  - [10. Progreso y feedback visual (32–35)](#10-progreso-y-feedback-visual-3235)
  - [11. Colecciones avanzadas (36–40)](#11-colecciones-avanzadas-3640)
  - [12. Selección y autocompletado (41–44)](#12-selección-y-autocompletado-4144)
  - [13. Layout responsivo y adaptativo (45–48)](#13-layout-responsivo-y-adaptativo-4548)
  - [14. Clipping y transformaciones (49–51)](#14-clipping-y-transformaciones-4951)
  - [15. Texto avanzado (52–53)](#15-texto-avanzado-5253)
  - [16. Navegación Material 3 (54–56)](#16-navegación-material-3-5456)
  - [17. Scroll avanzado (57–59)](#17-scroll-avanzado-5759)
  - [18. Ciclo de vida y Keys (60–62)](#18-ciclo-de-vida-y-keys-6062)
  - [19. API REST (63–71)](#19-api-rest-6371)
  - [20. Google Maps (72–84)](#20-google-maps-7284)

---

## Filosofía: el concepto de Widget

### ¿Qué es un Widget?

En Flutter, **todo es un widget**. Pero esta frase tan repetida esconde una distinción fundamental que los alumnos deben interiorizar desde el primer día:

> Un widget **no es** el elemento visual que ves en pantalla.  
> Un widget **es una descripción inmutable** de una parte de la interfaz.

Cuando escribes `Text('Hola')`, no estás creando un texto en pantalla. Estás creando un **objeto de configuración** que Flutter compara con la descripción anterior para decidir qué cambiar. El texto real en pantalla lo crea el framework a partir de esa descripción.

### La tríada: Widget → Element → RenderObject

Flutter utiliza tres árboles que trabajan en coordinación:

| Capa | Responsabilidad | Mutabilidad |
|------|----------------|-------------|
| **Widget** | Describe *qué* debe aparecer. Es la configuración. | Inmutable — se recrea en cada frame |
| **Element** | Gestiona el ciclo de vida y el árbol. Es el gestor de estado. | Mutable — persiste entre frames |
| **RenderObject** | Calcula *layout*, *paint* y *hit testing*. Dibuja pixels. | Mutable — persiste entre frames |

Flujo:

```
Widget (inmutable)          Element (gestor)           RenderObject (pintor)
    │                            │                            │
    ├── Text('Hola')  ──→  ──→  Element  ──→  ──→  RenderParagraph
    │                            │                            │
    ├── Container()   ──→  ──→  Element  ──→  ──→  RenderDecoratedBox
    │                            │                            │
    └── Column()      ──→  ──→  Element  ──→  ──→  RenderFlex
```

**Implicación clave**: Cuando `setState()` se ejecuta, Flutter crea *nuevos widgets* pero **reutiliza** los Elements y RenderObjects existentes siempre que sea posible. Esta reutilización es lo que hace a Flutter rápido.

### StatelessWidget vs StatefulWidget

| StatelessWidget | StatefulWidget |
|-----------------|---------------|
| `build()` se llama cada vez que el padre se reconstruye | Tiene un objeto `State` separado que persiste |
| No tiene estado mutable propio | `setState()` marca el State como sucio → `build()` se re-ejecuta |
| Ejemplos: `Text`, `Icon`, `Padding` | Ejemplos: `TextField`, `Checkbox`, `AnimationController` |

**Error común**: Creer que `StatelessWidget` significa "no cambia visualmente". Falso. Un `StatelessWidget` puede mostrar datos diferentes cada vez que su padre lo reconstruye con nuevas propiedades. Lo que no tiene es estado *propio* persistente.

### El árbol de Widgets es declarativo

En frameworks imperativos (Android View, iOS UIView):

```kotlin
// Imperativo: modificas la vista existente
textView.setText("Nuevo texto")
textView.setTextColor(Color.RED)
```

En Flutter (declarativo):

```dart
// Declarativo: describes el resultado final
// Flutter se encarga de llegar ahí
Text('Nuevo texto', style: TextStyle(color: Colors.red))
```

No "cambias" un widget. Creas una **nueva descripción** y Flutter la compara con la anterior para actualizar lo mínimo necesario. Esta mentalidad declarativa es el cambio de paradigma más difícil para alumnos que vienen de Android/iOS clásico.

### Las tres familias de widgets

Flutter clasifica sus widgets en tres familias funcionales:

#### 1. Widgets de estructura y navegación
Organizan la jerarquía y el flujo de la app.

| Widget | Rol |
|--------|-----|
| `Scaffold` | Estructura base: AppBar, body, FAB, drawer, bottomNav |
| `AppBar` | Barra superior con título, acciones, navegación |
| `Navigator` | Gestiona la pila de pantallas (push/pop) |
| `Drawer` | Menú lateral |
| `BottomNavigationBar` | Navegación por pestañas inferior |

#### 2. Widgets de layout
Posicionan y dimensionan a sus hijos. **No dibujan nada visible** (excepto decoraciones).

| Widget | Comportamiento |
|--------|---------------|
| `Row` / `Column` | Flex layout horizontal/vertical |
| `Stack` | Capas superpuestas (z-order) |
| `Expanded` / `Flexible` | Ocupa espacio disponible en Flex |
| `Container` | Caja con padding, margin, border, decoración |
| `Padding` | Agrega espacio interno |
| `Center` | Centra al hijo |
| `SizedBox` | Tamaño fijo o restricción |
| `ListView` | Lista scrollable |
| `GridView` | Grilla scrollable |

#### 3. Widgets de contenido
Muestran datos o capturan interacción del usuario.

| Widget | Tipo |
|--------|------|
| `Text` | Mostrar texto |
| `TextField` | Capturar texto |
| `Image` | Mostrar imagen |
| `Icon` | Mostrar icono |
| `ElevatedButton` | Botón elevado |
| `Checkbox` | Casilla de verificación |
| `Switch` | Interruptor on/off |
| `Slider` | Selector de valor continuo |

### El principio de composición

Flutter **no** tiene un widget `SuperButtonWithIconAndBadge`. En su lugar, **compones**:

```dart
ElevatedButton(
  onPressed: () {},
  child: Badge(
    label: Text('3'),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.mail),
        SizedBox(width: 8),
        Text('Mensajes'),
      ],
    ),
  ),
)
```

Cada widget hace **una cosa** y se combina con otros. Esta composición es el patrón más importante que los alumnos deben dominar.

### Composición vs. Herencia

Los widgets usan composición, no herencia. No hay `SuperButton extends Button extends Widget`. En su lugar:

```dart
// Composición: widgets que envuelven a otros widgets
Container(           // decoración
  child: Padding(    // espaciado
    child: Center(   // centrado
      child: Text(   // contenido
        'Hola',
      ),
    ),
  ),
)
```

Cada capa añade una responsabilidad. El árbol resultante es profundo pero cada nodo es simple.

### Performance: rebuilds y const

El rendimiento en Flutter depende de minimizar **rebuilds innecesarios**:

| Técnica | Efecto |
|---------|--------|
| `const` en constructores | Flutter reutiliza la misma instancia si los parámetros no cambian |
| `ValueNotifier` + `ValueListenableBuilder` | Solo reconstruye el subárbol que escucha |
| `RepaintBoundary` | Aísla repintados costosos |
| `Keys` | Ayuda a Flutter a identificar qué widgets mover vs recrear |
| `AutomaticKeepAliveClientMixin` | Evita destruir state al hacer scroll fuera de vista |

**Regla práctica**: Si un widget no cambia, ponle `const`. Si solo una parte cambia, aísla esa parte con `ValueNotifier` o `Provider`.

---

## Secciones propuestas (32–71)

### 10. Progreso y feedback visual (32–35)

Ejemplos que muestran cómo indicar al usuario que algo está cargando o ha sucedido.

#### 32. ProgressIndicator

| Campo | Valor |
|-------|-------|
| **Ruta** | `/progress_indicator` |
| **Clase** | `ProgressIndicatorExample` |
| **Concepto** | Indicadores de progreso determinados e indeterminados |
| **Demo interactiva** | LinearProgressIndicator con slider para valor 0–1; CircularProgressIndicator determinado e indeterminado; RefreshIndicator que simula carga |
| **Código simplificado** | `LinearProgressIndicator(value: 0.7)` y `CircularProgressIndicator()` |
| **Widget clave** | `LinearProgressIndicator`, `CircularProgressIndicator`, `RefreshIndicator` |

#### 33. RefreshIndicator

| Campo | Valor |
|-------|-------|
| **Ruta** | `/refresh_indicator` |
| **Clase** | `RefreshIndicatorExample` |
| **Concepto** | Pull-to-refresh en una lista con simulación de carga |
| **Demo interactiva** | ListView dentro de RefreshIndicator; al tirar hacia abajo, simula una carga de 2 segundos y añade nuevos elementos |
| **Código simplificado** | `RefreshIndicator(onRefresh: _fetchData, child: ListView(...))` |
| **Widget clave** | `RefreshIndicator` |

#### 34. Tooltip & Badge

| Campo | Valor |
|-------|-------|
| **Ruta** | `/tooltip_badge` |
| **Clase** | `TooltipBadgeExample` |
| **Concepto** | Tooltips informativos y badges con contador |
| **Demo interactiva** | Iconos con Tooltip (mantener pulsado muestra texto); Badge con contador que se incrementa con un botón |
| **Código simplificado** | `Tooltip(message: 'Buscar', child: Icon(Icons.search))` y `Badge(label: Text('5'), child: Icon(Icons.mail))` |
| **Widget clave** | `Tooltip`, `Badge` |

#### 35. SnackBar avanzado

| Campo | Valor |
|-------|-------|
| **Ruta** | `/snackbar_advanced` |
| **Clase** | `SnackBarAdvancedExample` |
| **Concepto** | Variantes de SnackBar: duration, action, behavior, tema personalizado |
| **Demo interactiva** | Botones para lanzar: SnackBar simple, con acción de deshacer, fixed vs floating, con duración personalizada |
| **Código simplificado** | `ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('...')))` |
| **Widget clave** | `ScaffoldMessenger`, `SnackBar`, `SnackBarAction` |

---

### 11. Colecciones avanzadas (36–40)

Widgets que organizan conjuntos de datos más allá de ListView y GridView.

#### 36. ExpansionTile

| Campo | Valor |
|-------|-------|
| **Ruta** | `/expansion_tile` |
| **Clase** | `ExpansionTileExample` |
| **Concepto** | Acordeones expandibles con leading, trailing, children |
| **Demo interactiva** | ExpansionTile con lista de secciones (animales, colores, países); cada sección se expande mostrando sus elementos; ExpansionTileList dentro de ListView |
| **Código simplificado** | `ExpansionTile(title: Text('Sección'), children: [ListTile(...), ...])` |
| **Widget clave** | `ExpansionTile`, `ExpansionTileList` |

#### 37. DataTable

| Campo | Valor |
|-------|-------|
| **Ruta** | `/data_table` |
| **Clase** | `DataTableExample` |
| **Concepto** | Tabla con ordenación por columnas y filas seleccionables |
| **Demo interactiva** | DataTable con datos de productos (nombre, precio, stock); sort por columna al tocar header; checkbox para seleccionar filas |
| **Código simplificado** | `DataTable(columns: [DataColumn(label: Text('Nombre'), numeric: false)], rows: [DataRow(cells: [DataCell(Text('...'))])])` |
| **Widget clave** | `DataTable`, `DataColumn`, `DataRow`, `DataCell` |

#### 38. Wrap

| Campo | Valor |
|-------|-------|
| **Ruta** | `/wrap` |
| **Clase** | `WrapExample` |
| **Concepto** | Flow layout: elementos fluyen a la siguiente línea |
| **Demo interactiva** | Wrap con Chips que se reorganizan al rotar/redimensionar; dirección horizontal vs vertical; spacing configurable con slider |
| **Código simplificado** | `Wrap(spacing: 8, runSpacing: 4, children: [Chip(...), ...])` |
| **Widget clave** | `Wrap` |

#### 39. Stepper

| Campo | Valor |
|-------|-------|
| **Ruta** | `/stepper` |
| **Clase** | `StepperExample` |
| **Concepto** | Wizard multi-paso con validación por paso |
| **Demo interactiva** | Stepper con 3 pasos (datos personales → dirección → confirmación); validación en cada paso; botones continuar/volver |
| **Código simplificado** | `Stepper(steps: [Step(title: Text('Paso 1'), content: ..., isActive: true)], onStepContinue: ...)` |
| **Widget clave** | `Stepper`, `Step` |

#### 40. PaginatedDataTable

| Campo | Valor |
|-------|-------|
| **Ruta** | `/paginated_data_table` |
| **Clase** | `PaginatedDataTableExample` |
| **Concepto** | Tabla paginada con datos dinámicos |
| **Demo interactiva** | PaginatedDataTable con 50+ filas de datos; filas por página configurables; sort por columna; header con acción |
| **Código simplificado** | `PaginatedDataTable(header: Text('Datos'), rowsPerPage: 10, columns: [...], source: _dataSource)` |
| **Widget clave** | `PaginatedDataTable`, `DataTableSource` |

---

### 12. Selección y autocompletado (41–44)

Widgets que permiten al usuario elegir entre opciones.

#### 41. DatePicker & TimePicker

| Campo | Valor |
|-------|-------|
| **Ruta** | `/date_time_picker` |
| **Clase** | `DateTimePickerExample` |
| **Concepto** | Selección de fecha y hora con restricciones |
| **Demo interactiva** | Botón para abrir `showDatePicker` (con rango firstDate/lastDate); botón para abrir `showTimePicker`; fecha y hora seleccionadas mostradas |
| **Código simplificado** | `showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030))` |
| **Widget clave** | `showDatePicker`, `showTimePicker` |

#### 42. DropdownButton

| Campo | Valor |
|-------|-------|
| **Ruta** | `/dropdown` |
| **Clase** | `DropdownExample` |
| **Concepto** | Menú desplegable con items, hint, onChanged |
| **Demo interactiva** | DropdownButton para seleccionar país, color, categoría; valor seleccionado mostrado; variantes: estilo outline, icono personalizado |
| **Código simplificado** | `DropdownButton<String>(value: selected, items: [...], onChanged: (val) => setState(...))` |
| **Widget clave** | `DropdownButton`, `DropdownMenuItem` |

#### 43. Autocomplete

| Campo | Valor |
|-------|-------|
| **Ruta** | `/autocomplete` |
| **Clase** | `AutocompleteExample` |
| **Concepto** | Filtrado en tiempo real con Autocomplete<T> |
| **Demo interactiva** | Autocomplete con lista de países; escribe "Es" → sugiere "España"; Autocomplete con tipo personalizado (no solo String) |
| **Código simplificado** | `Autocomplete<String>(optionsBuilder: (textEditingValue) => options.where(...), onSelected: (val) => ...)` |
| **Widget clave** | `Autocomplete` |

#### 44. SearchBar & SearchAnchor

| Campo | Valor |
|-------|-------|
| **Ruta** | `/search_bar` |
| **Clase** | `SearchBarExample` |
| **Concepto** | Barra de búsqueda Material 3 con sugerencias |
| **Demo interactiva** | SearchBar que al pulsar abre SearchView con sugerencias; filtrado en tiempo real de una lista de frutas |
| **Código simplificado** | `SearchBar(onSearch: ..., hintText: 'Buscar',)` con `SearchAnchor(builder: ..., suggestionsBuilder: ...)` |
| **Widget clave** | `SearchBar`, `SearchAnchor`, `SearchView` |

---

### 13. Layout responsivo y adaptativo (45–48)

Técnicas para que la app funcione en móviles, tablets y escritorio.

#### 45. MediaQuery

| Campo | Valor |
|-------|-------|
| **Ruta** | `/media_query` |
| **Clase** | `MediaQueryExample` |
| **Concepto** | Tamaño de pantalla, densidad de píxeles, orientación, padding seguro |
| **Demo interactiva** | Muestra en tiempo real: width, height, devicePixelRatio, orientation, padding (safe area), viewInsets (teclado); actualización al rotar |
| **Código simplificado** | `MediaQuery.of(context).size.width` y `MediaQuery.of(context).orientation` |
| **Widget clave** | `MediaQuery`, `MediaQueryData` |

#### 46. LayoutBuilder

| Campo | Valor |
|-------|-------|
| **Ruta** | `/layout_builder` |
| **Clase** | `LayoutBuilderExample` |
| **Concepto** | Adaptar layout según ancho disponible |
| **Demo interactiva** | LayoutBuilder que muestra 1 columna en móvil (< 600px), 2 en tablet (600–900px), 3 en desktop (> 900px); redimensionar la ventana para ver el cambio |
| **Código simplificado** | `LayoutBuilder(builder: (context, constraints) { if (constraints.maxWidth > 600) ... })` |
| **Widget clave** | `LayoutBuilder`, `BoxConstraints` |

#### 47. OrientationBuilder

| Campo | Valor |
|-------|-------|
| **Ruta** | `/orientation_builder` |
| **Clase** | `OrientationBuilderExample` |
| **Concepto** | Cambiar layout al rotar el dispositivo |
| **Demo interactiva** | OrientationBuilder que muestra grid en portrait vs row en landscape; rotar el dispositivo para ver el cambio |
| **Código simplificado** | `OrientationBuilder(builder: (context, orientation) { if (orientation == Orientation.portrait) ... })` |
| **Widget clave** | `OrientationBuilder` |

#### 48. SafeArea & Constraints

| Campo | Valor |
|-------|-------|
| **Ruta** | `/safe_area_constraints` |
| **Clase** | `SafeAreaConstraintsExample` |
| **Concepto** | SafeArea, ConstrainedBox, SizedBox, AspectRatio, FittedBox |
| **Demo interactiva** | Comparación visual: contenido con y sin SafeArea; ConstrainedBox con min/max; AspectRatio con diferentes ratios; FittedBox con BoxFit variants |
| **Código simplificado** | `SafeArea(child: ...)` y `ConstrainedBox(constraints: BoxConstraints(maxWidth: 200), child: ...)` |
| **Widget clave** | `SafeArea`, `ConstrainedBox`, `SizedBox`, `AspectRatio`, `FittedBox` |

---

### 14. Clipping y transformaciones (49–51)

Widgets que recortan y transforman visualmente a sus hijos.

#### 49. Clip widgets

| Campo | Valor |
|-------|-------|
| **Ruta** | `/clip` |
| **Clase** | `ClipExample` |
| **Concepto** | ClipRect, ClipRRect, ClipOval, ClipPath con recortes interactivos |
| **Demo interactiva** | Imagen/contenedor recortada con ClipRect, ClipRRect (borderRadius configurable), ClipOval, ClipPath (estrella); slider para ajustar el radio del ClipRRect |
| **Código simplificado** | `ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(...))` y `ClipOval(child: ...)` |
| **Widget clave** | `ClipRect`, `ClipRRect`, `ClipOval`, `ClipPath` |

#### 50. Transform

| Campo | Valor |
|-------|-------|
| **Ruta** | `/transform` |
| **Clase** | `TransformExample` |
| **Concepto** | Rotar, escalar, trasladar widgets con Transform |
| **Demo interactiva** | Sliders para rotación (0–360°), escala (0.5–2.0), traslación X/Y; Transform.flip horizontal/vertical; combinaciones de transformaciones |
| **Código simplificado** | `Transform.rotate(angle: pi / 4, child: ...)` y `Transform.scale(scale: 1.5, child: ...)` |
| **Widget clave** | `Transform.rotate`, `Transform.scale`, `Transform.translate` |

#### 51. InteractiveViewer

| Campo | Valor |
|-------|-------|
| **Ruta** | `/interactive_viewer` |
| **Clase** | `InteractiveViewerExample` |
| **Concepto** | Pan, zoom y límites en contenido grande |
| **Demo interactiva** | InteractiveViewer con una imagen o gráfico grande; pinch-to-zoom y pan; límites (minScale, maxScale, boundaryMargin); botón para resetear la transformación |
| **Código simplificado** | `InteractiveViewer(minScale: 0.5, maxScale: 4.0, child: Image.network(...))` |
| **Widget clave** | `InteractiveViewer`, `TransformationController` |

---

### 15. Texto avanzado (52–53)

#### 52. RichText & TextSpan

| Campo | Valor |
|-------|-------|
| **Ruta** | `/rich_text` |
| **Clase** | `RichTextExample` |
| **Concepto** | Texto con estilos mixtos (negrita, color, enlace dentro de un párrafo) |
| **Demo interactiva** | Párrafo con múltiples TextSpan (negrita, cursiva, color, enlace tappeable); botón para alternar entre Text.rich y RichText widget |
| **Código simplificado** | `Text.rich(TextSpan(children: [TextSpan(text: 'Hola ', style: ...), TextSpan(text: 'Mundo', style: TextStyle(fontWeight: FontWeight.bold))]))` |
| **Widget clave** | `RichText`, `TextSpan`, `Text.rich` |

#### 53. SelectableText

| Campo | Valor |
|-------|-------|
| **Ruta** | `/selectable_text` |
| **Clase** | `SelectableTextExample` |
| **Concepto** | Texto seleccionable y copiable |
| **Demo interactiva** | SelectableText largo que se puede seleccionar y copiar; comparación lado a lado con Text normal (no seleccionable); toolbar personalizado |
| **Código simplificado** | `SelectableText('Texto seleccionable', onTap: ..., toolbarOptions: ToolbarOptions(copy: true))` |
| **Widget clave** | `SelectableText` |

---

### 16. Navegación Material 3 (54–56)

Componentes de navegación introducidos o actualizados en Material 3.

#### 54. NavigationBar

| Campo | Valor |
|-------|-------|
| **Ruta** | `/navigation_bar` |
| **Clase** | `NavigationBarExample` |
| **Concepto** | Reemplazo M3 de BottomNavigationBar con indicador animado |
| **Demo interactiva** | NavigationBar con 4 destinos; indicador animado al cambiar; comparación visual con BottomNavigationBar clásico |
| **Código simplificado** | `NavigationBar(destinations: [NavigationDestination(icon: Icon(Icons.home), label: 'Inicio'), ...], onDestinationSelected: ...)` |
| **Widget clave** | `NavigationBar`, `NavigationDestination` |

#### 55. NavigationRail

| Campo | Valor |
|-------|-------|
| **Ruta** | `/navigation_rail` |
| **Clase** | `NavigationRailExample` |
| **Concepto** | Navegación lateral para tablets y desktop |
| **Demo interactiva** | NavigationRail a la izquierda con 5 destinos; contenido que cambia a la derecha; toggle entre modo mini y extended |
| **Código simplificado** | `NavigationRail(destinations: [NavigationRailDestination(icon: ..., label: ...)], selectedIndex: ..., onDestinationSelected: ...)` |
| **Widget clave** | `NavigationRail`, `NavigationRailDestination` |

#### 56. SegmentedButton

| Campo | Valor |
|-------|-------|
| **Ruta** | `/segmented_button` |
| **Clase** | `SegmentedButtonExample` |
| **Concepto** | Botón segmentado — toggle group Material 3 |
| **Demo interactiva** | SegmentedButton single-select (día/noche/tarde); SegmentedButton multi-select (seleccionar días de la semana); estilos personalizados |
| **Código simplificado** | `SegmentedButton(segments: [ButtonSegment(value: 'mañana', label: Text('Mañana')), ...], selected: {...}, onSelectionChanged: ...)` |
| **Widget clave** | `SegmentedButton`, `ButtonSegment` |

---

### 17. Scroll avanzado (57–59)

#### 57. Scrollbar

| Campo | Valor |
|-------|-------|
| **Ruta** | `/scrollbar` |
| **Clase** | `ScrollbarExample` |
| **Concepto** | Scrollbar temático sobre listas largas |
| **Demo interactiva** | ListView con Scrollbar visible; Scrollbar con thumbVisibility activo; personalización de thickness y radius |
| **Código simplificado** | `Scrollbar(child: ListView.builder(...))` con `thumbVisibility: true` |
| **Widget clave** | `Scrollbar`, `ScrollController` |

#### 58. ScrollController

| Campo | Valor |
|-------|-------|
| **Ruta** | `/scroll_controller` |
| **Clase** | `ScrollControllerExample` |
| **Concepto** | Control programático: scroll to top, scroll to index |
| **Demo interactiva** | Lista con ScrollController; botón flotante "ir arriba" que aparece al hacer scroll hacia abajo; botón "saltar al elemento 50"; mostrar posición del scroll |
| **Código simplificado** | `ScrollController().animateTo(0, duration: ..., curve: Curves.ease)` |
| **Widget clave** | `ScrollController`, `ScrollNotification` |

#### 59. NestedScrollView

| Campo | Valor |
|-------|-------|
| **Ruta** | `/nested_scroll` |
| **Clase** | `NestedScrollExample` |
| **Concepto** | Header + lista con scroll coordinado |
| **Demo interactiva** | NestedScrollView con header que se contrae al hacer scroll y lista debajo; TabBar en el header que filtra la lista |
| **Código simplificado** | `NestedScrollView(headerSliverBuilder: (context, _) => [SliverAppBar(...)], body: ListView(...))` |
| **Widget clave** | `NestedScrollView`, `SliverOverlapAbsorber` |

---

### 18. Ciclo de vida y Keys (60–62)

Conceptos fundamentales sobre cómo Flutter gestiona la vida de los widgets.

#### 60. Widget Lifecycle

| Campo | Valor |
|-------|-------|
| **Ruta** | `/widget_lifecycle` |
| **Clase** | `WidgetLifecycleExample` |
| **Concepto** | initState, didUpdateWidget, didChangeDependencies, dispose — con logs visibles |
| **Demo interactiva** | Widget que registra cada callback del ciclo de vida en una lista visible; al cambiar el parent, se ve didUpdateWidget; botón para montar/desmontar y ver initState/dispose; comparación con StatelessWidget |
| **Código simplificado** | `initState() { super.initState(); print('init'); }`, `dispose() { print('dispose'); super.dispose(); }` |
| **Widget clave** | `StatefulWidget`, `State`, `initState`, `dispose`, `didUpdateWidget`, `didChangeDependencies` |

#### 61. Keys

| Campo | Valor |
|-------|-------|
| **Ruta** | `/keys` |
| **Clase** | `KeysExample` |
| **Concepto** | ValueKey, ObjectKey, GlobalKey — demostrar qué pasa SIN keys al reordenar |
| **Demo interactiva** | Dos listas lado a lado: una CON ValueKey, otra SIN key; al reordenar elementos, la lista SIN key pierde state (color, texto); la lista CON Key mantiene el estado correctamente |
| **Código simplificado** | `StatefulShell(index: ValueKey(i), color: colors[i])` |
| **Widget clave** | `ValueKey`, `ObjectKey`, `GlobalKey`, `UniqueKey` |

#### 62. RepaintBoundary

| Campo | Valor |
|-------|-------|
| **Ruta** | `/repaint_boundary` |
| **Clase** | `RepaintBoundaryExample` |
| **Concepto** | Aislar repintados — mostrar rebuild count con y sin boundary |
| **Demo interactiva** | Dos columnas lado a lado: una con RepaintBoundary alrededor de un widget animado, otra sin; contador de repintados visible en cada caso; demuestra que sin boundary, los widgets hermanos se repintan innecesariamente |
| **Código simplificado** | `RepaintBoundary(child: AnimatedWidget(...))` |
| **Widget clave** | `RepaintBoundary` |

---

### 19. API REST (63–71)

Ejemplos prácticos de consumo de APIs REST públicas, cubriendo los patrones más comunes: GET, POST, PUT, DELETE, paginación, búsqueda, manejo de errores y carga de archivos.

> **Nota**: Todos los ejemplos usan la librería `http` (ya incluida en `pubspec.yaml`) y APIs públicas gratuitas: [JSONPlaceholder](https://jsonplaceholder.typicode.com/) para CRUD, [HTTPBin](https://httpbin.org/) para testing avanzado, y [Dog API](https://dog.ceo/dog-api/) para ejemplos ligeros.

#### 63. GET — Listar recursos

| Campo | Valor |
|-------|-------|
| **Ruta** | `/api_get_list` |
| **Clase** | `ApiGetListExample` |
| **Concepto** | GET request para obtener una lista de recursos |
| **Demo interactiva** | Fetch de `https://jsonplaceholder.typicode.com/users`; muestra loading → lista de usuarios (nombre, email, teléfono); pull-to-refresh; manejo de errores con reintento |
| **Código simplificado** | `http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'))` + `jsonDecode(response.body)` |
| **Widget clave** | `http.get()`, `jsonDecode`, `FutureBuilder` (patrón), `RefreshIndicator` |
| **Patrón** | GET lista → parsear JSON array → ListView.builder |

#### 64. GET — Detalle de recurso

| Campo | Valor |
|-------|-------|
| **Ruta** | `/api_get_detail` |
| **Clase** | `ApiGetDetailExample` |
| **Concepto** | GET request para obtener un recurso por ID |
| **Demo interactiva** | Lista de posts; al tocar uno, fetch de `https://jsonplaceholder.typicode.com/posts/{id}`; muestra detalle con título, body, comentarios asociados; navegación master-detail |
| **Código simplificado** | `http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts/$id'))` |
| **Widget clave** | `http.get()`, paso de argumentos por ruta |
| **Patrón** | GET detalle → parsear JSON object → DetailScreen |

#### 65. POST — Crear recurso

| Campo | Valor |
|-------|-------|
| **Ruta** | `/api_post` |
| **Clase** | `ApiPostExample` |
| **Concepto** | POST request para crear un nuevo recurso |
| **Demo interactiva** | Formulario para crear un post (title, body); envío con `http.post` y headers JSON; muestra la respuesta del servidor (id asignado); validación del formulario antes de enviar |
| **Código simplificado** | `http.post(Uri.parse(url), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'title': '...', 'body': '...', 'userId': 1}))` |
| **Widget clave** | `http.post()`, `jsonEncode`, `Form` + validación |
| **Patrón** | Form → validate → http.post → mostrar respuesta |

#### 66. PUT — Actualizar recurso

| Campo | Valor |
|-------|-------|
| **Ruta** | `/api_put` |
| **Clase** | `ApiPutExample` |
| **Concepto** | PUT request para actualizar un recurso existente |
| **Demo interactiva** | Carga un post existente; formulario con datos precargados; editar y enviar con `http.put`; muestra la respuesta actualizada; comparación antes/después |
| **Código simplificado** | `http.put(Uri.parse('$url/$id'), headers: {...}, body: jsonEncode(updatedData))` |
| **Widget clave** | `http.put()`, edición precargada |
| **Patrón** | GET detalle → editar formulario → http.put → mostrar resultado |

#### 67. DELETE — Eliminar recurso

| Campo | Valor |
|-------|-------|
| **Ruta** | `/api_delete` |
| **Clase** | `ApiDeleteExample` |
| **Concepto** | DELETE request con confirmación |
| **Demo interactiva** | Lista de posts; swipe para eliminar (Dismissible); confirmación con AlertDialog; `http.delete`; SnackBar con "Deshacer"; animación de eliminación |
| **Código simplificado** | `http.delete(Uri.parse('$url/$id'))` |
| **Widget clave** | `http.delete()`, `Dismissible`, `AlertDialog` de confirmación |
| **Patrón** | Lista → swipe/confirmar → http.delete → actualizar UI |

#### 68. Paginación

| Campo | Valor |
|-------|-------|
| **Ruta** | `/api_pagination` |
| **Clase** | `ApiPaginationExample` |
| **Concepto** | Scroll infinito con paginación progresiva |
| **Demo interactiva** | Lista de posts que carga de 10 en 10; al llegar al final, fetch de la siguiente página; indicador de carga en el footer; manejo de "no hay más datos" |
| **Código simplificado** | `ScrollController.addListener(() { if (sc.position.pixels == sc.position.maxScrollExtent) _loadMore(); })` |
| **Widget clave** | `ScrollController`, `NotificationListener<ScrollNotification>` |
| **Patrón** | Scroll infinito → fetch page N → añadir a lista → mostrar loading footer |

#### 69. Búsqueda en API

| Campo | Valor |
|-------|-------|
| **Ruta** | `/api_search` |
| **Clase** | `ApiSearchExample` |
| **Concepto** | Búsqueda con debounce contra una API |
| **Demo interactiva** | TextField con debounce (500ms); busca posts por título con `?title_like=query`; muestra resultados en tiempo real; indicador de "buscando..."; estado vacío con sugerencia |
| **Código simplificado** | `Timer(Duration(milliseconds: 500), () => http.get(Uri.parse('$url?title_like=$query')))` |
| **Widget clave** | `Timer`, `TextField`, `Debounce` pattern |
| **Patrón** | TextField → debounce → GET con query → mostrar resultados |

#### 70. Manejo de errores

| Campo | Valor |
|-------|-------|
| **Ruta** | `/api_errors` |
| **Clase** | `ApiErrorsExample` |
| **Concepto** | Manejo robusto de errores HTTP: timeout, sin conexión, errores de servidor |
| **Demo interactiva** | Botones para simular: timeout (5s), 404, 500, sin conexión; cada caso muestra el error apropiado con icono y mensaje; botón de reintento; patrones de error con try/catch |
| **Código simplificado** | `try { final response = await http.get(url).timeout(Duration(seconds: 5)); if (response.statusCode == 200) ... else throw HttpException('${response.statusCode}'); } on SocketException { ... } on TimeoutException { ... }` |
| **Widget clave** | `try/catch`, `SocketException`, `TimeoutException`, `HttpException` |
| **Patrón** | try/catch → clasificar error → mostrar UI apropiada → reintento |

#### 71. Carga de imágenes desde API

| Campo | Valor |
|-------|-------|
| **Ruta** | `/api_images` |
| **Clase** | `ApiImagesExample` |
| **Concepto** | Fetch de imágenes desde API, caché, placeholder, errores |
| **Demo interactiva** | Grid de fotos de perros desde Dog API (`https://dog.ceo/api/breed/hound/images`); FadeInImage con placeholder; manejo de errores de carga; caché con CachedNetworkImage (o explicación de por qué) |
| **Código simplificado** | `http.get(Uri.parse('https://dog.ceo/api/breed/hound/images'))` + `Image.network(url)` con `errorBuilder` |
| **Widget clave** | `Image.network`, `FadeInImage`, `errorBuilder` |
| **Patrón** | GET API → parsear URLs → GridView con Image.network + placeholders |

---

### 20. Google Maps (72–84)

Integración de mapas interactivos con `google_maps_flutter`. Cada ejemplo cubre un concepto atómico: desde el mapa más básico hasta estilos JSON y permisos de ubicación.

> **Nota previa**: Para usar Google Maps necesitas una API key de Google Cloud Platform. Sigue los pasos:
>
> 1. Crea un proyecto en [Google Cloud Console](https://console.cloud.google.com/).
> 2. Habilita **Maps SDK for Android** y **Maps SDK for iOS**.
> 3. Crea una credencial de tipo **API key**.
> 4. Restringe la clave a tu app (Android: package name + SHA-1; iOS: Bundle ID).
> 5. Coloca la clave en `android/app/src/main/AndroidManifest.xml` (meta-data `com.google.android.geo.API_KEY`) y en `ios/Runner/AppDelegate.swift` (`GMSServices.provideAPIKey(...)`).
>
> **Sin una clave válida el mapa se mostrará gris.** El resto de la app compila y funciona; solo el widget `GoogleMap` no renderizará tiles.

#### 72. Mapa básico

| Campo | Valor |
|-------|-------|
| **Ruta** | `/map_basic` |
| **Clase** | `BasicMapExample` |
| **Concepto** | Widget `GoogleMap` mínimo con `initialCameraPosition` |
| **Demo interactiva** | Mapa centrado en Madrid con zoom 10, sin overlays |
| **Código simplificado** | `GoogleMap(initialCameraPosition: CameraPosition(target: LatLng(40.4168, -3.7038), zoom: 10))` |
| **Widget clave** | `GoogleMap`, `CameraPosition`, `LatLng` |

#### 73. MapType — normal, satellite, terrain, hybrid

| Campo | Valor |
|-------|-------|
| **Ruta** | `/map_type` |
| **Clase** | `MapTypeExample` |
| **Concepto** | Cambiar el estilo del mapa declarativamente |
| **Demo interactiva** | `SegmentedButton` que alterna los 4 MapType; el mapa se reconstruye al cambiar |
| **Código simplificado** | `GoogleMap(mapType: MapType.satellite)` |
| **Widget clave** | `GoogleMap(mapType:)`, `SegmentedButton`, `MapType` |

#### 74. Cámara — moveCamera vs animateCamera

| Campo | Valor |
|-------|-------|
| **Ruta** | `/map_camera_control` |
| **Clase** | `CameraControlExample` |
| **Concepto** | Control programático de la cámara vía `GoogleMapController` |
| **Demo interactiva** | Botones para saltar (moveCamera) o animar (animateCamera) a Barcelona; animateCamera usa bearing 270 y tilt 30 para vista 3D; botón reset vuelve a Madrid |
| **Código simplificado** | `controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: ..., bearing: 270, tilt: 30, zoom: 12)))` |
| **Widget clave** | `GoogleMapController`, `onMapCreated`, `CameraUpdate`, `moveCamera`, `animateCamera` |

#### 75. Markers dinámicos

| Campo | Valor |
|-------|-------|
| **Ruta** | `/map_markers` |
| **Clase** | `MarkersExample` |
| **Concepto** | `Set<Marker>` reactivo + `onLongPress` |
| **Demo interactiva** | Long-press sobre el mapa añade un marcador en esa posición; botón fija uno en Madrid; contador de marcadores; InfoWindow con coordenadas |
| **Código simplificado** | `setState(() => _markers.add(Marker(markerId: MarkerId('m_$n'), position: pos, infoWindow: InfoWindow(title: 'Marcador #n'))))` |
| **Widget clave** | `Marker`, `MarkerId`, `InfoWindow`, `Set<Marker>`, `onLongPress` |

#### 76. InfoWindow

| Campo | Valor |
|-------|-------|
| **Ruta** | `/map_info_window` |
| **Clase** | `InfoWindowExample` |
| **Concepto** | Ventana de información con title, snippet y apertura programática |
| **Demo interactiva** | Marcador en Puerta del Sol con title y snippet; botón que abre el InfoWindow programáticamente |
| **Código simplificado** | `Marker(infoWindow: InfoWindow(title: '...', snippet: '...'))` y `controller.showMarkerInfoWindow(MarkerId('puerta_del_sol'))` |
| **Widget clave** | `InfoWindow`, `Marker.infoWindow`, `showMarkerInfoWindow` |

#### 77. Polylines — rutas

| Campo | Valor |
|-------|-------|
| **Ruta** | `/map_polylines` |
| **Clase** | `PolylinesExample` |
| **Concepto** | Línea que conecta puntos; geodesic sigue la curvatura terrestre |
| **Demo interactiva** | Ruta Southampton → Cobh → sitio del naufragio del Titanic con geodesic, caps y joints redondos |
| **Código simplificado** | `Polyline(polylineId: PolylineId('r'), points: [...], width: 5, color: Colors.red, geodesic: true, startCap: Cap.roundCap, jointType: JointType.round)` |
| **Widget clave** | `Polyline`, `PolylineId`, `Cap`, `JointType`, `geodesic` |

#### 78. Polygons — áreas

| Campo | Valor |
|-------|-------|
| **Ruta** | `/map_polygons` |
| **Clase** | `PolygonsExample` |
| **Concepto** | Polígono cerrado relleno con stroke y fill |
| **Demo interactiva** | Triángulo de las Bermudas con stroke rojo y fill amarillo semitransparente; consumeTapEvents captura taps |
| **Código simplificado** | `Polygon(polygonId: PolygonId('a'), points: [...], strokeColor: Colors.red, fillColor: Colors.yellow.withOpacity(0.35), consumeTapEvents: true)` |
| **Widget clave** | `Polygon`, `PolygonId`, `strokeColor`, `fillColor`, `consumeTapEvents` |

#### 79. Circles — radios y cobertura

| Campo | Valor |
|-------|-------|
| **Ruta** | `/map_circles` |
| **Clase** | `CirclesExample` |
| **Concepto** | Círculo definido por centro + radio en metros |
| **Demo interactiva** | Tres círculos concéntricos (2, 5 y 10 km) alrededor de Madrid con distintos colores y opacidades |
| **Código simplificado** | `Circle(circleId: CircleId('c'), center: LatLng(...), radius: 5000, strokeColor: Colors.blue, fillColor: Colors.blue.withOpacity(0.15))` |
| **Widget clave** | `Circle`, `CircleId`, `center`, `radius` (metros) |

#### 80. Controles de UI y gestures

| Campo | Valor |
|-------|-------|
| **Ruta** | `/map_ui_controls` |
| **Clase** | `MapUiControlsExample` |
| **Concepto** | Toggles declarativos de gestures y botones de UI |
| **Demo interactiva** | 8 FilterChips para activar/desactivar: zoom, rotate, tilt, scroll, compass, mapToolbar, myLocationButton, traffic; el mapa se reconstruye al cambiar |
| **Código simplificado** | `GoogleMap(zoomGesturesEnabled: true, rotateGesturesEnabled: false, compassEnabled: true, trafficEnabled: true)` |
| **Widget clave** | `zoomGesturesEnabled`, `rotateGesturesEnabled`, `tiltGesturesEnabled`, `scrollGesturesEnabled`, `compassEnabled`, `mapToolbarEnabled`, `myLocationButtonEnabled`, `trafficEnabled` |

#### 81. My Location + permisos

| Campo | Valor |
|-------|-------|
| **Ruta** | `/map_my_location` |
| **Clase** | `MyLocationExample` |
| **Concepto** | Punto azul de ubicación del usuario; requiere permisos |
| **Demo interactiva** | Diálogo simulando concesión/denegación de permiso; al conceder, myLocationEnabled y myLocationButtonEnabled se activan; en producción usa `permission_handler` |
| **Código simplificado** | `GoogleMap(myLocationEnabled: granted, myLocationButtonEnabled: granted)` |
| **Widget clave** | `myLocationEnabled`, `myLocationButtonEnabled`, `permission_handler` (producción) |

#### 82. Estilos de mapa (JSON)

| Campo | Valor |
|-------|-------|
| **Ruta** | `/map_styling` |
| **Clase** | `MapStylingExample` |
| **Concepto** | `setMapStyle` aplica un JSON de estilos; `onCameraMove` trackea la cámara |
| **Demo interactiva** | Dark style minimal aplicado en onMapCreated; texto en vivo con lat/lng/zoom de la cámara mientras mueves |
| **Código simplificado** | `controller.setMapStyle('[{"elementType":"geometry","stylers":[{"color":"#242f3e"}]}]')` y `GoogleMap(onCameraMove: (pos) => ...)` |
| **Widget clave** | `setMapStyle`, `onCameraMove`, generador en https://mapstyle.withgoogle.com/ |

#### 83. (Reservado para futuros ejemplos)

Reservado para ampliaciones: clusters, geocoding, directions API, place picker, map snapshots.

#### 84. (Reservado para futuros ejemplos)

Reservado para ampliaciones: heatmaps, KML layers, custom markers con BitmapDescriptor, indoor maps.

---

## Resumen de numeración

| Sección | # Ejemplos | Rango |
|---------|-----------|-------|
| 1. Layout & Estructura | 5 | 1–5 ✅ |
| 2. Navegación | 4 | 6–9 ✅ |
| 3. Entrada del usuario | 3 | 10–12 ✅ |
| 4. Estado | 3 | 13–15 ✅ |
| 5. Animación | 3 | 16–18 ✅ |
| 6. Visual & Temas | 3 | 19–21 ✅ |
| 7. Datos asíncronos | 3 | 22–24 ✅ |
| 8. Material Design | 4 | 25–28 ✅ |
| 9. Interacción avanzada | 3 | 29–31 ✅ |
| 10. Progreso y feedback visual | 4 | 32–35 |
| 11. Colecciones avanzadas | 5 | 36–40 |
| 12. Selección y autocompletado | 4 | 41–44 |
| 13. Layout responsivo y adaptativo | 4 | 45–48 |
| 14. Clipping y transformaciones | 3 | 49–51 |
| 15. Texto avanzado | 2 | 52–53 |
| 16. Navegación Material 3 | 3 | 54–56 |
| 17. Scroll avanzado | 3 | 57–59 |
| 18. Ciclo de vida y Keys | 3 | 60–62 |
| 19. API REST | 9 | 63–71 ✅ |
| 20. Google Maps | 10 | 72–84 ✅ |
| **Total** | **84** | — |