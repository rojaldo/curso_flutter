# Módulo: Google Maps para Flutter

## Introducción

Este módulo te guiará a través de todos los aspectos relacionados con la integración de **Google Maps en aplicaciones Flutter** para iOS y Android. Aprenderás desde la configuración inicial hasta técnicas avanzadas de geolocalización y rutas.

---

## Índice de Contenidos

1. [Conceptos Fundamentales](#1-conceptos-fundamentales)
2. [Configuración del Proyecto Flutter](#2-configuración-del-proyecto-flutter)
3. [API Keys - Android e iOS](#3-api-keys---android-e-ios)
4. [Primer Mapa en Flutter](#4-primer-mapa-en-flutter)
5. [Marcadores (Markers)](#5-marcadores-markers)
6. [Polilíneas y Polígonos](#6-polilíneas-y-polígonos)
7. [Ventanas de Información (InfoWindows)](#7-ventanas-de-información-infowindows)
8. [Geolocalización del Usuario](#8-geolocalización-del-usuario)
9. [Geocoding y Reverse Geocoding](#9-geocoding-y-reverse-geocoding)
10. [Places API y Autocompletado](#10-places-api-y-autocompletado)
11. [Direcciones y Rutas](#11-direcciones-y-rutas)
12. [Personalización del Mapa](#12-personalización-del-mapa)
13. [Optimización y Rendimiento](#13-optimización-y-rendimiento)
14. [Buenas Prácticas](#14-buenas-prácticas)
15. [Proyecto Práctico Completo](#15-proyecto-práctico-completo)

---

## 1. Conceptos Fundamentales

### 1.1 Sistema de Coordenadas

Google Maps utiliza coordenadas geográficas:

```dart
// Latitud: -90 a +90 (Sur a Norte)
// Longitud: -180 a +180 (Oeste a Este)

class Coordenada {
  final double latitud;
  final double longitud;
  
  const Coordenada({
    required this.latitud,
    required this.longitud,
  });
  
  // Madrid, España
  static const madrid = Coordenada(latitud: 40.4168, longitud: -3.7038);
}
```

### 1.2 LatLng y CameraPosition

En Flutter, usamos las clases del package `google_maps_flutter`:

```dart
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Coordenadas
final LatLng posicion = LatLng(40.4168, -3.7038);

// Posición de la cámara
final CameraPosition posicionInicial = CameraPosition(
  target: LatLng(40.4168, -3.7038),
  zoom: 14.0,        // 0-21+ (mundo → edificio)
  bearing: 0.0,      // Rotación en grados (0-360)
  tilt: 0.0,         // Inclinación en grados (0-90)
);
```

### 1.3 Niveles de Zoom

| Zoom | Escala | Visibilidad |
|------|--------|-------------|
| 0-2 | Mundial | Continentes |
| 3-5 | Continental | Países grandes |
| 6-10 | Regional | Ciudades principales |
| 11-14 | Ciudad | Calles principales |
| 15-18 | Calle | Edificios, negocios |
| 19-21+ | Edificio | Detalles máximos |

---

## 2. Configuración del Proyecto Flutter

### 2.1 Crear Proyecto

```bash
flutter create mi_app_mapas
cd mi_app_mapas
```

### 2.2 Dependencias en pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Google Maps
  google_maps_flutter: ^2.5.0
  
  # Geolocalización
  geolocator: ^10.1.0
  
  # Geocoding
  geocoding: ^2.1.0
  
  # HTTP para APIs
  http: ^1.1.0
  
  # Estado (opcional)
  provider: ^6.1.0
  
  # Utilidades
  flutter_polyline_points: ^1.0.0
```

### 2.3 Instalar Dependencias

```bash
flutter pub get
```

---

## 3. API Keys - Android e iOS

### 3.1 Google Cloud Console

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Crea un nuevo proyecto o selecciona uno existente
3. Habilita las APIs necesarias:
   - **Maps SDK for Android**
   - **Maps SDK for iOS**
   - **Places API** (opcional)
   - **Directions API** (opcional)
   - **Geocoding API** (opcional)

### 3.2 Crear API Keys

```
APIs & Services → Credentials → Create Credentials → API Key
```

Crear **dos keys separadas**:
- Una para Android
- Una para iOS

### 3.3 Configuración Android

#### android/app/src/main/AndroidManifest.xml

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application>
        <!-- Google Maps API Key -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="TU_API_KEY_ANDROID"/>
        
        <!-- Permisos de ubicación -->
        <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
        <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    </application>
</manifest>
```

#### android/app/build.gradle

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Mínimo para Google Maps
    }
}
```

### 3.4 Configuración iOS

#### ios/Runner/AppDelegate.swift

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configurar API Key
    GMSServices.provideAPIKey("TU_API_KEY_IOS")
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

#### ios/Runner/Info.plist

```xml
<dict>
    <!-- Permisos de ubicación -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Esta app necesita tu ubicación para mostrar el mapa</string>
    
    <key>NSLocationAlwaysUsageDescription</key>
    <string>Esta app necesita acceso a tu ubicación en segundo plano</string>
    
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>Esta app necesita acceso a tu ubicación para funcionar correctamente</string>
</dict>
```

### 3.5 Restricciones de Seguridad

**⚠️ IMPORTANTE**: Aplica restricciones a cada API Key

#### Para Android:
```
Application restrictions: Android apps
Package name: com.tuempresa.mi_app_mapas
SHA-1 fingerprint: (obtener con keytool)
```

```bash
# Obtener SHA-1
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

#### Para iOS:
```
Application restrictions: iOS apps
Bundle identifier: com.tuempresa.mi_app_mapas
```

---

## 4. Primer Mapa en Flutter

### 4.1 Widget Básico

```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  // Controlador del mapa
  GoogleMapController? _mapController;

  // Posición inicial: Madrid
  static const LatLng _posicionInicial = LatLng(40.4168, -3.7038);

  // Posición de la cámara
  static const CameraPosition _kMadrid = CameraPosition(
    target: _posicionInicial,
    zoom: 14.0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Primer Mapa')),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kMadrid,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
      ),
    );
  }
}
```

### 4.2 Opciones del Mapa

```dart
GoogleMap(
  mapType: MapType.normal,  // normal, satellite, terrain, hybrid
  initialCameraPosition: _posicionInicial,
  onMapCreated: _onMapCreated,
  
  // Controles UI
  zoomControlsEnabled: true,
  zoomGesturesEnabled: true,
  mapToolbarEnabled: true,
  compassEnabled: true,
  myLocationButtonEnabled: true,
  myLocationEnabled: true,
  
  // Gestos
  scrollGesturesEnabled: true,
  tiltGesturesEnabled: true,
  rotateGesturesEnabled: true,
  
  // Padding
  padding: EdgeInsets.only(bottom: 100),
  
  // Callbacks
  onTap: (LatLng posicion) {
    print('Tap en: $posicion');
  },
  onLongPress: (LatLng posicion) {
    print('Long press en: $posicion');
  },
  onCameraMove: (CameraPosition posicion) {
    print('Cámara movida a: ${posicion.target}');
  },
  onCameraIdle: () {
    print('Cámara detenida');
  },
);
```

### 4.3 Controlar la Cámara

```dart
class _MapaScreenState extends State<MapaScreen> {
  GoogleMapController? _mapController;

  // Mover la cámara a una posición
  Future<void> moverCamara(LatLng destino, {double zoom = 14.0}) async {
    await _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: destino, zoom: zoom),
      ),
    );
  }

  // Zoom in
  Future<void> zoomIn() async {
    await _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  // Zoom out
  Future<void> zoomOut() async {
    await _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  // Ajustar para ver todos los puntos
  Future<void> ajustarLimites(List<LatLng> puntos) async {
    final bounds = _calcularBounds(puntos);
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50.0),
    );
  }

  LatLngBounds _calcularBounds(List<LatLng> puntos) {
    double minLat = puntos.first.latitude;
    double maxLat = puntos.first.latitude;
    double minLng = puntos.first.longitude;
    double maxLng = puntos.first.longitude;

    for (final punto in puntos) {
      if (punto.latitude < minLat) minLat = punto.latitude;
      if (punto.latitude > maxLat) maxLat = punto.latitude;
      if (punto.longitude < minLng) minLng = punto.longitude;
      if (punto.longitude > maxLng) maxLng = punto.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: _posicionInicial,
        onMapCreated: (controller) => _mapController = controller,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => moverCamara(LatLng(41.3851, 2.1734)), // Barcelona
        child: const Icon(Icons.location_city),
      ),
    );
  }
}
```

---

## 5. Marcadores (Markers)

### 5.1 Marcador Básico

```dart
Set<Marker> _markers = {};

// Añadir marcador
void _añadirMarcador(LatLng posicion) {
  final markerId = MarkerId(posicion.toString());
  
  setState(() {
    _markers.add(
      Marker(
        markerId: markerId,
        position: posicion,
        infoWindow: InfoWindow(
          title: 'Mi ubicación',
          snippet: 'Descripción del lugar',
        ),
      ),
    );
  });
}

// En el widget
GoogleMap(
  markers: _markers,
  onTap: (LatLng posicion) {
    _añadirMarcador(posicion);
  },
);
```

### 5.2 Marcador Personalizado con Icono

```dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class MarcadorPersonalizado {
  static Future<BitmapDescriptor> crearDesdeAsset(String assetPath, {int width = 100}) async {
    final ImageStream stream = AssetImage(assetPath).resolve(ImageConfiguration.empty);
    final Completer<BitmapDescriptor> completer = Completer<BitmapDescriptor>();
    
    final listener = ImageStreamListener(
      (ImageInfo info, bool _) async {
        final ByteData? bytes = await info.image.toByteData(
          format: ImageByteFormat.png,
        );
        if (bytes != null) {
          completer.complete(BitmapDescriptor.fromBytes(bytes.buffer.asUint8List()));
        }
      },
    );
    
    stream.addListener(listener);
    return completer.future;
  }
}

// Uso
BitmapDescriptor? _iconoPersonalizado;

@override
void initState() {
  super.initState();
  _cargarIconos();
}

Future<void> _cargarIconos() async {
  _iconoPersonalizado = await MarcadorPersonalizado.crearDesdeAsset(
    'assets/marcador.png',
    width: 120,
  );
  setState(() {});
}
```

### 5.3 Marcadores con Colores

```dart
Marker(
  markerId: MarkerId('id'),
  position: posicion,
  icon: BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueRed,      // Rojo (default)
    // BitmapDescriptor.hueOrange, // Naranja
    // BitmapDescriptor.hueYellow, // Amarillo
    // BitmapDescriptor.hueGreen,  // Verde
    // BitmapDescriptor.hueCyan,   // Cian
    // BitmapDescriptor.hueAzure,  // Azul claro
    // BitmapDescriptor.hueBlue,   // Azul
    // BitmapDescriptor.hueViolet, // Violeta
    // BitmapDescriptor.hueMagenta,// Magenta
    // BitmapDescriptor.hueRose,   // Rosa
  ),
);
```

### 5.4 Marcador Arrastrable

```dart
Marker(
  markerId: MarkerId('draggable'),
  position: posicion,
  draggable: true,
  onDragStart: (LatLng posicion) {
    print('Drag start: $posicion');
  },
  onDrag: (LatLng posicion) {
    print('Dragging: $posicion');
  },
  onDragEnd: (LatLng posicion) {
    print('Drag end: $posicion');
    // Actualizar posición en tu estado
    setState(() {
      // ...
    });
  },
);
```

### 5.5 Gestión de Múltiples Marcadores

```dart
class MarcadorManager {
  final Set<Marker> _markers = {};
  final Map<String, Marker> _markersPorId = {};

  void añadirMarcador({
    required String id,
    required LatLng posicion,
    String? titulo,
    String? descripcion,
    BitmapDescriptor? icono,
    VoidCallback? onTap,
  }) {
    final marker = Marker(
      markerId: MarkerId(id),
      position: posicion,
      icon: icono ?? BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(
        title: titulo,
        snippet: descripcion,
      ),
      onTap: onTap,
    );
    
    _markersPorId[id] = marker;
    _markers.add(marker);
  }

  void eliminarMarcador(String id) {
    final marker = _markersPorId[id];
    if (marker != null) {
      _markers.remove(marker);
      _markersPorId.remove(id);
    }
  }

  void actualizarPosicion(String id, LatLng nuevaPosicion) {
    eliminarMarcador(id);
    añadirMarcador(id: id, posicion: nuevaPosicion);
  }

  void limpiarTodo() {
    _markers.clear();
    _markersPorId.clear();
  }

  Set<Marker> get markers => Set.from(_markers);
}
```

---

## 6. Polilíneas y Polígonos

### 6.1 Polilínea (Ruta)

```dart
Set<Polyline> _polylines = {};

void _dibujarRuta(List<LatLng> puntos) {
  final polylineId = PolylineId('ruta_1');
  
  setState(() {
    _polylines.add(
      Polyline(
        polylineId: polylineId,
        points: puntos,
        color: Colors.blue,
        width: 5,
        patterns: [PatternItem.dash(10), PatternItem.gap(5)], // Línea discontinua
        jointType: JointType.round,  // Unión redondeada
        startCap: Cap.roundCap,       // Inicio redondeado
        endCap: Cap.roundCap,         // Fin redondeado
        geodesic: true,              // Sigue la curvatura de la Tierra
        zIndex: 1,
      ),
    );
  });
}

GoogleMap(
  polylines: _polylines,
);

// Ejemplo de uso
final ruta = [
  LatLng(40.4168, -3.7038),  // Madrid
  LatLng(41.3851, 2.1734),   // Barcelona
  LatLng(39.4699, -0.3763),  // Valencia
];
_dibujarRuta(ruta);
```

### 6.2 Polígono (Área)

```dart
Set<Polygon> _polygons = {};

void _dibujarArea(List<LatLng> puntos) {
  final polygonId = PolygonId('area_1');
  
  setState(() {
    _polygons.add(
      Polygon(
        polygonId: polygonId,
        points: puntos,
        strokeColor: Colors.red,
        strokeWidth: 3,
        fillColor: Colors.red.withOpacity(0.3),
        geodesic: true,
        clickable: true,
        onTap: () {
          print('Polígono tocado');
        },
      ),
    );
  });
}

GoogleMap(
  polygons: _polygons,
);

// Ejemplo: Zona circular
List<LatLng> _crearPoligonoCircular(LatLng centro, double radioMetros, int lados) {
  final puntos = <LatLng>[];
  final double earthRadius = 6371000; // metros
  
  for (int i = 0; i < lados; i++) {
    final double bearing = 360 * i / lados;
    final double lat1 = centro.latitude * (pi / 180);
    final double lng1 = centro.longitude * (pi / 180);
    final double angularDistance = radioMetros / earthRadius;
    final double bearingRad = bearing * (pi / 180);
    
    final double lat2 = asin(sin(lat1) * cos(angularDistance) +
        cos(lat1) * sin(angularDistance) * cos(bearingRad));
    final double lng2 = lng1 + atan2(
        sin(bearingRad) * sin(angularDistance) * cos(lat1),
        cos(angularDistance) - sin(lat1) * sin(lat2));
    
    puntos.add(LatLng(lat2 * (180 / pi), lng2 * (180 / pi)));
  }
  
  return puntos;
}
```

### 6.3 Círculo

```dart
Set<Circle> _circles = {};

void _dibujarCirculo(LatLng centro, double radioMetros) {
  setState(() {
    _circles.add(
      Circle(
        circleId: CircleId('circulo_1'),
        center: centro,
        radius: radioMetros,
        strokeColor: Colors.blue,
        strokeWidth: 2,
        fillColor: Colors.blue.withOpacity(0.2),
        clickable: true,
        onTap: () {
          print('Círculo tocado');
        },
      ),
    );
  });
}

GoogleMap(
  circles: _circles,
);

// Ejemplo: Radio de 500m
_dibujarCirculo(LatLng(40.4168, -3.7038), 500);
```

---

## 7. Ventanas de Información (InfoWindows)

### 7.1 InfoWindow Básico

```dart
Marker(
  markerId: MarkerId('info_marker'),
  position: posicion,
  infoWindow: InfoWindow(
    title: 'Título del lugar',
    snippet: 'Descripción corta del lugar',
    anchor: const Offset(0.5, 0.0),  // Punto de anclaje
    onTap: () {
      print('InfoWindow tocado');
    },
  ),
);
```

### 7.2 InfoWindow Personalizado (Custom)

Para InfoWindows más complejos, necesitamos un enfoque diferente:

```dart
import 'dart:ui' as ui;

class CustomInfoWindow {
  static Future<BitmapDescriptor> crearInfoWindow({
    required String titulo,
    required String descripcion,
    required Color color,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = color;
    
    // Dimensiones
    const width = 300.0;
    const height = 100.0;
    
    // Dibujar fondo
    final rect = Rect.fromLTWH(0, 0, width, height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      paint,
    );
    
    // Dibujar texto (simplificado, en producción usar TextPainter)
    // ...
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }
}
```

### 7.3 Widget InfoWindow Alternativo

Para InfoWindows completamente personalizados:

```dart
class MapaConInfoWindow extends StatefulWidget {
  const MapaConInfoWindow({super.key});

  @override
  State<MapaConInfoWindow> createState() => _MapaConInfoWindowState();
}

class _MapaConInfoWindowState extends State<MapaConInfoWindow> {
  GoogleMapController? _mapController;
  LatLng? _markerSeleccionado;
  final Map<String, MarkerData> _markerData = {};

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: _posicionInicial,
          markers: _crearMarcadores(),
          onMapCreated: (controller) => _mapController = controller,
          onTap: (_) {
            setState(() {
              _markerSeleccionado = null;
            });
          },
        ),
        if (_markerSeleccionado != null && _markerData[_markerSeleccionado.toString()] != null)
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: _CustomInfoWindowWidget(
              data: _markerData[_markerSeleccionado.toString()]!,
              onClose: () {
                setState(() {
                  _markerSeleccionado = null;
                });
              },
            ),
          ),
      ],
    );
  }

  Set<Marker> _crearMarcadores() {
    return _markerData.entries.map((entry) {
      return Marker(
        markerId: MarkerId(entry.key),
        position: entry.value.posicion,
        onTap: () {
          setState(() {
            _markerSeleccionado = entry.value.posicion;
          });
        },
      );
    }).toSet();
  }
}

class MarkerData {
  final LatLng posicion;
  final String titulo;
  final String descripcion;
  final String? imagenUrl;

  MarkerData({
    required this.posicion,
    required this.titulo,
    required this.descripcion,
    this.imagenUrl,
  });
}

class _CustomInfoWindowWidget extends StatelessWidget {
  final MarkerData data;
  final VoidCallback onClose;

  const _CustomInfoWindowWidget({
    required this.data,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data.titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(data.descripcion),
            if (data.imagenUrl != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  data.imagenUrl!,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

## 8. Geolocalización del Usuario

### 8.1 Configurar Permisos

#### Android (AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

#### iOS (Info.plist)

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Esta app necesita tu ubicación para mostrar el mapa</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Esta app necesita tu ubicación para funciones en segundo plano</key>
```

### 8.2 Obtener Ubicación Actual

```dart
import 'package:geolocator/geolocator.dart';

class UbicacionService {
  Future<Position?> obtenerUbicacionActual() async {
    bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) {
      return Future.error('El servicio de ubicación está deshabilitado');
    }

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        return Future.error('Permisos de ubicación denegados');
      }
    }

    if (permiso == LocationPermission.deniedForever) {
      return Future.error('Permisos denegados permanentemente');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Stream<Position> seguirUbicacion() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Actualizar cada 10 metros
      ),
    );
  }

  Future<double> distanciaEntre(LatLng punto1, LatLng punto2) async {
    return Geolocator.distanceBetween(
      punto1.latitude,
      punto1.longitude,
      punto2.latitude,
      punto2.longitude,
    );
  }
}
```

### 8.3 Usar en el Mapa

```dart
class MapaConUbicacion extends StatefulWidget {
  const MapaConUbicacion({super.key});

  @override
  State<MapaConUbicacion> createState() => _MapaConUbicacionState();
}

class _MapaConUbicacionState extends State<MapaConUbicacion> {
  GoogleMapController? _mapController;
  Position? _ubicacionActual;
  StreamSubscription<Position>? _ubicacionSubscription;

  @override
  void initState() {
    super.initState();
    _obtenerUbicacion();
    _seguirUbicacion();
  }

  @override
  void dispose() {
    _ubicacionSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _obtenerUbicacion() async {
    final ubicacion = await UbicacionService().obtenerUbicacionActual();
    if (ubicacion != null && mounted) {
      setState(() {
        _ubicacionActual = ubicacion;
      });
      _moverAUbicacion(ubicacion);
    }
  }

  void _seguirUbicacion() {
    _ubicacionSubscription = UbicacionService().seguirUbicacion().listen(
      (Position posicion) {
        if (mounted) {
          setState(() {
            _ubicacionActual = posicion;
          });
        }
      },
    );
  }

  Future<void> _moverAUbicacion(Position posicion) async {
    await _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(posicion.latitude, posicion.longitude),
          zoom: 16.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(0, 0),  // Se actualizará
          zoom: 14.0,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
          if (_ubicacionActual != null) {
            _moverAUbicacion(_ubicacionActual!);
          }
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
```

---

## 9. Geocoding y Reverse Geocoding

### 9.1 Configurar Dependencia

```yaml
dependencies:
  geocoding: ^2.1.0
```

### 9.2 Geocoding (Dirección → Coordenadas)

```dart
import 'package:geocoding/geocoding.dart';

class GeocodingService {
  Future<List<Location>> direccionACoordenadas(String direccion) async {
    try {
      return await locationFromAddress(direccion);
    } catch (e) {
      return [];
    }
  }

  Future<LatLng?> buscarPrimeraCoincidencia(String direccion) async {
    final ubicaciones = await direccionACoordenadas(direccion);
    if (ubicaciones.isNotEmpty) {
      return LatLng(ubicaciones.first.latitude, ubicaciones.first.longitude);
    }
    return null;
  }
}

// Uso
final geocoding = GeocodingService();
final coordenadas = await geocoding.buscarPrimeraCoincidencia(
  'Plaza Mayor, Madrid, España',
);
if (coordenadas != null) {
  print('Latitud: ${coordenadas.latitude}');
  print('Longitud: ${coordenadas.longitude}');
}
```

### 9.3 Reverse Geocoding (Coordenadas → Dirección)

```dart
class GeocodingService {
  Future<List<Placemark>> coordenadasADireccion(double lat, double lng) async {
    try {
      return await placemarkFromCoordinates(lat, lng);
    } catch (e) {
      return [];
    }
  }

  Future<String?> obtenerDireccion(double lat, double lng) async {
    final placemarks = await coordenadasADireccion(lat, lng);
    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      return '${place.street}, ${place.locality}, ${place.country}';
    }
    return null;
  }
}

// Uso
final direccion = await GeocodingService().obtenerDireccion(40.4168, -3.7038);
print('Dirección: $direccion');
// Output: "Calle Mayor, Madrid, España"
```

### 9.4 Geocoding con Google Maps API (Alternativa)

Para más precisión o uso comercial:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleGeocodingService {
  final String apiKey;

  GoogleGeocodingService({required this.apiKey});

  Future<LatLng?> geocodificar(String direccion) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json'
      '?address=${Uri.encodeQueryComponent(direccion)}'
      '&key=$apiKey',
    );

    final response = await http.get(url);
    final data = json.decode(response.body);

    if (data['status'] == 'OK' && data['results'].isNotEmpty) {
      final location = data['results'][0]['geometry']['location'];
      return LatLng(location['lat'], location['lng']);
    }
    return null;
  }

  Future<String?> reverseGeocodificar(double lat, double lng) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json'
      '?latlng=$lat,$lng'
      '&key=$apiKey',
    );

    final response = await http.get(url);
    final data = json.decode(response.body);

    if (data['status'] == 'OK' && data['results'].isNotEmpty) {
      return data['results'][0]['formatted_address'];
    }
    return null;
  }
}
```

---

## 10. Places API y Autocompletado

### 10.1 Configurar Dependencia

```yaml
dependencies:
  google_places_flutter: ^2.0.0
  # O alternativamente:
  flutter_google_places: ^0.3.0
```

### 10.2 Autocompletado de Lugares

```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';

class BuscadorLugares extends StatefulWidget {
  const BuscadorLugares({super.key});

  @override
  State<BuscadorLugares> createState() => _BuscadorLugaresState();
}

class _BuscadorLugaresState extends State<BuscadorLugares> {
  final TextEditingController _controller = TextEditingController();
  final String _apiKey = 'TU_API_KEY';
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Campo de búsqueda con autocompletado
          GooglePlaceAutoCompleteTextField(
            textEditingController: _controller,
            googleAPIKey: _apiKey,
            inputDecoration: const InputDecoration(
              hintText: 'Buscar lugar...',
              prefixIcon: Icon(Icons.search),
            ),
            debounceDuration: const Duration(milliseconds: 500),
            countries: ['es'], // Restringir a España
            isCrossBtnShown: true,
            getPlaceDetailWithLatLng: (Place place) {
              // Resultado seleccionado
              final lat = double.parse(place.lat ?? '0');
              final lng = double.parse(place.lng ?? '0');
              _moverAlugar(LatLng(lat, lng));
            },
            itemClick: (Place place) {
              _controller.text = place.description ?? '';
            },
          ),
          // Mapa
          Expanded(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(40.4168, -3.7038),
                zoom: 14.0,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
          ),
        ],
      ),
    );
  }

  void _moverAlugar(LatLng posicion) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: posicion, zoom: 16.0),
      ),
    );
  }
}
```

### 10.3 Places API Manual

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlacesService {
  final String apiKey;

  PlacesService({required this.apiKey});

  Future<List<PlaceResult>> buscarLugares({
    required String query,
    String? location,
    int? radius,
  }) async {
    var url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/textsearch/json'
      '?query=${Uri.encodeQueryComponent(query)}'
      '&key=$apiKey',
    );

    if (location != null) {
      url = url.replace(query: '${url.query}&location=$location');
    }
    if (radius != null) {
      url = url.replace(query: '${url.query}&radius=$radius');
    }

    final response = await http.get(url);
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      return (data['results'] as List)
          .map((result) => PlaceResult.fromJson(result))
          .toList();
    }
    return [];
  }

  Future<PlaceDetail?> obtenerDetalles(String placeId) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
      '?place_id=$placeId'
      '&key=$apiKey',
    );

    final response = await http.get(url);
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      return PlaceDetail.fromJson(data['result']);
    }
    return null;
  }
}

class PlaceResult {
  final String id;
  final String name;
  final String? address;
  final double lat;
  final double lng;
  final double? rating;

  PlaceResult({
    required this.id,
    required this.name,
    this.address,
    required this.lat,
    required this.lng,
    this.rating,
  });

  factory PlaceResult.fromJson(Map<String, dynamic> json) {
    return PlaceResult(
      id: json['place_id'],
      name: json['name'],
      address: json['formatted_address'],
      lat: json['geometry']['location']['lat'],
      lng: json['geometry']['location']['lng'],
      rating: json['rating']?.toDouble(),
    );
  }
}

class PlaceDetail {
  final String name;
  final String address;
  final String? phone;
  final String? website;
  final List<String> openingHours;

  PlaceDetail({
    required this.name,
    required this.address,
    this.phone,
    this.website,
    this.openingHours = const [],
  });

  factory PlaceDetail.fromJson(Map<String, dynamic> json) {
    return PlaceDetail(
      name: json['name'],
      address: json['formatted_address'] ?? '',
      phone: json['formatted_phone_number'],
      website: json['website'],
      openingHours: json['opening_hours']?['weekday_text'] ?? [],
    );
  }
}
```

---

## 11. Direcciones y Rutas

### 11.1 Usando Directions API

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class DirectionsService {
  final String apiKey;

  DirectionsService({required this.apiKey});

  Future<DirectionsResult?> obtenerRuta({
    required LatLng origen,
    required LatLng destino,
    List<LatLng>? waypoints,
    String travelMode = 'driving', // driving, walking, bicycling, transit
  }) async {
    final originStr = '${origen.latitude},${origen.longitude}';
    final destStr = '${destino.latitude},${destino.longitude}';

    var url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=$originStr'
      '&destination=$destStr'
      '&mode=$travelMode'
      '&key=$apiKey',
    );

    if (waypoints != null && waypoints.isNotEmpty) {
      final waypointsStr = waypoints
          .map((p) => '${p.latitude},${p.longitude}')
          .join('|');
      url = Uri.parse('${url.toString()}&waypoints=$waypointsStr');
    }

    final response = await http.get(url);
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      return DirectionsResult.fromJson(data);
    }
    return null;
  }
}

class DirectionsResult {
  final List<LatLng> polylinePoints;
  final String distance;
  final String duration;
  final List<RouteStep> steps;

  DirectionsResult({
    required this.polylinePoints,
    required this.distance,
    required this.duration,
    required this.steps,
  });

  factory DirectionsResult.fromJson(Map<String, dynamic> json) {
    final route = json['routes'][0];
    final leg = route['legs'][0];

    // Decodificar polyline
    final polyline = route['overview_polyline']['points'];
    final points = _decodePolyline(polyline);

    // Obtener pasos
    final steps = (leg['steps'] as List)
        .map((step) => RouteStep.fromJson(step))
        .toList();

    return DirectionsResult(
      polylinePoints: points,
      distance: leg['distance']['text'],
      duration: leg['duration']['text'],
      steps: steps,
    );
  }

  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int b;
      int shift = 0;
      int result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }
}

class RouteStep {
  final String instruction;
  final String distance;
  final String duration;
  final LatLng startLocation;
  final LatLng endLocation;

  RouteStep({
    required this.instruction,
    required this.distance,
    required this.duration,
    required this.startLocation,
    required this.endLocation,
  });

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    return RouteStep(
      instruction: json['html_instructions'],
      distance: json['distance']['text'],
      duration: json['duration']['text'],
      startLocation: LatLng(
        json['start_location']['lat'],
        json['start_location']['lng'],
      ),
      endLocation: LatLng(
        json['end_location']['lat'],
        json['end_location']['lng'],
      ),
    );
  }
}
```

### 11.2 Mostrar Ruta en el Mapa

```dart
class MapaConRuta extends StatefulWidget {
  const MapaConRuta({super.key});

  @override
  State<MapaConRuta> createState() => _MapaConRutaState();
}

class _MapaConRutaState extends State<MapaConRuta> {
  final DirectionsService _directionsService = DirectionsService(apiKey: 'TU_API_KEY');
  
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  String? _distancia;
  String? _duracion;

  Future<void> _calcularRuta(LatLng origen, LatLng destino) async {
    final result = await _directionsService.obtenerRuta(
      origen: origen,
      destino: destino,
    );

    if (result != null) {
      setState(() {
        // Dibujar polyline
        _polylines.clear();
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('ruta'),
            points: result.polylinePoints,
            color: Colors.blue,
            width: 5,
          ),
        );

        // Marcadores
        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId('origen'),
            position: origen,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          ),
        );
        _markers.add(
          Marker(
            markerId: const MarkerId('destino'),
            position: destino,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );

        _distancia = result.distance;
        _duracion = result.duration;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(40.4168, -3.7038),
                zoom: 14.0,
              ),
              polylines: _polylines,
              markers: _markers,
            ),
          ),
          if (_distancia != null && _duracion != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.route),
                      const SizedBox(width: 8),
                      Text('Distancia: $_distancia'),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time),
                      const SizedBox(width: 8),
                      Text('Tiempo: $_duracion'),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
```

---

## 12. Personalización del Mapa

### 12.1 Estilos del Mapa

```dart
// Estilo nocturno
const String _mapStyleNight = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#242f3e"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#242f3e"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#746855"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{"color": "#38414e"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#212a37"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#17263c"}]
  }
]
''';

class _MapaScreenState extends State<MapaScreen> {
  GoogleMapController? _mapController;

  Future<void> _aplicarEstiloNocturno() async {
    await _mapController?.setMapStyle(_mapStyleNight);
  }

  Future<void> _quitarEstilo() async {
    await _mapController?.setMapStyle(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: _posicionInicial,
        onMapCreated: (controller) {
          _mapController = controller;
          _aplicarEstiloNocturno();
        },
      ),
    );
  }
}
```

### 12.2 Generar Estilos Personalizados

1. Ve a [Google Maps Styling Wizard](https://mapstyle.withgoogle.com/)
2. Personaliza colores, visibilidad, etc.
3. Exporta el JSON
4. Copia el JSON en tu código

```dart
// Guardar en archivo separado: assets/map_styles.json
// Cargar en runtime:
Future<String> _cargarEstiloMapa() async {
  return await rootBundle.loadString('assets/map_styles.json');
}

// Aplicar:
final estilo = await _cargarEstiloMapa();
await _mapController?.setMapStyle(estilo);
```

### 12.3 Cambiar Tipo de Mapa

```dart
class _MapaScreenState extends State<MapaScreen> {
  MapType _mapType = MapType.normal;

  void _cambiarTipoMapa() {
    setState(() {
      switch (_mapType) {
        case MapType.normal:
          _mapType = MapType.satellite;
          break;
        case MapType.satellite:
          _mapType = MapType.terrain;
          break;
        case MapType.terrain:
          _mapType = MapType.hybrid;
          break;
        case MapType.hybrid:
          _mapType = MapType.normal;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: _mapType,
        initialCameraPosition: _posicionInicial,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _cambiarTipoMapa,
        child: const Icon(Icons.layers),
      ),
    );
  }
}
```

---

## 13. Optimización y Rendimiento

### 13.1 Gestión de Marcadores Eficiente

```dart
class OptimizedMarkerManager {
  final Map<String, Marker> _markers = {};
  final int _maxMarkers = 100;

  // Solo mostrar marcadores visibles
  void updateVisibleMarkers(LatLngBounds bounds, List<MarkerData> allMarkers) {
    final visibleMarkers = <String, Marker>{};
    
    for (final data in allMarkers) {
      if (_isInBounds(data.position, bounds)) {
        visibleMarkers[data.id] = Marker(
          markerId: MarkerId(data.id),
          position: data.position,
        );
        
        if (visibleMarkers.length >= _maxMarkers) break;
      }
    }
    
    _markers.clear();
    _markers.addAll(visibleMarkers);
  }

  bool _isInBounds(LatLng point, LatLngBounds bounds) {
    return point.latitude >= bounds.southwest.latitude &&
        point.latitude <= bounds.northeast.latitude &&
        point.longitude >= bounds.southwest.longitude &&
        point.longitude <= bounds.northeast.longitude;
  }

  Set<Marker> get markers => _markers.values.toSet();
}
```

### 13.2 Cluster de Marcadores

Para muchos marcadores, usar clustering:

```yaml
dependencies:
  google_maps_cluster_manager: ^2.0.0
```

```dart
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';

class Place with ClusterItem {
  final String id;
  final LatLng location;

  Place({required this.id, required this.location});

  @override
  LatLng get location => location;
}

class _MapaScreenState extends State<MapaScreen> {
  late ClusterManager _clusterManager;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initClusterManager();
  }

  void _initClusterManager() {
    final items = _generatePlaces(); // Lista de Place
    
    _clusterManager = ClusterManager(
      items,
      _updateMarkers,
      stopClusteringZoom: 17.0,  // Zoom donde dejar de agrupar
    );
  }

  void _updateMarkers(Set<Marker> markers) {
    setState(() {
      _markers = markers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: _posicionInicial,
      markers: _markers,
      onCameraIdle: _clusterManager.updateMap,
      onMapCreated: (controller) {
        _clusterManager.setMapId(controller.mapId);
      },
    );
  }
}
```

### 13.3 Caché de Imágenes de Marcadores

```dart
class MarcadorCache {
  static final Map<String, BitmapDescriptor> _cache = {};

  static Future<BitmapDescriptor> getIcon(String assetPath) async {
    if (_cache.containsKey(assetPath)) {
      return _cache[assetPath]!;
    }

    final icon = await _createIconFromAsset(assetPath);
    _cache[assetPath] = icon;
    return icon;
  }

  static Future<BitmapDescriptor> _createIconFromAsset(String assetPath) async {
    // ... implementación
  }
}
```

### 13.4 Lazy Loading

```dart
class LazyMapLoader {
  bool _isLoading = false;
  int _loadedPages = 0;

  Future<List<MarkerData>> loadMoreMarkers(LatLngBounds bounds, int page) async {
    if (_isLoading) return [];

    _isLoading = true;
    try {
      // Cargar desde API
      final markers = await _fetchMarkersFromApi(bounds, page);
      _loadedPages++;
      return markers;
    } finally {
      _isLoading = false;
    }
  }
}
```

---

## 14. Buenas Prácticas

### 14.1 Proteger API Keys

```dart
// ❌ INCORRECTO - API key hardcodeada
const String apiKey = 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';

// ✅ CORRECTO - Usar variables de entorno o config
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class Config {
  static String get googleMapsKey {
    return dotenv.env['GOOGLE_MAPS_KEY'] ?? '';
  }
}
```

### 14.2 Manejo de Errores

```dart
class MapErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const MapErrorWidget({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
```

### 14.3 Gestión del Ciclo de Vida

```dart
class _MapaScreenState extends State<MapaScreen> with WidgetsBindingObserver {
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Pausar actualizaciones de ubicación
    } else if (state == AppLifecycleState.resumed) {
      // Reanudar actualizaciones
    }
  }
}
```

### 14.4 Testing

```dart
// test/map_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MockGoogleMapController extends Mock implements GoogleMapController {}

void main() {
  testWidgets('Map renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(0, 0),
              zoom: 10,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(GoogleMap), findsOneWidget);
  });
}
```

---

## 15. Proyecto Práctico Completo

### App: Buscador de Restaurantes con Rutas

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

void main() {
  runApp(const RestaurantFinderApp());
}

class RestaurantFinderApp extends StatelessWidget {
  const RestaurantFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant Finder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  LatLng? _selectedDestination;
  String? _routeInfo;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Ubicación deshabilitada');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      return Future.error('Permisos denegados');
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = position;
    });

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 16,
        ),
      ),
    );

    _addCurrentLocationMarker();
  }

  void _addCurrentLocationMarker() {
    if (_currentPosition == null) return;

    _markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Mi ubicación'),
      ),
    );
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedDestination = position;
      _markers.removeWhere((m) => m.markerId.value == 'destination');
      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Destino'),
        ),
      );
    });
  }

  Future<void> _calculateRoute() async {
    if (_currentPosition == null || _selectedDestination == null) return;

    // Aquí llamarías al DirectionsService
    // Por simplicidad, mostramos una polilínea recta
    setState(() {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: [
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            _selectedDestination!,
          ],
          color: Colors.blue,
          width: 5,
        ),
      );

      final distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        _selectedDestination!.latitude,
        _selectedDestination!.longitude,
      );

      _routeInfo = 'Distancia: ${(distance / 1000).toStringAsFixed(2)} km';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Finder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(40.4168, -3.7038),
              zoom: 14,
            ),
            onMapCreated: (controller) => _mapController = controller,
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onTap: _onMapTap,
          ),
          if (_routeInfo != null)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _routeInfo!,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _selectedDestination != null
          ? FloatingActionButton.extended(
              onPressed: _calculateRoute,
              icon: const Icon(Icons.directions),
              label: const Text('Calcular ruta'),
            )
          : null,
    );
  }
}
```

---

## Recursos Adicionales

### Documentación Oficial
- [google_maps_flutter package](https://pub.dev/packages/google_maps_flutter)
- [Google Maps Platform Documentation](https://developers.google.com/maps/documentation)
- [Flutter Google Maps Codelab](https://codelabs.developers.google.com/codelabs/flutter-google-maps)

### Librerías Útiles
- [google_maps_flutter](https://pub.dev/packages/google_maps_flutter) - Widget oficial de Google Maps
- [geolocator](https://pub.dev/packages/geolocator) - Geolocalización
- [geocoding](https://pub.dev/packages/geocoding) - Geocoding
- [flutter_google_places](https://pub.dev/packages/flutter_google_places) - Places autocompletado
- [google_maps_cluster_manager](https://pub.dev/packages/google_maps_cluster_manager) - Clustering de marcadores

### Herramientas
- [Google Cloud Console](https://console.cloud.google.com/)
- [Google Maps Styling Wizard](https://mapstyle.withgoogle.com/)
- [API Key Checker](https://github.com/googlemaps/android-maps-utils)

---

## Ejercicios Propuestos

### Ejercicio 1: Mapa con Mi Ubicación
Crear una app que:
- Centre el mapa en la ubicación del usuario
- Muestre un marcador azul en la posición actual
- Permita actualizar la ubicación con un botón

### Ejercicio 2: Buscador de Lugares
Crear una app que:
- Tenga un campo de búsqueda con autocompletado
- Muestre resultados en el mapa
- Permita ver detalles del lugar seleccionado

### Ejercicio 3: Calculadora de Rutas
Crear una app que:
- Permita seleccionar origen y destino
- Calcule la ruta entre ambos puntos
- Muestre distancia y tiempo estimado
- Dibuje la polilínea en el mapa

### Ejercicio 4: App de Tracking
Crear una app que:
- Rastree la ubicación del usuario en tiempo real
- Dibuje una polilínea con el recorrido
- Calcule la distancia total recorrida
- Guarde el recorrido para verlo después

---

## Conclusión

Este módulo te ha proporcionado una base sólida para trabajar con **Google Maps en Flutter**. Los conceptos clave son:

1. **Configuración**: API Keys para Android e iOS con restricciones de seguridad
2. **Mapas interactivos**: GoogleMap widget, cámara, gestos
3. **Marcadores**: Iconos personalizados, InfoWindows, clustering
4. **Overlays**: Polilíneas, polígonos, círculos
5. **Geolocalización**: Permisos, ubicación actual, seguimiento
6. **APIs**: Geocoding, Places, Directions
7. **Optimización**: Gestión de marcadores, caché, lazy loading
8. **Buenas prácticas**: Seguridad, testing, ciclo de vida

Siguiente paso: Practica con los ejercicios y desarrolla tu propia app integrando mapas con tus necesidades específicas.

---

**Autor**: Bot-Bunnny  
**Fecha**: Junio 2026  
**Versión**: 1.0 - Flutter Edition