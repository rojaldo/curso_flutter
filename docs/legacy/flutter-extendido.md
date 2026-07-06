## Módulo 10: Publicación (3 horas)

---

### 1. Preparación para producción

#### Configurar versiones y build numbers

```yaml
# pubspec.yaml
version: 1.0.0+1
# Formato: version.major.minor.patch+buildNumber
# version: 1.2.3+45 significa versión 1.2.3 build 45
```

#### Modos de compilación

```bash
# Debug (desarrollo)
flutter run

# Profile (rendimiento)
flutter run --profile

# Release (producción)
flutter run --release
```

#### Limpiar proyecto antes de publicar

```bash
# Limpiar build anterior
flutter clean

# Obtener dependencias
flutter pub get

# Verificar análisis estático
flutter analyze

# Ejecutar tests
flutter test

# Build release
flutter build apk --release
flutter build ios --release
```

---

### 2. Firmado de apps (Signing)

#### Android

**Generar keystore:**

```bash
keytool -genkey -v -keystore mi-app-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias mi-app-alias
```

**Configurar en `android/key.properties`:**

```properties
storePassword=mi_password
keyPassword=mi_key_password
keyAlias=mi-app-alias
storeFile=../mi-app-key.jks
```

**Configurar en `android/app/build.gradle`:**

```groovy
// Al inicio del archivo
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... otras configuraciones

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

**ProGuard rules (`android/app/proguard-rules.pro`):**

```proguard
# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Plugins específicos
-keep class com.example.miapp.** { *; }
```

**Build APK/AAB:**

```bash
# APK para testing
flutter build apk --release

# App Bundle para Google Play
flutter build appbundle --release
```

#### iOS

**Configurar en Xcode:**

1. Abrir `ios/Runner.xcworkspace` en Xcode
2. Seleccionar Runner > Signing & Capabilities
3. Seleccionar Team (Apple Developer)
4. Automáticamente se gestionan los certificados

**Configurar Bundle ID:**

En `ios/Runner/Info.plist`:

```xml
<key>CFBundleIdentifier</key>
<string>com.miempresa.miapp</string>
```

**Build para iOS:**

```bash
# Build sin firmar
flutter build ios --release

# Build con firmado automático
flutter build ios --release --codesign
```

**Generar IPA para TestFlight/App Store:**

```bash
# Abrir Xcode
open ios/Runner.xcworkspace

# En Xcode: Product > Archive > Distribute App
```

---

### 3. Google Play Store

#### Requisitos

- Cuenta de Google Play Developer ($25 una vez)
- App firmada con keystore propio
- App Bundle (.aab) preferiblemente
- Contenido multimedia:
  - Icono (512x512 px)
  - Capturas de pantalla (mínimo 2, preferible 4-8)
  - Banner de feature (1024x500 px) opcional
  - Video promocional opcional

#### Preparar recursos

**Icono de la app:**

```yaml
# pubspec.yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
```

**Ejecutar:**

```bash
flutter pub run flutter_launcher_icons
```

**Capturas de pantalla:**

- Usar emulador o dispositivo real
- Resolución recomendada: 1080x1920 o superior
- Formato: PNG o JPEG
- Incluir diferentes tamaños de pantalla

#### Subir a Google Play Console

1. **Crear aplicación:**
   - Ir a Google Play Console
   - Crear nueva aplicación
   - Completar información básica

2. **Configurar contenido:**
   - Clasificación de contenido
   - Detalles de la app (descripción, screenshots)
   - Categoría y etiquetas

3. **Subir AAB:**
   - Ir a "Lanzamientos de producción"
   - Crear nuevo lanzamiento
   - Subir archivo `.aab`
   - Notas de versión

4. **Revisión:**
   - Revisar advertencias y errores
   - Resolver problemas antes de publicar

5. **Publicar:**
   - Enviar para revisión
   - Tiempo de revisión: 1-7 días

#### Configurar firmado automático

```yaml
# .github/workflows/release.yml
name: Release to Google Play

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: actions/setup-java@v3
        with:
          java-version: '11'
          distribution: 'temurin'
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Build App Bundle
        run: flutter build appbundle --release
      
      - uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_STORE_SERVICE_ACCOUNT }}
          packageName: com.miempresa.miapp
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: production
```

---

### 4. App Store (iOS)

#### Requisitos

- Cuenta Apple Developer ($99/año)
- Certificados y provisioning profiles
- IPA firmada
- Contenido multimedia:
  - App icon (1024x1024 px)
  - Screenshots (2.5x mínimo)
  - App Preview videos opcional

#### App Store Connect

1. **Crear App ID:**
   - Ir a Apple Developer Portal
   - Crear nuevo App ID
   - Habilitar capabilities necesarias

2. **Crear certificados:**
   - Certificado de distribución
   - Certificado de desarrollo (opcional)

3. **Crear provisioning profiles:**
   - App Store Distribution
   - Incluir dispositivos de desarrollo

4. **Configurar en App Store Connect:**
   - Crear nueva app
   - Completar información
   - Subir build desde Xcode

5. **Enviar a revisión:**
   - Seleccionar build
   - Completar información de revisión
   - Tiempo de revisión: 1-3 días

#### Fastlane para iOS

```ruby
# ios/fastlane/Fastfile
default_platform(:ios)

platform :ios do
  desc "Build and upload to TestFlight"
  lane :beta do
    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "Runner",
      export_method: "app-store"
    )
    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )
  end

  desc "Build and upload to App Store"
  lane :release do
    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "Runner",
      export_method: "app-store"
    )
    upload_to_app_store(
      submit_for_review: true
    )
  end
end
```

---

### 5. CI/CD con GitHub Actions

#### Workflow completo

```yaml
# .github/workflows/ci-cd.yml
name: Flutter CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Analyze code
        run: flutter analyze
      
      - name: Check formatting
        run: dart format --set-exit-if-changed .

  test:
    runs-on: ubuntu-latest
    needs: analyze
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: coverage/lcov.info

  build-android:
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      
      - uses: actions/setup-java@v3
        with:
          java-version: '11'
          distribution: 'temurin'
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Decode keystore
        env:
          ENCODED_KEYSTORE: ${{ secrets.ENCODED_KEYSTORE }}
        run: |
          echo $ENCODED_KEYSTORE | base64 -d > android/app/key.jks
      
      - name: Create key.properties
        env:
          KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
          KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
        run: |
          echo "storePassword=$KEYSTORE_PASSWORD" > android/key.properties
          echo "keyPassword=$KEY_PASSWORD" >> android/key.properties
          echo "keyAlias=$KEY_ALIAS" >> android/key.properties
          echo "storeFile=key.jks" >> android/key.properties
      
      - name: Build APK
        run: flutter build apk --release
      
      - name: Build App Bundle
        run: flutter build appbundle --release
      
      - name: Upload APK artifact
        uses: actions/upload-artifact@v3
        with:
          name: app-release.apk
          path: build/app/outputs/flutter-apk/app-release.apk
      
      - name: Upload AAB artifact
        uses: actions/upload-artifact@v3
        with:
          name: app-release.aab
          path: build/app/outputs/bundle/release/app-release.aab

  build-ios:
    runs-on: macos-latest
    needs: test
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Build iOS (no codesign)
        run: flutter build ios --release --no-codesign
      
      - name: Upload iOS artifact
        uses: actions/upload-artifact@v3
        with:
          name: ios-build
          path: build/ios/iphoneos/Runner.app
```

---

### 6. Actualizaciones y versionado

#### Versionado semántico

```
MAJOR.MINOR.PATCH+BUILD

MAJOR: Cambios incompatibles
MINOR: Nuevas funcionalidades compatibles
PATCH: Correcciones de bugs
BUILD: Número de build incremental
```

#### Actualizar versión

```yaml
# pubspec.yaml
version: 1.2.3+45
```

```dart
// Obtener versión programáticamente
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VersionService {
  static Future<String> getVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return '${packageInfo.version} (${packageInfo.buildNumber})';
  }
}
```

Dependencia en `pubspec.yaml`:

```yaml
dependencies:
  package_info_plus: ^4.0.0
```

#### Changelog

```markdown
# CHANGELOG.md

## [1.2.0] - 2024-01-15

### Added
- Nueva funcionalidad X
- Soporte para tema oscuro

### Changed
- Mejorado rendimiento de lista
- Actualizada UI de perfil

### Fixed
- Corregido crash en login
- Solucionado problema con notificaciones

### Deprecated
- Método antiguo de sincronización

## [1.1.0] - 2024-01-01
...
```

---

### 7. Monetización

#### Ads con AdMob

```yaml
dependencies:
  google_mobile_ads: ^4.0.0
```

```dart
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static const String bannerAdUnitId = 'ca-app-pub-xxx/yyy';
  static const String interstitialAdUnitId = 'ca-app-pub-xxx/yyy';
  static const String rewardedAdUnitId = 'ca-app-pub-xxx/yyy';

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => print('Banner loaded'),
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    );
    _bannerAd!.load();
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) => print('Failed to load: $error'),
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }
}
```

#### Compras dentro de la app (In-App Purchases)

```yaml
dependencies:
  in_app_purchase: ^3.1.0
```

```dart
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  static const String premiumId = 'premium_subscription';
  static const String removeAdsId = 'remove_ads';

  Future<void> initialize() async {
    final available = await _inAppPurchase.isAvailable();
    if (!available) return;

    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          // Mostrar UI de pendiente
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // Entregar producto
          _deliverProduct(purchaseDetails);
          break;
        case PurchaseStatus.error:
          // Manejar error
          _handleError(purchaseDetails.error!);
          break;
        case PurchaseStatus.canceled:
          // Usuario canceló
          break;
      }
    }
  }

  Future<void> buy(String productId) async {
    final productDetails = await _inAppPurchase.queryProductDetails({productId});
    if (productDetails.productDetails.isNotEmpty) {
      final purchaseParam = PurchaseParam(
        productDetails: productDetails.productDetails.first,
      );
      _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  Future<void> restore() async {
    await _inAppPurchase.restorePurchases();
  }

  void dispose() {
    _subscription?.cancel();
  }
}
```

---

### 8. Analytics y Crashlytics

#### Firebase Analytics

```yaml
dependencies:
  firebase_analytics: ^10.0.0
```

```dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters?.map((key, value) => MapEntry(key, value)),
    );
  }

  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  Future<void> logScreenView(String screenName, String screenClass) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  // Eventos predefinidos
  Future<void> logAddToCart(String productId, double price) async {
    await _analytics.logAddToCart(
      currency: 'EUR',
      value: price,
      items: [
        AnalyticsEventItem(
          itemId: productId,
          itemName: 'Product',
          price: price,
        ),
      ],
    );
  }

  Future<void> logPurchase(String orderId, double total) async {
    await _analytics.logPurchase(
      currency: 'EUR',
      value: total,
      transactionId: orderId,
    );
  }
}
```

#### Firebase Crashlytics

```yaml
dependencies:
  firebase_crashlytics: ^3.0.0
```

```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  
  // Pasar errores no capturados a Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  
  // Pasar errores asíncronos no capturados
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  
  runApp(const MyApp());
}

class CrashlyticsService {
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  Future<void> log(String message) async {
    await _crashlytics.log(message);
  }

  Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value);
  }

  Future<void> setUserIdentifier(String identifier) async {
    await _crashlytics.setUserIdentifier(identifier);
  }

  Future<void> recordError(dynamic error, StackTrace stack) async {
    await _crashlytics.recordError(error, stack);
  }

  // Forzar crash para testing
  Future<void> crash() async {
    await _crashlytics.crash();
  }
}
```

---

### 9. Ejercicios prácticos del Módulo 10

#### Ejercicio: Preparar app para producción

1. Configurar keystore para Android
2. Configurar Bundle ID para iOS
3. Crear íconos con flutter_launcher_icons
4. Configurar ProGuard
5. Build APK y AAB
6. Crear cuenta de Google Play
7. Subir a Google Play Console

**Checklist de pre-publicación:**

```markdown
## Pre-Publicación Checklist

### Configuración
- [ ] Versión actualizada en pubspec.yaml
- [ ] Keystore generado y configurado (Android)
- [ ] Certificados configurados (iOS)
- [ ] ProGuard configurado (Android)
- [ ] Íconos generados
- [ ] Splash screen configurado

### Código
- [ ] flutter analyze sin errores
- [ ] flutter test pasa todos los tests
- [ ] Código comentado donde es necesario
- [ ] Secrets removidos del código
- [ ] Logs de debug deshabilitados

### Contenido
- [ ] Screenshots tomados
- [ ] Descripción escrita
- [ ] Política de privacidad publicada
- [ ] Términos de servicio publicados

### Legal
- [ ] Licencias de terceros incluidas
- [ ] Permisos justificados
- [ ] Clasificación de contenido completada
```

---

**Resumen del Módulo 10:**

En este módulo aprendiste:

✅ Preparación para producción (versiones, build modes)
✅ Firmado de apps (Android keystore, iOS certificates)
✅ Google Play Store (subida, revisión, lanzamiento)
✅ App Store (certificados, provisioning, revisión)
✅ CI/CD con GitHub Actions
✅ Versionado semántico y changelog
✅ Monetización (AdMob, In-App Purchases)
✅ Analytics y Crashlytics

---

## Cierre del Temario Flutter 30h

**Resumen del curso completo:**

| Módulo | Horas | Contenido |
|--------|-------|-----------|
| 1 | 2h | Introducción, instalación, primer proyecto |
| 2 | 4h | Fundamentos de Dart |
| 3 | 4h | Widgets Básicos y Layout |
| 4 | 4h | Estado y Navegación |
| 5 | 3h | Formularios y Validación |
| 6 | 4h | HTTP y APIs REST |
| 7 | 3h | Persistencia de Datos |
| 8 | 4h | Arquitectura y Patrones |
| 9 | 3h | Testing |
| 10 | 3h | Publicación |

**Total: 30 horas**

¡Felicidades por completar el temario!## Módulo 11: Animaciones (3 horas)

---

### 1. Introducción a las Animaciones en Flutter

#### ¿Qué son las animaciones?

Las animaciones en Flutter son cambios progresivos en los valores de propiedades visuales a lo largo del tiempo. Permiten crear interfaces fluidas, proporcionar retroalimentación visual y mejorar la experiencia del usuario.

**Tipos de animaciones en Flutter:**

| Tipo | Descripción | Uso |
|------|-------------|-----|
| Implícitas | Flutter maneja todo automáticamente | Transiciones simples, cambios de estado |
| Explícitas | Control total con AnimationController | Animaciones complejas, personalizadas |
| Hero | Transiciones entre pantallas | Navegación con elementos compartidos |
| Staggered | Animaciones encadenadas en secuencia | Onboarding, listas |

**Conceptos fundamentales:**

- **Animation**: Objeto que produce valores que cambian con el tiempo
- **AnimationController**: Controla la duración, dirección y estado de la animación
- **Tween**: Interpola entre dos valores (inicio y fin)
- **Curve**: Define la curva de aceleración (lineal, ease, bounce, etc.)

---

### 2. Animaciones Implícitas

Las animaciones implícitas son la forma más sencilla de animar widgets. Flutter maneja automáticamente la transición entre el valor anterior y el nuevo.

#### AnimatedContainer

El widget más común para animaciones implícitas. Anima cambios en sus propiedades.

```dart
import 'package:flutter/material.dart';

class AnimatedContainerExample extends StatefulWidget {
  const AnimatedContainerExample({super.key});

  @override
  State<AnimatedContainerExample> createState() => _AnimatedContainerExampleState();
}

class _AnimatedContainerExampleState extends State<AnimatedContainerExample> {
  double _width = 100;
  double _height = 100;
  Color _color = Colors.blue;
  BorderRadius _borderRadius = BorderRadius.circular(8);

  void _animar() {
    setState(() {
      // Cambiar valores - Flutter animará automáticamente
      _width = _width == 100 ? 200 : 100;
      _height = _height == 100 ? 200 : 100;
      _color = _color == Colors.blue ? Colors.purple : Colors.blue;
      _borderRadius = _borderRadius == BorderRadius.circular(8)
          ? BorderRadius.circular(50)
          : BorderRadius.circular(8);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AnimatedContainer')),
      body: Center(
        child: AnimatedContainer(
          // Duración de la animación
          duration: const Duration(milliseconds: 500),
          // Curva de aceleración
          curve: Curves.easeInOut,
          // Propiedades animadas
          width: _width,
          height: _height,
          decoration: BoxDecoration(
            color: _color,
            borderRadius: _borderRadius,
          ),
          // El child también puede cambiar
          child: const Center(
            child: Text(
              '¡Animado!',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _animar,
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
```

**Propiedades animables de AnimatedContainer:**

- `width`, `height` - Dimensiones
- `color`, `decoration` - Apariencia
- `padding`, `margin` - Espaciado
- `alignment` - Alineación del hijo
- `transform` - Transformaciones matriciales

#### AnimatedOpacity

Anima la opacidad de un widget gradualmente.

```dart
class AnimatedOpacityExample extends StatefulWidget {
  const AnimatedOpacityExample({super.key});

  @override
  State<AnimatedOpacityExample> createState() => _AnimatedOpacityExampleState();
}

class _AnimatedOpacityExampleState extends State<AnimatedOpacityExample> {
  double _opacity = 1.0;

  void _toggleOpacity() {
    setState(() {
      _opacity = _opacity == 1.0 ? 0.0 : 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AnimatedOpacity')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: Container(
                width: 200,
                height: 200,
                color: Colors.blue,
                child: const Center(
                  child: Text(
                    'Desvaneciéndome',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _toggleOpacity,
              child: Text(_opacity == 1.0 ? 'Ocultar' : 'Mostrar'),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### AnimatedCrossFade

Anima la transición entre dos widgets con un efecto de fundido cruzado.

```dart
class AnimatedCrossFadeExample extends StatefulWidget {
  const AnimatedCrossFadeExample({super.key});

  @override
  State<AnimatedCrossFadeExample> createState() => _AnimatedCrossFadeExampleState();
}

class _AnimatedCrossFadeExampleState extends State<AnimatedCrossFadeExample> {
  bool _mostrarPrimero = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AnimatedCrossFade')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedCrossFade(
              // Widget que se muestra cuando crossFadeState coincide
              firstChild: Container(
                width: 200,
                height: 200,
                color: Colors.blue,
                child: const Center(
                  child: Text('Primero', style: TextStyle(color: Colors.white, fontSize: 24)),
                ),
              ),
              // Widget alternativo
              secondChild: Container(
                width: 200,
                height: 200,
                color: Colors.orange,
                child: const Center(
                  child: Text('Segundo', style: TextStyle(color: Colors.white, fontSize: 24)),
                ),
              ),
              // Estado actual
              crossFadeState: _mostrarPrimero
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              // Duración de la transición
              duration: const Duration(milliseconds: 500),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _mostrarPrimero = !_mostrarPrimero;
                });
              },
              child: const Text('Cambiar'),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### AnimatedAlign

Anima el cambio de alineación de un widget dentro de su contenedor.

```dart
class AnimatedAlignExample extends StatefulWidget {
  const AnimatedAlignExample({super.key});

  @override
  State<AnimatedAlignExample> createState() => _AnimatedAlignExampleState();
}

class _AnimatedAlignExampleState extends State<AnimatedAlignExample> {
  Alignment _alignment = Alignment.topLeft;

  void _cambiarAlineacion() {
    setState(() {
      // Ciclar entre diferentes alineaciones
      if (_alignment == Alignment.topLeft) {
        _alignment = Alignment.topRight;
      } else if (_alignment == Alignment.topRight) {
        _alignment = Alignment.bottomRight;
      } else if (_alignment == Alignment.bottomRight) {
        _alignment = Alignment.bottomLeft;
      } else {
        _alignment = Alignment.topLeft;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AnimatedAlign')),
      body: Container(
        width: double.infinity,
        height: 300,
        color: Colors.grey[200],
        child: AnimatedAlign(
          alignment: _alignment,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          child: Container(
            width: 80,
            height: 80,
            color: Colors.blue,
            child: const Center(
              child: Text('Mueve', style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _cambiarAlineacion,
        child: const Icon(Icons.swap_horiz),
      ),
    );
  }
}
```

#### AnimatedPadding

Anima cambios en el padding.

```dart
class AnimatedPaddingExample extends StatefulWidget {
  const AnimatedPaddingExample({super.key});

  @override
  State<AnimatedPaddingExample> createState() => _AnimatedPaddingExampleState();
}

class _AnimatedPaddingExampleState extends State<AnimatedPaddingExample> {
  double _padding = 16;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AnimatedPadding')),
      body: Container(
        color: Colors.grey[300],
        child: AnimatedPadding(
          padding: EdgeInsets.all(_padding),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          child: Container(
            color: Colors.blue,
            child: const Center(
              child: Text(
                'Contenido con padding dinámico',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _padding = _padding == 16 ? 50 : 16;
          });
        },
        child: const Icon(Icons.expand),
      ),
    );
  }
}
```

#### AnimatedPositioned

Anima la posición de un widget dentro de un Stack.

```dart
class AnimatedPositionedExample extends StatefulWidget {
  const AnimatedPositionedExample({super.key});

  @override
  State<AnimatedPositionedExample> createState() => _AnimatedPositionedExampleState();
}

class _AnimatedPositionedExampleState extends State<AnimatedPositionedExample> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AnimatedPositioned')),
      body: Stack(
        children: [
          AnimatedPositioned(
            top: _expandido ? 50 : 150,
            left: _expandido ? 20 : 100,
            width: _expandido ? 300 : 150,
            height: _expandido ? 200 : 100,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _expandido = !_expandido;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    'Tócame',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

#### AnimatedDefaultTextStyle

Anima cambios en el estilo de texto.

```dart
class AnimatedTextStyleExample extends StatefulWidget {
  const AnimatedTextStyleExample({super.key});

  @override
  State<AnimatedTextStyleExample> createState() => _AnimatedTextStyleExampleState();
}

class _AnimatedTextStyleExampleState extends State<AnimatedTextStyleExample> {
  bool _grande = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AnimatedDefaultTextStyle')),
      body: Center(
        child: AnimatedDefaultTextStyle(
          style: TextStyle(
            fontSize: _grande ? 48 : 24,
            fontWeight: _grande ? FontWeight.bold : FontWeight.normal,
            color: _grande ? Colors.purple : Colors.blue,
          ),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          child: const Text('Texto Animado'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _grande = !_grande;
          });
        },
        child: const Icon(Icons.text_fields),
      ),
    );
  }
}
```

---

### 3. Animaciones Explícitas

Las animaciones explícitas dan control total sobre el proceso de animación mediante `AnimationController`.

#### Conceptos fundamentales

**AnimationController**

Es el corazón de las animaciones explícitas. Controla:
- Duración de la animación
- Estado (forward, reverse, stop)
- Valor actual (de 0.0 a 1.0)
- Repeticiones y rebotes

```dart
class AnimacionBasica extends StatefulWidget {
  const AnimacionBasica({super.key});

  @override
  State<AnimacionBasica> createState() => _AnimacionBasicaState();
}

class _AnimacionBasicaState extends State<AnimacionBasica>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Crear controlador con duración
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this, // Requiere TickerProviderStateMixin
    );
  }

  @override
  void dispose() {
    // Siempre disposear el controlador
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animación Básica')),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              width: 100 + (_controller.value * 200),
              height: 100 + (_controller.value * 200),
              color: Color.lerp(Colors.blue, Colors.purple, _controller.value),
            );
          },
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'play',
            onPressed: () => _controller.forward(),
            child: const Icon(Icons.play_arrow),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            heroTag: 'reverse',
            onPressed: () => _controller.reverse(),
            child: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            heroTag: 'repeat',
            onPressed: () => _controller.repeat(),
            child: const Icon(Icons.repeat),
          ),
        ],
      ),
    );
  }
}
```

#### Tween y Curves

**Tween** interpola entre dos valores. **Curves** define cómo progresa la animación.

```dart
class TweenCurveExample extends StatefulWidget {
  const TweenCurveExample({super.key});

  @override
  State<TweenCurveExample> createState() => _TweenCurveExampleState();
}

class _TweenCurveExampleState extends State<TweenCurveExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Tween para tamaño
    _sizeAnimation = Tween<double>(begin: 50, end: 200).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    // Tween para color
    _colorAnimation = ColorTween(begin: Colors.blue, end: Colors.purple).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Tween para posición
    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(2, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.bounceOut,
      ),
    );

    // Tween para rotación
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Iniciar animación automáticamente
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tween y Curves')),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: _positionAnimation.value * 50,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: Container(
                  width: _sizeAnimation.value,
                  height: _sizeAnimation.value,
                  decoration: BoxDecoration(
                    color: _colorAnimation.value,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(5, 5),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_controller.status == AnimationStatus.completed) {
            _controller.reverse();
          } else {
            _controller.forward();
          }
        },
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
```

**Curvas disponibles en Flutter:**

```dart
// Curvas comunes
Curves.linear         // Velocidad constante
Curves.easeIn         // Empieza lento, termina rápido
Curves.easeOut        // Empieza rápido, termina lento
Curves.easeInOut      // Lento al inicio y final
Curves.bounceIn       // Rebota al entrar
Curves.bounceOut      // Rebota al salir
Curves.elasticIn      // Efecto elástico al entrar
Curves.elasticOut     // Efecto elástico al salir
Curves.fastOutSlowIn  // Aceleración suave
Curves.slowMiddle     // Lento en el medio
```

#### AnimatedBuilder

Construye widgets basándose en el valor de la animación de manera eficiente.

```dart
class AnimatedBuilderExample extends StatefulWidget {
  const AnimatedBuilderExample({super.key});

  @override
  State<AnimatedBuilderExample> createState() => _AnimatedBuilderExampleState();
}

class _AnimatedBuilderExampleState extends State<AnimatedBuilderExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AnimatedBuilder')),
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            // Este código se ejecuta en cada frame
            return Transform.rotate(
              angle: _animation.value,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.purple, Colors.pink],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    'Girando',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            );
          },
          // child se pasa al builder pero no se reconstruye
          // Útil para widgets estáticos dentro de la animación
          child: const Text('Este widget no se reconstruye'),
        ),
      ),
    );
  }
}
```

#### Múltiples Animaciones

```dart
class MultipleAnimationsExample extends StatefulWidget {
  const MultipleAnimationsExample({super.key});

  @override
  State<MultipleAnimationsExample> createState() => _MultipleAnimationsExampleState();
}

class _MultipleAnimationsExampleState extends State<MultipleAnimationsExample>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _colorController;
  late AnimationController _rotateController;

  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    // Múltiples controladores con TickerProviderStateMixin
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _colorController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _colorAnimation = ColorTween(begin: Colors.blue, end: Colors.purple).animate(
      CurvedAnimation(parent: _colorController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );

    // Animaciones automáticas
    _colorController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _colorController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Múltiples Animaciones')),
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleController, _colorController, _rotateController]),
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotateAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: _colorAnimation.value,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Animado',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'scale',
            onPressed: () {
              if (_scaleController.status == AnimationStatus.completed) {
                _scaleController.reverse();
              } else {
                _scaleController.forward();
              }
            },
            child: const Icon(Icons.zoom_out_map),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            heroTag: 'rotate',
            onPressed: () {
              _rotateController.forward().then((_) {
                _rotateController.reverse();
              });
            },
            child: const Icon(Icons.rotate_right),
          ),
        ],
      ),
    );
  }
}
```

---

### 4. Hero Animations

Las animaciones Hero crean transiciones fluidas entre pantallas cuando un elemento es compartido.

#### Hero Básico

```dart
// Pantalla 1 - Lista de elementos
class HeroListScreen extends StatelessWidget {
  const HeroListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Galería Hero')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 10,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HeroDetailScreen(
                    imageIndex: index,
                  ),
                ),
              );
            },
            child: Hero(
              // Tag único para identificar el elemento
              tag: 'image_$index',
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://picsum.photos/seed/$index/400/400',
                    ),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Pantalla 2 - Detalle del elemento
class HeroDetailScreen extends StatelessWidget {
  final int imageIndex;

  const HeroDetailScreen({
    super.key,
    required this.imageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Imagen ${imageIndex + 1}')),
      body: Center(
        child: Hero(
          // Mismo tag que en la pantalla anterior
          tag: 'image_$imageIndex',
          child: Container(
            width: double.infinity,
            height: 400,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://picsum.photos/seed/$imageIndex/800/600',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

#### Hero con Flight Shuttle

Personaliza la animación Hero con `flightShuttleBuilder`:

```dart
class HeroCustomExample extends StatelessWidget {
  const HeroCustomExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hero Custom')),
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HeroDetailCustomScreen(),
              ),
            );
          },
          child: Hero(
            tag: 'custom_hero',
            flightShuttleBuilder: (flightContext, animation, flightDirection,
                fromHeroContext, toHeroContext) {
              // Animación personalizada durante el vuelo
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: animation.value * 0.5,
                    child: Transform.scale(
                      scale: 1 + animation.value * 0.5,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Color.lerp(Colors.blue, Colors.purple, animation.value),
                          borderRadius: BorderRadius.circular(
                            animation.value * 50,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HeroDetailCustomScreen extends StatelessWidget {
  const HeroDetailCustomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle Hero Custom')),
      body: Center(
        child: Hero(
          tag: 'custom_hero',
          child: Container(
            width: 300,
            height: 300,
            decoration: const BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

### 5. Animaciones Staggered

Las animaciones staggered permiten ejecutar múltiples animaciones en secuencia con delays entre ellas.

#### Staggered Animation Básica

```dart
class StaggeredAnimationExample extends StatefulWidget {
  const StaggeredAnimationExample({super.key});

  @override
  State<StaggeredAnimationExample> createState() => _StaggeredAnimationExampleState();
}

class _StaggeredAnimationExampleState extends State<StaggeredAnimationExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  // Animaciones escalonadas
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Interval define cuándo empieza y termina cada animación
    // (0.0 - 1.0) representa el progreso total de la animación

    // Fade: 0.0 a 0.25 del tiempo total
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
      ),
    );

    // Slide: 0.25 a 0.5 del tiempo total
    _slideAnimation = Tween<double>(begin: -100, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.5, curve: Curves.easeOut),
      ),
    );

    // Scale: 0.5 a 0.75 del tiempo total
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.75, curve: Curves.elasticOut),
      ),
    );

    // Rotate: 0.75 a 1.0 del tiempo total
    _rotateAnimation = Tween<double>(begin: 0, end: 0.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 1.0, curve: Curves.easeInOut),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Staggered Animation')),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.translate(
                offset: Offset(_slideAnimation.value, 0),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotateAnimation.value,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.purple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Staggered',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_controller.status == AnimationStatus.completed) {
            _controller.reverse();
          } else {
            _controller.forward();
          }
        },
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
```

#### Staggered List Animation

Animación de entrada para elementos de una lista:

```dart
class StaggeredListExample extends StatefulWidget {
  const StaggeredListExample({super.key});

  @override
  State<StaggeredListExample> createState() => _StaggeredListExampleState();
}

class _StaggeredListExampleState extends State<StaggeredListExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<String> _items = List.generate(20, (i) => 'Elemento ${i + 1}');

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staggered List')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          return _AnimatedListItem(
            animation: _controller,
            index: index,
            child: ListTile(
              leading: CircleAvatar(
                child: Text('${index + 1}'),
              ),
              title: Text(_items[index]),
              subtitle: Text('Descripción del elemento ${index + 1}'),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _controller.reset();
          _controller.forward();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class _AnimatedListItem extends StatelessWidget {
  final Animation<double> animation;
  final int index;
  final Widget child;

  const _AnimatedListItem({
    required this.animation,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Cada elemento aparece con un delay basado en su índice
    final itemAnimation = Tween<Offset>(
      begin: const Offset(1, 0), // Empieza fuera de la pantalla (derecha)
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: Interval(
          (index * 0.05).clamp(0.0, 0.9), // Start
          ((index * 0.05) + 0.1).clamp(0.0, 1.0), // End
          curve: Curves.easeOut,
        ),
      ),
    );

    final fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: animation,
        curve: Interval(
          (index * 0.05).clamp(0.0, 0.9),
          ((index * 0.05) + 0.1).clamp(0.0, 1.0),
          curve: Curves.easeIn,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: itemAnimation,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
```

---

### 6. Animaciones Avanzadas

#### AnimatedBuilder con CustomPainter

Combina animaciones con dibujos personalizados:

```dart
class AnimatedCustomPainterExample extends StatefulWidget {
  const AnimatedCustomPainterExample({super.key});

  @override
  State<AnimatedCustomPainterExample> createState() => _AnimatedCustomPainterExampleState();
}

class _AnimatedCustomPainterExampleState extends State<AnimatedCustomPainterExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animated CustomPainter')),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: const Size(300, 300),
              painter: _CirclePulsePainter(_controller.value),
            );
          },
        ),
      ),
    );
  }
}

class _CirclePulsePainter extends CustomPainter {
  final double progress;

  _CirclePulsePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Dibujar múltiples círculos concéntricos
    for (int i = 0; i < 5; i++) {
      final animationProgress = (progress + i * 0.2) % 1.0;
      final radius = maxRadius * animationProgress;
      final opacity = 1.0 - animationProgress;

      final paint = Paint()
        ..color = Colors.blue.withOpacity(opacity * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(center, radius, paint);
    }

    // Círculo central
    final centerPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 20, centerPaint);
  }

  @override
  bool shouldRepaint(_CirclePulsePainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
```

#### Animación con Física (Spring)

```dart
class SpringAnimationExample extends StatefulWidget {
  const SpringAnimationExample({super.key});

  @override
  State<SpringAnimationExample> createState() => _SpringAnimationExampleState();
}

class _SpringAnimationExampleState extends State<SpringAnimationExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Simulación de física spring
    _animation = Tween<double>(begin: 100, end: 300).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut, // Efecto spring
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
    return Scaffold(
      appBar: AppBar(title: const Text('Spring Animation')),
      body: Center(
        child: GestureDetector(
          onTap: () {
            if (_controller.status == AnimationStatus.completed) {
              _controller.reverse();
            } else {
              _controller.forward();
            }
          },
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                width: _animation.value,
                height: _animation.value,
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(_animation.value / 4),
                ),
                child: const Center(
                  child: Text(
                    'Tócame',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
```

#### Animación de Partículas

```dart
class ParticleAnimationExample extends StatefulWidget {
  const ParticleAnimationExample({super.key});

  @override
  State<ParticleAnimationExample> createState() => _ParticleAnimationExampleState();
}

class _ParticleAnimationExampleState extends State<ParticleAnimationExample>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final int _particleCount = 50;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Crear partículas aleatorias
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(_Particle.random());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Particle Animation')),
      body: Container(
        color: Colors.black,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: _ParticlePainter(
                particles: _particles,
                progress: _controller.value,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Particle {
  double x;
  double y;
  double speed;
  double size;
  Color color;

  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.color,
  });

  factory _Particle.random() {
    return _Particle(
      x: double.parse((Random().nextDouble() * 1000).toStringAsFixed(1)),
      y: double.parse((Random().nextDouble() * 800).toStringAsFixed(1)),
      speed: 0.5 + Random().nextDouble() * 2,
      size: 2 + Random().nextDouble() * 4,
      color: [
        Colors.blue,
        Colors.purple,
        Colors.pink,
        Colors.cyan,
        Colors.amber,
      ][Random().nextInt(5)],
    );
  }

  void update(double progress) {
    y = (y + speed) % 800;
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.update(progress);

      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x % size.width, particle.y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) {
    return true;
  }
}

import 'dart:math';
```

---

### 7. Lottie y Rive

#### Lottie (animaciones vectoriales)

Lottie permite reproducir animaciones vectoriales creadas en After Effects exportadas como JSON.

```yaml
# pubspec.yaml
dependencies:
  lottie: ^2.7.0
```

```dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieExample extends StatefulWidget {
  const LottieExample({super.key});

  @override
  State<LottieExample> createState() => _LottieExampleState();
}

class _LottieExampleState extends State<LottieExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lottie Animations')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animación desde assets
          Lottie.asset(
            'assets/animations/loading.json',
            controller: _controller,
            onLoaded: (composition) {
              _controller
                ..duration = composition.duration
                ..forward();
            },
          ),

          const SizedBox(height: 20),

          // Animación desde URL
          Lottie.network(
            'https://assets2.lottiefiles.com/packages/lf20_UJNc2t.json',
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),

          const SizedBox(height: 20),

          // Controles de animación
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _controller.forward(),
                child: const Text('Play'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => _controller.stop(),
                child: const Text('Stop'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => _controller.reverse(),
                child: const Text('Reverse'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Ejemplo con eventos
class LottieInteractiveExample extends StatefulWidget {
  const LottieInteractiveExample({super.key});

  @override
  State<LottieInteractiveExample> createState() => _LottieInteractiveExampleState();
}

class _LottieInteractiveExampleState extends State<LottieInteractiveExample> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lottie Interactivo')),
      body: Center(
        child: GestureDetector(
          onTap: () {
            setState(() {
              _isPlaying = !_isPlaying;
            });
          },
          child: Lottie.network(
            'https://assets2.lottiefiles.com/packages/lf20_UJNc2t.json',
            animate: _isPlaying,
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
  }
}
```

#### Rive (animaciones interactivas)

Rive permite crear animaciones interactivas y estados visuales.

```yaml
# pubspec.yaml
dependencies:
  rive: ^0.12.4
```

```dart
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class RiveExample extends StatefulWidget {
  const RiveExample({super.key});

  @override
  State<RiveExample> createState() => _RiveExampleState();
}

class _RiveExampleState extends State<RiveExample> {
  Artboard? _artboard;
  StateMachineController? _controller;
  SMIInput<bool>? _hoverInput;
  SMIInput<bool>? _pressInput;

  @override
  void initState() {
    super.initState();
    _loadRiveFile();
  }

  void _loadRiveFile() async {
    // Cargar archivo Rive desde assets
    final data = await rootBundle.load('assets/animations/button.riv');
    final file = RiveFile.import(data);
    final artboard = file.mainArtboard;

    // Obtener el StateMachine
    var controller = StateMachineController.fromArtboard(
      artboard,
      'ButtonStateMachine',
    );

    if (controller != null) {
      artboard.addController(controller);
      _controller = controller;

      // Obtener inputs
      _hoverInput = controller.findInput<bool>('hover');
      _pressInput = controller.findInput<bool>('press');
    }

    setState(() {
      _artboard = artboard;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rive Animations')),
      body: Center(
        child: _artboard == null
            ? const CircularProgressIndicator()
            : GestureDetector(
                onHover: (isHovering) {
                  if (_hoverInput != null) {
                    _hoverInput!.value = isHovering;
                  }
                },
                onTapDown: (_) {
                  if (_pressInput != null) {
                    _pressInput!.value = true;
                  }
                },
                onTapUp: (_) {
                  if (_pressInput != null) {
                    _pressInput!.value = false;
                  }
                },
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Rive(
                    artboard: _artboard!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
      ),
    );
  }
}

// Ejemplo simple de Rive
class RiveSimpleExample extends StatelessWidget {
  const RiveSimpleExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rive Simple')),
      body: Center(
        child: SizedBox(
          width: 300,
          height: 300,
          child: RiveAnimation.network(
            'https://cdn.rive.app/animations/vehicles.riv',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
```

---

### 8. Ejercicios Prácticos

#### Ejercicio 1: Botón animado

Crea un botón que:
1. Se agrande al presionarlo
2. Cambie de color gradualmente
3. Muestre un indicador de carga mientras procesa
4. Vuelva a su estado original al terminar

```dart
class AnimatedButtonExercise extends StatefulWidget {
  const AnimatedButtonExercise({super.key});

  @override
  State<AnimatedButtonExercise> createState() => _AnimatedButtonExerciseState();
}

class _AnimatedButtonExerciseState extends State<AnimatedButtonExercise>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _colorAnimation = ColorTween(
      begin: Colors.blue,
      end: Colors.blue.shade700,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onPressed() async {
    // Animación de presión
    _controller.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _controller.reverse();

    // Simular carga
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Botón Animado')),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _colorAnimation.value,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Presioname',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
```

#### Ejercicio 2: Tarjeta flip

Crea una tarjeta que gire al presionarla mostrando información diferente en cada lado.

```dart
class FlipCardExercise extends StatefulWidget {
  const FlipCardExercise({super.key});

  @override
  State<FlipCardExercise> createState() => _FlipCardExerciseState();
}

class _FlipCardExerciseState extends State<FlipCardExercise>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _isFront = !_isFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tarjeta Flip')),
      body: Center(
        child: GestureDetector(
          onTap: _flipCard,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final angle = _animation.value * 3.14159;
              final transform = Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle);

              return Transform(
                transform: transform,
                alignment: Alignment.center,
                child: Container(
                  width: 300,
                  height: 200,
                  decoration: BoxDecoration(
                    color: _animation.value < 0.5
                        ? Colors.blue
                        : Colors.purple,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _animation.value < 0.5 ? 'Frente' : 'Reverso',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
```

#### Ejercicio 3: Splash screen animado

Crea una pantalla de bienvenida con:
1. Logo que aparece con fade
2. Logo que escala y rebota
3. Texto que aparece después del logo
4. Navegación automática a la pantalla principal

```dart
class SplashScreenExercise extends StatefulWidget {
  const SplashScreenExercise({super.key});

  @override
  State<SplashScreenExercise> createState() => _SplashScreenExerciseState();
}

class _SplashScreenExerciseState extends State<SplashScreenExercise>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    await _logoController.forward();
    await _textController.forward();
    
    // Navegar después de la animación
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animado
            AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.flutter_dash,
                        size: 80,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            // Texto animado
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _textController,
                child: const Text(
                  'Mi App Flutter',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(
        child: Text('¡Bienvenido!'),
      ),
    );
  }
}
```

---

**Resumen del Módulo 11:**

En este módulo aprendiste:

✅ Conceptos fundamentales de animaciones en Flutter
✅ Animaciones implícitas (AnimatedContainer, AnimatedOpacity, etc.)
✅ Animaciones explícitas con AnimationController
✅ Tweens y Curves para personalizar animaciones
✅ AnimatedBuilder para construir widgets animados
✅ Hero animations para transiciones entre pantallas
✅ Animaciones staggered para secuencias
✅ CustomPainter con animaciones
✅ Lottie y Rive para animaciones vectoriales
✅ Ejercicios prácticos de animaciones complejas

**Próximo módulo:** State Management Avanzado## Módulo 12: State Management Avanzado (4 horas)

---

### 1. Introducción al State Management

#### ¿Por qué necesitamos State Management?

A medida que las aplicaciones Flutter crecen, gestionar el estado se vuelve más complejo. Los problemas comunes incluyen:

- **State hoisting**: Elevar el estado a través de múltiples niveles de widgets
- **Prop drilling**: Pasar callbacks y datos a través de muchos widgets intermedios
- **Código duplicado**: Lógica de estado repetida en múltiples lugares
- **Dificultad de testing**: Lógica de estado mezclada con UI

**Tipos de estado:**

| Tipo | Ámbito | Ejemplo |
|------|--------|---------|
| Efímero (Ephemeral) | Un solo widget | Texto en un TextField, toggle activo |
| Local | Una pantalla | Formulario, filtros de búsqueda |
| Global | Toda la app | Usuario logueado, tema, carrito |
| Persistente | Sobrevive reinicios | Preferencias, datos offline |

#### Patrones de State Management

Flutter ofrece múltiples enfoques:

```
setState()          → Simple, para estado efímero local
InheritedWidget     → Base de todos los patterns, bajo nivel
Provider            → Wrapper de InheritedWidget, recomendado por Flutter
Riverpod            → Evolución de Provider, más seguro y flexible
BLoC/Cubit          → Pattern basado en Streams, escalable
GetX                → Todo en uno (estado, navegación, DI)
MobX                → Reactive programming con observables
```

---

### 2. Provider

Provider es la solución recomendada por el equipo de Flutter para la mayoría de aplicaciones.

#### Instalación

```yaml
# pubspec.yaml
dependencies:
  provider: ^6.1.1
```

#### Provider básico

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Modelo de datos
class Contador extends ChangeNotifier {
  int _valor = 0;

  int get valor => _valor;

  void incrementar() {
    _valor++;
    notifyListeners(); // Notifica a los listeners
  }

  void decrementar() {
    _valor--;
    notifyListeners();
  }

  void reiniciar() {
    _valor = 0;
    notifyListeners();
  }
}

// App principal con Provider
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => Contador(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Provider Demo',
      home: const ContadorScreen(),
    );
  }
}

class ContadorScreen extends StatelessWidget {
  const ContadorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Escucha cambios y reconstruye
    final contador = context.watch<Contador>();

    return Scaffold(
      appBar: AppBar(title: const Text('Provider Contador')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Contador:', style: TextStyle(fontSize: 20)),
            Text(
              '${contador.valor}',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () => context.read<Contador>().incrementar(),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'remove',
            onPressed: () => context.read<Contador>().decrementar(),
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'reset',
            onPressed: () => context.read<Contador>().reiniciar(),
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
```

#### Tipos de Provider

```dart
// ChangeNotifierProvider - Para modelos que usan notifyListeners
ChangeNotifierProvider(
  create: (context) => MiModelo(),
  child: MiWidget(),
)

// Provider - Para valores simples sin notificación
Provider(
  create: (context) => 'Valor simple',
  child: MiWidget(),
)

// StateNotifierProvider - Para StateNotifier (más inmutable)
StateNotifierProvider(
  create: (context) => MiStateNotifier(),
  child: MiWidget(),
)

// FutureProvider - Para valores asíncronos
FutureProvider(
  create: (context) => miFuncionAsync(),
  initialData: 'Cargando...',
  child: MiWidget(),
)

// StreamProvider - Para streams
StreamProvider(
  create: (context) => miStream(),
  initialData: null,
  child: MiWidget(),
)

// MultiProvider - Múltiples providers
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => Usuario()),
    ChangeNotifierProvider(create: (_) => Carrito()),
    Provider(create: (_) => ApiService()),
  ],
  child: MyApp(),
)
```

#### Consumer y Selector

```dart
// Consumer - Reconstruye solo el widget necesario
class ContadorConsumer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consumer Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Solo este widget se reconstruye cuando cambia el contador
            Consumer<Contador>(
              builder: (context, contador, child) {
                return Text(
                  '${contador.valor}',
                  style: const TextStyle(fontSize: 48),
                );
              },
            ),
            // Este widget NO se reconstruye
            const Text('Contador', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}

// Selector - Optimiza reconstrucciones con comparación
class ContadorSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            // Solo se reconstruye si valor es par
            Selector<Contador, bool>(
              selector: (context, contador) => contador.valor % 2 == 0,
              builder: (context, esPar, child) {
                return Text(esPar ? 'Par' : 'Impar');
              },
            ),
            // Solo se reconstruye si el valor cambia específicamente
            Selector<Contador, int>(
              selector: (context, contador) => contador.valor,
              shouldRebuild: (previous, next) => previous != next,
              builder: (context, valor, child) {
                return Text('$valor');
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

#### Ejemplo completo: Carrito de compras

```dart
// models/producto.dart
class Producto {
  final String id;
  final String nombre;
  final double precio;
  final String imagen;

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.imagen,
  });
}

// models/item_carrito.dart
class ItemCarrito {
  final Producto producto;
  int cantidad;

  ItemCarrito({
    required this.producto,
    this.cantidad = 1,
  });

  double get total => producto.precio * cantidad;
}

// providers/carrito_provider.dart
class Carrito extends ChangeNotifier {
  final List<ItemCarrito> _items = [];

  List<ItemCarrito> get items => List.unmodifiable(_items);
  
  int get cantidadTotal => _items.fold(0, (sum, item) => sum + item.cantidad);
  
  double get precioTotal => _items.fold(0, (sum, item) => sum + item.total);

  bool estaEnCarrito(Producto producto) {
    return _items.any((item) => item.producto.id == producto.id);
  }

  int cantidadProducto(Producto producto) {
    final item = _items.firstWhere(
      (item) => item.producto.id == producto.id,
      orElse: () => ItemCarrito(producto: producto, cantidad: 0),
    );
    return item.cantidad;
  }

  void agregar(Producto producto) {
    final index = _items.indexWhere((item) => item.producto.id == producto.id);
    if (index >= 0) {
      _items[index].cantidad++;
    } else {
      _items.add(ItemCarrito(producto: producto));
    }
    notifyListeners();
  }

  void remover(Producto producto) {
    final index = _items.indexWhere((item) => item.producto.id == producto.id);
    if (index >= 0) {
      if (_items[index].cantidad > 1) {
        _items[index].cantidad--;
      } else {
        _items.removeAt(index);
      }
    }
    notifyListeners();
  }

  void eliminarProducto(Producto producto) {
    _items.removeWhere((item) => item.producto.id == producto.id);
    notifyListeners();
  }

  void vaciar() {
    _items.clear();
    notifyListeners();
  }
}

// providers/catalogo_provider.dart
class Catalogo extends ChangeNotifier {
  final List<Producto> _productos = [
    Producto(id: '1', nombre: 'Laptop', precio: 999.99, imagen: 'laptop.jpg'),
    Producto(id: '2', nombre: 'Smartphone', precio: 699.99, imagen: 'phone.jpg'),
    Producto(id: '3', nombre: 'Tablet', precio: 449.99, imagen: 'tablet.jpg'),
    Producto(id: '4', nombre: 'Auriculares', precio: 149.99, imagen: 'headphones.jpg'),
    Producto(id: '5', nombre: 'Teclado', precio: 79.99, imagen: 'keyboard.jpg'),
    Producto(id: '6', nombre: 'Mouse', precio: 49.99, imagen: 'mouse.jpg'),
  ];

  List<Producto> get productos => List.unmodifiable(_productos);

  Producto porId(String id) {
    return _productos.firstWhere((p) => p.id == id);
  }
}

// main.dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Catalogo()),
        ChangeNotifierProvider(create: (_) => Carrito()),
      ],
      child: const TiendaApp(),
    ),
  );
}

class TiendaApp extends StatelessWidget {
  const TiendaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Tienda',
      routes: {
        '/': (context) => const CatalogoScreen(),
        '/carrito': (context) => const CarritoScreen(),
      },
    );
  }
}

// screens/catalogo_screen.dart
class CatalogoScreen extends StatelessWidget {
  const CatalogoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo'),
        actions: [
          // Badge con cantidad de items
          Consumer<Carrito>(
            builder: (context, carrito, child) {
              return Badge(
                label: Text('${carrito.cantidadTotal}'),
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () => Navigator.pushNamed(context, '/carrito'),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<Catalogo>(
        builder: (context, catalogo, child) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemCount: catalogo.productos.length,
            itemBuilder: (context, index) {
              final producto = catalogo.productos[index];
              return ProductoCard(producto: producto);
            },
          );
        },
      ),
    );
  }
}

// widgets/producto_card.dart
class ProductoCard extends StatelessWidget {
  final Producto producto;

  const ProductoCard({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    final carrito = context.watch<Carrito>();
    final enCarrito = carrito.estaEnCarrito(producto);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: Center(
                child: Icon(
                  Icons.image,
                  size: 50,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${producto.precio.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: enCarrito
                        ? null
                        : () => context.read<Carrito>().agregar(producto),
                    icon: Icon(enCarrito ? Icons.check : Icons.add_shopping_cart),
                    label: Text(enCarrito ? 'En carrito' : 'Agregar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// screens/carrito_screen.dart
class CarritoScreen extends StatelessWidget {
  const CarritoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Carrito')),
      body: Consumer<Carrito>(
        builder: (context, carrito, child) {
          if (carrito.items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Tu carrito está vacío', style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: carrito.items.length,
                  itemBuilder: (context, index) {
                    final item = carrito.items[index];
                    return ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image),
                      ),
                      title: Text(item.producto.nombre),
                      subtitle: Text('\$${item.producto.precio.toStringAsFixed(2)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () => context.read<Carrito>().remover(item.producto),
                          ),
                          Text('${item.cantidad}'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => context.read<Carrito>().agregar(item.producto),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => context.read<Carrito>().eliminarProducto(item.producto),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:', style: TextStyle(fontSize: 18)),
                        Text(
                          '\$${carrito.precioTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('¡Compra realizada!')),
                          );
                          context.read<Carrito>().vaciar();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Comprar'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

---

### 3. Riverpod

Riverpod es la evolución de Provider, diseñado para ser más seguro, flexible y fácil de probar.

#### Instalación

```yaml
# pubspec.yaml
dependencies:
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

dev_dependencies:
  build_runner: ^2.4.8
  riverpod_generator: ^2.3.9
```

#### Providers en Riverpod

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider básico - valor simple
final nombreProvider = Provider<String>((ref) => 'Flutter');

// StateProvider - estado mutable simple
final contadorProvider = StateProvider<int>((ref) => 0);

// StateNotifierProvider - estado mutable complejo
class ContadorNotifier extends StateNotifier<int> {
  ContadorNotifier() : super(0);

  void incrementar() => state++;
  void decrementar() => state--;
  void reiniciar() => state = 0;
}

final contadorNotifierProvider = StateNotifierProvider<ContadorNotifier, int>(
  (ref) => ContadorNotifier(),
);

// FutureProvider - datos asíncronos
final datosFutureProvider = FutureProvider<String>((ref) async {
  await Future.delayed(const Duration(seconds: 2));
  return 'Datos cargados';
});

// StreamProvider - streams
final relojProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});

// Provider combinado
final nombreCompletoProvider = Provider<String>((ref) {
  final nombre = ref.watch(nombreProvider);
  return 'Hola, $nombre!';
});

// Provider con dependencias
final apiProvider = Provider<ApiService>((ref) => ApiService());
final usuarioProvider = FutureProvider<Usuario>((ref) async {
  final api = ref.watch(apiProvider);
  return api.obtenerUsuario();
});
```

#### Consumir providers

```dart
// Usando ConsumerWidget (StatelessWidget con ref)
class ContadorWidget extends ConsumerWidget {
  const ContadorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch - escucha cambios y reconstruye
    final contador = ref.watch(contadorProvider);
    
    return Text('Contador: $contador');
  }
}

// Usando ConsumerStatefulWidget (StatefulWidget con ref)
class ContadorStatefulWidget extends ConsumerStatefulWidget {
  const ContadorStatefulWidget({super.key});

  @override
  ConsumerState<ContadorStatefulWidget> createState() => _ContadorStatefulWidgetState();
}

class _ContadorStatefulWidgetState extends ConsumerState<ContadorStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    // watch - escucha cambios
    final contador = ref.watch(contadorNotifierProvider);
    
    return Scaffold(
      body: Center(
        child: Text('Contador: $contador'),
      ),
      floatingActionButton: FloatingActionButton(
        // read - lee sin escuchar cambios (para callbacks)
        onPressed: () => ref.read(contadorNotifierProvider.notifier).incrementar(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Consumer - reconstruye solo lo necesario
class ContadorConsumer extends ConsumerWidget {
  const ContadorConsumer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            // Solo esto se reconstruye cuando contador cambia
            Consumer(
              builder: (context, ref, child) {
                final contador = ref.watch(contadorProvider);
                return Text('$contador');
              },
            ),
            // Esto nunca se reconstruye por contador
            const Text('Contador'),
          ],
        ),
      ),
    );
  }
}
```

#### Estado complejo con StateNotifier

```dart
// models/tarea.dart
class Tarea {
  final String id;
  final String titulo;
  final String descripcion;
  final bool completada;
  final DateTime fechaCreacion;

  Tarea({
    required this.id,
    required this.titulo,
    this.descripcion = '',
    this.completada = false,
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  Tarea copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    bool? completada,
    DateTime? fechaCreacion,
  }) {
    return Tarea(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      completada: completada ?? this.completada,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }
}

// providers/tareas_provider.dart
class TareasNotifier extends StateNotifier<List<Tarea>> {
  TareasNotifier() : super([]);

  void agregar(Tarea tarea) {
    state = [...state, tarea];
  }

  void eliminar(String id) {
    state = state.where((tarea) => tarea.id != id).toList();
  }

  void toggleCompletada(String id) {
    state = state.map((tarea) {
      if (tarea.id == id) {
        return tarea.copyWith(completada: !tarea.completada);
      }
      return tarea;
    }).toList();
  }

  void editar(String id, Tarea nuevaTarea) {
    state = state.map((tarea) {
      if (tarea.id == id) {
        return nuevaTarea;
      }
      return tarea;
    }).toList();
  }

  void limpiarCompletadas() {
    state = state.where((tarea) => !tarea.completada).toList();
  }
}

final tareasProvider = StateNotifierProvider<TareasNotifier, List<Tarea>>((ref) {
  return TareasNotifier();
});

// Providers derivados
final tareasPendientesProvider = Provider<List<Tarea>>((ref) {
  return ref.watch(tareasProvider).where((t) => !t.completada).toList();
});

final tareasCompletadasProvider = Provider<List<Tarea>>((ref) {
  return ref.watch(tareasProvider).where((t) => t.completada).toList();
});

final contadorTareasProvider = Provider<int>((ref) {
  return ref.watch(tareasProvider).length;
});

final contadorPendientesProvider = Provider<int>((ref) {
  return ref.watch(tareasPendientesProvider).length;
});

// screens/tareas_screen.dart
class TareasScreen extends ConsumerWidget {
  const TareasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tareas = ref.watch(tareasProvider);
    final pendientes = ref.watch(contadorPendientesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tareas ($pendientes pendientes)'),
      ),
      body: tareas.isEmpty
          ? const Center(child: Text('No hay tareas'))
          : ListView.builder(
              itemCount: tareas.length,
              itemBuilder: (context, index) {
                final tarea = tareas[index];
                return TareaTile(tarea: tarea);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoNuevaTarea(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _mostrarDialogoNuevaTarea(BuildContext context, WidgetRef ref) {
    final tituloController = TextEditingController();
    final descripcionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nueva Tarea'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(tareasProvider.notifier).agregar(
                  Tarea(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    titulo: tituloController.text,
                    descripcion: descripcionController.text,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}

// widgets/tarea_tile.dart
class TareaTile extends ConsumerWidget {
  final Tarea tarea;

  const TareaTile({super.key, required this.tarea});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Checkbox(
        value: tarea.completada,
        onChanged: (_) {
          ref.read(tareasProvider.notifier).toggleCompletada(tarea.id);
        },
      ),
      title: Text(
        tarea.titulo,
        style: TextStyle(
          decoration: tarea.completada ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: tarea.descripcion.isNotEmpty ? Text(tarea.descripcion) : null,
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          ref.read(tareasProvider.notifier).eliminar(tarea.id);
        },
      ),
    );
  }
}
```

#### Providers asíncronos y manejo de errores

```dart
// Service de API
class ApiService {
  Future<List<Producto>> obtenerProductos() async {
    await Future.delayed(const Duration(seconds: 1));
    // Simular error
    if (DateTime.now().second % 5 == 0) {
      throw Exception('Error de conexión');
    }
    return [
      Producto(id: '1', nombre: 'Producto 1', precio: 100),
      Producto(id: '2', nombre: 'Producto 2', precio: 200),
      Producto(id: '3', nombre: 'Producto 3', precio: 300),
    ];
  }
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final productosProvider = FutureProvider<List<Producto>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.obtenerProductos();
});

// Pantalla con manejo de estados
class ProductosScreen extends ConsumerWidget {
  const ProductosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productosAsync = ref.watch(productosProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Productos')),
      body: productosAsync.when(
        data: (productos) {
          if (productos.isEmpty) {
            return const Center(child: Text('No hay productos'));
          }
          return ListView.builder(
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final producto = productos[index];
              return ListTile(
                title: Text(producto.nombre),
                subtitle: Text('\$${producto.precio}'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${error.toString()}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(productosProvider),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.invalidate(productosProvider),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
```

#### Riverpod con código generado

```dart
// realm_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'realm_provider.g.dart';

// Código generado automáticamente
@riverpod
class Contador2 extends _$Contador2 {
  @override
  int build() => 0;

  void incrementar() => state++;
  void decrementar() => state--;
}

@riverpod
Future<List<Producto>> productos2(Productos2Ref ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.obtenerProductos();
}

@riverpod
List<Producto> productosFiltrados(
  ProductosFiltradosRef ref,
  String busqueda,
) {
  final productos = ref.watch(productosProvider).valueOrNull ?? [];
  return productos.where((p) => p.nombre.contains(busqueda)).toList();
}
```

---

### 4. BLoC/Cubit

BLoC (Business Logic Component) es un patrón de gestión de estado basado en Streams, muy popular en Flutter.

#### Instalación

```yaml
# pubspec.yaml
dependencies:
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
```

#### Cubit básico

Cubit es una versión simplificada de BLoC, ideal para estados simples.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Cubit
class ContadorCubit extends Cubit<int> {
  ContadorCubit() : super(0);

  void incrementar() => emit(state + 1);
  void decrementar() => emit(state - 1);
  void reiniciar() => emit(0);
}

// App
void main() {
  runApp(
    BlocProvider(
      create: (context) => ContadorCubit(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const ContadorScreen(),
    );
  }
}

class ContadorScreen extends StatelessWidget {
  const ContadorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cubit Contador')),
      body: Center(
        child: BlocBuilder<ContadorCubit, int>(
          builder: (context, state) {
            return Text(
              'Contador: $state',
              style: const TextStyle(fontSize: 48),
            );
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () => context.read<ContadorCubit>().incrementar(),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'remove',
            onPressed: () => context.read<ContadorCubit>().decrementar(),
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'reset',
            onPressed: () => context.read<ContadorCubit>().reiniciar(),
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
```

#### BLoC con eventos

BLoC usa eventos para manejar lógica más compleja.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class ContadorEvent extends Equatable {
  const ContadorEvent();

  @override
  List<Object?> get props => [];
}

class IncrementarEvent extends ContadorEvent {}

class DecrementarEvent extends ContadorEvent {}

class IncrementarPorEvent extends ContadorEvent {
  final int cantidad;
  const IncrementarPorEvent(this.cantidad);

  @override
  List<Object?> get props => [cantidad];
}

class ReiniciarEvent extends ContadorEvent {}

// States
class ContadorState extends Equatable {
  final int valor;
  final String mensaje;

  const ContadorState({
    required this.valor,
    this.mensaje = '',
  });

  ContadorState copyWith({
    int? valor,
    String? mensaje,
  }) {
    return ContadorState(
      valor: valor ?? this.valor,
      mensaje: mensaje ?? this.mensaje,
    );
  }

  @override
  List<Object?> get props => [valor, mensaje];
}

// BLoC
class ContadorBloc extends Bloc<ContadorEvent, ContadorState> {
  ContadorBloc() : super(const ContadorState(valor: 0)) {
    on<IncrementarEvent>(_onIncrementar);
    on<DecrementarEvent>(_onDecrementar);
    on<IncrementarPorEvent>(_onIncrementarPor);
    on<ReiniciarEvent>(_onReiniciar);
  }

  void _onIncrementar(IncrementarEvent event, Emitter<ContadorState> emit) {
    final nuevoValor = state.valor + 1;
    emit(state.copyWith(
      valor: nuevoValor,
      mensaje: nuevoValor % 10 == 0 ? '¡Múltiplo de 10!' : '',
    ));
  }

  void _onDecrementar(DecrementarEvent event, Emitter<ContadorState> emit) {
    final nuevoValor = state.valor - 1;
    emit(state.copyWith(
      valor: nuevoValor,
      mensaje: nuevoValor < 0 ? '¡Valor negativo!' : '',
    ));
  }

  void _onIncrementarPor(IncrementarPorEvent event, Emitter<ContadorState> emit) {
    emit(state.copyWith(valor: state.valor + event.cantidad));
  }

  void _onReiniciar(ReiniciarEvent event, Emitter<ContadorState> emit) {
    emit(const ContadorState(valor: 0));
  }
}

// UI
class ContadorBlocScreen extends StatelessWidget {
  const ContadorBlocScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BLoC Contador')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BlocBuilder<ContadorBloc, ContadorState>(
              builder: (context, state) {
                return Column(
                  children: [
                    Text(
                      'Valor: ${state.valor}',
                      style: const TextStyle(fontSize: 48),
                    ),
                    if (state.mensaje.isNotEmpty)
                      Text(
                        state.mensaje,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.blue,
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () => context.read<ContadorBloc>().add(IncrementarEvent()),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'add10',
            onPressed: () => context.read<ContadorBloc>().add(IncrementarPorEvent(10)),
            child: const Text('+10'),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'remove',
            onPressed: () => context.read<ContadorBloc>().add(DecrementarEvent()),
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
```

#### Ejemplo completo: Autenticación con BLoC

```dart
// events/auth_event.dart
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class LogoutEvent extends AuthEvent {}

class CheckAuthEvent extends AuthEvent {}

// states/auth_state.dart
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final Usuario usuario;

  const Authenticated(this.usuario);

  @override
  List<Object?> get props => [usuario];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String mensaje;

  const AuthError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}

// bloc/auth_bloc.dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc({required this.authService}) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthEvent>(_onCheckAuth);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final usuario = await authService.login(event.email, event.password);
      emit(Authenticated(usuario));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authService.logout();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onCheckAuth(CheckAuthEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final usuario = await authService.checkAuth();
      if (usuario != null) {
        emit(Authenticated(usuario));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }
}

// screens/login_screen.dart
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.mensaje)),
            );
          }
          if (state is Authenticated) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese su email';
                      }
                      if (!value.contains('@')) {
                        return 'Email inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese su contraseña';
                      }
                      if (value.length < 6) {
                        return 'Mínimo 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  if (state is AuthLoading)
                    const CircularProgressIndicator()
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                              LoginEvent(
                                email: _emailController.text,
                                password: _passwordController.text,
                              ),
                            );
                          }
                        },
                        child: const Text('Iniciar Sesión'),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
```

---

### 5. GetX

GetX es una solución "todo en uno" que incluye gestión de estado, navegación y dependencias.

#### Instalación

```yaml
# pubspec.yaml
dependencies:
  get: ^4.6.6
```

#### GetX básico

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Controller
class ContadorController extends GetxController {
  // Variable reactiva
  final _contador = 0.obs;
  int get contador => _contador.value;

  void incrementar() => _contador.value++;
  void decrementar() => _contador.value--;
  void reiniciar() => _contador.value = 0;
}

// View con GetView
class ContadorScreen extends GetView<ContadorController> {
  const ContadorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inyección automática
    // final controller = Get.put(ContadorController());

    return Scaffold(
      appBar: AppBar(title: const Text('GetX Contador')),
      body: Center(
        child: Obx(() => Text(
          '${controller.contador}',
          style: const TextStyle(fontSize: 48),
        )),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add',
            onPressed: controller.incrementar,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'remove',
            onPressed: controller.decrementar,
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
```

#### Navegación con GetX

```dart
// main.dart
void main() {
  runApp(const GetMaterialApp(
    home: HomeScreen(),
    getPages: [
      GetPage(name: '/', page: () => const HomeScreen()),
      GetPage(name: '/detalle/:id', page: () => const DetalleScreen()),
      GetPage(name: '/config', page: () => const ConfigScreen()),
    ],
  ));
}

// Navegación
class HomeController extends GetxController {
  void irADetalle(String id) {
    Get.toNamed('/detalle/$id');
  }

  void irAConfig() {
    Get.toNamed('/config');
  }

  void volver() {
    Get.back();
  }

  void volverConResultado() {
    Get.back(result: 'Datos devueltos');
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Get.toNamed('/detalle/123'),
              child: const Text('Ir a Detalle'),
            ),
            ElevatedButton(
              onPressed: () async {
                final resultado = await Get.toNamed('/config');
                print('Resultado: $resultado');
              },
              child: const Text('Ir a Config'),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### Diálogos y Snackbars

```dart
class DialogsController extends GetxController {
  void mostrarSnackbar() {
    Get.snackbar(
      'Título',
      'Mensaje de la snackbar',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      mainButton: TextButton(
        onPressed: Get.back,
        child: const Text('Cerrar'),
      ),
    );
  }

  void mostrarDialogo() {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmación'),
        content: const Text('¿Estás seguro?'),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar('Éxito', 'Acción confirmada');
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void mostrarBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Opciones', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar'),
              onTap: Get.back,
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Eliminar'),
              onTap: Get.back,
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 6. Comparativa y Mejores Prácticas

#### ¿Cuándo usar cada solución?

| Solución | Complejidad | Uso recomendado |
|----------|-------------|-----------------|
| setState | Baja | Estado efímero local, widgets simples |
| Provider | Media | Estado global simple, apps pequeñas/medianas |
| Riverpod | Media-Alta | Estado complejo, mejor testing, apps medianas/grandes |
| BLoC/Cubit | Alta | Arquitectura limpia, apps empresariales, equipos grandes |
| GetX | Baja-Media | Desarrollo rápido, apps pequeñas, proyectos con tiempo limitado |

#### Mejores prácticas

```dart
// ✅ Separar UI de lógica
// providers/usuario_provider.dart
class UsuarioNotifier extends StateNotifier<Usuario?> {
  UsuarioNotifier() : super(null);

  Future<void> login(String email, String password) async {
    // Lógica de autenticación
    final usuario = await AuthService.login(email, password);
    state = usuario;
  }

  void logout() {
    state = null;
  }
}

// screens/login_screen.dart
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Solo UI
  }
}

// ✅ Usar modelos inmutables
class Usuario {
  final String id;
  final String nombre;
  final String email;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.email,
  });

  Usuario copyWith({
    String? id,
    String? nombre,
    String? email,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
    );
  }
}

// ✅ Evitar lógica en widgets
// ❌ Mal
class MalEjemplo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<Usuario>(context);
    // Lógica de negocio en UI
    if (usuario.email.endsWith('@admin.com')) {
      return AdminScreen();
    }
    return UserScreen();
  }
}

// ✅ Bien
class BuenEjemplo extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final esAdmin = ref.watch(esAdminProvider);
    if (esAdmin) {
      return const AdminScreen();
    }
    return const UserScreen();
  }
}

// ✅ Providers derivados
final esAdminProvider = Provider<bool>((ref) {
  final usuario = ref.watch(usuarioProvider);
  return usuario?.email.endsWith('@admin.com') ?? false;
});

// ✅ Testing friendly
// providers/providers.dart
final usuarioProvider = StateNotifierProvider<UsuarioNotifier, Usuario?>((ref) {
  return UsuarioNotifier();
});

// tests/usuario_test.dart
void main() {
  test('login actualiza el estado', () async {
    final container = ProviderContainer();
    final notifier = container.read(usuarioProvider.notifier);

    await notifier.login('test@test.com', 'password');

    expect(container.read(usuarioProvider), isNotNull);
  });
}
```

---

### 7. Ejercicios Prácticos

#### Ejercicio 1: App de Tareas con Provider

Crear una app de gestión de tareas que:
- Agregue, edite y elimine tareas
- Marque tareas como completadas
- Filtre por estado (todas, pendientes, completadas)
- Persista datos localmente

#### Ejercicio 2: App de Clima con Riverpod

Crear una app de clima que:
- Busque ciudades
- Muestre el clima actual
- Maneje estados de carga y error
- Caché los resultados

#### Ejercicio 3: App de Autenticación con BLoC

Crear un flujo de autenticación que:
- Login con email/password
- Registro de usuarios
- Logout
- Mantenga la sesión

---

**Resumen del Módulo 12:**

En este módulo aprendiste:

✅ Conceptos de State Management y sus tipos
✅ Provider para estado global simple
✅ Riverpod para estado más seguro y testeable
✅ BLoC/Cubit para arquitectura escalable
✅ GetX para desarrollo rápido
✅ Comparativa y cuándo usar cada solución
✅ Mejores prácticas de State Management

**Próximo módulo:** Bases de Datos Locales## Módulo 13: Bases de Datos Locales (3 horas)

---

### 1. Introducción a la Persistencia Local

#### ¿Por qué bases de datos locales?

Las aplicaciones móviles necesitan almacenar datos localmente por varias razones:

- **Offline-first**: Funcionar sin conexión
- **Rendimiento**: Acceso rápido a datos cacheados
- **Privacidad**: Datos sensibles no salen del dispositivo
- **Eficiencia**: Reducir llamadas a APIs

#### Opciones en Flutter

| Solución | Tipo | Uso recomendado | Complejidad |
|----------|------|-----------------|-------------|
| SharedPreferences | Key-Value | Configuraciones, preferencias | Baja |
| Hive | NoSQL Key-Value | Datos simples, cache | Baja |
| Drift (SQLite) | Relacional | Datos complejos, relaciones | Media-Alta |
| ObjectBox | NoSQL Objects | Alto rendimiento, consultas complejas | Media |
| Isar | NoSQL | Alto rendimiento, full-text search | Media |

---

### 2. SharedPreferences

SharedPreferences es la opción más simple para almacenar datos clave-valor.

#### Instalación

```yaml
# pubspec.yaml
dependencies:
  shared_preferences: ^2.2.2
```

#### Uso básico

```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Servicio de preferencias
class PreferenciasService {
  static const String _keyTema = 'tema';
  static const String _keyIdioma = 'idioma';
  static const String _keyNotificaciones = 'notificaciones';
  static const String _keyUsuarioId = 'usuario_id';
  static const String _keyUsuarioNombre = 'usuario_nombre';
  static const String _keyPrimeraVez = 'primera_vez';

  // Guardar valores
  Future<void> guardarTema(String tema) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTema, tema);
  }

  Future<void> guardarIdioma(String idioma) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyIdioma, idioma);
  }

  Future<void> guardarNotificaciones(bool activo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificaciones, activo);
  }

  Future<void> guardarUsuario(String id, String nombre) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsuarioId, id);
    await prefs.setString(_keyUsuarioNombre, nombre);
  }

  Future<void> marcarPrimeraVez() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPrimeraVez, false);
  }

  // Leer valores
  Future<String?> obtenerTema() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyTema);
  }

  Future<String?> obtenerIdioma() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyIdioma);
  }

  Future<bool> obtenerNotificaciones() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotificaciones) ?? true;
  }

  Future<String?> obtenerUsuarioId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsuarioId);
  }

  Future<String?> obtenerUsuarioNombre() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsuarioNombre);
  }

  Future<bool> esPrimeraVez() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPrimeraVez) ?? true;
  }

  // Eliminar valores
  Future<void> eliminarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsuarioId);
    await prefs.remove(_keyUsuarioNombre);
  }

  Future<void> limpiarTodo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

// Pantalla de configuración
class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  final _preferencias = PreferenciasService();
  String _tema = 'sistema';
  String _idioma = 'es';
  bool _notificaciones = true;

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  Future<void> _cargarPreferencias() async {
    final tema = await _preferencias.obtenerTema() ?? 'sistema';
    final idioma = await _preferencias.obtenerIdioma() ?? 'es';
    final notificaciones = await _preferencias.obtenerNotificaciones();

    setState(() {
      _tema = tema;
      _idioma = idioma;
      _notificaciones = notificaciones;
    });
  }

  Future<void> _guardarTema(String tema) async {
    await _preferencias.guardarTema(tema);
    setState(() => _tema = tema);
  }

  Future<void> _guardarIdioma(String idioma) async {
    await _preferencias.guardarIdioma(idioma);
    setState(() => _idioma = idioma);
  }

  Future<void> _guardarNotificaciones(bool valor) async {
    await _preferencias.guardarNotificaciones(valor);
    setState(() => _notificaciones = valor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        children: [
          // Tema
          ListTile(
            title: const Text('Tema'),
            subtitle: Text(_tema == 'sistema'
                ? 'Sistema'
                : _tema == 'oscuro'
                    ? 'Oscuro'
                    : 'Claro'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _mostrarDialogoTema(),
          ),

          // Idioma
          ListTile(
            title: const Text('Idioma'),
            subtitle: Text(_idioma == 'es' ? 'Español' : 'English'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _mostrarDialogoIdioma(),
          ),

          // Notificaciones
          SwitchListTile(
            title: const Text('Notificaciones'),
            subtitle: const Text('Recibir notificaciones push'),
            value: _notificaciones,
            onChanged: _guardarNotificaciones,
          ),

          const Divider(),

          // Limpiar datos
          ListTile(
            title: const Text('Limpiar datos', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Eliminar todas las preferencias'),
            onTap: () => _confirmarLimpiar(),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoTema() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seleccionar tema'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Sistema'),
                value: 'sistema',
                groupValue: _tema,
                onChanged: (valor) {
                  Navigator.pop(context);
                  _guardarTema(valor!);
                },
              ),
              RadioListTile<String>(
                title: const Text('Claro'),
                value: 'claro',
                groupValue: _tema,
                onChanged: (valor) {
                  Navigator.pop(context);
                  _guardarTema(valor!);
                },
              ),
              RadioListTile<String>(
                title: const Text('Oscuro'),
                value: 'oscuro',
                groupValue: _tema,
                onChanged: (valor) {
                  Navigator.pop(context);
                  _guardarTema(valor!);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarDialogoIdioma() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seleccionar idioma'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Español'),
                value: 'es',
                groupValue: _idioma,
                onChanged: (valor) {
                  Navigator.pop(context);
                  _guardarIdioma(valor!);
                },
              ),
              RadioListTile<String>(
                title: const Text('English'),
                value: 'en',
                groupValue: _idioma,
                onChanged: (valor) {
                  Navigator.pop(context);
                  _guardarIdioma(valor!);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmarLimpiar() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('¿Limpiar datos?'),
          content: const Text('Se eliminarán todas las preferencias guardadas.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _preferencias.limpiarTodo();
                Navigator.pop(context);
                _cargarPreferencias();
              },
              child: const Text('Limpiar'),
            ),
          ],
        );
      },
    );
  }
}
```

---

### 3. Hive

Hive es una base de datos NoSQL key-value, rápida y sin dependencias nativas.

#### Instalación

```yaml
# pubspec.yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.1

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.8
```

#### Inicialización

```dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Hive
  await Hive.initFlutter();
  
  // Registrar adaptadores
  Hive.registerAdapter(TareaAdapter());
  Hive.registerAdapter(UsuarioAdapter());
  
  // Abrir boxes
  await Hive.openBox<Tarea>('tareas');
  await Hive.openBox<Usuario>('usuarios');
  await Hive.openBox('configuracion');
  
  runApp(const MyApp());
}
```

#### Modelos con Hive

```dart
import 'package:hive/hive.dart';

part 'tarea.g.dart';

@HiveType(typeId: 0)
class Tarea extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String titulo;

  @HiveField(2)
  String descripcion;

  @HiveField(3)
  bool completada;

  @HiveField(4)
  DateTime fechaCreacion;

  @HiveField(5)
  DateTime? fechaCompletado;

  @HiveField(6)
  int prioridad; // 0=baja, 1=media, 2=alta

  @HiveField(7)
  List<String> etiquetas;

  Tarea({
    required this.id,
    required this.titulo,
    this.descripcion = '',
    this.completada = false,
    DateTime? fechaCreacion,
    this.fechaCompletado,
    this.prioridad = 1,
    List<String>? etiquetas,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now(),
       etiquetas = etiquetas ?? [];

  Tarea copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    bool? completada,
    DateTime? fechaCreacion,
    DateTime? fechaCompletado,
    int? prioridad,
    List<String>? etiquetas,
  }) {
    return Tarea(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      completada: completada ?? this.completada,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaCompletado: fechaCompletado ?? this.fechaCompletado,
      prioridad: prioridad ?? this.prioridad,
      etiquetas: etiquetas ?? List.from(this.etiquetas),
    );
  }

  // Método para marcar como completada
  void toggleCompletada() {
    completada = !completada;
    fechaCompletado = completada ? DateTime.now() : null;
    save(); // HiveObject tiene método save()
  }
}

// Generar código con: flutter packages pub run build_runner build
```

#### Servicio de tareas con Hive

```dart
import 'package:hive/hive.dart';

class TareasService {
  static const String _boxName = 'tareas';
  Box<Tarea>? _box;

  // Inicializar box
  Future<void> init() async {
    _box = await Hive.openBox<Tarea>(_boxName);
  }

  // Crear tarea
  Future<Tarea> crear(Tarea tarea) async {
    await _box!.put(tarea.id, tarea);
    return tarea;
  }

  // Leer todas las tareas
  List<Tarea> obtenerTodas() {
    return _box!.values.toList();
  }

  // Leer tarea por ID
  Tarea? obtenerPorId(String id) {
    return _box!.get(id);
  }

  // Actualizar tarea
  Future<void> actualizar(Tarea tarea) async {
    await _box!.put(tarea.id, tarea);
  }

  // Eliminar tarea
  Future<void> eliminar(String id) async {
    await _box!.delete(id);
  }

  // Filtrar tareas
  List<Tarea> obtenerPendientes() {
    return _box!.values.where((t) => !t.completada).toList();
  }

  List<Tarea> obtenerCompletadas() {
    return _box!.values.where((t) => t.completada).toList();
  }

  List<Tarea> obtenerPorPrioridad(int prioridad) {
    return _box!.values.where((t) => t.prioridad == prioridad).toList();
  }

  List<Tarea> obtenerPorEtiqueta(String etiqueta) {
    return _box!.values.where((t) => t.etiquetas.contains(etiqueta)).toList();
  }

  // Buscar tareas
  List<Tarea> buscar(String query) {
    final lowerQuery = query.toLowerCase();
    return _box!.values.where((t) {
      return t.titulo.toLowerCase().contains(lowerQuery) ||
          t.descripcion.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Estadísticas
  Map<String, int> obtenerEstadisticas() {
    final todas = _box!.values.toList();
    return {
      'total': todas.length,
      'completadas': todas.where((t) => t.completada).length,
      'pendientes': todas.where((t) => !t.completada).length,
      'alta': todas.where((t) => t.prioridad == 2).length,
      'media': todas.where((t) => t.prioridad == 1).length,
      'baja': todas.where((t) => t.prioridad == 0).length,
    };
  }

  // Limpiar todas las tareas
  Future<void> limpiar() async {
    await _box!.clear();
  }
}
```

#### Provider con Hive

```dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TareasProvider extends ChangeNotifier {
  final TareasService _service = TareasService();
  List<Tarea> _tareas = [];
  String _filtro = 'todas'; // 'todas', 'pendientes', 'completadas'

  List<Tarea> get tareas {
    switch (_filtro) {
      case 'pendientes':
        return _tareas.where((t) => !t.completada).toList();
      case 'completadas':
        return _tareas.where((t) => t.completada).toList();
      default:
        return _tareas;
    }
  }

  String get filtro => _filtro;

  Future<void> init() async {
    await _service.init();
    _cargarTareas();
  }

  void _cargarTareas() {
    _tareas = _service.obtenerTodas();
    notifyListeners();
  }

  Future<void> agregar(Tarea tarea) async {
    await _service.crear(tarea);
    _cargarTareas();
  }

  Future<void> actualizar(Tarea tarea) async {
    await _service.actualizar(tarea);
    _cargarTareas();
  }

  Future<void> eliminar(String id) async {
    await _service.eliminar(id);
    _cargarTareas();
  }

  Future<void> toggleCompletada(String id) async {
    final tarea = _service.obtenerPorId(id);
    if (tarea != null) {
      final actualizada = tarea.copyWith(completada: !tarea.completada);
      await _service.actualizar(actualizada);
      _cargarTareas();
    }
  }

  void setFiltro(String nuevoFiltro) {
    _filtro = nuevoFiltro;
    notifyListeners();
  }

  List<Tarea> buscar(String query) {
    return _service.buscar(query);
  }
}
```

#### Pantalla de tareas con Hive

```dart
class TareasHiveScreen extends StatefulWidget {
  const TareasHiveScreen({super.key});

  @override
  State<TareasHiveScreen> createState() => _TareasHiveScreenState();
}

class _TareasHiveScreenState extends State<TareasHiveScreen> {
  final TareasProvider _provider = TareasProvider();
  final TextEditingController _buscarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _provider.init().then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _buscarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _provider,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Tareas Hive'),
            actions: [
              PopupMenuButton<String>(
                onSelected: (valor) {
                  _provider.setFiltro(valor);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'todas', child: Text('Todas')),
                  const PopupMenuItem(value: 'pendientes', child: Text('Pendientes')),
                  const PopupMenuItem(value: 'completadas', child: Text('Completadas')),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // Barra de búsqueda
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _buscarController,
                  decoration: InputDecoration(
                    hintText: 'Buscar tareas...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (query) {
                    setState(() {});
                  },
                ),
              ),

              // Lista de tareas
              Expanded(
                child: _provider.tareas.isEmpty
                    ? const Center(child: Text('No hay tareas'))
                    : ListView.builder(
                        itemCount: _provider.tareas.length,
                        itemBuilder: (context, index) {
                          final tarea = _provider.tareas[index];
                          return TareaHiveTile(
                            tarea: tarea,
                            onToggle: () => _provider.toggleCompletada(tarea.id),
                            onDelete: () => _eliminarTarea(tarea.id),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _mostrarDialogoNuevaTarea(),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _mostrarDialogoNuevaTarea() {
    final tituloController = TextEditingController();
    final descripcionController = TextEditingController();
    int prioridad = 1;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nueva Tarea'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: tituloController,
                    decoration: const InputDecoration(labelText: 'Título'),
                  ),
                  TextField(
                    controller: descripcionController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Prioridad: '),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Baja'),
                        selected: prioridad == 0,
                        onSelected: (selected) => setState(() => prioridad = 0),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Media'),
                        selected: prioridad == 1,
                        onSelected: (selected) => setState(() => prioridad = 1),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Alta'),
                        selected: prioridad == 2,
                        onSelected: (selected) => setState(() => prioridad = 2),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (tituloController.text.isNotEmpty) {
                      _provider.agregar(Tarea(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        titulo: tituloController.text,
                        descripcion: descripcionController.text,
                        prioridad: prioridad,
                      ));
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _eliminarTarea(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('¿Eliminar tarea?'),
          content: const Text('Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                _provider.eliminar(id);
                Navigator.pop(context);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}

class TareaHiveTile extends StatelessWidget {
  final Tarea tarea;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TareaHiveTile({
    super.key,
    required this.tarea,
    required this.onToggle,
    required this.onDelete,
  });

  Color _getColorPrioridad() {
    switch (tarea.prioridad) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: tarea.completada,
        onChanged: (_) => onToggle(),
      ),
      title: Text(
        tarea.titulo,
        style: TextStyle(
          decoration: tarea.completada ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: tarea.descripcion.isNotEmpty ? Text(tarea.descripcion) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getColorPrioridad(),
              shape: BoxShape.circle,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
```

---

### 4. Drift (SQLite)

Drift es un wrapper de SQLite con soporte para consultas reactivas y relaciones.

#### Instalación

```yaml
# pubspec.yaml
dependencies:
  drift: ^2.14.0
  drift_flutter: ^0.1.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.1
  path: ^1.8.3

dev_dependencies:
  drift_dev: ^2.14.0
  build_runner: ^2.4.8
```

#### Definición de tablas

```dart
// database/tables.dart
import 'package:drift/drift.dart';

// Tabla de usuarios
class Usuarios extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text().withLength(min: 1, max: 100)();
  TextColumn get email => text().unique()();
  TextColumn get passwordHash => text()();
  DateTimeColumn get fechaCreacion => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
}

// Tabla de proyectos
class Proyectos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text().withLength(min: 1, max: 200)();
  TextColumn get descripcion => text().nullable()();
  IntColumn get creadorId => integer().references(Usuarios, #id)();
  DateTimeColumn get fechaCreacion => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get fechaActualizacion => dateTime().nullable()();
}

// Tabla de tareas
class TareasDB extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get titulo => text().withLength(min: 1, max: 200)();
  TextColumn get descripcion => text().nullable()();
  IntColumn get proyectoId => integer().references(Proyectos, #id)();
  IntColumn get asignadoA => integer().nullable().references(Usuarios, #id)();
  IntColumn get prioridad => integer().withDefault(const Constant(1))(); // 0=baja, 1=media, 2=alta
  IntColumn get estado => integer().withDefault(const Constant(0))(); // 0=pendiente, 1=en_progreso, 2=completada
  DateTimeColumn get fechaLimite => dateTime().nullable()();
  DateTimeColumn get fechaCreacion => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get fechaCompletado => dateTime().nullable()();
}

// Tabla de comentarios
class Comentarios extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tareaId => integer().references(TareasDB, #id)();
  IntColumn get usuarioId => integer().references(Usuarios, #id)();
  TextColumn get contenido => text()();
  DateTimeColumn get fechaCreacion => dateTime().withDefault(currentDateAndTime)();
}
```

#### Base de datos

```dart
// database/database.dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Usuarios, Proyectos, TareasDB, Comentarios])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Migraciones futuras
        // if (from < 2) {
        //   await m.addColumn(tareas, tareas.nuevaColumna);
        // }
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'mi_app_database');
  }
}
```

#### DAOs (Data Access Objects)

```dart
// database/daos/usuarios_dao.dart
part of '../database.dart';

@DriftAccessor(tables: [Usuarios])
class UsuariosDao extends DatabaseAccessor<AppDatabase> with _$UsuariosDaoMixin {
  UsuariosDao(AppDatabase db) : super(db);

  // Obtener todos los usuarios
  Future<List<Usuario>> obtenerTodos() => select(usuarios).get();

  // Obtener usuario por ID
  Future<Usuario?> obtenerPorId(int id) {
    return (select(usuarios)..where((u) => u.id.equals(id))).getSingleOrNull();
  }

  // Obtener usuario por email
  Future<Usuario?> obtenerPorEmail(String email) {
    return (select(usuarios)..where((u) => u.email.equals(email))).getSingleOrNull();
  }

  // Crear usuario
  Future<int> crear(UsuariosCompanion usuario) {
    return into(usuarios).insert(usuario);
  }

  // Actualizar usuario
  Future<int> actualizar(UsuariosCompanion usuario) {
    return (update(usuarios)..where((u) => u.id.equals(usuario.id.value))).write(usuario);
  }

  // Eliminar usuario
  Future<int> eliminar(int id) {
    return (delete(usuarios)..where((u) => u.id.equals(id))).go();
  }

  // Observar usuario (reactivo)
  Stream<Usuario?> observarPorId(int id) {
    return (select(usuarios)..where((u) => u.id.equals(id))).watchSingleOrNull();
  }

  // Observar todos (reactivo)
  Stream<List<Usuario>> observarTodos() {
    return select(usuarios).watch();
  }
}
```

```dart
// database/daos/tareas_dao.dart
part of '../database.dart';

@DriftAccessor(tables: [TareasDB, Proyectos, Usuarios])
class TareasDao extends DatabaseAccessor<AppDatabase> with _$TareasDaoMixin {
  TareasDao(AppDatabase db) : super(db);

  // Obtener todas las tareas con información relacionada
  Future<List<TareaConRelaciones>> obtenerTodasConRelaciones() {
    final query = select(tareasDB).join([
      leftOuterJoin(proyectos, proyectos.id.equalsExp(tareasDB.proyectoId)),
      leftOuterJoin(usuarios, usuarios.id.equalsExp(tareasDB.asignadoA)),
    ]);

    return query.map((row) {
      final tarea = row.readTable(tareasDB);
      final proyecto = row.readTable(proyectos);
      final usuario = row.readTableOrNull(usuarios);
      return TareaConRelaciones(
        tarea: tarea,
        proyecto: proyecto,
        asignadoA: usuario,
      );
    }).get();
  }

  // Obtener tareas por proyecto
  Future<List<TareaDB>> obtenerPorProyecto(int proyectoId) {
    return (select(tareasDB)..where((t) => t.proyectoId.equals(proyectoId))).get();
  }

  // Obtener tareas por usuario asignado
  Future<List<TareaDB>> obtenerPorUsuario(int usuarioId) {
    return (select(tareasDB)..where((t) => t.asignadoA.equals(usuarioId))).get();
  }

  // Obtener tareas pendientes
  Future<List<TareaDB>> obtenerPendientes() {
    return (select(tareasDB)..where((t) => t.estado.equals(0))).get();
  }

  // Obtener tareas por prioridad
  Future<List<TareaDB>> obtenerPorPrioridad(int prioridad) {
    return (select(tareasDB)..where((t) => t.prioridad.equals(prioridad)))
        .orderBy([(t) => OrderingTerm.desc(t.fechaLimite)])
        .get();
  }

  // Buscar tareas
  Future<List<TareaDB>> buscar(String query) {
    final lowerQuery = '%${query.toLowerCase()}%';
    return (select(tareasDB)
          ..where((t) =>
              t.titulo.like(lowerQuery) | t.descripcion.like(lowerQuery)))
          ..orderBy([(t) => OrderingTerm.desc(t.fechaCreacion)]))
        .get();
  }

  // Crear tarea
  Future<int> crear(TareasDBCompanion tarea) {
    return into(tareasDB).insert(tarea);
  }

  // Actualizar tarea
  Future<int> actualizar(TareasDBCompanion tarea) {
    return (update(tareasDB)..where((t) => t.id.equals(tarea.id.value))).write(tarea);
  }

  // Marcar como completada
  Future<int> marcarCompletada(int id) {
    return (update(tareasDB)..where((t) => t.id.equals(id))).write(
      TareasDBCompanion(
        estado: Value(2),
        fechaCompletado: Value(DateTime.now()),
      ),
    );
  }

  // Eliminar tarea
  Future<int> eliminar(int id) {
    return (delete(tareasDB)..where((t) => t.id.equals(id))).go();
  }

  // Observar tareas (reactivo)
  Stream<List<TareaDB>> observarTodas() {
    return (select(tareasDB)..orderBy([(t) => OrderingTerm.desc(t.fechaCreacion)]))
        .watch();
  }

  Stream<List<TareaDB>> observarPorProyecto(int proyectoId) {
    return (select(tareasDB)..where((t) => t.proyectoId.equals(proyectoId)))
        .watch();
  }

  // Estadísticas
  Future<Map<String, int>> obtenerEstadisticas(int proyectoId) async {
    final todas = await (select(tareasDB)..where((t) => t.proyectoId.equals(proyectoId))).get();
    return {
      'total': todas.length,
      'pendientes': todas.where((t) => t.estado == 0).length,
      'en_progreso': todas.where((t) => t.estado == 1).length,
      'completadas': todas.where((t) => t.estado == 2).length,
    };
  }
}

// Clase para resultados con joins
class TareaConRelaciones {
  final TareaDB tarea;
  final Proyecto proyecto;
  final Usuario? asignadoA;

  TareaConRelaciones({
    required this.tarea,
    required this.proyecto,
    this.asignadoA,
  });
}
```

#### Integrar DAOs en la base de datos

```dart
// database/database.dart
@DriftDatabase(
  tables: [Usuarios, Proyectos, TareasDB, Comentarios],
  daos: [UsuariosDao, TareasDao, ProyectosDao, ComentariosDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ... código anterior
}
```

#### Provider con Drift

```dart
// providers/database_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final tareasDaoProvider = Provider<TareasDao>((ref) {
  return ref.watch(databaseProvider).tareasDao;
});

final usuariosDaoProvider = Provider<UsuariosDao>((ref) {
  return ref.watch(databaseProvider).usuariosDao;
});

// Provider reactivo de tareas
final tareasProvider = StreamProvider<List<TareaDB>>((ref) {
  final dao = ref.watch(tareasDaoProvider);
  return dao.observarTodas();
});

// Provider de tareas por proyecto
final tareasPorProyectoProvider = StreamProvider.family<List<TareaDB>, int>((ref, proyectoId) {
  final dao = ref.watch(tareasDaoProvider);
  return dao.observarPorProyecto(proyectoId);
});
```

---

### 5. ObjectBox

ObjectBox es una base de datos NoSQL de alto rendimiento con soporte para relaciones.

#### Instalación

```yaml
# pubspec.yaml
dependencies:
  objectbox: ^2.4.0
  objectbox_flutter_libs: any
  path_provider: ^2.1.1
  path: ^1.8.3

dev_dependencies:
  build_runner: ^2.4.8
  objectbox_generator: ^2.4.0
```

#### Modelos con ObjectBox

```dart
// models/usuario.dart
import 'package:objectbox/objectbox.dart';

@Entity()
class UsuarioOB {
  @Id()
  int id = 0;

  String nombre;
  String email;
  String passwordHash;
  DateTime fechaCreacion;
  bool activo;

  @Backlink('creador')
  final proyectos = ToMany<ProyectoOB>();

  @Backlink('asignadoA')
  final tareas = ToMany<TareaOB>();

  UsuarioOB({
    this.id = 0,
    required this.nombre,
    required this.email,
    required this.passwordHash,
    DateTime? fechaCreacion,
    this.activo = true,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();
}

// models/proyecto.dart
@Entity()
class ProyectoOB {
  @Id()
  int id = 0;

  String nombre;
  String? descripcion;
  DateTime fechaCreacion;
  DateTime? fechaActualizacion;

  final creador = ToOne<UsuarioOB>();
  final tareas = ToMany<TareaOB>();

  ProyectoOB({
    this.id = 0,
    required this.nombre,
    this.descripcion,
    DateTime? fechaCreacion,
    this.fechaActualizacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();
}

// models/tarea.dart
@Entity()
class TareaOB {
  @Id()
  int id = 0;

  String titulo;
  String? descripcion;
  int prioridad; // 0=baja, 1=media, 2=alta
  int estado; // 0=pendiente, 1=en_progreso, 2=completada
  DateTime fechaCreacion;
  DateTime? fechaLimite;
  DateTime? fechaCompletado;

  final proyecto = ToOne<ProyectoOB>();
  final asignadoA = ToOne<UsuarioOB>();
  final comentarios = ToMany<ComentarioOB>();

  TareaOB({
    this.id = 0,
    required this.titulo,
    this.descripcion,
    this.prioridad = 1,
    this.estado = 0,
    DateTime? fechaCreacion,
    this.fechaLimite,
    this.fechaCompletado,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();
}

@Entity()
class ComentarioOB {
  @Id()
  int id = 0;

  String contenido;
  DateTime fechaCreacion;

  final tarea = ToOne<TareaOB>();
  final usuario = ToOne<UsuarioOB>();

  ComentarioOB({
    this.id = 0,
    required this.contenido,
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();
}
```

---

### 6. Comparativa de rendimiento

```
| Operación | SharedPreferences | Hive | Drift (SQLite) | ObjectBox |
|-----------|------------------|------|----------------|-----------|
| Lectura simple | ~0.5ms | ~0.1ms | ~1ms | ~0.2ms |
| Escritura simple | ~1ms | ~0.3ms | ~2ms | ~0.3ms |
| Bulk insert (1000) | ~500ms | ~50ms | ~100ms | ~20ms |
| Query compleja | N/A | Limitado | ~5ms | ~1ms |
| Relaciones | N/A | Manual | Sí | Sí |
| Full-text search | N/A | N/A | Sí | Sí |
```

---

### 7. Ejercicios Prácticos

#### Ejercicio 1: App de notas con Hive

Crear una app de notas que:
- Permita crear, editar, eliminar notas
- Guarde título, contenido, fecha
- Soporte etiquetas
- Tenga búsqueda

#### Ejercicio 2: App de proyectos con Drift

Crear una app de gestión de proyectos que:
- Tenga usuarios, proyectos y tareas
- Soporte relaciones
- Use queries reactivas
- Implemente estadísticas

#### Ejercicio 3: App offline-first

Crear una app que:
- Sincronice datos con API
- Funcione offline
- Resuelva conflictos
- Priorice datos locales

---

**Resumen del Módulo 13:**

En este módulo aprendiste:

✅ Opciones de persistencia local en Flutter
✅ SharedPreferences para datos simples
✅ Hive para almacenamiento NoSQL key-value
✅ Drift para bases de datos relacionales con SQLite
✅ ObjectBox para alto rendimiento
✅ Comparativa de rendimiento
✅ Mejores prácticas de persistencia

**Próximo módulo:** Firebase## Módulo 14: Firebase (4 horas)

---

### 1. Introducción a Firebase

#### ¿Qué es Firebase?

Firebase es una plataforma de desarrollo de aplicaciones de Google que proporciona servicios backend sin necesidad de gestionar servidores propios.

**Servicios principales:**

| Servicio | Descripción |
|----------|-------------|
| Authentication | Gestión de usuarios (email, Google, Apple, etc.) |
| Cloud Firestore | Base de datos NoSQL en tiempo real |
| Realtime Database | Base de datos JSON en tiempo real |
| Cloud Storage | Almacenamiento de archivos |
| Cloud Messaging | Notificaciones push |
| Analytics | Análisis de uso y comportamiento |
| Crashlytics | Seguimiento de errores |
| Remote Config | Configuración remota |
| Performance | Monitoreo de rendimiento |

#### Configuración del proyecto

**1. Crear proyecto en Firebase Console:**
- Ir a https://console.firebase.google.com
- Crear nuevo proyecto
- Habilitar Google Analytics (opcional)

**2. Añadir apps:**
- iOS: Descargar `GoogleService-Info.plist`
- Android: Descargar `google-services.json`

**3. Instalar dependencias:**

```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  firebase_storage: ^11.6.0
  firebase_messaging: ^14.2.0
  firebase_analytics: ^10.8.0
  firebase_crashlytics: ^3.4.0
```

**4. Configurar Android:**

```groovy
// android/build.gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}

// android/app/build.gradle
apply plugin: 'com.google.gms.google-services'
apply plugin: 'com.google.firebase.crashlytics'

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
}
```

**5. Configurar iOS:**

```ruby
# ios/Podfile
platform :ios, '13.0'

target 'Runner' do
  use_frameworks!
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'Firebase/Messaging'
end
```

**6. Inicializar Firebase:**

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

---

### 2. Firebase Authentication

Firebase Authentication proporciona autenticación lista para usar con múltiples proveedores.

#### Configuración

```dart
// services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream de estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  Stream<User?> get userChanges => _auth.userChanges();

  // Usuario actual
  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;
  String? get currentUserEmail => _auth.currentUser?.email;
  String? get currentUserDisplayName => _auth.currentUser?.displayName;
  String? get currentUserPhotoUrl => _auth.currentUser?.photoURL;

  // Registro con email y contraseña
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (displayName != null && credential.user != null) {
      await credential.user!.updateDisplayName(displayName);
    }

    return credential;
  }

  // Login con email y contraseña
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Login con Google
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Inicio de sesión cancelado');
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  // Login con Apple
  Future<UserCredential> signInWithApple() async {
    final appleProvider = AppleAuthProvider();
    return await _auth.signInWithProvider(appleProvider);
  }

  // Enviar email de verificación
  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  // Enviar email de restablecimiento de contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Actualizar perfil
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    await _auth.currentUser?.updateDisplayName(displayName);
    await _auth.currentUser?.updatePhotoURL(photoURL);
  }

  // Actualizar email
  Future<void> updateEmail(String newEmail) async {
    await _auth.currentUser?.verifyBeforeUpdateEmail(newEmail);
  }

  // Actualizar contraseña
  Future<void> updatePassword(String newPassword) async {
    await _auth.currentUser?.updatePassword(newPassword);
  }

  // Reautenticar
  Future<UserCredential> reauthenticate({
    required String email,
    required String password,
  }) async {
    final credential = EmailAuthProvider.credential(email: email, password: password);
    return await _auth.currentUser!.reauthenticateWithCredential(credential);
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Eliminar cuenta
  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }
}
```

#### Pantalla de login

```dart
// screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-email':
        return 'Email inválido';
      case 'user-disabled':
        return 'Cuenta deshabilitada';
      case 'too-many-requests':
        return 'Demasiados intentos. Intente más tarde';
      default:
        return 'Error de autenticación: $code';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  const Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Iniciar Sesión',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese su email';
                      }
                      if (!value.contains('@')) {
                        return 'Email inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Contraseña
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese su contraseña';
                      }
                      if (value.length < 6) {
                        return 'Mínimo 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Olvidé contraseña
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _showResetPasswordDialog(),
                      child: const Text('¿Olvidaste tu contraseña?'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Error message
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Botón login
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Iniciar Sesión'),
                  ),
                  const SizedBox(height: 16),

                  // Divider
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('o'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Google Sign In
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    icon: const Icon(Icons.login),
                    label: const Text('Continuar con Google'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Registro
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿No tienes cuenta?'),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/register'),
                        child: const Text('Regístrate'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showResetPasswordDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Restablecer contraseña'),
          content: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (emailController.text.isNotEmpty) {
                  await _authService.sendPasswordResetEmail(emailController.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Email enviado')),
                  );
                }
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }
}
```

#### Auth wrapper

```dart
// widgets/auth_wrapper.dart
class AuthWrapper extends StatelessWidget {
  final Widget loggedInScreen;
  final Widget loggedOutScreen;

  const AuthWrapper({
    super.key,
    required this.loggedInScreen,
    required this.loggedOutScreen,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return loggedInScreen;
        }

        return loggedOutScreen;
      },
    );
  }
}
```

---

### 3. Cloud Firestore

Cloud Firestore es una base de datos NoSQL flexible y escalable.

#### Modelos

```dart
// models/usuario_model.dart
class UsuarioModel {
  final String id;
  final String nombre;
  final String email;
  final String? fotoUrl;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;
  final bool activo;

  UsuarioModel({
    required this.id,
    required this.nombre,
    required this.email,
    this.fotoUrl,
    DateTime? fechaCreacion,
    this.fechaActualizacion,
    this.activo = true,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  factory UsuarioModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UsuarioModel(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      email: data['email'] ?? '',
      fotoUrl: data['fotoUrl'],
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate(),
      fechaActualizacion: (data['fechaActualizacion'] as Timestamp?)?.toDate(),
      activo: data['activo'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'email': email,
      'fotoUrl': fotoUrl,
      'fechaCreacion': FieldValue.serverTimestamp(),
      'activo': activo,
    };
  }

  UsuarioModel copyWith({
    String? nombre,
    String? email,
    String? fotoUrl,
    bool? activo,
  }) {
    return UsuarioModel(
      id: id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      fechaCreacion: fechaCreacion,
      activo: activo ?? this.activo,
    );
  }
}

// models/tarea_model.dart
class TareaModel {
  final String id;
  final String titulo;
  final String? descripcion;
  final String usuarioId;
  final String? proyectoId;
  final int prioridad; // 0=baja, 1=media, 2=alta
  final int estado; // 0=pendiente, 1=en_progreso, 2=completada
  final DateTime fechaCreacion;
  final DateTime? fechaLimite;
  final DateTime? fechaCompletado;
  final List<String> etiquetas;

  TareaModel({
    required this.id,
    required this.titulo,
    this.descripcion,
    required this.usuarioId,
    this.proyectoId,
    this.prioridad = 1,
    this.estado = 0,
    DateTime? fechaCreacion,
    this.fechaLimite,
    this.fechaCompletado,
    List<String>? etiquetas,
  })  : fechaCreacion = fechaCreacion ?? DateTime.now(),
        etiquetas = etiquetas ?? [];

  factory TareaModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TareaModel(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      descripcion: data['descripcion'],
      usuarioId: data['usuarioId'] ?? '',
      proyectoId: data['proyectoId'],
      prioridad: data['prioridad'] ?? 1,
      estado: data['estado'] ?? 0,
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate(),
      fechaLimite: (data['fechaLimite'] as Timestamp?)?.toDate(),
      fechaCompletado: (data['fechaCompletado'] as Timestamp?)?.toDate(),
      etiquetas: List<String>.from(data['etiquetas'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'usuarioId': usuarioId,
      'proyectoId': proyectoId,
      'prioridad': prioridad,
      'estado': estado,
      'fechaCreacion': FieldValue.serverTimestamp(),
      'fechaLimite': fechaLimite,
      'fechaCompletado': fechaCompletado,
      'etiquetas': etiquetas,
    };
  }
}
```

#### Servicio de Firestore

```dart
// services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference<Map<String, dynamic>> get _usuarios =>
      _firestore.collection('usuarios');
  CollectionReference<Map<String, dynamic>> get _tareas =>
      _firestore.collection('tareas');
  CollectionReference<Map<String, dynamic>> get _proyectos =>
      _firestore.collection('proyectos');

  // CRUD Usuarios
  Future<void> crearUsuario(UsuarioModel usuario) async {
    await _usuarios.doc(usuario.id).set(usuario.toFirestore());
  }

  Future<UsuarioModel?> obtenerUsuario(String id) async {
    final doc = await _usuarios.doc(id).get();
    if (doc.exists) {
      return UsuarioModel.fromFirestore(doc);
    }
    return null;
  }

  Stream<UsuarioModel?> observarUsuario(String id) {
    return _usuarios.doc(id).snapshots().map((doc) {
      if (doc.exists) {
        return UsuarioModel.fromFirestore(doc);
      }
      return null;
    });
  }

  Future<void> actualizarUsuario(UsuarioModel usuario) async {
    await _usuarios.doc(usuario.id).update({
      ...usuario.toFirestore(),
      'fechaActualizacion': FieldValue.serverTimestamp(),
    });
  }

  Future<void> eliminarUsuario(String id) async {
    await _usuarios.doc(id).delete();
  }

  // CRUD Tareas
  Future<String> crearTarea(TareaModel tarea) async {
    final docRef = await _tareas.add(tarea.toFirestore());
    return docRef.id;
  }

  Future<TareaModel?> obtenerTarea(String id) async {
    final doc = await _tareas.doc(id).get();
    if (doc.exists) {
      return TareaModel.fromFirestore(doc);
    }
    return null;
  }

  Stream<List<TareaModel>> observarTareasPorUsuario(String usuarioId) {
    return _tareas
        .where('usuarioId', isEqualTo: usuarioId)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TareaModel.fromFirestore(doc)).toList());
  }

  Stream<List<TareaModel>> observarTareasPorProyecto(String proyectoId) {
    return _tareas
        .where('proyectoId', isEqualTo: proyectoId)
        .orderBy('prioridad', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TareaModel.fromFirestore(doc)).toList());
  }

  Stream<List<TareaModel>> observarTareasPendientes(String usuarioId) {
    return _tareas
        .where('usuarioId', isEqualTo: usuarioId)
        .where('estado', isLessThan: 2)
        .orderBy('fechaLimite')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TareaModel.fromFirestore(doc)).toList());
  }

  Future<void> actualizarTarea(TareaModel tarea) async {
    await _tareas.doc(tarea.id).update(tarea.toFirestore());
  }

  Future<void> actualizarEstadoTarea(String id, int nuevoEstado) async {
    await _tareas.doc(id).update({
      'estado': nuevoEstado,
      'fechaCompletado': nuevoEstado == 2 ? FieldValue.serverTimestamp() : null,
    });
  }

  Future<void> eliminarTarea(String id) async {
    await _tareas.doc(id).delete();
  }

  // Búsqueda
  Future<List<TareaModel>> buscarTareas(String usuarioId, String query) async {
    // Firestore no soporta búsqueda de texto completo nativamente
    // Solución: buscar por prefijo
    final snapshot = await _tareas
        .where('usuarioId', isEqualTo: usuarioId)
        .orderBy('titulo')
        .startAt([query])
        .endAt([query + '\uf8ff'])
        .get();

    return snapshot.docs.map((doc) => TareaModel.fromFirestore(doc)).toList();
  }

  // Transacciones
  Future<void> completarTareaConEstadisticas(
    String tareaId,
    String usuarioId,
  ) async {
    return _firestore.runTransaction((transaction) async {
      // Obtener tarea
      final tareaDoc = _tareas.doc(tareaId);
      final tareaSnapshot = await transaction.get(tareaDoc);

      if (!tareaSnapshot.exists) {
        throw Exception('Tarea no encontrada');
      }

      // Actualizar tarea
      transaction.update(tareaDoc, {
        'estado': 2,
        'fechaCompletado': FieldValue.serverTimestamp(),
      });

      // Actualizar estadísticas del usuario
      final statsDoc = _firestore.collection('estadisticas').doc(usuarioId);
      transaction.set(
        statsDoc,
        {'tareasCompletadas': FieldValue.increment(1)},
        SetOptions(merge: true),
      );
    });
  }

  // Batch operations
  Future<void> crearMultiplesTareas(List<TareaModel> tareas) async {
    final batch = _firestore.batch();

    for (final tarea in tareas) {
      final docRef = _tareas.doc();
      batch.set(docRef, tarea.toFirestore());
    }

    await batch.commit();
  }

  // Paginación
  Future<List<TareaModel>> obtenerTareasPaginadas(
    String usuarioId, {
    DocumentSnapshot? lastDocument,
    int limite = 20,
  }) async {
    Query query = _tareas
        .where('usuarioId', isEqualTo: usuarioId)
        .orderBy('fechaCreacion', descending: true)
        .limit(limite);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => TareaModel.fromFirestore(doc)).toList();
  }
}
```

#### Provider con Firestore

```dart
// providers/tareas_provider.dart
class TareasProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final String _usuarioId;

  List<TareaModel> _tareas = [];
  List<TareaModel> get tareas => _tareas;

  StreamSubscription<QuerySnapshot>? _subscription;

  TareasProvider(this._usuarioId) {
    _inicializar();
  }

  void _inicializar() {
    _subscription = _firestore
        .observarTareasPorUsuario(_usuarioId)
        .listen((tareas) {
      _tareas = tareas;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> agregarTarea(TareaModel tarea) async {
    await _firestore.crearTarea(tarea);
  }

  Future<void> actualizarTarea(TareaModel tarea) async {
    await _firestore.actualizarTarea(tarea);
  }

  Future<void> eliminarTarea(String id) async {
    await _firestore.eliminarTarea(id);
  }

  Future<void> toggleCompletada(String id) async {
    final tarea = _tareas.firstWhere((t) => t.id == id);
    final nuevoEstado = tarea.estado == 2 ? 0 : 2;
    await _firestore.actualizarEstadoTarea(id, nuevoEstado);
  }
}
```

---

### 4. Cloud Storage

Cloud Storage permite almacenar y descargar archivos.

```dart
// services/storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Subir imagen de perfil
  Future<String> subirImagenPerfil(String usuarioId, File imagen) async {
    final ref = _storage.ref().child('perfiles/$usuarioId.jpg');

    // Subir con metadata
    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'usuarioId': usuarioId},
    );

    final uploadTask = ref.putFile(imagen, metadata);
    final snapshot = await uploadTask;

    return await snapshot.ref.getDownloadURL();
  }

  // Subir archivo genérico
  Future<String> subirArchivo({
    required String ruta,
    required File archivo,
    String? contentType,
    Function(double)? onProgress,
  }) async {
    final ref = _storage.ref().child(ruta);

    final metadata = contentType != null
        ? SettableMetadata(contentType: contentType)
        : null;

    final uploadTask = ref.putFile(archivo, metadata);

    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });
    }

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Descargar archivo
  Future<File> descargarArchivo(String ruta, File destino) async {
    final ref = _storage.ref().child(ruta);
    await ref.writeToFile(destino);
    return destino;
  }

  // Obtener URL de descarga
  Future<String> obtenerUrlDescarga(String ruta) async {
    final ref = _storage.ref().child(ruta);
    return await ref.getDownloadURL();
  }

  // Eliminar archivo
  Future<void> eliminarArchivo(String ruta) async {
    final ref = _storage.ref().child(ruta);
    await ref.delete();
  }

  // Listar archivos
  Future<List<Reference>> listarArchivos(String ruta) async {
    final ref = _storage.ref().child(ruta);
    final result = await ref.listAll();
    return result.items;
  }

  // Subir múltiples archivos
  Future<List<String>> subirMultiplesArchivos({
    required String rutaBase,
    required List<File> archivos,
    Function(int, int)? onProgress,
  }) async {
    final urls = <String>[];

    for (var i = 0; i < archivos.length; i++) {
      final archivo = archivos[i];
      final nombre = DateTime.now().millisecondsSinceEpoch.toString();
      final ruta = '$rutaBase/$nombre';

      final url = await subirArchivo(ruta: ruta, archivo: archivo);
      urls.add(url);

      onProgress?.call(i + 1, archivos.length);
    }

    return urls;
  }
}
```

#### Widget de subida de imagen

```dart
class ImageUploader extends StatefulWidget {
  final String usuarioId;
  final String? currentImageUrl;
  final Function(String) onImageUploaded;

  const ImageUploader({
    super.key,
    required this.usuarioId,
    this.currentImageUrl,
    required this.onImageUploaded,
  });

  @override
  State<ImageUploader> createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  final StorageService _storage = StorageService();
  final ImagePicker _picker = ImagePicker();

  bool _isUploading = false;
  double _uploadProgress = 0;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.currentImageUrl;
  }

  Future<void> _pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });

    try {
      final file = File(image.path);
      final url = await _storage.subirImagenPerfil(widget.usuarioId, file);

      setState(() {
        _imageUrl = url;
        _isUploading = false;
      });

      widget.onImageUploaded(url);
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: _imageUrl != null
                  ? NetworkImage(_imageUrl!) as ImageProvider
                  : const AssetImage('assets/default_avatar.png'),
              child: _isUploading
                  ? CircularProgressIndicator(
                      value: _uploadProgress,
                      color: Colors.white,
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: IconButton(
                onPressed: _isUploading ? null : _pickAndUploadImage,
                icon: const Icon(Icons.camera_alt),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        if (_isUploading)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(value: _uploadProgress),
          ),
      ],
    );
  }
}
```

---

### 5. Firebase Cloud Messaging

Notificaciones push con Firebase Cloud Messaging.

```dart
// services/messaging_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';

class MessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Solicitar permisos (iOS)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Obtener token
    final token = await _messaging.getToken();
    print('FCM Token: $token');

    // Escuchar token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      print('Nuevo token: $newToken');
      // Actualizar token en servidor
    });

    // Manejar mensajes en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensaje recibido en foreground: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // Manejar mensajes cuando la app está en background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App abierta desde notificación: ${message.notification?.title}');
      _handleMessageTap(message);
    });

    // Verificar si la app se abrió desde una notificación terminada
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageTap(initialMessage);
    }
  }

  void _showLocalNotification(RemoteMessage message) {
    // Implementar notificación local
    // Requiere flutter_local_notifications package
  }

  void _handleMessageTap(RemoteMessage message) {
    final data = message.data;
    // Navegar a pantalla específica basado en data
    if (data['type'] == 'tarea') {
      // Navigator.pushNamed(context, '/tarea', arguments: data['id']);
    }
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}
```

---

### 6. Firebase Analytics y Crashlytics

```dart
// services/analytics_service.dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  Future<void> logViewItem({
    required String itemId,
    required String itemName,
    required String itemCategory,
  }) async {
    await _analytics.logViewItem(
      itemId: itemId,
      itemName: itemName,
      itemCategory: itemCategory,
    );
  }

  Future<void> logAddToCart({
    required String itemId,
    required String itemName,
    required double price,
    required String currency,
  }) async {
    await _analytics.logAddToCart(
      itemId: itemId,
      itemName: itemName,
      price: price,
      currency: currency,
    );
  }

  Future<void> logPurchase({
    required double value,
    required String currency,
    required String transactionId,
  }) async {
    await _analytics.logPurchase(
      value: value,
      currency: currency,
      transactionId: transactionId,
    );
  }

  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }
}

// services/crashlytics_service.dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class CrashlyticsService {
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  Future<void> initialize() async {
    await _crashlytics.setCrashlyticsCollectionEnabled(true);
  }

  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
  }) async {
    await _crashlytics.recordError(exception, stack, reason: reason);
  }

  Future<void> log(String message) async {
    await _crashlytics.log(message);
  }

  Future<void> setUserId(String userId) async {
    await _crashlytics.setUserIdentifier(userId);
  }

  Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value);
  }
}
```

---

### 7. Ejercicios Prácticos

#### Ejercicio 1: App de chat con Firestore

Crear una app de chat que:
- Autentique usuarios
- Muestre lista de conversaciones
- Permita enviar mensajes en tiempo real
- Guarde timestamps y estados de lectura

#### Ejercicio 2: App de tareas con Firebase

Crear una app de tareas que:
- Sincronice tareas con Firestore
- Funcione offline
- Muestre notificaciones push
- Registre eventos en Analytics

#### Ejercicio 3: App de fotos con Storage

Crear una app que:
- Permita subir fotos
- Organice en álbumes
- Comparta con otros usuarios
- Use notificaciones para alertar

---

**Resumen del Módulo 14:**

En este módulo aprendiste:

✅ Configuración de Firebase en Flutter
✅ Firebase Authentication con múltiples proveedores
✅ Cloud Firestore para datos en tiempo real
✅ Cloud Storage para archivos
✅ Firebase Cloud Messaging para notificaciones
✅ Firebase Analytics y Crashlytics
✅ Patrones y mejores prácticas

**Próximo módulo:** Multimedia y Cámara## Módulo 15: Multimedia y Cámara (2 horas)

---

### 1. Selección de Imágenes

#### image_picker

El plugin más popular para seleccionar imágenes y videos de la galería o cámara.

```yaml
# pubspec.yaml
dependencies:
  image_picker: ^1.0.7
```

**Configuración Android:**

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
```

**Configuración iOS:**

```xml
<!-- ios/Runner/Info.plist -->
<key>NSCameraUsageDescription</key>
<string>Se necesita acceso a la cámara para tomar fotos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Se necesita acceso a la galería para seleccionar fotos</string>
<key>NSMicrophoneUsageDescription</key>
<string>Se necesita acceso al micrófono para grabar videos</string>
```

#### Uso básico

```dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerExample extends StatefulWidget {
  const ImagePickerExample({super.key});

  @override
  State<ImagePickerExample> createState() => _ImagePickerExampleState();
}

class _ImagePickerExampleState extends State<ImagePickerExample> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  List<XFile> _imageFiles = [];

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  Future<void> _pickFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  Future<void> _pickMultipleImages() async {
    final List<XFile> images = await _picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (images.isNotEmpty) {
      setState(() {
        _imageFiles = images;
      });
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 5),
    );

    if (video != null) {
      // Manejar video
      print('Video seleccionado: ${video.path}');
    }
  }

  Future<void> _recordVideo() async {
    final XFile? video = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 1),
    );

    if (video != null) {
      print('Video grabado: ${video.path}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Picker')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Imagen seleccionada
            if (_imageFile != null)
              Container(
                height: 300,
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(File(_imageFile!.path)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            // Múltiples imágenes
            if (_imageFiles.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imageFiles.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 120,
                      height: 120,
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(File(_imageFiles[index].path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 24),

            // Botones
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galería'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _pickFromCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Cámara'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _pickMultipleImages,
                    icon: const Icon(Icons.collections),
                    label: const Text('Múltiples imágenes'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _pickVideo,
                    icon: const Icon(Icons.video_library),
                    label: const Text('Video de galería'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _recordVideo,
                    icon: const Icon(Icons.videocam),
                    label: const Text('Grabar video'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### Widget reutilizable

```dart
class ImagePickerWidget extends StatelessWidget {
  final XFile? image;
  final Function(XFile) onImageSelected;
  final String? placeholderText;
  final double? width;
  final double? height;

  const ImagePickerWidget({
    super.key,
    this.image,
    required this.onImageSelected,
    this.placeholderText,
    this.width,
    this.height,
  });

  Future<void> _showPicker(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final XFile? pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1920,
                    maxHeight: 1080,
                    imageQuality: 85,
                  );
                  if (pickedFile != null) {
                    onImageSelected(pickedFile);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Cámara'),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final XFile? pickedFile = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1920,
                    maxHeight: 1080,
                    imageQuality: 85,
                  );
                  if (pickedFile != null) {
                    onImageSelected(pickedFile);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        width: width ?? double.infinity,
        height: height ?? 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          image: image != null
              ? DecorationImage(
                  image: FileImage(File(image!.path)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey[600]),
                  const SizedBox(height: 8),
                  Text(
                    placeholderText ?? 'Toca para seleccionar imagen',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
```

---

### 2. Procesamiento de Imágenes

#### image package

Para manipulación básica de imágenes.

```yaml
# pubspec.yaml
dependencies:
  image: ^4.1.7
```

```dart
import 'dart:io';
import 'package:image/image.dart' as img;

class ImageProcessingService {
  // Redimensionar imagen
  Future<File> resizeImage(File imageFile, {int width = 800, int height = 600}) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('No se pudo decodificar la imagen');
    }

    final resized = img.copyResize(image, width: width, height: height);
    final encoded = img.encodeJpg(resized, quality: 85);

    final outputPath = '${imageFile.path}_resized.jpg';
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(encoded);

    return outputFile;
  }

  // Recortar imagen
  Future<File> cropImage(
    File imageFile, {
    required int x,
    required int y,
    required int width,
    required int height,
  }) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('No se pudo decodificar la imagen');
    }

    final cropped = img.copyCrop(image, x: x, y: y, width: width, height: height);
    final encoded = img.encodeJpg(cropped, quality: 85);

    final outputPath = '${imageFile.path}_cropped.jpg';
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(encoded);

    return outputFile;
  }

  // Rotar imagen
  Future<File> rotateImage(File imageFile, {int degrees = 90}) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('No se pudo decodificar la imagen');
    }

    final rotated = img.copyRotate(image, angle: degrees);
    final encoded = img.encodeJpg(rotated, quality: 85);

    final outputPath = '${imageFile.path}_rotated.jpg';
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(encoded);

    return outputFile;
  }

  // Aplicar filtro
  Future<File> applyGrayscale(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('No se pudo decodificar la imagen');
    }

    final grayscale = img.grayscale(image);
    final encoded = img.encodeJpg(grayscale, quality: 85);

    final outputPath = '${imageFile.path}_gray.jpg';
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(encoded);

    return outputFile;
  }

  // Ajustar brillo
  Future<File> adjustBrightness(File imageFile, {int brightness = 50}) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('No se pudo decodificar la imagen');
    }

    final adjusted = img.adjustColor(image, brightness: brightness);
    final encoded = img.encodeJpg(adjusted, quality: 85);

    final outputPath = '${imageFile.path}_bright.jpg';
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(encoded);

    return outputFile;
  }

  // Comprimir imagen
  Future<File> compressImage(File imageFile, {int quality = 70}) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('No se pudo decodificar la imagen');
    }

    final encoded = img.encodeJpg(image, quality: quality);

    final outputPath = '${imageFile.path}_compressed.jpg';
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(encoded);

    return outputFile;
  }

  // Crear thumbnail
  Future<File> createThumbnail(File imageFile, {int size = 150}) async {
    return await resizeImage(imageFile, width: size, height: size);
  }

  // Obtener información de imagen
  Future<Map<String, dynamic>> getImageInfo(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('No se pudo decodificar la imagen');
    }

    return {
      'width': image.width,
      'height': image.height,
      'format': imageFile.path.split('.').last.toUpperCase(),
      'size': bytes.length,
      'aspectRatio': image.width / image.height,
    };
  }
}
```

---

### 3. Reproducción de Video

#### video_player

```yaml
# pubspec.yaml
dependencies:
  video_player: ^2.8.2
```

```dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerExample extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerExample({super.key, required this.videoUrl});

  @override
  State<VideoPlayerExample> createState() => _VideoPlayerExampleState();
}

class _VideoPlayerExampleState extends State<VideoPlayerExample> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

    await _controller.initialize();
    setState(() {
      _isInitialized = true;
    });

    _controller.addListener(() {
      if (_controller.value.isPlaying != _isPlaying) {
        setState(() {
          _isPlaying = _controller.value.isPlaying;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Player')),
      body: Column(
        children: [
          // Video
          if (_isInitialized)
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
          else
            const AspectRatio(
              aspectRatio: 16 / 9,
              child: Center(child: CircularProgressIndicator()),
            ),

          // Controles
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Barra de progreso
                VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: Colors.blue,
                    bufferedColor: Colors.lightBlue,
                    backgroundColor: Colors.grey,
                  ),
                ),

                const SizedBox(height: 16),

                // Controles de reproducción
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay_10),
                      onPressed: () {
                        final position = _controller.value.position - const Duration(seconds: 10);
                        _controller.seekTo(position);
                      },
                    ),
                    IconButton(
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                      iconSize: 48,
                      onPressed: () {
                        if (_isPlaying) {
                          _controller.pause();
                        } else {
                          _controller.play();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.forward_10),
                      onPressed: () {
                        final position = _controller.value.position + const Duration(seconds: 10);
                        _controller.seekTo(position);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Control de volumen
                Row(
                  children: [
                    const Icon(Icons.volume_down),
                    Expanded(
                      child: Slider(
                        value: _controller.value.volume,
                        onChanged: (value) {
                          _controller.setVolume(value);
                        },
                      ),
                    ),
                    const Icon(Icons.volume_up),
                  ],
                ),

                // Control de velocidad
                Row(
                  children: [
                    const Text('Velocidad: '),
                    DropdownButton<double>(
                      value: _controller.value.playbackSpeed,
                      items: [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
                          .map((speed) => DropdownMenuItem(
                                value: speed,
                                child: Text('${speed}x'),
                              ))
                          .toList(),
                      onChanged: (speed) {
                        if (speed != null) {
                          _controller.setPlaybackSpeed(speed);
                        }
                      },
                    ),
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

#### Reproductor de video desde assets

```dart
class AssetVideoPlayer extends StatefulWidget {
  final String assetPath;

  const AssetVideoPlayer({super.key, required this.assetPath});

  @override
  State<AssetVideoPlayer> createState() => _AssetVideoPlayerState();
}

class _AssetVideoPlayerState extends State<AssetVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.assetPath);
    _controller.initialize().then((_) {
      setState(() {
        _isInitialized = true;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : const Center(child: CircularProgressIndicator());
  }
}
```

---

### 4. Reproducción de Audio

#### just_audio

```yaml
# pubspec.yaml
dependencies:
  just_audio: ^0.9.36
  audio_session: ^0.1.18
```

```dart
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class AudioPlayerExample extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerExample({super.key, required this.audioUrl});

  @override
  State<AudioPlayerExample> createState() => _AudioPlayerExampleState();
}

class _AudioPlayerExampleState extends State<AudioPlayerExample> {
  late AudioPlayer _player;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    // Configurar sesión de audio
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    _player = AudioPlayer();

    // Escuchar eventos
    _player.durationStream.listen((duration) {
      setState(() {
        _duration = duration ?? Duration.zero;
      });
    });

    _player.positionStream.listen((position) {
      setState(() {
        _position = position;
      });
    });

    _player.playerStateStream.listen((state) {
      setState(() {});
    });

    // Cargar audio
    try {
      await _player.setUrl(widget.audioUrl);
    } catch (e) {
      print('Error cargando audio: $e');
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Player')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Portada (placeholder)
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.music_note, size: 80, color: Colors.grey),
            ),

            const SizedBox(height: 32),

            // Título
            const Text(
              'Mi Canción',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Artista Desconocido',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 32),

            // Barra de progreso
            Slider(
              value: _position.inSeconds.toDouble(),
              max: _duration.inSeconds.toDouble(),
              onChanged: (value) {
                _player.seek(Duration(seconds: value.toInt()));
              },
            ),

            // Tiempo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(_position)),
                Text(_formatDuration(_duration)),
              ],
            ),

            const SizedBox(height: 24),

            // Controles
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Aleatorio
                IconButton(
                  icon: const Icon(Icons.shuffle),
                  onPressed: () {
                    _player.setShuffleModeEnabled(!_player.shuffleModeEnabled);
                  },
                ),

                // Anterior
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  iconSize: 36,
                  onPressed: () {
                    _player.seekToPrevious();
                  },
                ),

                // Play/Pause
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _player.playing ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    iconSize: 48,
                    onPressed: () {
                      if (_player.playing) {
                        _player.pause();
                      } else {
                        _player.play();
                      }
                    },
                  ),
                ),

                // Siguiente
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  iconSize: 36,
                  onPressed: () {
                    _player.seekToNext();
                  },
                ),

                // Repetir
                IconButton(
                  icon: Icon(
                    _player.loopMode == LoopMode.one
                        ? Icons.repeat_one
                        : Icons.repeat,
                  ),
                  onPressed: () {
                    if (_player.loopMode == LoopMode.off) {
                      _player.setLoopMode(LoopMode.all);
                    } else if (_player.loopMode == LoopMode.all) {
                      _player.setLoopMode(LoopMode.one);
                    } else {
                      _player.setLoopMode(LoopMode.off);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Control de volumen
            Row(
              children: [
                const Icon(Icons.volume_down),
                Expanded(
                  child: Slider(
                    value: _player.volume,
                    onChanged: (value) {
                      _player.setVolume(value);
                    },
                  ),
                ),
                const Icon(Icons.volume_up),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

#### Playlist de audio

```dart
class PlaylistPlayer extends StatefulWidget {
  final List<String> audioUrls;

  const PlaylistPlayer({super.key, required this.audioUrls});

  @override
  State<PlaylistPlayer> createState() => _PlaylistPlayerState();
}

class _PlaylistPlayerState extends State<PlaylistPlayer> {
  late AudioPlayer _player;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    _player = AudioPlayer();

    // Crear playlist
    final playlist = ConcatenatingAudioSource(
      children: widget.audioUrls.map((url) {
        return AudioSource.uri(Uri.parse(url));
      }).toList(),
    );

    await _player.setAudioSource(playlist);

    _player.currentIndexStream.listen((index) {
      if (index != null) {
        setState(() {
          _currentIndex = index;
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Playlist')),
      body: ListView.builder(
        itemCount: widget.audioUrls.length,
        itemBuilder: (context, index) {
          final isSelected = index == _currentIndex;
          return ListTile(
            leading: Icon(
              isSelected ? Icons.play_circle : Icons.music_note,
              color: isSelected ? Colors.blue : null,
            ),
            title: Text('Canción ${index + 1}'),
            selected: isSelected,
            onTap: () {
              _player.seek(Duration.zero, index: index);
              _player.play();
            },
          );
        },
      ),
    );
  }
}
```

---

### 5. Caché de Imágenes

#### cached_network_image

```yaml
# pubspec.yaml
dependencies:
  cached_network_image: ^3.3.1
```

```dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CachedImageExample extends StatelessWidget {
  final String imageUrl;

  const CachedImageExample({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cached Network Image')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Imagen básica con placeholder y error
            CachedNetworkImage(
              imageUrl: imageUrl,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Center(
                child: Icon(Icons.error, color: Colors.red),
              ),
            ),

            const SizedBox(height: 16),

            // Imagen con dimensiones específicas
            CachedNetworkImage(
              imageUrl: imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.broken_image, size: 48),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Imagen circular (avatar)
            CachedNetworkImage(
              imageUrl: imageUrl,
              imageBuilder: (context, imageProvider) => Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(color: Colors.blue, width: 3),
                ),
              ),
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),

            const SizedBox(height: 16),

            // Imagen con fade in
            CachedNetworkImage(
              imageUrl: imageUrl,
              fadeInDuration: const Duration(milliseconds: 500),
              fadeOutDuration: const Duration(milliseconds: 500),
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
              ),
            ),

            const SizedBox(height: 16),

            // Imagen con memCacheWidth para optimizar memoria
            CachedNetworkImage(
              imageUrl: imageUrl,
              memCacheWidth: 300, // Redimensionar en memoria
              maxWidthDiskCache: 500, // Redimensionar en disco
              placeholder: (context, url) => const CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}

// Grid de imágenes con caché
class ImageGridExample extends StatelessWidget {
  final List<String> imageUrls;

  const ImageGridExample({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _showFullScreenImage(context, imageUrls[index]),
          child: CachedNetworkImage(
            imageUrl: imageUrls[index],
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[200],
              child: const Icon(Icons.error),
            ),
          ),
        );
      },
    );
  }

  void _showFullScreenImage(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(),
          body: Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

### 6. Ejercicios Prácticos

#### Ejercicio 1: App de fotos de perfil

Crear una app que:
- Permita seleccionar foto de galería o cámara
- Recorte la imagen en forma circular
- Aplique filtros (blanco y negro, brillo)
- Suba la imagen a Firebase Storage
- Muestre la imagen con caché

#### Ejercicio 2: App de galería

Crear una app que:
- Seleccione múltiples imágenes
- Muestre en un grid con thumbnails
- Permita ver en pantalla completa con zoom
- Comparta imágenes
- Guarde en caché

#### Ejercicio 3: App de música

Crear una app que:
- Reproduzca archivos de audio locales
- Muestre una playlist
- Controle volumen y progreso
- Reproduzca en background
- Muestre notificaciones de reproducción

---

**Resumen del Módulo 15:**

En este módulo aprendiste:

✅ Selección de imágenes y videos con image_picker
✅ Procesamiento de imágenes con el package image
✅ Reproducción de video con video_player
✅ Reproducción de audio con just_audio
✅ Caché de imágenes con cached_network_image
✅ Patrones y mejores prácticas de multimedia

**Próximo módulo:** Mapas y Ubicación## Módulo 16: Mapas y Ubicación (3 horas)

---

### 1. Google Maps Flutter

#### Configuración

**1. Obtener API Key de Google Maps:**
- Ir a Google Cloud Console
- Crear proyecto
- Habilitar Maps SDK for Android e iOS
- Crear credenciales (API Key)

**2. Android:**

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application>
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="TU_API_KEY"/>
    </application>
</manifest>
```

**3. iOS:**

```xml
<!-- ios/Runner/AppDelegate.swift -->
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("TU_API_KEY")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

**4. pubspec.yaml:**

```yaml
dependencies:
  google_maps_flutter: ^2.5.3
  geolocator: ^10.1.0
  geocoding: ^2.1.1
```

#### Mapa básico

```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapaBasico extends StatefulWidget {
  const MapaBasico({super.key});

  @override
  State<MapaBasico> createState() => _MapaBasicoState();
}

class _MapaBasicoState extends State<MapaBasico> {
  late GoogleMapController _mapController;
  final LatLng _center = const LatLng(40.4168, -3.7038); // Madrid
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final Set<Polygon> _polygons = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 15,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
        },
        markers: _markers,
        polylines: _polylines,
        polygons: _polygons,
        onTap: _onMapTap,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        mapType: MapType.normal,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToLocation,
        child: const Icon(Icons.location_searching),
      ),
    );
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(position.toString()),
          position: position,
          infoWindow: InfoWindow(
            title: 'Ubicación',
            snippet: '${position.latitude}, ${position.longitude}',
          ),
        ),
      );
    });
  }

  void _goToLocation() async {
    final position = await _getCurrentLocation();
    _mapController.animateCamera(
      CameraUpdate.newLatLng(position),
    );
  }

  Future<LatLng> _getCurrentLocation() async {
    // Implementar con geolocator
    return _center;
  }
}
```

#### Marcadores

```dart
class MarcadoresExample extends StatefulWidget {
  const MarcadoresExample({super.key});

  @override
  State<MarcadoresExample> createState() => _MarcadoresExampleState();
}

class _MarcadoresExampleState extends State<MarcadoresExample> {
  final Set<Marker> _markers = {};
  int _markerId = 0;

  void _addMarker(LatLng position) {
    final markerId = MarkerId('marker_${_markerId++}');
    
    final marker = Marker(
      markerId: markerId,
      position: position,
      draggable: true,
      onDragEnd: (newPosition) {
        print('Nueva posición: $newPosition');
      },
      infoWindow: InfoWindow(
        title: 'Marcador $_markerId',
        snippet: 'Toca para editar',
        onTap: () {
          _showMarkerOptions(markerId);
        },
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );

    setState(() {
      _markers.add(marker);
    });
  }

  void _showMarkerOptions(MarkerId markerId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar'),
                onTap: () {
                  Navigator.pop(context);
                  _editMarker(markerId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Eliminar'),
                onTap: () {
                  Navigator.pop(context);
                  _removeMarker(markerId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _editMarker(MarkerId markerId) {
    // Implementar edición
  }

  void _removeMarker(MarkerId markerId) {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId == markerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(40.4168, -3.7038),
          zoom: 12,
        ),
        markers: _markers,
        onTap: _addMarker,
      ),
    );
  }
}
```

#### Polilíneas y Polígonos

```dart
class RutasExample extends StatefulWidget {
  const RutasExample({super.key});

  @override
  State<RutasExample> createState() => _RutasExampleState();
}

class _RutasExampleState extends State<RutasExample> {
  final Set<Polyline> _polylines = {};
  final Set<Polygon> _polygons = {};
  final List<LatLng> _points = [];

  void _addPoint(LatLng position) {
    setState(() {
      _points.add(position);
      
      // Polilínea
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: _points,
          color: Colors.blue,
          width: 5,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      );
    });
  }

  void _closePolygon() {
    if (_points.length < 3) return;

    setState(() {
      _polygons.add(
        Polygon(
          polygonId: const PolygonId('area'),
          points: _points,
          strokeColor: Colors.red,
          strokeWidth: 3,
          fillColor: Colors.red.withOpacity(0.3),
        ),
      );
      _points.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(40.4168, -3.7038),
          zoom: 12,
        ),
        polylines: _polylines,
        polygons: _polygons,
        onTap: _addPoint,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _closePolygon,
        child: const Icon(Icons.check),
      ),
    );
  }
}
```

---

### 2. Geolocalización

#### Obtener ubicación actual

```dart
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<bool> checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<Position?> getCurrentPosition() async {
    final hasPermission = await checkPermission();
    if (!hasPermission) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  Future<double> getDistanceBetween(
    LatLng start,
    LatLng end,
  ) async {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }
}
```

#### Seguimiento de ubicación

```dart
class LocationTrackingScreen extends StatefulWidget {
  const LocationTrackingScreen({super.key});

  @override
  State<LocationTrackingScreen> createState() => _LocationTrackingScreenState();
}

class _LocationTrackingScreenState extends State<LocationTrackingScreen> {
  final LocationService _locationService = LocationService();
  Position? _currentPosition;
  StreamSubscription<Position>? _positionSubscription;
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startTracking() async {
    final position = await _locationService.getCurrentPosition();
    setState(() {
      _currentPosition = position;
    });

    _positionSubscription = _locationService.getPositionStream().listen((position) {
      setState(() {
        _currentPosition = position;
        _routePoints.add(LatLng(position.latitude, position.longitude));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seguimiento GPS')),
      body: Column(
        children: [
          if (_currentPosition != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}'),
                  Text('Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}'),
                  Text('Alt: ${_currentPosition!.altitude.toStringAsFixed(2)}m'),
                  Text('Velocidad: ${(_currentPosition!.speed * 3.6).toStringAsFixed(1)} km/h'),
                ],
              ),
            ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _currentPosition?.latitude ?? 40.4168,
                  _currentPosition?.longitude ?? -3.7038,
                ),
                zoom: 15,
              ),
              myLocationEnabled: true,
              polylines: {
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: _routePoints,
                  color: Colors.blue,
                  width: 3,
                ),
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

### 3. Geocoding

```dart
import 'package:geocoding/geocoding.dart';

class GeocodingService {
  Future<List<Location>> searchAddress(String query) async {
    return await locationFromAddress(query);
  }

  Future<List<Placemark>> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    return await placemarkFromCoordinates(latitude, longitude);
  }

  Future<String?> getFullAddress(double latitude, double longitude) async {
    final placemarks = await getAddressFromCoordinates(latitude, longitude);
    if (placemarks.isEmpty) return null;

    final place = placemarks.first;
    return '${place.street}, ${place.locality}, ${place.country}';
  }
}
```

---

### 4. Ejercicios Prácticos

#### Ejercicio 1: App de rutas

Crear una app que:
- Muestre la ubicación actual
- Permita buscar lugares
- Trace rutas entre puntos
- Calcule distancias

#### Ejercicio 2: App de check-in

Crear una app que:
- Obtenga la ubicación actual
- Convierta coordenadas a dirección
- Guarde check-ins con foto
- Muestre en un mapa

**Resumen del Módulo 16:**

En este módulo aprendiste:

✅ Configuración de Google Maps
✅ Marcadores, polilíneas y polígonos
✅ Geolocalización con geolocator
✅ Geocoding para convertir direcciones
✅ Seguimiento de ubicación en tiempo real

**Próximo módulo:** Notificaciones y Background## Módulo 17: Notificaciones y Background (2 horas)

---

### 1. Notificaciones Locales

#### flutter_local_notifications

```yaml
dependencies:
  flutter_local_notifications: ^16.3.0
  timezone: ^0.9.2
```

#### Configuración

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimezones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  static void _onNotificationTapped(NotificationResponse response) {
    print('Notificación tappeada: ${response.payload}');
    // Navegar a pantalla específica
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? channel,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channel ?? 'default_channel',
      'Notificaciones',
      channelDescription: 'Canal de notificaciones',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Notificaciones programadas',
      channelDescription: 'Canal para notificaciones programadas',
      importance: Importance.high,
      priority: Priority.high,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTimestamp,
      payload: payload,
    );
  }

  static Future<void> showDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'daily_channel',
      'Recordatorios diarios',
      importance: Importance.high,
    );

    final details = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<void> showProgressNotification({
    required int id,
    required String title,
    required String body,
    required int progress,
    required int maxProgress,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'progress_channel',
      'Descargas',
      channelDescription: 'Progreso de descargas',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: maxProgress,
      progress: progress,
    );

    final details = NotificationDetails(android: androidDetails);

    await _notifications.show(id, title, body, details);
  }
}
```

---

### 2. Notificaciones Push

#### Firebase Cloud Messaging

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Solicitar permisos
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Obtener token
    String? token = await _messaging.getToken();
    print('FCM Token: $token');

    // Escuchar refresh del token
    _messaging.onTokenRefresh.listen((newToken) {
      print('Nuevo token: $newToken');
      // Actualizar en servidor
    });

    // Mensajes en foreground
    FirebaseMessaging.onMessage.listen((message) {
      _handleForegroundMessage(message);
    });

    // Mensajes cuando la app está en background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleBackgroundMessage(message);
    });

    // Verificar si la app se abrió desde una notificación
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('Mensaje recibido: ${message.notification?.title}');
    
    // Mostrar notificación local
    NotificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: message.notification?.title ?? 'Sin título',
      body: message.notification?.body ?? 'Sin contenido',
      payload: message.data.toString(),
    );
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    print('App abierta desde notificación: ${message.notification?.title}');
    
    // Navegar a pantalla específica basado en data
    final data = message.data;
    if (data.containsKey('screen')) {
      // Navigator.pushNamed(context, data['screen']);
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}
```

---

### 3. Background Tasks

#### workmanager

```yaml
dependencies:
  workmanager: ^0.5.1
```

```dart
import 'package:workmanager/workmanager.dart';

class BackgroundService {
  static const String taskName = 'background_task';

  static Future<void> initialize() async {
    await Workmanager().initialize(
      _callbackDispatcher,
      isInDebugMode: true,
    );
  }

  static void _callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      print('Ejecutando tarea en background: $task');

      // Sincronizar datos
      await _syncData();

      // Descargar actualizaciones
      await _downloadUpdates();

      return Future.value(true);
    });
  }

  static Future<void> _syncData() async {
    // Implementar sincronización
  }

  static Future<void> _downloadUpdates() async {
    // Implementar descarga
  }

  static Future<void> registerPeriodicTask() async {
    await Workmanager().registerPeriodicTask(
      taskName,
      taskName,
      frequency: const Duration(hours: 1),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );
  }

  static Future<void> registerOneOffTask() async {
    await Workmanager().registerOneOffTask(
      taskName,
      taskName,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  static Future<void> cancelTask() async {
    await Workmanager().cancelByUniqueName(taskName);
  }
}
```

---

### 4. Ejercicios Prácticos

#### Ejercicio 1: App de recordatorios

Crear una app que:
- Programe notificaciones locales
- Muestre notificaciones diarias
- Permita cancelar recordatorios

#### Ejercicio 2: App de sincronización

Crear una app que:
- Sincronice datos en background
- Descarge actualizaciones periódicas
- Muestre notificaciones de progreso

**Resumen del Módulo 17:**

En este módulo aprendiste:

✅ Notificaciones locales con flutter_local_notifications
✅ Notificaciones push con Firebase Cloud Messaging
✅ Programación de notificaciones
✅ Background tasks con workmanager

**Próximo módulo:** Seguridad y Autenticación## Módulo 18: Seguridad y Autenticación (3 horas)

---

### 1. Autenticación Biométrica

#### local_auth

```yaml
dependencies:
  local_auth: ^2.1.8
```

```dart
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isAvailable() async {
    return await _auth.canCheckBiometrics;
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _auth.getAvailableBiometrics();
  }

  Future<bool> authenticate({
    String localizedReason = 'Autentícate para continuar',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (e) {
      if (e is PlatformException) {
        switch (e.code) {
          case notAvailable:
            print('Biometría no disponible');
            break;
          case notEnrolled:
            print('No hay credenciales registradas');
            break;
          case lockedOut:
            print('Demasiados intentos');
            break;
          case permanentlyLockedOut:
            print('Biometría deshabilitada permanentemente');
            break;
        }
      }
      return false;
    }
  }

  Future<void> stopAuthentication() async {
    await _auth.stopAuthentication();
  }
}

// Pantalla de autenticación
class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key});

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen> {
  final BiometricService _biometric = BiometricService();
  bool _isAuthenticating = false;
  String _status = 'Toca para autenticar';
  List<BiometricType> _availableBiometrics = [];

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final available = await _biometric.isAvailable();
    if (available) {
      _availableBiometrics = await _biometric.getAvailableBiometrics();
      setState(() {
        _status = 'Biometría disponible: ${_availableBiometrics.join(', ')}';
      });
    } else {
      setState(() {
        _status = 'Biometría no disponible en este dispositivo';
      });
    }
  }

  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
      _status = 'Autenticando...';
    });

    final authenticated = await _biometric.authenticate(
      localizedReason: 'Usa tu huella o Face ID para acceder',
    );

    setState(() {
      _isAuthenticating = false;
      _status = authenticated ? '¡Autenticado!' : 'Autenticación fallida';
    });

    if (authenticated) {
      // Navegar a pantalla principal
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fingerprint,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 32),
            Text(
              _status,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            if (_isAuthenticating)
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                onPressed: _authenticate,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Autenticar'),
              ),
          ],
        ),
      ),
    );
  }
}
```

---

### 2. Almacenamiento Seguro

#### flutter_secure_storage

```yaml
dependencies:
  flutter_secure_storage: ^9.0.0
```

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<void> save(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  // Guardar tokens de autenticación
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await save('access_token', accessToken);
    await save('refresh_token', refreshToken);
  }

  Future<Map<String, String>?> getTokens() async {
    final accessToken = await read('access_token');
    final refreshToken = await read('refresh_token');

    if (accessToken == null || refreshToken == null) {
      return null;
    }

    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }

  Future<void> clearTokens() async {
    await delete('access_token');
    await delete('refresh_token');
  }
}
```

---

### 3. Cifrado de Datos

#### encrypt

```yaml
dependencies:
  encrypt: ^5.0.1
  cryptography: ^2.7.0
```

```dart
import 'package:encrypt/encrypt.dart';
import 'package:cryptography/cryptography.dart';

class EncryptionService {
  // AES Encryption
  final _key = Key.fromUtf8('mi_clave_secreta_32_caracteres!!');
  final _iv = IV.fromLength(16);

  String encryptAES(String text) {
    final encrypter = Encrypter(AES(_key));
    final encrypted = encrypter.encrypt(text, iv: _iv);
    return encrypted.base64;
  }

  String decryptAES(String encryptedText) {
    final encrypter = Encrypter(AES(_key));
    final decrypted = encrypter.decrypt64(encryptedText, iv: _iv);
    return decrypted;
  }

  // RSA Encryption (asymmetric)
  KeyPair? _rsaKeyPair;

  Future<void> generateRSAKeyPair() async {
    final algorithm = X25519();
    _rsaKeyPair = await algorithm.newKeyPair();
  }

  Future<String> encryptRSA(String text) async {
    if (_rsaKeyPair == null) {
      await generateRSAKeyPair();
    }
    
    // Implementar cifrado RSA
    final publicKey = await _rsaKeyPair!.extractPublicKey();
    final algorithm = X25519();
    
    // Nota: RSA en Flutter requiere implementación adicional
    return text; // Placeholder
  }

  // Hashing
  String hashPassword(String password, String salt) {
    final encrypter = Encrypter(AES(_key));
    return encrypter.encrypt(password + salt, iv: _iv).base64;
  }

  bool verifyPassword(String password, String hash, String salt) {
    final encrypted = hashPassword(password, salt);
    return encrypted == hash;
  }
}
```

---

### 4. SSL Pinning

```dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class SecureHttpClient {
  static Future<http.Client> createPinnedClient() async {
    final sslCert = await rootBundle.load('assets/certificates/cert.pem');
    
    final securityContext = SecurityContext(withTrustedRoots: false);
    securityContext.setTrustedCertificatesBytes(sslCert.buffer.asUint8List());

    final httpClient = HttpClient(context: securityContext);
    
    return IOClient(httpClient);
  }

  static Future<http.Client> createPinnedClientFromCerts(List<String> certPaths) async {
    final securityContext = SecurityContext(withTrustedRoots: false);
    
    for (final path in certPaths) {
      final cert = await rootBundle.load(path);
      securityContext.setTrustedCertificatesBytes(cert.buffer.asUint8List());
    }

    final httpClient = HttpClient(context: securityContext);
    return IOClient(httpClient);
  }
}

// Uso
class ApiService {
  late final http.Client _client;

  Future<void> init() async {
    _client = await SecureHttpClient.createPinnedClient();
  }

  Future<http.Response> get(String url) async {
    return await _client.get(Uri.parse(url));
  }

  Future<http.Response> post(String url, dynamic body) async {
    return await _client.post(
      Uri.parse(url),
      body: body,
      headers: {'Content-Type': 'application/json'},
    );
  }
}
```

---

### 5. Ejercicios Prácticos

#### Ejercicio 1: App con PIN

Crear una app que:
- Configure un PIN de 4 dígitos
- Solicite PIN al abrir la app
- Use biometría como alternativa
- Bloquee después de 3 intentos

#### Ejercicio 2: App con datos cifrados

Crear una app que:
- Guarde contraseñas cifradas
- Use almacenamiento seguro
- Implemente autenticación biométrica

**Resumen del Módulo 18:**

En este módulo aprendiste:

✅ Autenticación biométrica con local_auth
✅ Almacenamiento seguro con flutter_secure_storage
✅ Cifrado de datos con encrypt
✅ SSL Pinning para APIs seguras

**Próximo módulo:** Internacionalización## Módulo 19: Internacionalización (2 horas)

---

### 1. Configuración de Localización

#### flutter_localizations e intl

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.18.1
```

#### Estructura de archivos

```
lib/
├── l10n/
│   ├── app_localizations.dart
│   ├── app_localizations_delegate.dart
│   └── arb/
│       ├── app_en.arb
│       ├── app_es.arb
│       └── app_fr.arb
```

#### Configuración en main.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App',
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('fr'),
      ],
      home: const HomeScreen(),
    );
  }
}
```

---

### 2. Archivos ARB

#### app_en.arb

```json
{
  "@@locale": "en",
  "appTitle": "My App",
  "@appTitle": {
    "description": "The title of the application"
  },
  "hello": "Hello",
  "@hello": {
    "description": "Greeting message"
  },
  "helloUser": "Hello {name}",
  "@helloUser": {
    "description": "Greeting message with name",
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  },
  "itemsCount": "{count, plural, one{1 item} other{{count} items}}",
  "@itemsCount": {
    "description": "Number of items",
    "placeholders": {
      "count": {
        "type": "int"
      }
    }
  },
  "lastSeen": "Last seen {time}",
  "@lastSeen": {
    "description": "Time since last seen",
    "placeholders": {
      "time": {
        "type": "String"
      }
    }
  },
  "settings": "Settings",
  "language": "Language",
  "theme": "Theme",
  "darkMode": "Dark Mode",
  "lightMode": "Light Mode",
  "logout": "Logout",
  "login": "Login",
  "email": "Email",
  "password": "Password",
  "welcomeMessage": "Welcome to {app}!",
  "@welcomeMessage": {
    "placeholders": {
      "app": {
        "type": "String"
      }
    }
  }
}
```

#### app_es.arb

```json
{
  "@@locale": "es",
  "appTitle": "Mi App",
  "hello": "Hola",
  "helloUser": "Hola {name}",
  "itemsCount": "{count, plural, one{1 elemento} other{{count} elementos}}",
  "lastSeen": "Visto hace {time}",
  "settings": "Configuración",
  "language": "Idioma",
  "theme": "Tema",
  "darkMode": "Modo Oscuro",
  "lightMode": "Modo Claro",
  "logout": "Cerrar Sesión",
  "login": "Iniciar Sesión",
  "email": "Email",
  "password": "Contraseña",
  "welcomeMessage": "¡Bienvenido a {app}!"
}
```

---

### 3. Implementación de Localizaciones

```dart
// l10n/app_localizations.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationsDelegate();

  Future<bool> load() async {
    String jsonString = await rootBundle.loadString(
      'assets/i18n/${locale.languageCode}.json',
    );
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
    return true;
  }

  String translate(String key, {Map<String, String>? args}) {
    String text = _localizedStrings[key] ?? key;
    if (args != null) {
      args.forEach((argKey, argValue) {
        text = text.replaceAll('{$argKey}', argValue);
      });
    }
    return text;
  }

  // Getters para textos comunes
  String get appTitle => _localizedStrings['appTitle'] ?? 'My App';
  String get hello => _localizedStrings['hello'] ?? 'Hello';
  String get settings => _localizedStrings['settings'] ?? 'Settings';
  String get language => _localizedStrings['language'] ?? 'Language';
  String get theme => _localizedStrings['theme'] ?? 'Theme';
  String get darkMode => _localizedStrings['darkMode'] ?? 'Dark Mode';
  String get lightMode => _localizedStrings['lightMode'] ?? 'Light Mode';
  String get logout => _localizedStrings['logout'] ?? 'Logout';
  String get login => _localizedStrings['login'] ?? 'Login';
  String get email => _localizedStrings['email'] ?? 'Email';
  String get password => _localizedStrings['password'] ?? 'Password';

  String helloUser(String name) {
    return translate('helloUser', args: {'name': name});
  }

  String itemsCount(int count) {
    return translate('itemsCount', args: {'count': count.toString()});
  }

  String welcomeMessage(String app) {
    return translate('welcomeMessage', args: {'app': app});
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
```

---

### 4. Extension para Fácil Acceso

```dart
// extensions/context_extension.dart
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

// Uso
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.appTitle)),
      body: Center(
        child: Column(
          children: [
            Text(context.l10n.hello),
            Text(context.l10n.helloUser('Juan')),
            Text(context.l10n.itemsCount(5)),
          ],
        ),
      ),
    );
  }
}
```

---

### 5. Cambio de Idioma Dinámico

```dart
class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  static const Map<String, Locale> localeMap = {
    'English': Locale('en'),
    'Español': Locale('es'),
    'Français': Locale('fr'),
  };
}

// Pantalla de configuración
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLocale = languageProvider.locale;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.language)),
      body: ListView.builder(
        itemCount: LanguageProvider.localeMap.length,
        itemBuilder: (context, index) {
          final entry = LanguageProvider.localeMap.entries.elementAt(index);
          final isSelected = currentLocale == entry.value;

          return ListTile(
            title: Text(entry.key),
            trailing: isSelected ? const Icon(Icons.check) : null,
            selected: isSelected,
            onTap: () {
              languageProvider.setLocale(entry.value);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
```

---

### 6. Formateo de Fechas y Números

```dart
import 'package:intl/intl.dart';

class FormatService {
  // Fechas
  String formatDate(DateTime date, {String locale = 'en'}) {
    return DateFormat.yMMMMd(locale).format(date);
  }

  String formatShortDate(DateTime date, {String locale = 'en'}) {
    return DateFormat.yMd(locale).format(date);
  }

  String formatTime(DateTime date, {String locale = 'en'}) {
    return DateFormat.jm(locale).format(date);
  }

  String formatDateTime(DateTime date, {String locale = 'en'}) {
    return DateFormat.yMMMMd(locale).add_jm().format(date);
  }

  String formatRelative(DateTime date, {String locale = 'en'}) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return DateFormat.yMMMd(locale).format(date);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Números
  String formatNumber(num number, {String locale = 'en'}) {
    return NumberFormat.decimalPattern(locale).format(number);
  }

  String formatCurrency(num amount, {String locale = 'en', String symbol = '\$'}) {
    return NumberFormat.currency(locale: locale, symbol: symbol).format(amount);
  }

  String formatPercent(num value, {String locale = 'en'}) {
    return NumberFormat.percentPattern(locale).format(value);
  }

  String formatCompact(num number, {String locale = 'en'}) {
    return NumberFormat.compact(locale: locale).format(number);
  }
}
```

---

### 7. RTL (Right-to-Left)

```dart
class RTLExample extends StatelessWidget {
  const RTLExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('مثال RTL')),
        body: const Center(
          child: Text('النص من اليمين إلى اليسار'),
        ),
      ),
    );
  }
}

// Detectar dirección automáticamente
bool isRTL(Locale locale) {
  final rtlLocales = ['ar', 'he', 'fa', 'ur'];
  return rtlLocales.contains(locale.languageCode);
}

TextDirection getTextDirection(Locale locale) {
  return isRTL(locale) ? TextDirection.rtl : TextDirection.ltr;
}
```

---

### 8. Ejercicios Prácticos

#### Ejercicio 1: App multidioma

Crear una app que:
- Soporte 3 idiomas
- Permita cambiar idioma
- Formatee fechas y monedas correctamente
- Guarde preferencia de idioma

#### Ejercicio 2: App RTL

Crear una app que:
- Detecte idioma RTL
- Ajuste la dirección del texto
- Invierta iconos y navegación

**Resumen del Módulo 19:**

En este módulo aprendiste:

✅ Configuración de localización
✅ Archivos ARB para traducciones
✅ Cambio de idioma dinámico
✅ Formateo de fechas y números
✅ Soporte RTL

**Próximo módulo:** Plataformas Específicas# Curso Completo de Flutter - 30 Horas

## Módulo 1: Introducción a Flutter (2 horas)

---

### 1. Qué es Flutter y Dart

#### ¿Qué es Flutter?

Flutter es un framework de desarrollo de aplicaciones multiplataforma creado por Google. Permite crear aplicaciones para iOS, Android, Web y plataformas de escritorio (Windows, macOS, Linux) desde una única base de código.

**Características principales:**

- **Multiplataforma real**: Un solo código funciona en iOS, Android, Web y Desktop
- **Renderizado propio**: Flutter dibuja todos los elementos de la interfaz (no usa componentes nativos)
- **Hot Reload**: Los cambios en el código se reflejan instantáneamente en la app
- **Widget-based**: Todo en Flutter es un widget, desde un botón hasta la pantalla completa
- **Lenguaje Dart**: Flutter usa Dart, un lenguaje optimizado para UI

**Ventajas de Flutter:**

| Ventaja | Descripción |
|---------|-------------|
| Productividad | Hot Reload permite iterar muy rápido |
| Consistencia | La UI se ve igual en todas las plataformas |
| Performance | Compila a código nativo (no hay bridge como React Native) |
| UI Expressiva | Animaciones fluidas y controles personalizados |
| Open Source | Gratis y con una comunidad muy activa |

**Flutter vs Alternativas:**

| Framework | Lenguaje | Performance | UI Nativa | Hot Reload |
|-----------|----------|-------------|------------|------------|
| Flutter | Dart | Alta | No (renderiza propio) | Sí |
| React Native | JavaScript | Media | Sí (componentes nativos) | Sí |
| Native iOS | Swift | Máxima | Sí | No (rebuild) |
| Native Android | Kotlin | Máxima | Sí | No (rebuild) |

#### ¿Qué es Dart?

Dart es el lenguaje de programación que usa Flutter. Fue creado por Google y está optimizado para desarrollo de interfaces de usuario.

**Características de Dart:**

- **Tipado estático**: Los tipos se verifican en tiempo de compilación
- **Null safety**: Sistema robusto para evitar errores de valores nulos
- **Orientado a objetos**: Clases, herencia, mixins, interfaces
- **Compilación AOT y JIT**: Código nativo en producción, Hot Reload en desarrollo
- **Sintaxis familiar**: Similar a Java, JavaScript, Swift

**Ejemplo básico de Dart:**

```dart
// Variables y tipos
String nombre = 'Flutter';
int version = 3;
double rendimiento = 60.0; // FPS
bool esMultiplataforma = true;

// Funciones
void main() {
  print('Bienvenido a $nombre $version');
  print('Performance: $rendimiento FPS');
  print('Multiplataforma: $esMultiplataforma');
}

// Clases
class Aplicacion {
  String nombre;
  int version;

  // Constructor con sintaxis corta
  Aplicacion(this.nombre, this.version);

  // Método
  void ejecutar() {
    print('Ejecutando $nombre v$version');
  }
}
```

**¿Por qué Dart para Flutter?**

1. **Hot Reload**: El JIT (Just-In-Time) de Dart permite recargar código sin reiniciar
2. **Performance**: El AOT (Ahead-Of-Time) compila a código máquina nativo
3. **Productividad**: Sintaxis limpia y características modernas
4. **Reactive**: Soporte nativo para programación asíncrona y streams

---

### 2. Instalación y configuración del entorno de desarrollo

#### Requisitos del sistema

**Para Windows:**
- Windows 10 o superior (64-bit)
- Espacio en disco: 2.5 GB mínimo
- Git instalado

**Para macOS:**
- macOS 10.14 (Mojave) o superior
- Xcode (para desarrollo iOS)
- Git instalado

**Para Linux:**
- Ubuntu 18.04 LTS o superior (o equivalente)
- Git instalado

#### Instalación paso a paso

**1. Descargar Flutter SDK**

```bash
# Windows (PowerShell)
# Descargar desde: https://docs.flutter.dev/get-started/install/windows

# macOS
git clone https://github.com/flutter/flutter.git -b stable

# Linux
git clone https://github.com/flutter/flutter.git -b stable
```

**2. Configurar PATH**

```bash
# Agregar Flutter al PATH

# macOS/Linux (agregar a ~/.bashrc o ~/.zshrc)
export PATH="$PATH:`pwd`/flutter/bin"

# Windows: Agregar a variables de entorno del sistema
# C:\flutter\bin
```

**3. Verificar instalación**

```bash
# Ejecutar comando de verificación
flutter doctor

# Este comando verifica:
# - Flutter SDK instalado
# - Android Studio / VS Code
# - Conexión a dispositivos
# - Herramientas necesarias
```

**Salida típica de flutter doctor:**

```
Doctor summary (to see all details, run flutter doctor -v):

[✓] Flutter (Channel stable, 3.19.0)
[✓] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
[✓] Xcode - develop for iOS and macOS (Xcode 15.2)
[✓] Chrome - develop for the web
[✓] Android Studio (version 2023.2)
[✓] VS Code (version 1.86)
[✓] Connected device (3 available)
[✓] Network resources

! Doctor found issues in 1 category.
```

**4. Instalar extensiones en VS Code**

Extensiones recomendadas:

- **Flutter** (Dart Code) - Oficial de Flutter
- **Dart** (Dart Code) - Soporte para Dart
- **Awesome Flutter Snippets** - Snippets útiles
- **Flutter Widget Snippets** - Snippets de widgets
- **Error Lens** - Muestra errores en línea

**5. Configurar emuladores**

**Android Emulator:**

```bash
# Crear emulador desde Android Studio
# Tools > Device Manager > Create Device

# O desde línea de comandos
flutter emulators --create --name android_emulator

# Listar emuladores disponibles
flutter emulators

# Iniciar emulador
flutter emulators --launch android_emulator
```

**iOS Simulator (solo macOS):**

```bash
# Abrir Simulator
open -a Simulator

# Listar dispositivos iOS
flutter devices
```

#### Verificación completa

```bash
# Crear proyecto de prueba
flutter create mi_primera_app
cd mi_primera_app

# Ejecutar en modo debug
flutter run

# Si todo está correcto, verás la app de contador por defecto
```

---

### 3. Estructura de un proyecto Flutter

#### Anatomía del proyecto

Cuando ejecutas `flutter create mi_app`, se genera esta estructura:

```
mi_app/
├── android/                 # Configuración específica de Android
│   ├── app/
│   │   ├── src/
│   │   │   └── main/
│   │   │       └── AndroidManifest.xml
│   │   └── build.gradle
│   └── build.gradle
├── ios/                     # Configuración específica de iOS
│   └── Runner/
│       ├── Info.plist
│       └── AppDelegate.swift
├── lib/                     # Código Dart (aquí va tu app)
│   └── main.dart           # Punto de entrada
├── test/                    # Tests unitarios y de widgets
│   └── widget_test.dart
├── web/                     # Configuración para Web
│   ├── index.html
│   └── manifest.json
├── linux/                   # Configuración para Linux
├── macos/                   # Configuración para macOS
├── windows/                 # Configuración para Windows
├── pubspec.yaml            # Dependencias y metadata
├── pubspec.lock            # Versiones exactas de dependencias
├── .gitignore              # Archivos ignorados por Git
├── .metadata              # Metadata de Flutter
└── README.md              # Documentación del proyecto
```

#### Archivos clave explicados

**pubspec.yaml - El corazón del proyecto**

```yaml
name: mi_app                          # Nombre del paquete
description: Mi primera app Flutter   # Descripción
publish_to: 'none'                   # No publicar en pub.dev
version: 1.0.0+1                      # Versión (versión+build_number)

environment:
  sdk: '>=3.0.0 <4.0.0'              # Versión de Dart SDK requerida

dependencies:
  flutter:                            # SDK de Flutter
    sdk: flutter
  cupertino_icons: ^1.0.2            # Iconos estilo iOS

dev_dependencies:
  flutter_test:                       # Herramientas de testing
    sdk: flutter
  flutter_lints: ^2.0.0              # Linting rules

flutter:
  uses-material-design: true          # Usar Material Design

  # Assets (imágenes, fuentes, etc.)
  # assets:
  #   - images/
  #   - fonts/

  # Fuentes personalizadas
  # fonts:
  #   - family: MiFuente
  #     fonts:
  #       - asset: fonts/MiFuente-Regular.ttf
```

**main.dart - Punto de entrada**

```dart
import 'package:flutter/material.dart';

void main() {
  // Punto de entrada de la aplicación
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp es el widget raíz para apps Material Design
    return MaterialApp(
      title: 'Mi Primera App',
      theme: ThemeData(
        // Tema de la aplicación
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Text(
          '¡Hola Flutter!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
```

#### Carpetas importantes

**lib/ - Tu código Dart**

```
lib/
├── main.dart              # Punto de entrada
├── screens/               # Pantallas/Páginas
│   ├── home_screen.dart
│   ├── details_screen.dart
│   └── settings_screen.dart
├── widgets/               # Widgets reutilizables
│   ├── custom_button.dart
│   └── user_card.dart
├── models/                # Modelos de datos
│   ├── user.dart
│   └── product.dart
├── services/              # Lógica de negocio/APIs
│   ├── api_service.dart
│   └── auth_service.dart
├── providers/             # Estado (Provider, Riverpod, BLoC)
│   └── user_provider.dart
└── utils/                 # Utilidades
    ├── constants.dart
    └── helpers.dart
```

**test/ - Tests**

```dart
// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/main.dart';

void main() {
  testWidgets('App muestra texto inicial', (WidgetTester tester) async {
    // Construir la app
    await tester.pumpWidget(const MiApp());

    // Verificar que existe el texto
    expect(find.text('¡Hola Flutter!'), findsOneWidget);
  });
}
```

---

### 4. Hot Reload vs Hot Restart

#### ¿Qué es Hot Reload?

Hot Reload es una de las características más importantes de Flutter. Permite ver los cambios en el código casi instantáneamente sin perder el estado de la aplicación.

**Cómo funciona:**

1. Haces un cambio en el código Dart
2. Guardas el archivo (o presionas el botón de Hot Reload)
3. Flutter inyecta el código actualizado en la Dart VM
4. El widget se reconstruye conservando su estado

**Ventajas:**
- Desarrollo muy rápido
- No pierdes datos del estado (formularios llenos, posición en listas, etc.)
- Iteración instantánea en UI

**Ejemplo práctico:**

```dart
class ContadorWidget extends StatefulWidget {
  const ContadorWidget({super.key});

  @override
  State<ContadorWidget> createState() => _ContadorWidgetState();
}

class _ContadorWidgetState extends State<ContadorWidget> {
  int contador = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // CAMBIA ESTE TEXTO Y USA HOT RELOAD
        Text(
          'Has presionado $contador veces',  // Cambia el texto aquí
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              contador++;
            });
          },
          child: const Text('Incrementar'),
        ),
      ],
    );
  }
}
```

**Con Hot Reload:**
1. Presiona el botón 5 veces (contador = 5)
2. Cambia el texto a "Veces presionadas: $contador"
3. Guarda y Hot Reload
4. **Resultado:** El contador sigue en 5, pero el texto cambió

**Sin Hot Reload (Hot Restart):**
1. Presiona el botón 5 veces (contador = 5)
2. Cambia el texto
3. Hot Restart
4. **Resultado:** El contador vuelve a 0 (estado perdido)

#### Hot Restart (Reinicio en caliente)

Hot Restart recarga completamente la aplicación, similar a cerrar y volver a abrir la app.

**Cuándo usar Hot Restart:**

- Cambios en el código de inicialización (main())
- Cambios en el tema global (MaterialApp)
- Añadir nuevas dependencias (requiere `flutter pub get`)
- Cambios en el estado que no se reflejan con Hot Reload
- Errores que persisten después de Hot Reload

**Cómo ejecutar:**

```bash
# En la terminal (mientras flutter run está activo)
# Presiona 'R' mayúscula para Hot Restart
# Presiona 'r' minúscula para Hot Reload

# O en VS Code:
# - Hot Reload: Ctrl+S (guardar) o botón ⚡
# - Hot Restart: Shift+R o botón 🔄
```

#### Diferencias detalladas

| Característica | Hot Reload | Hot Restart |
|----------------|------------|-------------|
| Velocidad | ~1 segundo | ~3-5 segundos |
| Estado | Conservado | Reiniciado |
| Código inyectado | Solo cambios | Todo el código |
| main() | No se ejecuta | Se ejecuta de nuevo |
| Variables estáticas | No se actualizan | Se reinician |
| Dependencias nuevas | ❌ No funciona | ✅ Funciona |

#### Cuándo NO funciona Hot Reload

**1. Cambios en main():**

```dart
void main() {
  // Estos cambios requieren Hot Restart
  runApp(const MiApp());
}
```

**2. Cambios en variables globales o estáticas:**

```dart
// Variable global - requiere Hot Restart
const String API_URL = 'https://api.example.com';

class Config {
  // Variable estática - requiere Hot Restart
  static String ambiente = 'dev';
}
```

**3. Cambios en inicializadores:**

```dart
class MiWidget extends StatefulWidget {
  const MiWidget({super.key});

  @override
  State<MiWidget> createState() => MiWidgetState();
}

// Cambios en initState requieren Hot Restart
class MiWidgetState extends State<MiWidget> {
  @override
  void initState() {
    super.initState();
    // Código de inicialización
  }
}
```

**4. Cambios en enums:**

```dart
// Añadir o modificar enums requiere Hot Restart
enum Estado { inicial, cargando, error, exito }
```

---

### 5. Widget Tree y Render Tree

#### Concepto fundamental

Flutter funciona con tres árboles principales que trabajan juntos:

1. **Widget Tree**: Configuración de la UI (inmutable)
2. **Element Tree**: Instancias de widgets en memoria (gestiona ciclo de vida)
3. **Render Tree**: Objetos que realmente dibujan en pantalla

**Widget Tree:**

```dart
// Esta estructura forma el Widget Tree
MaterialApp
└── Scaffold
    ├── AppBar
    │   └── Text
    └── Center
        └── Text
```

**Ejemplo visual:**

```dart
class EjemploWidget extends StatelessWidget {
  const EjemploWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // El Widget Tree se construye aquí
    return MaterialApp(                    // Widget
      home: Scaffold(                      // Widget
        appBar: AppBar(                    // Widget
          title: const Text('Mi App'),    // Widget
        ),
        body: Center(                     // Widget
          child: const Text(              // Widget
            'Hola Mundo',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
```

#### Flujo de renderizado

```
Widget (Configuración)
    ↓
Element (Gestiona estado y ciclo de vida)
    ↓
RenderObject (Dibuja en pantalla)
```

**Ejemplo detallado del flujo:**

```dart
// 1. WIDGET (Configuración inmutable)
// Solo describe QUÉ se debe renderizar
class MiBoton extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;

  const MiBoton({
    super.key,
    required this.texto,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Retorna configuración del widget hijo
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(texto),
    );
  }
}

// 2. ELEMENT (Gestiona el widget)
// Element es creado por Flutter automáticamente
// Mantiene la posición en el árbol y gestiona actualizaciones
// Cuando el widget se reconstruye, Element compara si debe actualizar el RenderObject

// 3. RENDER OBJECT (Dibuja)
// RenderBox/RenderParagraph/etc. realmente pintan en el canvas
```

#### StatelessWidget vs StatefulWidget en el árbol

**StatelessWidget:**

```dart
// StatelessWidget - Sin estado mutable
class TarjetaUsuario extends StatelessWidget {
  final String nombre;
  final String email;

  const TarjetaUsuario({
    super.key,
    required this.nombre,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    // Se recrea cada vez que los parámetros cambian
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(email),
          ],
        ),
      ),
    );
  }
}
```

**StatefulWidget:**

```dart
// StatefulWidget - Con estado mutable
class ContadorWidget extends StatefulWidget {
  final int valorInicial;

  const ContadorWidget({
    super.key,
    this.valorInicial = 0,
  });

  @override
  State<ContadorWidget> createState() => _ContadorWidgetState();
}

// La clase State PERSISTE entre reconstrucciones
class _ContadorWidgetState extends State<ContadorWidget> {
  // Este estado se mantiene incluso cuando el widget se reconstruye
  late int contador;

  @override
  void initState() {
    super.initState();
    contador = widget.valorInicial;  // Acceder a propiedades del widget
  }

  void incrementar() {
    setState(() {
      contador++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Este método se llama cada vez que setState() es invocado
    return Row(
      children: [
        Text('Contador: $contador'),
        ElevatedButton(
          onPressed: incrementar,
          child: const Text(' + '),
        ),
      ],
    );
  }
}
```

#### El árbol en acción

```dart
// Ejemplo completo mostrando cómo interactúan los árboles
class AppCompleja extends StatelessWidget {
  const AppCompleja({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Árboles Flutter')),
        body: ListView.builder(
          itemCount: 100,
          itemBuilder: (context, index) {
            // Cada ListTile es un Widget
            // Flutter crea Elements y RenderObjects eficientemente
            // ListView.builder solo renderiza los items visibles
            return ListTile(
              leading: CircleAvatar(child: Text('$index')),
              title: Text('Usuario $index'),
              subtitle: Text('email$index@example.com'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                // Navegación
              },
            );
          },
        ),
      ),
    );
  }
}
```

**Flujo de actualización:**

```
1. Usuario toca botón "Incrementar"
2. onTap llama a setState()
3. Flutter marca el Element como "dirty"
4. En el siguiente frame, Flutter llama a build()
5. Se crea un nuevo Widget Tree
6. Flutter compara con el árbol anterior (diffing)
7. Solo actualiza los RenderObjects que cambiaron
8. GPU dibuja solo lo que cambió
```

#### Optimización del árbol

**Mal ejemplo (Widget hondo):**

```dart
// Demasiados niveles de anidación
Widget malEjemplo() {
  return Container(
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Column(
          children: [
            Container(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Container(
                      child: Text('Texto'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
```

**Buen ejemplo (Widget plano):**

```dart
// Menos niveles, mismo resultado
Widget buenEjemplo() {
  return Padding(
    padding: const EdgeInsets.all(8),
    child: Column(
      children: [
        Row(
          children: [
            Text('Texto'),
          ],
        ),
      ],
    ),
  );
}
```

**Regla:** Minimiza la profundidad del árbol siempre que sea posible.

---

### 6. Primer proyecto: "Hola Mundo"

#### Crear el proyecto

```bash
# Crear nuevo proyecto
flutter create hola_mundo
cd hola_mundo

# Ejecutar en dispositivo/emulador
flutter run
```

#### Limpiar el código por defecto

Flutter genera mucho código por defecto. Vamos a crear un "Hola Mundo" minimalista:

```dart
// lib/main.dart
import 'package:flutter/material.dart';

void main() {
  runApp(const HolaMundoApp());
}

class HolaMundoApp extends StatelessWidget {
  const HolaMundoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp: Widget raíz para apps Material Design
    return MaterialApp(
      // Ocultar banner de debug
      debugShowCheckedModeBanner: false,

      // Título de la app (usado por el sistema)
      title: 'Hola Mundo',

      // Tema global de la app
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),

      // Pantalla inicial
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold: Estructura básica de una pantalla
    return Scaffold(
      // AppBar: Barra superior con título y acciones
      appBar: AppBar(
        title: const Text('Mi Primera App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),

      // Body: Contenido principal
      body: const Center(
        // Center: Centra el contenido hijo
        child: Column(
          // Column: Organiza widgets verticalmente
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono decorativo
            Icon(
              Icons.waving_hand,
              size: 80,
              color: Colors.amber,
            ),
            SizedBox(height: 20), // Espaciado
            // Texto principal
            Text(
              '¡Hola Mundo!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            // Texto secundario
            Text(
              'Bienvenido a Flutter',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),

      // FloatingActionButton: Botón flotante de acción principal
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acción al presionar
          print('¡Botón presionado!');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

#### Versión interactiva con estado

Vamos a crear una versión más interactiva que cuente clics:

```dart
// lib/main.dart - Versión interactiva
import 'package:flutter/material.dart';

void main() {
  runApp(const HolaMundoInteractivo());
}

class HolaMundoInteractivo extends StatelessWidget {
  const HolaMundoInteractivo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hola Mundo Interactivo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ContadorPage(),
    );
  }
}

class ContadorPage extends StatefulWidget {
  const ContadorPage({super.key});

  @override
  State<ContadorPage> createState() => _ContadorPageState();
}

class _ContadorPageState extends State<ContadorPage> {
  // Estado mutable del widget
  int _contador = 0;
  String _mensaje = 'Presiona el botón';

  void _incrementar() {
    setState(() {
      _contador++;

      // Cambiar mensaje según el contador
      if (_contador == 0) {
        _mensaje = 'Presiona el botón';
      } else if (_contador < 5) {
        _mensaje = '¡Sigue así!';
      } else if (_contador < 10) {
        _mensaje = '¡Vas muy bien!';
      } else if (_contador < 20) {
        _mensaje = '¡Increíble!';
      } else {
        _mensaje = '¡Eres un experto!';
      }
    });
  }

  void _reiniciar() {
    setState(() {
      _contador = 0;
      _mensaje = 'Presiona el botón';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contador Interactivo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Botón de reinicio en la AppBar
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reiniciar,
            tooltip: 'Reiniciar contador',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mostrar mensaje
            Text(
              _mensaje,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            // Mostrar contador
            Text(
              '$_contador',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 40),
            // Botón de decrementar
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _contador > 0
                      ? () {
                          setState(() {
                            _contador--;
                            if (_contador == 0) _mensaje = 'Presiona el botón';
                          });
                        }
                      : null, // Deshabilitado si contador es 0
                  icon: const Icon(Icons.remove),
                  label: const Text('Decrementar'),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: _incrementar,
                  icon: const Icon(Icons.add),
                  label: const Text('Incrementar'),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _reiniciar,
        tooltip: 'Reiniciar',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
```

#### Ejercicio práctico: Personalizar el Hola Mundo

**Objetivo:** Modifica el código para:

1. Cambiar el color del tema a tu color favorito
2. Añadir un segundo contador
3. Agregar un botón para alternar entre modo claro/oscuro

**Solución:**

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MiAppPersonalizada());
}

class MiAppPersonalizada extends StatefulWidget {
  const MiAppPersonalizada({super.key});

  @override
  State<MiAppPersonalizada> createState() => _MiAppPersonalizadaState();
}

class _MiAppPersonalizadaState extends State<MiAppPersonalizada> {
  bool _modoOscuro = false;
  int _contador1 = 0;
  int _contador2 = 0;

  void _alternarTema() {
    setState(() {
      _modoOscuro = !_modoOscuro;
    });
  }

  void _incrementarContador(int numero) {
    setState(() {
      if (numero == 1) {
        _contador1++;
      } else {
        _contador2++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App Personalizada',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple, // Tu color favorito
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _modoOscuro ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Mi App Personalizada'),
          actions: [
            IconButton(
              icon: Icon(_modoOscuro ? Icons.light_mode : Icons.dark_mode),
              onPressed: _alternarTema,
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Contador 1: $_contador1',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _incrementarContador(1),
                child: const Text('Incrementar 1'),
              ),
              const SizedBox(height: 30),
              Text(
                'Contador 2: $_contador2',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _incrementarContador(2),
                child: const Text('Incrementar 2'),
              ),
              const SizedBox(height: 30),
              Text(
                'Total: ${_contador1 + _contador2}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### Resumen del Módulo 1

En este módulo aprendiste:

✅ Qué es Flutter y por qué usarlo
✅ Qué es Dart y sus características principales
✅ Instalar y configurar Flutter
✅ Estructura de un proyecto Flutter
✅ Diferencia entre Hot Reload y Hot Restart
✅ Cómo funciona el Widget Tree y Render Tree
✅ Crear tu primera app Flutter

**Próximos pasos:**
- Módulo 2: Fundamentos de Dart
- Módulo 3: Widgets Básicos

---

## Módulo 20: Plataformas Específicas (4 horas)

---

### 1. Plataformas Soportadas

Flutter soporta múltiples plataformas:

| Plataforma | Estado | Notas |
|------------|--------|-------|
| Android | Estable | SDK mínimo 21 |
| iOS | Estable | Requiere Mac + Xcode |
| Web | Estable | Chrome, Safari, Edge |
| Windows | Estable | Visual Studio |
| macOS | Estable | Xcode |
| Linux | Estable | GTK |

#### Requisitos por plataforma

```bash
# Verificar dispositivos y plataformas disponibles
flutter devices
flutter doctor -v

# Habilitar plataformas
flutter config --enable-web
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
flutter config --enable-linux-desktop

# Crear proyecto multiplataforma
flutter create --platforms=android,ios,web,windows,macos,linux my_app
```

---

### 2. Platform Channels

#### Conceptos fundamentales

Flutter se comunica con código nativo a través de:
- **MethodChannel**: Llamadas a métodos
- **EventChannel**: Streams de eventos
- **BasicMessageChannel**: Mensajes bidireccionales

#### MethodChannel básico

```dart
import 'package:flutter/services.dart';

class NativeService {
  static const MethodChannel _channel = MethodChannel('com.example.app/native');

  // Llamar método nativo
  static Future<String?> getPlatformVersion() async {
    try {
      final String? version = await _channel.invokeMethod('getPlatformVersion');
      return version;
    } on PlatformException catch (e) {
      print('Error: ${e.message}');
      return null;
    }
  }

  static Future<String?> getDeviceModel() async {
    try {
      final String? model = await _channel.invokeMethod('getDeviceModel');
      return model;
    } on PlatformException catch (e) {
      print('Error: ${e.message}');
      return null;
    }
  }

  // Con argumentos
  static Future<bool> saveToGallery(String imagePath) async {
    try {
      final bool success = await _channel.invokeMethod('saveToGallery', {
        'imagePath': imagePath,
      });
      return success;
    } on PlatformException catch (e) {
      print('Error: ${e.message}');
      return false;
    }
  }
}
```

#### Implementación Android (Kotlin)

```kotlin
// android/app/src/main/kotlin/com/example/app/MainActivity.kt
package com.example.app

import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.app/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getPlatformVersion" -> {
                    result.success("Android ${Build.VERSION.RELEASE}")
                }
                "getDeviceModel" -> {
                    result.success("${Build.MANUFACTURER} ${Build.MODEL}")
                }
                "saveToGallery" -> {
                    val imagePath = call.argument<String>("imagePath")
                    if (imagePath != null) {
                        val success = saveImageToGallery(imagePath)
                        result.success(success)
                    } else {
                        result.error("INVALID_ARGUMENT", "imagePath is required", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun saveImageToGallery(imagePath: String): Boolean {
        // Implementar guardado en galería
        return true
    }
}
```

#### Implementación iOS (Swift)

```swift
// ios/Runner/AppDelegate.swift
import UIKit
import Flutter
import Photos

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private let CHANNEL = "com.example.app/native"

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        let nativeChannel = FlutterMethodChannel(
            name: CHANNEL,
            binaryMessenger: controller.binaryMessenger
        )

        nativeChannel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "getPlatformVersion":
                result.success("iOS \(UIDevice.current.systemVersion)")
            case "getDeviceModel":
                result.success(UIDevice.current.model)
            case "saveToGallery":
                guard let args = call.arguments as? [String: Any],
                      let imagePath = args["imagePath"] as? String else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "imagePath is required", details: nil))
                    return
                }
                self?.saveImageToGallery(imagePath: imagePath, result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func saveImageToGallery(imagePath: String, result: @escaping FlutterResult) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                result(FlutterError(code: "PERMISSION_DENIED", message: "Photo library permission denied", details: nil))
                return
            }

            // Guardar imagen
            result(true)
        }
    }
}
```

---

### 3. EventChannel para Streams

```dart
import 'package:flutter/services.dart';

class BatteryService {
  static const EventChannel _channel = EventChannel('com.example.app/battery');

  static Stream<int> get batteryLevel {
    return _channel.receiveBroadcastStream().map((event) => event as int);
  }
}

// Uso
class BatteryScreen extends StatefulWidget {
  const BatteryScreen({super.key});

  @override
  State<BatteryScreen> createState() => _BatteryScreenState();
}

class _BatteryScreenState extends State<BatteryScreen> {
  int _batteryLevel = 0;

  @override
  void initState() {
    super.initState();
    BatteryService.batteryLevel.listen((level) {
      setState(() {
        _batteryLevel = level;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Batería: $_batteryLevel%'),
      ),
    );
  }
}
```

#### Implementación Android EventChannel

```kotlin
class BatteryStreamHandler(
    private val context: Context
) : EventChannel.StreamHandler {
    private var receiver: BroadcastReceiver? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val level = intent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
                events?.success(level)
            }
        }

        val filter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        context.registerReceiver(receiver, filter)
    }

    override fun onCancel(arguments: Any?) {
        receiver?.let {
            context.unregisterReceiver(it)
        }
    }
}

// En MainActivity
EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.app/battery")
    .setStreamHandler(BatteryStreamHandler(this))
```

---

### 4. Acceso a Hardware Específico

#### Cámara

```dart
import 'package:camera/camera.dart';

class CameraService {
  List<CameraDescription> cameras = [];
  CameraController? controller;

  Future<void> initialize() async {
    cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      controller = CameraController(
        cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller!.initialize();
    }
  }

  Future<XFile?> takePicture() async {
    if (controller == null || !controller!.value.isInitialized) return null;
    return await controller!.takePicture();
  }

  void dispose() {
    controller?.dispose();
  }
}
```

#### Sensores

```yaml
dependencies:
  sensors_plus: ^4.0.2
```

```dart
import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  // Acelerómetro
  Stream<AccelerometerEvent> get accelerometer => accelerometerEventStream();

  // Giroscopio
  Stream<GyroscopeEvent> get gyroscope => gyroscopeEventStream();

  // Magnetómetro
  Stream<MagnetometerEvent> get magnetometer => magnetometerEventStream();

  // Brújula
  Stream<CompassEvent> get compass => compassEventStream();

  // Ejemplo: Detectar movimiento
  void detectMovement() {
    accelerometer.listen((event) {
      final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      if (magnitude > 15) {
        print('Movimiento detectado!');
      }
    });
  }
}
```

#### Bluetooth

```yaml
dependencies:
  flutter_blue_plus: ^1.31.15
```

```dart
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothService {
  // Verificar si Bluetooth está disponible
  Future<bool> isAvailable() async {
    return await FlutterBluePlus.adapterState.first != BluetoothAdapterState.unavailable;
  }

  // Escanear dispositivos
  Future<void> scanDevices({Duration timeout = const Duration(seconds: 10)}) async {
    await FlutterBluePlus.startScan(timeout: timeout);
    await Future.delayed(timeout);
    await FlutterBluePlus.stopScan();
  }

  // Conectar a dispositivo
  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect(timeout: const Duration(seconds: 10));
  }

  // Desconectar
  Future<void> disconnect(BluetoothDevice device) async {
    await device.disconnect();
  }

  // Descubrir servicios
  Future<List<BluetoothService>> discoverServices(BluetoothDevice device) async {
    return await device.discoverServices();
  }

  // Leer característica
  Future<List<int>> readCharacteristic(BluetoothCharacteristic characteristic) async {
    return await characteristic.read();
  }

  // Escribir característica
  Future<void> writeCharacteristic(
    BluetoothCharacteristic characteristic,
    List<int> value,
  ) async {
    await characteristic.write(value);
  }
}
```

---

### 5. Adaptaciones por Plataforma

#### Widgets adaptativos

```dart
import 'dart:io' show Platform;

class AdaptiveScaffold extends StatelessWidget {
  final Widget? appBar;
  final Widget? drawer;
  final Widget? navigationRail;
  final Widget body;

  const AdaptiveScaffold({
    super.key,
    this.appBar,
    this.drawer,
    this.navigationRail,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    // Mobile: AppBar + Drawer
    if (Platform.isAndroid || Platform.isIOS) {
      return Scaffold(
        appBar: appBar as PreferredSizeWidget?,
        drawer: drawer,
        body: body,
      );
    }

    // Desktop: Navigation Rail
    return Scaffold(
      body: Row(
        children: [
          if (navigationRail != null) navigationRail!,
          Expanded(child: body),
        ],
      ),
    );
  }
}

// Widget adaptativo
class AdaptiveIcon extends StatelessWidget {
  final IconData android;
  final IconData ios;
  final double? size;
  final Color? color;

  const AdaptiveIcon({
    super.key,
    required this.android,
    required this.ios,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      Platform.isIOS ? ios : android,
      size: size,
      color: color,
    );
  }
}
```

#### Detección de plataforma

```dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformInfo {
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isLinux => !kIsWeb && Platform.isLinux;
  static bool get isWeb => kIsWeb;
  static bool get isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  static bool get isFuchsia => !kIsWeb && Platform.isFuchsia;

  static String get platformName {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isLinux) return 'linux';
    if (Platform.isFuchsia) return 'fuchsia';
    return 'unknown';
  }

  static TargetPlatform get defaultTargetPlatform {
    if (kIsWeb) return TargetPlatform.android;
    return defaultTargetPlatform;
  }
}
```

---

### 6. Plugins Específicos

#### Flutter Plugin Architecture

```yaml
# pubspec.yaml
dependencies:
  shared_preferences: ^2.2.2
  path_provider: ^2.1.1
  package_info_plus: ^5.0.1
  device_info_plus: ^9.1.1
  connectivity_plus: ^5.0.2
```

#### Path Provider

```dart
import 'package:path_provider/path_provider.dart';

class PathService {
  // Directorio de documentos (persistente)
  Future<Directory> getDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  // Cache temporal
  Future<Directory> getCacheDirectory() async {
    return await getTemporaryDirectory();
  }

  // Almacenamiento externo (Android)
  Future<Directory?> getExternalStorageDirectory() async {
    return await getExternalStorageDirectory();
  }

  // Descargas (Android)
  Future<List<Directory>> getExternalStorageDirectories() async {
    return await getExternalStorageDirectories(type: StorageDirectory.downloads) ?? [];
  }

  // Soporte externo
  Future<Directory?> getExternalStorage() async {
    if (Platform.isAndroid) {
      return await getExternalStorageDirectory();
    }
    return null;
  }
}
```

#### Package Info

```dart
import 'package:package_info_plus/package_info_plus.dart';

class AppInfoService {
  static Future<PackageInfo> getPackageInfo() async {
    return await PackageInfo.fromPlatform();
  }

  static Future<String> getAppName() async {
    final info = await getPackageInfo();
    return info.appName;
  }

  static Future<String> getVersion() async {
    final info = await getPackageInfo();
    return info.version;
  }

  static Future<String> getBuildNumber() async {
    final info = await getPackageInfo();
    return info.buildNumber;
  }

  static Future<String> getPackageName() async {
    final info = await getPackageInfo();
    return info.packageName;
  }
}
```

#### Device Info

```dart
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static Future<BaseDeviceInfo> getDeviceInfo() async {
    return await _deviceInfo.deviceInfo;
  }

  static Future<AndroidDeviceInfo> getAndroidInfo() async {
    return await _deviceInfo.androidInfo;
  }

  static Future<IosDeviceInfo> getIosInfo() async {
    return await _deviceInfo.iosInfo;
  }

  static Future<WebBrowserInfo> getWebBrowserInfo() async {
    return await _deviceInfo.webBrowserInfo;
  }

  static Future<String> getDeviceId() async {
    if (Platform.isAndroid) {
      final info = await getAndroidInfo();
      return info.id;
    } else if (Platform.isIOS) {
      final info = await getIosInfo();
      return info.identifierForVendor ?? 'unknown';
    }
    return 'unknown';
  }

  static Future<String> getDeviceModel() async {
    if (Platform.isAndroid) {
      final info = await getAndroidInfo();
      return '${info.manufacturer} ${info.model}';
    } else if (Platform.isIOS) {
      final info = await getIosInfo();
      return info.model;
    }
    return 'unknown';
  }
}
```

#### Connectivity

```dart
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();

  static Future<List<ConnectivityResult>> checkConnectivity() async {
    return await _connectivity.checkConnectivity();
  }

  static Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  static bool isConnected(List<ConnectivityResult> result) {
    return !result.contains(ConnectivityResult.none);
  }

  static bool isWifi(List<ConnectivityResult> result) {
    return result.contains(ConnectivityResult.wifi);
  }

  static bool isMobile(List<ConnectivityResult> result) {
    return result.contains(ConnectivityResult.mobile);
  }
}
```

---

### 7. Plataforma Web

#### Diferencias Web

```dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

class WebService {
  static bool get isWeb => kIsWeb;

  static void openUrl(String url) {
    if (kIsWeb) {
      html.window.open(url, '_blank');
    }
  }

  static void setWindowTitle(String title) {
    if (kIsWeb) {
      html.document.title = title;
    }
  }

  static String get currentUrl {
    if (kIsWeb) {
      return html.window.location.href;
    }
    return '';
  }

  static void reload() {
    if (kIsWeb) {
      html.window.location.reload();
    }
  }

  // Storage Web
  static void saveToLocalStorage(String key, String value) {
    if (kIsWeb) {
      html.window.localStorage[key] = value;
    }
  }

  static String? getFromLocalStorage(String key) {
    if (kIsWeb) {
      return html.window.localStorage[key];
    }
    return null;
  }
}
```

#### Responsive Web

```dart
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return desktop;
        } else if (constraints.maxWidth >= 600) {
          return tablet;
        } else {
          return mobile;
        }
      },
    );
  }
}
```

---

### 8. Ejercicios Prácticos

#### Ejercicio 1: App multiplataforma

Crear una app que:
- Detecte la plataforma actual
- Muestre información del dispositivo
- Tenga widgets adaptativos por plataforma
- Use MethodChannel para obtener datos nativos

#### Ejercicio 2: Integración con hardware

Crear una app que:
- Use sensores del dispositivo
- Implemente funcionalidad de cámara
- Use Bluetooth para conectar con dispositivos
- Funcione en Android, iOS y Web

---

**Resumen del Módulo 20:**

En este módulo aprendiste:

✅ Plataformas soportadas por Flutter
✅ Platform Channels (MethodChannel, EventChannel)
✅ Implementaciones nativas en Android e iOS
✅ Acceso a hardware específico
✅ Widgets adaptativos por plataforma
✅ Diferencias y adaptaciones para Web
✅ Plugins comunes (path_provider, device_info, connectivity)

---

**🎉 ¡Temario Completo!**

Has completado los 20 módulos del temario de Flutter:
- 10 módulos originales (30 horas)
- 10 módulos adicionales (27 horas)
- **Total: 57 horas de contenido**

Próximos pasos recomendados:
- Practicar con proyectos reales
- Contribuir a paquetes de código abierto
- Crear tu portafolio de apps## Módulo 2: Fundamentos de Dart (4 horas)

---

### 1. Variables y Tipos de Datos

#### Variables

En Dart, las variables almacenan referencias a objetos. El tipo de variable se puede inferir o declarar explícitamente.

```dart
// Inferencia de tipos - Dart infiere el tipo automáticamente
var nombre = 'Ana';           // Tipo: String
var edad = 25;                // Tipo: int
var altura = 1.75;            // Tipo: double
var esEstudiante = true;     // Tipo: bool
var notas = [8, 9, 10];      // Tipo: List<int>

// Declaración explícita de tipos
String ciudad = 'Madrid';
int poblacion = 3200000;
double temperatura = 23.5;
bool activo = true;

// Tipo Object - acepta cualquier valor
Object cualquierCosa = 'puede ser string';
cualquierCosa = 42;           // ahora es int
cualquierCosa = true;         // ahora es bool

// Tipo dynamic - desactiva la verificación de tipos estática
dynamic dinamico = 'texto';
dinamico = 42;                // válido en tiempo de compilación
dinamico.hola();              // válido en compilación, error en runtime si no existe
```

#### final y const

`final` y `const` declaran variables inmutables, pero con diferencias importantes:

```dart
// final - asignación única, valor determinado en runtime
final String nombre = 'Carlos';
final DateTime ahora = DateTime.now();  // válido, se evalúa en runtime

// const - constante en tiempo de compilación
const pi = 3.14159;
const velocidadLuz = 299792458;  // metros por segundo

// Diferencia clave:
final ahora = DateTime.now();     // ✅ válido - se evalúa en runtime
const ahora2 = DateTime.now();     // ❌ Error - debe ser constante en compilación

// const con colecciones
const colores = ['rojo', 'verde', 'azul'];
const configuracion = {
  'servidor': 'localhost',
  'puerto': 8080,
};

// const en objetos
class Punto {
  final int x;
  final int y;
  
  const Punto(this.x, this.y);  // constructor constante
  
  static const Punto origen = Punto(0, 0);
}

const punto1 = Punto(10, 20);
const punto2 = Punto(10, 20);
print(identical(punto1, punto2));  // true - son el mismo objeto
```

#### Tipos numéricos

```dart
// int - números enteros
int edad = 30;
int hex = 0xFF;              // 255 en hexadecimal
int binario = 0b1111;        // 15 en binario

// double - números de punto flotante
double pi = 3.14159265359;
double cientifico = 1.42e5;  // 142000.0

// Operaciones numéricas
int a = 10;
int b = 3;

print(a + b);   // 13 - suma
print(a - b);   // 7  - resta
print(a * b);   // 30 - multiplicación
print(a / b);   // 3.333... - división (siempre double)
print(a ~/ b);  // 3  - división entera
print(a % b);   // 1  - módulo (resto)

// Métodos útiles
int valor = -42;
print(valor.abs());      // 42 - valor absoluto
print(valor.sign);       // -1 - signo (-1, 0, o 1)
print(3.14159.round());  // 3 - redondeo
print(3.14159.ceil());   // 4 - redondeo hacia arriba
print(3.14159.floor());  // 3 - redondeo hacia abajo
print(3.14159.toInt());  // 3 - conversión a int
print(42.toDouble());     // 42.0 - conversión a double

// Parsing desde String
int.parse('42');          // 42
double.parse('3.14');     // 3.14
int.tryParse('abc');      // null (no lanza excepción)
```

#### Strings

```dart
// Literales de string
String simple = 'Hola mundo';
String comillasDobles = "Hola mundo";
String multilinea = '''
Este es un string
que ocupa múltiples
líneas
''';

// Interpolación
String nombre = 'María';
int edad = 28;
String saludo = 'Hola, soy $nombre';
String info = 'Tengo $edad años, el año que viene tendré ${edad + 1}';
String expresion = 'El resultado es ${5 * 7}';

// Concatenación
String parte1 = 'Hola';
String parte2 = 'Mundo';
String completo = parte1 + ' ' + parte2;  // 'Hola Mundo'

// Propiedades y métodos
String texto = '  Flutter es genial  ';
print(texto.length);           // 20
print(texto.isEmpty);          // false
print(texto.contains('Flutter')); // true
print(texto.startsWith('  '));    // true
print(texto.endsWith('l  '));     // true
print(texto.indexOf('es'));       // 9
print(texto.lastIndexOf('e'));    // 15

// Métodos de transformación
print(texto.trim());           // 'Flutter es genial'
print(texto.toUpperCase());    // '  FLUTTER ES GENIAL  '
print(texto.toLowerCase());    // '  flutter es genial  '
print(texto.substring(2, 9));  // 'Flutter'
print(texto.replaceAll('e', 'E')); // '  FluttEr Es gEnial  '

// División y unión
String csv = 'uno,dos,tres,cuatro';
List<String> lista = csv.split(',');  // ['uno', 'dos', 'tres', 'cuatro']
String unido = lista.join('-');        // 'uno-dos-tres-cuatro'

// Raw strings (interpreta literalmente)
String raw = r'C:\Users\Nombre\Archivo.txt';  // Las barras no se escapan
String escape = 'C:\\Users\\Nombre\\Archivo.txt';  // Equivalente sin r

// String vacío vs null
String vacio = '';
String? nulo = null;
print(vacio.isEmpty);   // true
print(vacio.length);    // 0
// print(nulo.isEmpty); // Error - null no tiene métodos
print(nulo?.isEmpty);   // null - acceso seguro
```

#### Booleanos

```dart
bool activo = true;
bool inactivo = false;

// Operadores lógicos
bool a = true;
bool b = false;

print(!a);        // false - NOT
print(a && b);    // false - AND
print(a || b);    // true  - OR

// Expresiones que evalúan a booleano
int edad = 18;
bool esMayorEdad = edad >= 18;           // true
bool puedeVotar = edad >= 18 && edad <= 120;  // true

String? nombre;
bool tieneNombre = nombre != null;      // false

// Operador if-null (??)
bool? nullableBool;
bool resultado = nullableBool ?? false;  // false

// Igualdad
print(5 == 5);    // true
print(5 == '5');  // false - tipos diferentes
print(true == 1); // false - no hay conversión automática
```

#### Colecciones: Listas

```dart
// Creación de listas
List<int> numeros = [1, 2, 3, 4, 5];
var frutas = ['manzana', 'banana', 'naranja'];
List<String> vacia = [];
var listaMixta = [1, 'dos', true];  // List<Object>

// Lista con tamaño fijo
List<int> fija = List.filled(5, 0);       // [0, 0, 0, 0, 0]
List<int> generar = List.generate(5, (i) => i * 2);  // [0, 2, 4, 6, 8]

// Acceso a elementos
print(frutas[0]);        // 'manzana'
print(frutas.first);     // 'manzana'
print(frutas.last);      // 'naranja'
print(frutas.length);    // 3

// Índices negativos no están soportados directamente, pero se puede:
print(frutas[frutas.length - 1]);  // Último elemento

// Modificar listas
frutas.add('pera');              // Añadir al final
frutas.addAll(['uva', 'mango']); // Añadir múltiples
frutas.insert(1, 'kiwi');        // Insertar en posición
frutas.insertAll(1, ['piña', 'fresa']);  // Insertar múltiples
frutas.remove('banana');          // Eliminar por valor
frutas.removeAt(0);               // Eliminar por índice
frutas.removeLast();             // Eliminar el último
frutas.removeWhere((f) => f.startsWith('m')); // Eliminar condicional
frutas.clear();                  // Vaciar lista

// Operador spread (...)
var lista1 = [1, 2, 3];
var lista2 = [4, 5, 6];
var combinada = [...lista1, ...lista2];  // [1, 2, 3, 4, 5, 6]

// Spread con null-aware (...?)
List<int>? nullableList = null;
var segura = [0, ...?nullableList, 7];  // [0, 7] - ignora null

// Collection if
bool activo = true;
var elementos = [
  'elemento1',
  'elemento2',
  if (activo) 'elemento activo',
];
// ['elemento1', 'elemento2', 'elemento activo']

// Collection for
var numeros = [1, 2, 3];
var duplicados = [
  for (var n in numeros) n * 2
];  // [2, 4, 6]

// Métodos funcionales
var nums = [1, 2, 3, 4, 5];

// map - transforma cada elemento
var cuadrados = nums.map((n) => n * n).toList();  // [1, 4, 9, 16, 25]

// where - filtra elementos
var pares = nums.where((n) => n % 2 == 0).toList();  // [2, 4]

// any - ¿algún elemento cumple la condición?
bool algunMayor4 = nums.any((n) => n > 4);  // true

// every - ¿todos los elementos cumplen?
bool todosPositivos = nums.every((n) => n > 0);  // true

// reduce - combina elementos en un valor
int suma = nums.reduce((a, b) => a + b);  // 15

// fold - reduce con valor inicial
int producto = nums.fold(1, (a, b) => a * b);  // 120

// sort - ordenar in-place
var desordenado = [3, 1, 4, 1, 5, 9, 2, 6];
desordenado.sort();  // [1, 1, 2, 3, 4, 5, 6, 9]

// sort con comparador personalizado
var personas = [
  {'nombre': 'Ana', 'edad': 30},
  {'nombre': 'Carlos', 'edad': 25},
  {'nombre': 'Beto', 'edad': 35},
];
personas.sort((a, b) => (a['edad'] as int).compareTo(b['edad'] as int));

// sublist - obtener sublista
var nums2 = [1, 2, 3, 4, 5];
var sub = nums2.sublist(1, 4);  // [2, 3, 4]

// indexOf - encontrar posición
print(frutas.indexOf('naranja'));    // 2
print(frutas.indexOf('pera'));       // -1 (no encontrado)

// contains - verificar existencia
print(frutas.contains('manzana'));   // true
```

#### Colecciones: Sets

```dart
// Creación de sets (colecciones sin duplicados)
Set<int> numeros = {1, 2, 3, 4, 5};
var frutas = <String>{'manzana', 'banana', 'naranja'};
Set<String> vacio = {};  // Set vacío

// Set vacío vs Map vacío
var esSetVacio = <int>{};      // Set<int>
var esMapVacio = <int, int>{}; // Map<int, int>

// Los duplicados se eliminan automáticamente
var conDuplicados = [1, 2, 2, 3, 3, 3, 4];
Set<int> sinDuplicados = conDuplicados.toSet();  // {1, 2, 3, 4}

// Operaciones de conjuntos
var setA = {1, 2, 3, 4};
var setB = {3, 4, 5, 6};

// Unión
var union = setA.union(setB);  // {1, 2, 3, 4, 5, 6}

// Intersección
var interseccion = setA.intersection(setB);  // {3, 4}

// Diferencia
var diferencia = setA.difference(setB);  // {1, 2}

// Métodos
frutas.add('pera');           // Añadir elemento
frutas.addAll(['uva', 'mango']);  // Añadir múltiples
frutas.remove('banana');      // Eliminar elemento
frutas.contains('manzana');   // true
frutas.containsAll({'manzana', 'pera'});  // true si todos están
frutas.length;               // Cantidad de elementos
frutas.isEmpty;               // ¿Está vacío?
```

#### Colecciones: Maps

```dart
// Creación de maps (diccionarios clave-valor)
Map<String, int> edades = {
  'Ana': 28,
  'Carlos': 32,
  'María': 25,
};
var capitales = <String, String>{
  'España': 'Madrid',
  'Francia': 'París',
  'Italia': 'Roma',
};
Map<int, String> vacio = {};

// Acceso a valores
print(edades['Ana']);      // 28
print(edades['Pedro']);    // null (no existe)
print(edades['Pedro'] ?? 0);  // 0 (valor por defecto)

// Modificar maps
edades['Pedro'] = 30;           // Añadir o actualizar
edades.putIfAbsent('Laura', () => 27);  // Añadir si no existe
edades.update('Ana', (valor) => valor + 1);  // Actualizar valor
edades.remove('Carlos');        // Eliminar por clave
edades.clear();                 // Vaciar map

// Propiedades
print(edades.length);          // Cantidad de pares
print(edades.isEmpty);          // ¿Está vacío?
print(edades.keys);             // Iterable de claves
print(edades.values);           // Iterable de valores
print(edades.entries);           // Iterable de MapEntry

// Iteración
capitales.forEach((pais, capital) {
  print('$pais: $capital');
});

for (var entry in capitales.entries) {
  print('${entry.key} -> ${entry.value}');
}

for (var pais in capitales.keys) {
  print(pais);
}

// Map desde listas
var nombres = ['Ana', 'Carlos', 'María'];
var longitudes = nombres.asMap().map((index, nombre) => 
  MapEntry(index, nombre.length)
);  // {0: 3, 1: 6, 2: 5}

// Métodos útiles
var mapa = {'a': 1, 'b': 2, 'c': 3};

// containsKey - verificar si existe clave
print(mapa.containsKey('a'));  // true

// containsValue - verificar si existe valor
print(mapa.containsValue(2));  // true

// updateAll - actualizar todos los valores
mapa.updateAll((key, value) => value * 2);  // {'a': 2, 'b': 4, 'c': 6}

// removeWhere - eliminar condicional
mapa.removeWhere((key, value) => value > 3);  // {'a': 2}

// map - transformar a nuevo map
var nuevoMapa = mapa.map((key, value) => 
  MapEntry(key.toUpperCase(), value * 10)
);
```

---

### 2. Operadores

#### Operadores aritméticos

```dart
int a = 10;
int b = 3;

// Operadores básicos
print(a + b);    // 13 - suma
print(a - b);    // 7  - resta
print(a * b);    // 30 - multiplicación
print(a / b);    // 3.333... - división (double)
print(a ~/ b);   // 3  - división entera
print(a % b);    // 1  - módulo (resto)
print(-a);       // -10 - negación unaria

// Incremento y decremento
int x = 5;
print(x++);  // 5 (imprime, luego incrementa) - x ahora es 6
print(++x);  // 7 (incrementa, luego imprime)
print(x--);  // 7 (imprime, luego decrementa) - x ahora es 6
print(--x);  // 5 (decrementa, luego imprime)

// Ejemplo práctico: división con resto
int dividend = 17;
int divisor = 5;
int cociente = dividend ~/ divisor;   // 3
int resto = dividend % divisor;         // 2
print('$dividend ÷ $divisor = $cociente con resto $resto');
print('Verificación: ${divisor * cociente + resto} = $dividend'); // 17 = 17
```

#### Operadores de asignación

```dart
// Asignación simple
int a = 10;

// Asignación compuesta
a += 5;   // a = a + 5  → 15
a -= 3;   // a = a - 3  → 12
a *= 2;   // a = a * 2  → 24
a ~/= 5;  // a = a ~/ 5 → 4
a %= 3;   // a = a % 3  → 1

// Asignación if-null (??=)
int? b;
b ??= 10;  // Si b es null, asigna 10
print(b);  // 10

int c = 5;
c ??= 10;  // Si c NO es null, no hace nada
print(c);  // 5
```

#### Operadores de igualdad y relacionales

```dart
// Igualdad
print(5 == 5);    // true
print(5 == '5');  // false - tipos diferentes
print(5 != 5);    // false

// Comparaciones
print(5 > 3);     // true
print(5 < 3);     // false
print(5 >= 5);    // true
print(5 <= 4);    // false

// Comparación de strings
print('abc' == 'abc');      // true
print('abc'.compareTo('abd'));  // -1 (abc < abd)
print('abc'.compareTo('abc'));  // 0 (iguales)
print('abd'.compareTo('abc'));  // 1 (abd > abc)

// identical - verifica si son el MISMO objeto
var lista1 = [1, 2, 3];
var lista2 = [1, 2, 3];
var lista3 = lista1;

print(lista1 == lista2);     // true - mismo contenido
print(identical(lista1, lista2));  // false - objetos diferentes
print(identical(lista1, lista3));  // true - mismo objeto

// const crea objetos canónicos
const a1 = [1, 2, 3];
const a2 = [1, 2, 3];
print(identical(a1, a2));    // true - objetos canónicos
```

#### Operadores lógicos

```dart
bool activo = true;
bool verificado = false;

// NOT lógico
print(!activo);           // false

// AND lógico (cortocircuito)
print(activo && verificado);  // false
// Si el primero es false, no evalúa el segundo

// OR lógico (cortocircuito)
print(activo || verificado);  // true
// Si el primero es true, no evalúa el segundo

// Ejemplo de cortocircuito
String? nombre;
// Si nombre es null, no intenta imprimir length
bool esValido = nombre != null && nombre.length > 0;  // false, seguro

// Operadores a nivel de bits
int x = 5;   // binario: 0101
int y = 3;   // binario: 0011

print(x & y);   // 1   (AND: 0001)
print(x | y);   // 7   (OR:  0111)
print(x ^ y);   // 6   (XOR: 0110)
print(~x);      // -6  (NOT: inversión de bits)
print(x << 2);  // 20  (desplazamiento izquierda: 10100)
print(x >> 1);  // 2   (desplazamiento derecha: 0010)
```

#### Operadores de tipo

```dart
// is - verifica si es de un tipo
Object valor = 'Hola';

if (valor is String) {
  print('Es un String de ${valor.length} caracteres');
}

if (valor is! int) {
  print('No es un int');
}

// as - conversión de tipo (cast)
Object objeto = 'Texto';
String texto = objeto as String;  // Conversión explícita

// Peligroso si no es del tipo correcto
// Object numero = 'no es numero';
// int n = numero as int;  // Error en runtime

// is + cast automático (promoción de tipo)
void procesar(Object valor) {
  if (valor is String) {
    // Dentro del if, Dart sabe que valor es String
    print(valor.toUpperCase());  // No necesita cast
  }
}

// Ejemplo práctico
void manejarDato(dynamic dato) {
  if (dato is int) {
    print('Entero: ${dato * 2}');
  } else if (dato is String) {
    print('String: ${dato.toUpperCase()}');
  } else if (dato is List) {
    print('Lista con ${dato.length} elementos');
  } else {
    print('Tipo desconocido: ${dato.runtimeType}');
  }
}
```

#### Operador condicional (ternario)

```dart
// Sintaxis: condición ? valorSiTrue : valorSiFalse
int edad = 20;
String estado = edad >= 18 ? 'Mayor de edad' : 'Menor de edad';
print(estado);  // Mayor de edad

// Anidamiento (usar con moderación)
int puntos = 85;
String calificacion = puntos >= 90 ? 'Excelente' 
                    : puntos >= 70 ? 'Aprobado' 
                    : 'Reprobado';

// Operador if-null (??)
String? nombre;
String saludo = 'Hola, ${nombre ?? 'Invitado'}';
print(saludo);  // Hola, Invitado

// Encadenamiento de ??
String? a;
String? b;
String? c = 'valor';
String resultado = a ?? b ?? c ?? 'default';
print(resultado);  // valor

// Ejemplo práctico
class Usuario {
  String? nombre;
  String? email;
  
  Usuario({this.nombre, this.email});
  
  String get nombreMostrar => nombre ?? email?.split('@')[0] ?? 'Anónimo';
}
```

#### Operador cascade (..)

```dart
class Persona {
  String nombre = '';
  int edad = 0;
  String ciudad = '';
  
  void presentarse() {
    print('Soy $nombre, tengo $edad años y vivo en $ciudad');
  }
}

// Sin cascade
var p1 = Persona();
p1.nombre = 'Ana';
p1.edad = 28;
p1.ciudad = 'Madrid';
p1.presentarse();

// Con cascade (más conciso)
var p2 = Persona()
  ..nombre = 'Carlos'
  ..edad = 32
  ..ciudad = 'Barcelona'
  ..presentarse();

// Cascade con constructor
class Punto {
  double x = 0;
  double y = 0;
  
  Punto();
  
  Punto.cero() : x = 0, y = 0;
}

var punto = Punto()
  ..x = 10
  ..y = 20;

// Cascade anidado
class Direccion {
  String calle = '';
  String ciudad = '';
}

class Persona2 {
  String nombre = '';
  Direccion direccion = Direccion();
}

var persona = Persona2()
  ..nombre = 'María'
  ..direccion.calle = 'Calle Principal'
  ..direccion.ciudad = 'Valencia';

// Cascade con null-aware (?..)
Persona2? personaNula;
personaNula
  ?..nombre = 'Pedro'
  ..direccion.ciudad = 'Sevilla';  // Solo si personaNula no es null
```

---

### 3. Control de Flujo

#### if-else

```dart
// If simple
int edad = 20;

if (edad >= 18) {
  print('Mayor de edad');
}

// If-else
if (edad >= 18) {
  print('Mayor de edad');
} else {
  print('Menor de edad');
}

// If-else if-else
int nota = 75;

if (nota >= 90) {
  print('Excelente');
} else if (nota >= 70) {
  print('Aprobado');
} else if (nota >= 50) {
  print('Suficiente');
} else {
  print('Reprobado');
}

// If con expresiones complejas
bool tieneLicencia = true;
bool tieneSeguro = true;
int edadConductor = 25;

if (edadConductor >= 18 && tieneLicencia && tieneSeguro) {
  print('Puede conducir');
}

// Short-circuit evaluation
bool? baseDatosDisponible;
bool? cacheDisponible;

// Si baseDatosDisponible es true, no evalúa lo demás
if (baseDatosDisponible ?? cacheDisponible ?? false) {
  print('Datos disponibles');
}
```

#### switch-case

```dart
// Switch básico
String dia = 'lunes';

switch (dia) {
  case 'lunes':
    print('Inicio de semana');
    break;
  case 'martes':
  case 'miércoles':
  case 'jueves':
    print('Medio de semana');
    break;
  case 'viernes':
    print('Viernes');
    break;
  case 'sábado':
  case 'domingo':
    print('Fin de semana');
    break;
  default:
    print('Día no reconocido');
}

// Switch con expresiones (Dart 3+)
String obtenerDia(int numero) {
  return switch (numero) {
    1 => 'Lunes',
    2 => 'Martes',
    3 => 'Miércoles',
    4 => 'Jueves',
    5 => 'Viernes',
    6 || 7 => 'Fin de semana',
    _ => 'Número inválido',
  };
}

// Switch con patrones
enum Estado { pendiente, aprobado, rechazado, enRevision }

void manejarEstado(Estado estado) {
  switch (estado) {
    case Estado.pendiente:
      print('Esperando aprobación');
      break;
    case Estado.aprobado:
      print('Aprobado');
      break;
    case Estado.rechazado:
      print('Rechazado');
      break;
    case Estado.enRevision:
      print('En revisión');
      break;
  }
}

// Switch con guardas (when)
void clasificarNumero(int n) {
  switch (n) {
    case > 0:
      print('Positivo');
      break;
    case < 0:
      print('Negativo');
      break;
    case 0:
      print('Cero');
      break;
  }
}

// Switch exhaustivo en enums
enum Transporte { auto, bicicleta, caminando }

void tiempoEstimado(Transporte t) {
  // El switch debe ser exhaustivo para todos los casos del enum
  switch (t) {
    case Transporte.auto:
      print('Rápido');
      break;
    case Transporte.bicicleta:
      print('Moderado');
      break;
    case Transporte.caminando:
      print('Lento');
      break;
  }
}
```

#### Bucles: for

```dart
// For básico
for (int i = 0; i < 5; i++) {
  print('Iteración $i');
}

// For con step personalizado
for (int i = 10; i >= 0; i -= 2) {
  print(i);  // 10, 8, 6, 4, 2, 0
}

// For-each en colecciones
var frutas = ['manzana', 'banana', 'naranja'];
for (var fruta in frutas) {
  print(fruta);
}

// For-each con índice
for (int i = 0; i < frutas.length; i++) {
  print('$i: ${frutas[i]}');
}

// forEach método
frutas.forEach((fruta) {
  print(fruta);
});

// forEach con índice usando asMap
frutas.asMap().forEach((indice, fruta) {
  print('$indice: $fruta');
});

// For sobre map
var edades = {'Ana': 28, 'Carlos': 32, 'María': 25};
for (var entrada in edades.entries) {
  print('${entrada.key}: ${entrada.value} años');
}

// For anidado (tablas de multiplicar)
for (int i = 1; i <= 3; i++) {
  for (int j = 1; j <= 3; j++) {
    print('$i × $j = ${i * j}');
  }
  print('---');
}
```

#### Bucles: while y do-while

```dart
// While - ejecuta mientras la condición sea true
int contador = 0;
while (contador < 5) {
  print('Contador: $contador');
  contador++;
}

// Ejemplo: leer hasta encontrar valor
var numeros = [1, 2, 3, -1, 4, 5];
int i = 0;
while (numeros[i] != -1) {
  print(numeros[i]);
  i++;
}

// Do-while - ejecuta al menos una vez
int n = 0;
do {
  print(n);
  n++;
} while (n < 3);

// Ejemplo práctico: validación de entrada
import 'dart:io';

String? obtenerEntrada() {
  String? entrada;
  do {
    stdout.write('Introduce un número positivo: ');
    entrada = stdin.readLineSync();
    int? numero = int.tryParse(entrada ?? '');
    if (numero != null && numero > 0) {
      return entrada;
    }
    print('Entrada inválida');
  } while (true);
}

// While con break
int valor = 0;
while (true) {
  print(valor);
  valor++;
  if (valor >= 5) {
    break;  // Sale del bucle
  }
}
```

#### break y continue

```dart
// break - sale del bucle completamente
for (int i = 0; i < 10; i++) {
  if (i == 5) {
    print('Deteniendo en $i');
    break;
  }
  print(i);
}
// Imprime: 0, 1, 2, 3, 4, Deteniendo en 5

// continue - salta a la siguiente iteración
for (int i = 0; i < 10; i++) {
  if (i % 2 == 0) {
    continue;  // Salta los pares
  }
  print(i);
}
// Imprime: 1, 3, 5, 7, 9

// continue con label (bucles anidados)
externo:
for (int i = 0; i < 3; i++) {
  for (int j = 0; j < 3; j++) {
    if (i == 1 && j == 1) {
      continue externo;  // Continúa en el bucle externo
    }
    print('($i, $j)');
  }
}
// Imprime: (0,0), (0,1), (0,2), (1,0), (2,0), (2,1), (2,2)

// break con label
externo:
for (int i = 0; i < 5; i++) {
  for (int j = 0; j < 5; j++) {
    if (i + j == 4) {
      break externo;  // Sale completamente de ambos bucles
    }
    print('($i, $j)');
  }
}
```

#### assert

```dart
// Assert verifica condiciones en desarrollo
int edad = 25;
assert(edad >= 0, 'La edad no puede ser negativa');
assert(edad < 150, 'Edad no válida');

// Assert con expresiones
String nombre = 'Ana';
assert(nombre.isNotEmpty, 'El nombre no puede estar vacío');
assert(nombre.length <= 100, 'El nombre es demasiado largo');

// Assert en funciones
double dividir(double a, double b) {
  assert(b != 0, 'El divisor no puede ser cero');
  return a / b;
}

// Assert en constructores
class Persona {
  final String nombre;
  final int edad;
  
  Persona(this.nombre, this.edad) {
    assert(nombre.isNotEmpty, 'El nombre es obligatorio');
    assert(edad >= 0, 'La edad debe ser positiva');
    assert(edad < 150, 'Edad no válida');
  }
}

// Nota: assert solo funciona en modo debug
// En producción, las aserciones se ignoran
```

---

### 4. Funciones

#### Declaración de funciones

```dart
// Función básica
int sumar(int a, int b) {
  return a + b;
}

// Función con tipo de retorno inferido
sumar2(int a, int b) {
  return a + b;  // Se infiere que retorna int
}

// Función sin retorno (void)
void saludar(String nombre) {
  print('Hola, $nombre');
}

// Arrow function (=>)
int cuadrado(int n) => n * n;
bool esPar(int n) => n % 2 == 0;
String saludar2(String nombre) => 'Hola, $nombre';

// Función con múltiples retornos
String clasificarNota(int nota) {
  if (nota >= 90) return 'Excelente';
  if (nota >= 70) return 'Aprobado';
  return 'Reprobado';
}
```

#### Parámetros

```dart
// Parámetros posicionales requeridos
int sumar(int a, int b) => a + b;
print(sumar(5, 3));  // 8

// Parámetros posicionales opcionales (entre [])
String saludar(String nombre, [String? apellido]) {
  if (apellido != null) {
    return 'Hola, $nombre $apellido';
  }
  return 'Hola, $nombre';
}
print(saludar('Ana'));           // Hola, Ana
print(saludar('Ana', 'García')); // Hola, Ana García

// Parámetros opcionales con valor por defecto
String saludar3(String nombre, [String titulo = 'Sr.']) {
  return 'Hola, $titulo $nombre';
}
print(saludar3('Ana'));          // Hola, Sr. Ana
print(saludar3('Ana', 'Sra.'));  // Hola, Sra. Ana

// Parámetros nombrados (entre {})
void crearUsuario({
  required String nombre,
  required String email,
  int edad = 0,
  bool activo = true,
}) {
  print('Usuario: $nombre, $email, $edad, activo: $activo');
}

crearUsuario(
  nombre: 'Ana',
  email: 'ana@email.com',
  edad: 28,
);

// Parámetros nombrados requeridos (required)
void enviarEmail({
  required String destinatario,
  required String asunto,
  String cuerpo = '',
}) {
  print('Enviando a: $destinatario');
  print('Asunto: $asunto');
}

enviarEmail(
  destinatario: 'user@email.com',
  asunto: 'Hola',
);

// Combinación de parámetros posicionales y nombrados
String formatear(String nombre, {String titulo = 'Sr.'}) {
  return '$titulo $nombre';
}
print(formatear('Ana', titulo: 'Sra.'));  // Sra. Ana

// Parámetros con valor por defecto que no son constantes
// Error: los valores por defecto deben ser constantes en compile-time
// DateTime ahora = DateTime.now(); // ❌ Error

// Solución: usar valor null y asignar en el cuerpo
void mostrarFecha({DateTime? fecha}) {
  fecha ??= DateTime.now();  // Si es null, asignar ahora
  print(fecha);
}
```

#### Funciones como objetos de primera clase

```dart
// Asignar función a variable
int sumar(int a, int b) => a + b;
var operacion = sumar;
print(operacion(5, 3));  // 8

// Función como parámetro
void ejecutarOperacion(int a, int b, int Function(int, int) operacion) {
  print('Resultado: ${operacion(a, b)}');
}

ejecutarOperacion(5, 3, sumar);
ejecutarOperacion(5, 3, (a, b) => a * b);  // 15

// Función que retorna otra función
Function multiplicarPor(int factor) {
  return (int numero) => numero * factor;
}

var porDos = multiplicarPor(2);
var porCinco = multiplicarPor(5);

print(porDos(10));   // 20
print(porCinco(10)); // 50

// Almacenar funciones en colecciones
var operaciones = <String, int Function(int, int)>{
  'sumar': (a, b) => a + b,
  'restar': (a, b) => a - b,
  'multiplicar': (a, b) => a * b,
  'dividir': (a, b) => a ~/ b,
};

print(operaciones['sumar']!(5, 3));  // 8
```

#### Funciones anónimas y closures

```dart
// Función anónima (lambda)
var lista = [1, 2, 3, 4, 5];

// Con función anónima completa
var pares = lista.where((numero) {
  return numero % 2 == 0;
}).toList();

// Con arrow function
var impares = lista.where((n) => n % 2 != 0).toList();

// forEach con función anónima
lista.forEach((elemento) {
  print(elemento * 2);
});

// Closure - función que captura variables del ámbito externo
Function hacerContador() {
  int contador = 0;
  return () {
    contador++;
    return contador;
  };
}

var contador1 = hacerContador();
var contador2 = hacerContador();

print(contador1());  // 1
print(contador1());  // 2
print(contador2());  // 1 - contador independiente

// Closure con parámetros
Function hacerMultiplicador(int factor) {
  return (int numero) => numero * factor;
}

var multiplicarPor3 = hacerMultiplicador(3);
print(multiplicarPor3(5));  // 15

// Uso práctico de closures
class Boton {
  String texto;
  Function onClick;
  
  Boton(this.texto, this.onClick);
}

void crearBotones() {
  var botones = <Boton>[];
  
  for (int i = 0; i < 3; i++) {
    botones.add(Boton('Botón $i', () {
      print('Clickeado: $i');  // Captura el valor de i
    }));
  }
  
  botones[0].onClick();  // Clickeado: 0
  botones[1].onClick();  // Clickeado: 1
  botones[2].onClick();  // Clickeado: 2
}
```

#### Funciones asíncronas

```dart
import 'dart:async';

// async y await
Future<String> obtenerDatos() async {
  await Future.delayed(Duration(seconds: 2));
  return 'Datos cargados';
}

// Función async básica
Future<void> procesarDatos() async {
  print('Iniciando...');
  String datos = await obtenerDatos();
  print(datos);
}

// Manejo de errores con try-catch
Future<void> procesarConError() async {
  try {
    String datos = await obtenerDatos();
    print(datos);
  } catch (e) {
    print('Error: $e');
  } finally {
    print('Proceso terminado');
  }
}

// Múltiples awaits
Future<void> procesarVarios() async {
  var dato1 = await obtenerDatos();
  var dato2 = await obtenerDatos();
  print('$dato1 y $dato2');
}

// Paralelo con Future.wait
Future<void> procesarParalelo() async {
  var resultados = await Future.wait([
    obtenerDatos(),
    obtenerDatos(),
    obtenerDatos(),
  ]);
  print(resultados);
}

// Future con tipado
Future<int> obtenerNumero() async {
  await Future.delayed(Duration(seconds: 1));
  return 42;
}

// Stream
Stream<int> contadorStream() async* {
  for (int i = 1; i <= 5; i++) {
    await Future.delayed(Duration(seconds: 1));
    yield i;
  }
}

Future<void> escucharStream() async {
  await for (var numero in contadorStream()) {
    print('Número: $numero');
  }
}
```

---

### 5. Programación Orientada a Objetos

#### Clases básicas

```dart
class Persona {
  // Propiedades (campos)
  String nombre;
  int edad;
  String ciudad;
  
  // Constructor
  Persona(this.nombre, this.edad, this.ciudad);
  
  // Constructor nombrado
  Persona.vacio()
      : nombre = 'Anónimo',
        edad = 0,
        ciudad = 'Desconocida';
  
  Persona.soloNombre(this.nombre)
      : edad = 0,
        ciudad = 'Desconocida';
  
  // Método
  void presentarse() {
    print('Hola, soy $nombre, tengo $edad años y vivo en $ciudad');
  }
  
  // Método con retorno
  String obtenerDescripcion() {
    return '$nombre ($edad años) de $ciudad';
  }
  
  // Getter
  bool get esMayorEdad => edad >= 18;
  
  // Setter
  set cambiarEdad(int nuevaEdad) {
    if (nuevaEdad >= 0 && nuevaEdad < 150) {
      edad = nuevaEdad;
    }
  }
}

// Uso
var persona1 = Persona('Ana', 28, 'Madrid');
persona1.presentarse();
print(persona1.obtenerDescripcion());
print(persona1.esMayorEdad);  // true

var persona2 = Persona.vacio();
persona2.presentarse();

persona1.cambiarEdad = 30;
print(persona1.edad);  // 30
```

#### Propiedades

```dart
class Punto {
  // Propiedades privadas (convención: _prefijo)
  double _x;
  double _y;
  
  // Constructor
  Punto(this._x, this._y);
  
  // Getters
  double get x => _x;
  double get y => _y;
  
  // Setter con validación
  set x(double valor) {
    if (valor >= 0) _x = valor;
  }
  
  set y(double valor) {
    if (valor >= 0) _y = valor;
  }
  
  // Getter computado
  double get distancia => sqrt(_x * _x + _y * _y);
  
  // Propiedad de solo lectura
  String get coordenadas => '($_x, $_y)';
}

import 'dart:math' show sqrt;
```

#### Constructores

```dart
class Punto2D {
  final double x;
  final double y;
  
  // Constructor por defecto
  Punto2D(this.x, this.y);
  
  // Constructor con valores por defecto
  Punto2D.origen()
      : x = 0,
        y = 0;
  
  // Constructor desde JSON
  Punto2D.fromJson(Map<String, dynamic> json)
      : x = json['x'],
        y = json['y'];
  
  // Constructor con lista inicializadora
  Punto2D.fromCoordenadas(String coordenadas)
      : x = double.parse(coordenadas.split(',')[0]),
        y = double.parse(coordenadas.split(',')[1]);
  
  // Constructor redireccionador
  Punto2D.cero() : this(0, 0);
  
  // Factory constructor
  static final _cache = <String, Punto2D>{};
  
  factory Punto2D.desdeCache(double x, double y) {
    var clave = '$x,$y';
    return _cache.putIfAbsent(clave, () => Punto2D(x, y));
  }
  
  // Método
  @override
  String toString() => 'Punto2D($x, $y)';
}

// Uso
var p1 = Punto2D(3, 4);
var p2 = Punto2D.origen();
var p3 = Punto2D.fromJson({'x': 5.0, 'y': 12.0});
var p4 = Punto2D.fromCoordenadas('7,24');
var p5 = Punto2D.cero();
```

#### Herencia

```dart
// Clase padre
class Animal {
  String nombre;
  int edad;
  
  Animal(this.nombre, this.edad);
  
  void hacerSonido() {
    print('$nombre hace un sonido');
  }
  
  void moverse() {
    print('$nombre se mueve');
  }
  
  String get descripcion => '$nombre ($edad años)';
}

// Clase hija
class Perro extends Animal {
  String raza;
  
  // Constructor que llama al padre
  Perro(String nombre, int edad, this.raza) : super(nombre, edad);
  
  // Sobrescribir método
  @override
  void hacerSonido() {
    print('$nombre ladra: ¡Guau!');
  }
  
  // Método específico
  void traerPelota() {
    print('$nombre trae la pelota');
  }
  
  // Sobrescribir getter
  @override
  String get descripcion => '${super.descripcion} - Raza: $raza';
}

class Gato extends Animal {
  bool esInterior;
  
  Gato(String nombre, int edad, {this.esInterior = true}) : super(nombre, edad);
  
  @override
  void hacerSonido() {
    print('$nombre maúlla: ¡Miau!');
  }
  
  void ronronear() {
    print('$nombre ronronea');
  }
}

// Uso
var perro = Perro('Max', 5, 'Labrador');
perro.hacerSonido();  // Max ladra: ¡Guau!
perro.moverse();      // Max se mueve
perro.traerPelota();  // Max trae la pelota

var gato = Gato('Michi', 3, esInterior: true);
gato.hacerSonido();   // Michi maúlla: ¡Miau!
gato.ronronear();     // Michi ronronea
```

#### Interfaces y clases abstractas

```dart
// Clase abstracta
abstract class Forma {
  String nombre;
  
  Forma(this.nombre);
  
  // Método abstracto (sin implementación)
  double calcularArea();
  
  // Método concreto
  void mostrarInfo() {
    print('$nombre con área: ${calcularArea()}');
  }
}

class Circulo extends Forma {
  double radio;
  
  Circulo(this.radio) : super('Círculo');
  
  @override
  double calcularArea() => 3.14159 * radio * radio;
}

class Rectangulo extends Forma {
  double ancho;
  double alto;
  
  Rectangulo(this.ancho, this.alto) : super('Rectángulo');
  
  @override
  double calcularArea() => ancho * alto;
}

// Interface implícita
// En Dart, todas las clases definen implícitamente una interface
class Volador {
  void volar() {
    print('Volando...');
  }
}

class Pajaro implements Volador {
  @override
  void volar() {
    print('El pájaro vuela con sus alas');
  }
}

class Avion implements Volador {
  @override
  void volar() {
    print('El avión vuela con motores');
  }
}

// Interface explícita
abstract class Dibujable {
  void dibujar();
  void redimensionar(double factor);
}

class Cuadrado implements Dibujable {
  double lado;
  
  Cuadrado(this.lado);
  
  @override
  void dibujar() {
    print('Dibujando cuadrado de lado $lado');
  }
  
  @override
  void redimensionar(double factor) {
    lado *= factor;
  }
}
```

#### Mixins

```dart
// Mixin básico
mixin Logger {
  void log(String mensaje) {
    print('[LOG] $mensaje - ${DateTime.now()}');
  }
}

mixin Temporizador {
  Stopwatch _stopwatch = Stopwatch();
  
  void iniciarTiempo() {
    _stopwatch.start();
  }
  
  void detenerTiempo() {
    _stopwatch.stop();
    print('Tiempo transcurrido: ${_stopwatch.elapsedMilliseconds}ms');
  }
}

// Clase que usa mixins
class Tarea with Logger, Temporizador {
  String nombre;
  
  Tarea(this.nombre);
  
  void ejecutar() {
    log('Iniciando tarea: $nombre');
    iniciarTiempo();
    
    // Simular trabajo
    for (int i = 0; i < 1000000; i++) {
      // proceso
    }
    
    detenerTiempo();
    log('Tarea completada: $nombre');
  }
}

// Mixin con restricciones (on)
mixin Volador2 on Animal {
  void volar() {
    print('$nombre está volando');
  }
}

class Aguila extends Animal with Volador2 {
  Aguila(String nombre) : super(nombre, 0);
  
  @override
  void hacerSonido() {
    print('$nombre grita');
  }
}
```

#### Enums

```dart
// Enum simple
enum Estado {
  pendiente,
  enProgreso,
  completado,
  cancelado,
}

void manejarEstado(Estado estado) {
  switch (estado) {
    case Estado.pendiente:
      print('Pendiente de revisión');
      break;
    case Estado.enProgreso:
      print('En progreso');
      break;
    case Estado.completado:
      print('Completado');
      break;
    case Estado.cancelado:
      print('Cancelado');
      break;
  }
}

// Enum con valores
enum Prioridad {
  baja(1),
  media(2),
  alta(3),
  critica(4);
  
  final int valor;
  const Prioridad(this.valor);
  
  String get descripcion {
    switch (this) {
      case Prioridad.baja:
        return 'Baja prioridad';
      case Prioridad.media:
        return 'Media prioridad';
      case Prioridad.alta:
        return 'Alta prioridad';
      case Prioridad.critica:
        return 'Crítica';
    }
  }
}

// Enum con métodos
enum DiaSemana {
  lunes(1),
  martes(2),
  miercoles(3),
  jueves(4),
  viernes(5),
  sabado(6),
  domingo(7);
  
  final int numero;
  const DiaSemana(this.numero);
  
  bool get esFinSemana => numero >= 6;
  
  String get nombreCorto => name.substring(0, 3);
  
  static DiaSemana desdeNumero(int n) {
    return DiaSemana.values.firstWhere(
      (d) => d.numero == n,
      orElse: () => DiaSemana.lunes,
    );
  }
}
```

---

### 6. Manejo de Excepciones

#### try-catch-finally

```dart
// Try-catch básico
try {
  var resultado = 100 ~/ 0;  // División por cero
  print(resultado);
} catch (e) {
  print('Error: $e');
}

// Capturar tipo específico de excepción
try {
  var lista = [1, 2, 3];
  print(lista[10]);  // Índice fuera de rango
} on RangeError catch (e) {
  print('Error de índice: $e');
} on FormatException catch (e) {
  print('Error de formato: $e');
} catch (e) {
  print('Error genérico: $e');
}

// Capturar excepción y stack trace
try {
  throw Exception('Algo salió mal');
} catch (e, stackTrace) {
  print('Error: $e');
  print('Stack trace: $stackTrace');
}

// Finally - siempre se ejecuta
try {
  var archivo = File('datos.txt');
  var contenido = archivo.readAsStringSync();
  print(contenido);
} catch (e) {
  print('Error leyendo archivo: $e');
} finally {
  print('Proceso completado');
}
```

#### throw

```dart
// Lanzar excepción
void verificarEdad(int edad) {
  if (edad < 0) {
    throw ArgumentError('La edad no puede ser negativa');
  }
  if (edad > 150) {
    throw RangeError('Edad no válida');
  }
}

// Excepción personalizada
class MiExcepcion implements Exception {
  final String mensaje;
  final int codigo;
  
  MiExcepcion(this.mensaje, this.codigo);
  
  @override
  String toString() => 'MiExcepcion($codigo): $mensaje';
}

void procesarDatos(List<int> datos) {
  if (datos.isEmpty) {
    throw MiExcepcion('La lista está vacía', 400);
  }
  // Procesar...
}

// Uso
try {
  verificarEdad(-5);
} on ArgumentError catch (e) {
  print('Argumento inválido: $e');
} on RangeError catch (e) {
  print('Rango inválido: $e');
}

try {
  procesarDatos([]);
} on MiExcepcion catch (e) {
  print('Error ${e.codigo}: ${e.mensaje}');
}
```

#### Ejemplo práctico: Validación

```dart
class ValidacionException implements Exception {
  final String campo;
  final String mensaje;
  
  ValidacionException(this.campo, this.mensaje);
  
  @override
  String toString() => 'Error en $campo: $mensaje';
}

class Usuario {
  String nombre;
  String email;
  int edad;
  
  Usuario(this.nombre, this.email, this.edad) {
    _validar();
  }
  
  void _validar() {
    if (nombre.isEmpty) {
      throw ValidacionException('nombre', 'El nombre es obligatorio');
    }
    
    if (!email.contains('@')) {
      throw ValidacionException('email', 'Email no válido');
    }
    
    if (edad < 0 || edad > 120) {
      throw ValidacionException('edad', 'Edad debe estar entre 0 y 120');
    }
  }
  
  @override
  String toString() => 'Usuario($nombre, $email, $edad)';
}

void crearUsuario() {
  try {
    var usuario = Usuario('', 'ana@email.com', 28);
    print('Usuario creado: $usuario');
  } on ValidacionException catch (e) {
    print('Error de validación: $e');
  } catch (e) {
    print('Error inesperado: $e');
  } finally {
    print('Proceso de creación finalizado');
  }
}
```

---

### 7. Null Safety

#### Conceptos básicos

```dart
// Tipos no anulables por defecto
String nombre = 'Ana';
// nombre = null;  // Error - String no puede ser null

// Tipos anulables (con ?)
String? nombreNulo;
nombreNulo = 'Ana';
nombreNulo = null;  // Válido

// Acceso seguro con ?.
String? ciudad;
int? longitud = ciudad?.length;  // null si ciudad es null

// Operador if-null (??)
String? nombreOpcional;
String saludo = nombreOpcional ?? 'Invitado';

// Operador de asignación if-null (??=)
String? nombre2;
nombre2 ??= 'Por defecto';  // Asigna si es null
print(nombre2);  // Por defecto
```

#### Aserción de no-null (!)

```dart
String? obtenerNombre() {
  // Puede retornar null
  return 'Carlos';
}

void main() {
  String? nombre = obtenerNombre();
  
  // Si estamos seguros de que no es null
  int longitud = nombre!.length;  // Lanza error si es null
  
  // Uso común en widgets
  // controller!.text  // Acceso forzado
}

// Peligro: solo usar cuando estamos SEGUROS
String? texto;
// print(texto!.length);  // Runtime error: null
```

#### late

```dart
// late - inicialización diferida
class Usuario {
  late String nombre;
  late int edad;
  
  void inicializar(String n, int e) {
    nombre = n;
    edad = e;
  }
}

var usuario = Usuario();
// print(usuario.nombre);  // Error: no inicializado
usuario.inicializar('Ana', 28);
print(usuario.nombre);  // Ana

// late con inicialización lazy
class Config {
  late String configuracion = _cargarConfig();
  
  String _cargarConfig() {
    print('Cargando configuración...');
    return 'configuración cargada';
  }
}

var config = Config();  // _cargarConfig no se ejecuta
print(config.configuracion);  // Ahora se ejecuta
print(config.configuracion);  // Ya está en cache

// late en variables de instancia
class Controlador {
  late final String id = _generarId();
  
  String _generarId() {
    return 'ID-${DateTime.now().millisecondsSinceEpoch}';
  }
}
```

#### Patrones comunes

```dart
// Verificación de null antes de uso
String? nombre;
if (nombre != null) {
  // Dentro del if, nombre es String (no String?)
  print(nombre.length);
}

// Promoción de tipo
void procesar(String? valor) {
  if (valor == null) {
    print('Es null');
    return;
  }
  
  // Aquí valor es String (promoción automática)
  print(valor.toUpperCase());
}

// Uso con colecciones
List<String?> nombres = ['Ana', null, 'Carlos', null, 'María'];
List<String> nombresValidos = nombres.whereType<String>().toList();
// ['Ana', 'Carlos', 'María']

// Map con valores null
Map<String, String?> configuracion = {
  'nombre': 'Ana',
  'email': null,
  'ciudad': 'Madrid',
};

var emailValido = configuracion['email'] ?? 'no@email.com';

// Streams y null
Stream<String?> obtenerDatos() async* {
  yield 'dato1';
  yield null;
  yield 'dato2';
}

Future<void> procesarStream() async {
  await for (var dato in obtenerDatos()) {
    print(dato ?? 'NULL');
  }
}
```

---

### 8. Asincronía

#### Future

```dart
import 'dart:async';

// Crear un Future
Future<String> obtenerNombre() {
  return Future.delayed(Duration(seconds: 2), () => 'Ana');
}

// Usar con async/await
Future<void> main() async {
  print('Iniciando...');
  String nombre = await obtenerNombre();
  print('Nombre: $nombre');
}

// Crear Future con constructor
Future<int> calcular() {
  return Future(() {
    // Cálculo costoso
    var suma = 0;
    for (var i = 0; i < 1000000; i++) {
      suma += i;
    }
    return suma;
  });
}

// Future.value y Future.error
Future<String> obtenerDato(bool exito) {
  if (exito) {
    return Future.value('Dato obtenido');
  } else {
    return Future.error(Exception('Error al obtener dato'));
  }
}

// Múltiples Futures en paralelo
Future<void> obtenerVarios() async {
  var resultados = await Future.wait([
    obtenerNombre(),
    obtenerNombre(),
    obtenerNombre(),
  ]);
  print(resultados);  // ['Ana', 'Ana', 'Ana']
}

// Timeout
Future<void> conTimeout() async {
  try {
    var resultado = await obtenerNombre().timeout(Duration(seconds: 1));
    print(resultado);
  } on TimeoutException catch (e) {
    print('Timeout: $e');
  }
}

// Encadenamiento de Futures
Future<int> procesoEncadenado() async {
  return await obtenerNombre()
      .then((nombre) => nombre.length)
      .then((longitud) => longitud * 2)
      .catchError((error) => 0);
}
```

#### async/await

```dart
// Función async
Future<String> obtenerDatos() async {
  await Future.delayed(Duration(seconds: 1));
  return 'Datos';
}

// Función async con try-catch
Future<void> procesarDatos() async {
  try {
    String datos = await obtenerDatos();
    print('Datos: $datos');
    
    // Múltiples awaits
    var dato1 = await Future.delayed(Duration(seconds: 1), () => 'A');
    var dato2 = await Future.delayed(Duration(seconds: 1), () => 'B');
    print('$dato1, $dato2');
    
  } catch (e) {
    print('Error: $e');
  } finally {
    print('Proceso finalizado');
  }
}

// await en bucle
Future<void> procesarLista(List<String> items) async {
  for (var item in items) {
    await procesarItem(item);
  }
}

Future<void> procesarItem(String item) async {
  await Future.delayed(Duration(milliseconds: 100));
  print('Procesado: $item');
}

// Parallel waits
Future<void> procesarParalelo() async {
  var futuro1 = Future.delayed(Duration(seconds: 1), () => 'A');
  var futuro2 = Future.delayed(Duration(seconds: 1), () => 'B');
  var futuro3 = Future.delayed(Duration(seconds: 1), () => 'C');
  
  // Ejecutar en paralelo
  var resultado1 = await futuro1;
  var resultado2 = await futuro2;
  var resultado3 = await futuro3;
  
  print('$resultado1, $resultado2, $resultado3');
  
  // Alternativa con Future.wait
  var resultados = await Future.wait([futuro1, futuro2, futuro3]);
  print(resultados);
}
```

#### Stream

```dart
import 'dart:async';

// Crear Stream con StreamController
StreamController<int> controlador = StreamController<int>();

void emitirNumeros() {
  for (int i = 1; i <= 5; i++) {
    controlador.sink.add(i);
    sleep(Duration(seconds: 1));
  }
  controlador.close();
}

// Escuchar Stream
void escuchar() {
  controlador.stream.listen(
    (dato) => print('Dato: $dato'),
    onError: (error) => print('Error: $error'),
    onDone: () => print('Completado'),
  );
}

// Stream con async*
Stream<int> generarNumeros(int max) async* {
  for (int i = 1; i <= max; i++) {
    await Future.delayed(Duration(seconds: 1));
    yield i;
  }
}

// Consumir Stream
Future<void> consumirStream() async {
  await for (var numero in generarNumeros(5)) {
    print('Número: $numero');
  }
}

// Stream con listen
void escucharStream() {
  generarNumeros(5).listen(
    (numero) => print('Recibido: $numero'),
    onError: (e) => print('Error: $e'),
    onDone: () => print('Stream completado'),
    cancelOnError: false,
  );
}

// Transformar Stream
void transformarStream() {
  generarNumeros(5)
      .map((n) => n * 2)
      .where((n) => n > 2)
      .listen((n) => print(n));
}

// Broadcast Stream (múltiples listeners)
void broadcastStream() {
  var controlador = StreamController<int>.broadcast();
  
  controlador.stream.listen((n) => print('Listener 1: $n'));
  controlador.stream.listen((n) => print('Listener 2: $n'));
  
  controlador.sink.add(1);
  controlador.sink.add(2);
}
```

---

### 9. Ejercicios Prácticos

#### Ejercicio 1: Gestión de usuarios

```dart
class Usuario {
  final int id;
  final String nombre;
  final String email;
  final int edad;
  
  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.edad,
  });
  
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nombre: json['nombre'],
      email: json['email'],
      edad: json['edad'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'edad': edad,
    };
  }
  
  @override
  String toString() => 'Usuario($id, $nombre, $email, $edad)';
}

class GestorUsuarios {
  final List<Usuario> _usuarios = [];
  
  void agregar(Usuario usuario) {
    if (_usuarios.any((u) => u.id == usuario.id)) {
      throw Exception('Usuario con ID ${usuario.id} ya existe');
    }
    _usuarios.add(usuario);
  }
  
  Usuario? buscar(int id) {
    try {
      return _usuarios.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }
  
  List<Usuario> buscarPorNombre(String patron) {
    return _usuarios
        .where((u) => u.nombre.toLowerCase().contains(patron.toLowerCase()))
        .toList();
  }
  
  bool eliminar(int id) {
    var usuario = buscar(id);
    if (usuario == null) return false;
    return _usuarios.remove(usuario);
  }
  
  List<Usuario> obtenerTodos() => List.unmodifiable(_usuarios);
  
  int get cantidad => _usuarios.length;
}
```

#### Ejercicio 2: Calculadora con validación

```dart
class Calculadora {
  double sumar(double a, double b) => a + b;
  
  double restar(double a, double b) => a - b;
  
  double multiplicar(double a, double b) => a * b;
  
  double dividir(double a, double b) {
    if (b == 0) {
      throw ArgumentError('No se puede dividir por cero');
    }
    return a / b;
  }
  
  double potencia(double base, int exponente) {
    if (exponente < 0) {
      throw ArgumentError('El exponente debe ser no negativo');
    }
    double resultado = 1;
    for (int i = 0; i < exponente; i++) {
      resultado *= base;
    }
    return resultado;
  }
  
  List<double> fibonacci(int n) {
    if (n < 0) {
      throw ArgumentError('n debe ser no negativo');
    }
    if (n == 0) return [];
    if (n == 1) return [0];
    
    var fib = [0, 1];
    for (int i = 2; i < n; i++) {
      fib.add(fib[i - 1] + fib[i - 2]);
    }
    return fib;
  }
}
```

#### Ejercicio 3: Sistema de reservas

```dart
enum EstadoReserva {
  pendiente,
  confirmada,
  cancelada,
}

class Reserva {
  final String id;
  final String cliente;
  final DateTime fecha;
  EstadoReserva estado;
  
  Reserva({
    required this.id,
    required this.cliente,
    required this.fecha,
    this.estado = EstadoReserva.pendiente,
  });
  
  void confirmar() {
    if (estado != EstadoReserva.pendiente) {
      throw Exception('Solo se pueden confirmar reservas pendientes');
    }
    estado = EstadoReserva.confirmada;
  }
  
  void cancelar() {
    if (estado == EstadoReserva.cancelada) {
      throw Exception('La reserva ya está cancelada');
    }
    estado = EstadoReserva.cancelada;
  }
  
  @override
  String toString() => 'Reserva($id, $cliente, $fecha, $estado)';
}

class SistemaReservas {
  final List<Reserva> _reservas = [];
  int _contadorId = 0;
  
  Reserva crear(String cliente, DateTime fecha) {
    final id = 'RES-${++_contadorId}';
    final reserva = Reserva(id: id, cliente: cliente, fecha: fecha);
    _reservas.add(reserva);
    return reserva;
  }
  
  Reserva? buscar(String id) {
    try {
      return _reservas.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }
  
  List<Reserva> buscarPorCliente(String cliente) {
    return _reservas.where((r) => r.cliente == cliente).toList();
  }
  
  List<Reserva> buscarPorFecha(DateTime fecha) {
    return _reservas.where((r) => 
      r.fecha.year == fecha.year &&
      r.fecha.month == fecha.month &&
      r.fecha.day == fecha.day
    ).toList();
  }
}
```

---

**Resumen del Módulo 2:**

En este módulo aprendiste:

✅ Variables, tipos de datos y colecciones (List, Set, Map)
✅ Operadores aritméticos, lógicos, de asignación y tipo
✅ Control de flujo: if-else, switch, for, while, break, continue
✅ Funciones: parámetros, funciones anónimas, closures, async/await
✅ POO: clases, herencia, interfaces, mixins, enums
✅ Manejo de excepciones con try-catch-finally
✅ Null safety: tipos anulables, late, aserciones
✅ Programación asíncrona: Future, Stream, async/await

**Próximo módulo:** Widgets Básicos y Layout## Módulo 3: Widgets Básicos y Layout (4 horas)

---

### 1. StatelessWidget vs StatefulWidget

#### StatelessWidget

Un `StatelessWidget` es un widget que no tiene estado mutable. Su apariencia depende únicamente de sus parámetros de configuración.

**Características:**
- Inmutable: no puede cambiar después de ser construido
- Se recrea cuando los parámetros cambian
- Ideal para widgets de presentación (textos, iconos, tarjetas)

**Ejemplo básico:**

```dart
class TarjetaUsuario extends StatelessWidget {
  // Parámetros inmutables
  final String nombre;
  final String email;
  final String? avatarUrl;

  // Constructor constante para optimización
  const TarjetaUsuario({
    super.key,
    required this.nombre,
    required this.email,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 30,
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl!)
                  : null,
              child: avatarUrl == null
                  ? Text(nombre[0].toUpperCase())
                  : null,
            ),
            const SizedBox(width: 16),
            // Información
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

#### StatefulWidget

Un `StatefulWidget` es un widget que tiene estado mutable. Puede cambiar su apariencia en respuesta a eventos.

**Características:**
- Mutable: el estado puede cambiar durante la vida del widget
- Se compone de dos clases: el Widget y el State
- El State persiste entre reconstrucciones
- Ideal para formularios, contadores, animaciones

**Ejemplo básico:**

```dart
class ContadorWidget extends StatefulWidget {
  // Parámetros inmutables
  final int valorInicial;
  final int paso;

  const ContadorWidget({
    super.key,
    this.valorInicial = 0,
    this.paso = 1,
  });

  @override
  State<ContadorWidget> createState() => _ContadorWidgetState();
}

class _ContadorWidgetState extends State<ContadorWidget> {
  // Estado mutable
  late int _contador;

  @override
  void initState() {
    super.initState();
    // Inicializar estado desde parámetros del widget
    _contador = widget.valorInicial;
  }

  void _incrementar() {
    // setState marca el widget como "dirty" y programa reconstrucción
    setState(() {
      _contador += widget.paso;
    });
  }

  void _decrementar() {
    setState(() {
      _contador -= widget.paso;
    });
  }

  void _reiniciar() {
    setState(() {
      _contador = widget.valorInicial;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Contador: $_contador',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _contador > 0 ? _decrementar : null,
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _incrementar,
                  child: const Text('Incrementar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

#### Ciclo de vida del StatefulWidget

```dart
class CicloVidaWidget extends StatefulWidget {
  const CicloVidaWidget({super.key});

  @override
  State<CicloVidaWidget> createState() => _CicloVidaWidgetState();
}

class _CicloVidaWidgetState extends State<CicloVidaWidget> {
  @override
  void initState() {
    super.initState();
    // Se llama una vez cuando el State se crea
    // Ideal para: inicializar variables, suscripciones, controllers
    print('initState: Widget creado');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Se llama cuando cambian las dependencias (Theme, Locale, etc.)
    print('didChangeDependencies: Dependencias cambiadas');
  }

  @override
  void didUpdateWidget(CicloVidaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Se llama cuando el widget padre reconstruye con nuevos parámetros
    print('didUpdateWidget: Widget actualizado');
  }

  @override
  void dispose() {
    // Se llama cuando el widget se elimina del árbol permanentemente
    // IMPORTANTE: Limpiar recursos aquí (controllers, streams, etc.)
    print('dispose: Widget eliminado');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Se llama cada vez que el widget necesita renderizarse
    return const Text('Ciclo de vida');
  }
}
```

**Diagrama del ciclo de vida:**

```
 createState()         → Crea el State
        ↓
 initState()          → Inicialización (una sola vez)
        ↓
 didChangeDependencies() → Dependencias disponibles
        ↓
 build()              → Construye el widget
        ↓
  ┌─────────────────────────────────────┐
  │  didUpdateWidget()  ← Padre actualiza │
  │        ↓                            │
  │  setState() → build()               │
  └─────────────────────────────────────┘
        ↓
 dispose()            → Limpieza antes de eliminar
```

---

### 2. Widgets de texto, imágenes e iconos

#### Text

El widget `Text` muestra una cadena de texto con estilo opcional.

```dart
// Texto básico
const Text('Hola Mundo');

// Texto con estilo
const Text(
  'Hola Mundo',
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
    letterSpacing: 2,
    wordSpacing: 4,
    decoration: TextDecoration.underline,
    decorationColor: Colors.red,
    decorationStyle: TextDecorationStyle.dashed,
  ),
);

// Texto con RichText (múltiples estilos)
RichText(
  text: TextSpan(
    style: const TextStyle(fontSize: 20, color: Colors.black),
    children: [
      const TextSpan(text: 'Hola '),
      const TextSpan(
        text: 'Mundo',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
      const TextSpan(text: '!'),
      TextSpan(
        text: ' 🎉',
        style: TextStyle(color: Colors.purple[400]),
      ),
    ],
  ),
);

// Texto con número máximo de líneas
const Text(
  'Este es un texto muy largo que será truncado si excede las líneas...',
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
);

// Texto seleccionable
const SelectableText(
  'Este texto se puede seleccionar y copiar',
  style: TextStyle(fontSize: 16),
);
```

#### Image

El widget `Image` muestra imágenes desde diversas fuentes.

```dart
// Imagen desde assets (carpeta assets/)
// Primero añadir en pubspec.yaml:
// flutter:
//   assets:
//     - assets/images/
const Image(
  image: AssetImage('assets/images/logo.png'),
  width: 100,
  height: 100,
  fit: BoxFit.cover,
);

// Imagen desde red
Image.network(
  'https://picsum.photos/200',
  width: 200,
  height: 200,
  fit: BoxFit.cover,
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return const Center(child: CircularProgressIndicator());
  },
  errorBuilder: (context, error, stackTrace) {
    return const Center(
      child: Icon(Icons.error, color: Colors.red),
    );
  },
);

// Imagen desde archivo local
Image.file(
  File('/path/to/image.jpg'),
  width: 200,
  height: 200,
);

// Imagen desde bytes
Image.memory(
  Uint8List.fromList(imageBytes),
  width: 200,
  height: 200,
);

// Tipos de ajuste (BoxFit)
// BoxFit.fill: Estira para llenar
// BoxFit.cover: Mantiene proporción, cubre todo
// BoxFit.contain: Mantiene proporción, visible completa
// BoxFit.fitWidth: Ajusta al ancho
// BoxFit.fitHeight: Ajusta al alto
// BoxFit.scaleDown: No agranda más del original
```

#### Icon

El widget `Icon` muestra íconos Material Design.

```dart
// Icono básico
const Icon(Icons.favorite);

// Icono con tamaño y color
const Icon(
  Icons.favorite,
  size: 48,
  color: Colors.red,
);

// Icono con sombra
const Icon(
  Icons.favorite,
  size: 48,
  color: Colors.red,
  shadows: [
    Shadow(
      color: Colors.black26,
      blurRadius: 4,
      offset: Offset(2, 2),
    ),
  ],
);

// IconButton (botón con icono)
IconButton(
  icon: const Icon(Icons.settings),
  onPressed: () {
    print('Settings pressed');
  },
  tooltip: 'Configuración',
);

// Iconos comunes
// Icons.home, Icons.person, Icons.settings
// Icons.add, Icons.edit, Icons.delete
// Icons.favorite, Icons.star, Icons.bookmark
// Icons.search, Icons.filter, Icons.sort
// Icons.arrow_back, Icons.arrow_forward
// Icons.email, Icons.phone, Icons.location_on
// Icons.camera, Icons.photo, Icons.videocam
```

---

### 3. Container, Padding, Center, Align

#### Container

El widget `Container` es un versátil contenedor que puede tener padding, bordes, márgenes, color de fondo, etc.

```dart
// Container básico
Container(
  width: 200,
  height: 100,
  color: Colors.blue,
  child: const Text('Hola'),
);

// Container con todo
Container(
  width: double.infinity,
  padding: const EdgeInsets.all(16),
  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey.shade300),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: const Text('Container completo'),
);

// Container con gradiente
Container(
  width: 200,
  height: 100,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.purple,
        Colors.blue,
        Colors.teal,
      ],
    ),
    borderRadius: BorderRadius.circular(16),
  ),
  child: const Center(
    child: Text(
      'Gradiente',
      style: TextStyle(color: Colors.white, fontSize: 20),
    ),
  ),
);

// Container con imagen de fondo
Container(
  width: 200,
  height: 150,
  decoration: BoxDecoration(
    image: DecorationImage(
      image: NetworkImage('https://picsum.photos/200'),
      fit: BoxFit.cover,
    ),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Container(
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.5),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Center(
      child: Text(
        'Overlay',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    ),
  ),
);
```

#### Padding

El widget `Padding` añade espacio alrededor de su hijo.

```dart
// Padding básico
const Padding(
  padding: EdgeInsets.all(16),
  child: Text('Con padding'),
);

// Padding asimétrico
const Padding(
  padding: EdgeInsets.only(
    left: 8,
    top: 16,
    right: 8,
    bottom: 24,
  ),
  child: Text('Padding específico'),
);

// Padding simétrico
const Padding(
  padding: EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 10,
  ),
  child: Text('Padding simétrico'),
);

// Combinado
Padding(
  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
  child: Container(
    color: Colors.blue,
    child: const Text('Padding con fromLTRB'),
  ),
);
```

#### Center

El widget `Center` centra su hijo dentro de sí mismo.

```dart
// Centro absoluto
const Center(
  child: Text('Centrado'),
);

// Con tamaño específico
Center(
  child: Container(
    width: 200,
    height: 100,
    color: Colors.amber,
    child: const Center(child: Text('Centrado en container')),
  ),
);
```

#### Align

El widget `Align` alinea su hijo en una posición específica.

```dart
// Alineación en diferentes posiciones
const Align(
  alignment: Alignment.topLeft,
  child: Text('Arriba izquierda'),
);

const Align(
  alignment: Alignment.topRight,
  child: Text('Arriba derecha'),
);

const Align(
  alignment: Alignment.bottomCenter,
  child: Text('Abajo centro'),
);

// Alineación personalizada (valores de -1 a 1)
const Align(
  alignment: Alignment(0.5, 0.5), // Centro-derecha-abajo
  child: Text('Personalizado'),
);

// Con FractionalOffset (valores de 0 a 1)
const Align(
  alignment: FractionalOffset(0.75, 0.25),
  child: Text('Con FractionalOffset'),
);
```

---

### 4. Column, Row, Stack, Wrap

#### Column

El widget `Column` organiza widgets verticalmente.

```dart
// Column básico
const Column(
  children: [
    Text('Primero'),
    Text('Segundo'),
    Text('Tercero'),
  ],
);

// Column con alineación
Column(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribución vertical
  crossAxisAlignment: CrossAxisAlignment.start, // Alineación horizontal
  children: [
    Container(width: 50, height: 50, color: Colors.red),
    Container(width: 100, height: 50, color: Colors.green),
    Container(width: 75, height: 50, color: Colors.blue),
  ],
);

// MainAxisAlignment:
// - start: Arriba
// - end: Abajo
// - center: Centro
// - spaceBetween: Espacio entre items
// - spaceAround: Espacio alrededor
// - spaceEvenly: Espacio igual

// CrossAxisAlignment:
// - start: Izquierda
// - end: Derecha
// - center: Centro
// - stretch: Expande al ancho
// - baseline: Alinea por línea base de texto

// Column con expansión
Column(
  children: [
    const Text('Header'),
    Expanded(
      child: Container(
        color: Colors.grey[200],
        child: const Center(child: Text('Contenido expandible')),
      ),
    ),
    const Text('Footer'),
  ],
);

// Column con scroll
const SingleChildScrollView(
  child: Column(
    children: [
      ListTile(title: Text('Item 1')),
      ListTile(title: Text('Item 2')),
      // ... más items
      ListTile(title: Text('Item 100')),
    ],
  ),
);
```

#### Row

El widget `Row` organiza widgets horizontalmente.

```dart
// Row básico
const Row(
  children: [
    Icon(Icons.star),
    Text('Favorito'),
  ],
);

// Row con alineación
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribución horizontal
  crossAxisAlignment: CrossAxisAlignment.center, // Alineación vertical
  children: [
    Container(width: 50, height: 50, color: Colors.red),
    Container(width: 50, height: 100, color: Colors.green),
    Container(width: 50, height: 50, color: Colors.blue),
  ],
);

// Row con expansión
Row(
  children: [
    const Expanded(
      flex: 2, // Doble espacio
      child: TextField(decoration: InputDecoration(labelText: 'Nombre')),
    ),
    const SizedBox(width: 8),
    const Expanded(
      flex: 1, // Espacio normal
      child: TextField(decoration: InputDecoration(labelText: 'Edad')),
    ),
  ],
);

// Row con scroll horizontal
const SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [
      Chip(label: Text('Tag 1')),
      Chip(label: Text('Tag 2')),
      // ... más tags
      Chip(label: Text('Tag 50')),
    ],
  ),
);
```

#### Stack

El widget `Stack` superpone widgets unos sobre otros.

```dart
// Stack básico
Stack(
  children: [
    Container(
      width: 200,
      height: 200,
      color: Colors.blue,
    ),
    Container(
      width: 150,
      height: 150,
      color: Colors.green,
    ),
    Container(
      width: 100,
      height: 100,
      color: Colors.red,
    ),
  ],
);

// Stack con Positioned
Stack(
  children: [
    Container(
      width: 300,
      height: 200,
      color: Colors.blue[100],
    ),
    Positioned(
      left: 20,
      top: 20,
      child: Container(
        width: 100,
        height: 80,
        color: Colors.red,
      ),
    ),
    Positioned(
      right: 20,
      bottom: 20,
      child: Container(
        width: 100,
        height: 80,
        color: Colors.green,
      ),
    ),
    const Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Text('Texto superpuesto'),
    ),
  ],
);

// Stack para tarjeta con badge
Container(
  width: 200,
  height: 250,
  child: Stack(
    children: [
      // Imagen de fondo
      Positioned.fill(
        child: Image.network(
          'https://picsum.photos/200/250',
          fit: BoxFit.cover,
        ),
      ),
      // Badge
      Positioned(
        top: 10,
        right: 10,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'NUEVO',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
      // Título en la parte inferior
      Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          child: const Text(
            'Producto',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ],
  ),
);
```

#### Wrap

El widget `Wrap` organiza widgets en múltiples líneas cuando no caben.

```dart
// Wrap básico
Wrap(
  spacing: 8, // Espacio horizontal entre items
  runSpacing: 4, // Espacio vertical entre líneas
  children: [
    Chip(label: Text('Flutter')),
    Chip(label: Text('Dart')),
    Chip(label: Text('React')),
    Chip(label: Text('Vue')),
    Chip(label: Text('Angular')),
    Chip(label: Text('Svelte')),
  ],
);

// Wrap con alineación
Wrap(
  alignment: WrapAlignment.center,
  spacing: 8,
  runSpacing: 8,
  children: List.generate(
    20,
    (index) => Container(
      width: 80,
      height: 80,
      color: Colors.primaries[index % Colors.primaries.length],
      child: Center(child: Text('$index')),
    ),
  ),
);

// Wrap para tags/chips
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: [
    'Flutter',
    'React Native',
    'Swift',
    'Kotlin',
    'JavaScript',
    'TypeScript',
  ].map((tag) => Chip(
    label: Text(tag),
    avatar: const Icon(Icons.tag, size: 16),
  )).toList(),
);
```

---

### 5. ListView, GridView, SingleChildScrollView

#### ListView

El widget `ListView` muestra una lista desplazable de widgets.

```dart
// ListView básico
ListView(
  children: [
    ListTile(title: Text('Item 1')),
    ListTile(title: Text('Item 2')),
    ListTile(title: Text('Item 3')),
  ],
);

// ListView.builder (para listas largas)
ListView.builder(
  itemCount: 100,
  itemBuilder: (context, index) {
    return ListTile(
      leading: CircleAvatar(child: Text('$index')),
      title: Text('Usuario $index'),
      subtitle: Text('email$index@example.com'),
      trailing: const Icon(Icons.arrow_forward),
      onTap: () => print('Tapped $index'),
    );
  },
);

// ListView.separated (con separadores)
ListView.separated(
  itemCount: 20,
  separatorBuilder: (context, index) => const Divider(),
  itemBuilder: (context, index) {
    return ListTile(
      title: Text('Item $index'),
    );
  },
);

// ListView con RefreshIndicator (pull to refresh)
RefreshIndicator(
  onRefresh: () async {
    // Simular carga de datos
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      // Actualizar lista
    });
  },
  child: ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) {
      return ListTile(title: Text(items[index]));
    },
  ),
);
```

#### GridView

El widget `GridView` muestra una cuadrícula de widgets.

```dart
// GridView.count (número fijo de columnas)
GridView.count(
  crossAxisCount: 2, // Número de columnas
  mainAxisSpacing: 10, // Espacio vertical
  crossAxisSpacing: 10, // Espacio horizontal
  children: List.generate(20, (index) {
    return Container(
      color: Colors.primaries[index % Colors.primaries.length],
      child: Center(child: Text('$index')),
    );
  }),
);

// GridView.extent (tamaño máximo de items)
GridView.extent(
  maxCrossAxisExtent: 150, // Ancho máximo de cada item
  mainAxisSpacing: 10,
  crossAxisSpacing: 10,
  children: List.generate(20, (index) {
    return Container(
      color: Colors.primaries[index % Colors.primaries.length],
      child: Center(child: Text('$index')),
    );
  }),
);

// GridView.builder (para grids grandes)
GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
    childAspectRatio: 1.0, // Relación ancho/alto
  ),
  itemCount: 100,
  itemBuilder: (context, index) {
    return Container(
      color: Colors.primaries[index % Colors.primaries.length],
      child: Center(child: Text('$index')),
    );
  },
);

// GridView con diferentes alturas
GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
    childAspectRatio: 0.75, // Items más altos que anchos
  ),
  itemCount: products.length,
  itemBuilder: (context, index) {
    final product = products[index];
    return Card(
      child: Column(
        children: [
          Expanded(
            child: Image.network(product.imageUrl, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(product.name),
          ),
          Text('\$${product.price}'),
        ],
      ),
    );
  },
);
```

#### SingleChildScrollView

El widget `SingleChildScrollView` permite hacer scroll cuando el contenido excede el tamaño.

```dart
// SingleChildScrollView básico
SingleChildScrollView(
  child: Column(
    children: List.generate(50, (index) {
      return ListTile(title: Text('Item $index'));
    }),
  ),
);

// Con padding
const SingleChildScrollView(
  padding: EdgeInsets.all(16),
  child: Text(
    'Texto largo que necesita scroll...',
    style: TextStyle(fontSize: 16),
  ),
);

// Scroll horizontal
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: List.generate(20, (index) {
      return Container(
        width: 150,
        margin: const EdgeInsets.all(8),
        color: Colors.primaries[index % Colors.primaries.length],
        child: Center(child: Text('Card $index')),
      );
    }),
  ),
);

// Control del scroll con ScrollController
final ScrollController _controller = ScrollController();

@override
void initState() {
  super.initState();
  _controller.addListener(() {
    print('Scroll position: ${_controller.offset}');
  });
}

void _scrollToTop() {
  _controller.animateTo(
    0,
    duration: const Duration(milliseconds: 500),
    curve: Curves.easeInOut,
  );
}

SingleChildScrollView(
  controller: _controller,
  child: Column(
    children: [
      // ... contenido
    ],
  ),
);
```

---

### 6. Scaffold, AppBar, Drawer, BottomNavigationBar

#### Scaffold

El widget `Scaffold` proporciona la estructura básica de una pantalla Material Design.

```dart
Scaffold(
  // Barra superior
  appBar: AppBar(
    title: const Text('Mi App'),
  ),

  // Contenido principal
  body: const Center(
    child: Text('Contenido'),
  ),

  // Botón flotante de acción
  floatingActionButton: FloatingActionButton(
    onPressed: () {},
    child: const Icon(Icons.add),
  ),

  // Posición del FAB
  floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

  // Menú lateral
  drawer: Drawer(
    child: ListView(
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(color: Colors.blue),
          child: Text('Menú'),
        ),
        ListTile(title: const Text('Opción 1')),
        ListTile(title: const Text('Opción 2')),
      ],
    ),
  ),

  // Menú lateral derecho
  endDrawer: Drawer(
    child: ListView(
      children: [
        ListTile(title: const Text('Filtros')),
      ],
    ),
  ),

  // Barra de navegación inferior
  bottomNavigationBar: BottomNavigationBar(
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ],
  ),
);
```

#### AppBar

```dart
AppBar(
  // Título
  title: const Text('Mi App'),

  // Color de fondo
  backgroundColor: Colors.blue,

  // Color del primer plano (texto e iconos)
  foregroundColor: Colors.white,

  // Elevación (sombra)
  elevation: 4,

  // Acciones a la derecha
  actions: [
    IconButton(
      icon: const Icon(Icons.search),
      onPressed: () {
        // Acción de búsqueda
      },
    ),
    IconButton(
      icon: const Icon(Icons.notifications),
      onPressed: () {},
    ),
    PopupMenuButton<String>(
      onSelected: (value) {
        print('Selected: $value');
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'settings', child: Text('Configuración')),
        const PopupMenuItem(value: 'logout', child: Text('Cerrar sesión')),
      ],
    ),
  ],

  // Botón de retroceso
  leading: IconButton(
    icon: const Icon(Icons.menu),
    onPressed: () {},
  ),
);
```

#### Drawer

```dart
Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
      // Cabecera del drawer
      const DrawerHeader(
        decoration: BoxDecoration(
          color: Colors.blue,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
              child: Icon(Icons.person, size: 30),
            ),
            SizedBox(height: 10),
            Text(
              'Usuario',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
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
        leading: const Icon(Icons.home),
        title: const Text('Inicio'),
        onTap: () {
          Navigator.pop(context);
          // Navegar a inicio
        },
      ),
      ListTile(
        leading: const Icon(Icons.settings),
        title: const Text('Configuración'),
        onTap: () {
          Navigator.pop(context);
          // Navegar a configuración
        },
      ),
      const Divider(),
      ListTile(
        leading: const Icon(Icons.logout),
        title: const Text('Cerrar sesión'),
        onTap: () {
          Navigator.pop(context);
          // Cerrar sesión
        },
      ),
    ],
  ),
);
```

#### BottomNavigationBar

```dart
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    SearchScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Para más de 3 items
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
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

---

### 7. Ejercicios prácticos del Módulo 3

#### Ejercicio 1: Perfil de usuario

Crear una tarjeta de perfil con:
- Avatar circular
- Nombre y email
- Botones de acción
- Estadísticas en fila

**Solución:**

```dart
class PerfilUsuario extends StatelessWidget {
  const PerfilUsuario({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Avatar y datos
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150'),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Juan García',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'juan.garcia@email.com',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.person_add),
                        label: const Text('Seguir'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.message),
                        label: const Text('Mensaje'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Estadísticas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat('Posts', '128'),
                _buildStat('Seguidores', '5.2K'),
                _buildStat('Siguiendo', '234'),
              ],
            ),

            const SizedBox(height: 20),

            // Publicaciones
            const Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Publicaciones'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
            ),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                return Container(
                  color: Colors.primaries[index % Colors.primaries.length],
                  child: Center(child: Text('$index')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}
```

#### Ejercicio 2: Lista de productos

Crear una lista de productos con:
- Imagen, título, precio
- Rating con estrellas
- Botón de añadir al carrito

**Solución:**

```dart
class Producto {
  final String nombre;
  final double precio;
  final String imagen;
  final double rating;

  const Producto({
    required this.nombre,
    required this.precio,
    required this.imagen,
    required this.rating,
  });
}

class ListaProductos extends StatelessWidget {
  ListaProductos({super.key});

  final List<Producto> productos = const [
    Producto(nombre: 'Laptop', precio: 999.99, imagen: 'https://via.placeholder.com/100', rating: 4.5),
    Producto(nombre: 'Phone', precio: 699.99, imagen: 'https://via.placeholder.com/100', rating: 4.8),
    Producto(nombre: 'Tablet', precio: 449.99, imagen: 'https://via.placeholder.com/100', rating: 4.2),
    Producto(nombre: 'Watch', precio: 299.99, imagen: 'https://via.placeholder.com/100', rating: 4.6),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Productos')),
      body: ListView.builder(
        itemCount: productos.length,
        itemBuilder: (context, index) {
          final producto = productos[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  // Imagen
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      producto.imagen,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Información
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          producto.nombre,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${producto.precio.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.green[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: List.generate(5, (i) {
                            return Icon(
                              i < producto.rating.floor()
                                  ? Icons.star
                                  : (i < producto.rating ? Icons.star_half : Icons.star_border),
                              size: 16,
                              color: Colors.amber,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  // Botón
                  IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${producto.nombre} añadido al carrito')),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
```

---

**Resumen del Módulo 3:**

En este módulo aprendiste:

✅ StatelessWidget vs StatefulWidget y cuándo usar cada uno
✅ Ciclo de vida de los widgets
✅ Widgets de texto, imágenes e iconos
✅ Container, Padding, Center, Align
✅ Layout widgets: Column, Row, Stack, Wrap
✅ Listas: ListView, GridView, SingleChildScrollView
✅ Estructura: Scaffold, AppBar, Drawer, BottomNavigationBar
✅ Ejercicios prácticos integrando todo lo aprendido

**Próximo módulo:** Estado y Navegación
## Módulo 4: Estado y Navegación (4 horas)

---

### 1. Gestión de estado local

#### ¿Qué es el estado?

El **estado** (state) son los datos que pueden cambiar durante la vida de una aplicación y que afectan a lo que el usuario ve. 

**Tipos de estado:**
- **Estado local**: Pertenece a un solo widget (ej: contador, formulario)
- **Estado elevado**: Se pasa de padre a hijos (ej: tema, usuario logueado)
- **Estado global**: Compartido entre múltiples pantallas (ej: carrito, sesión)

#### setState y reconstrucción

El método `setState` marca el widget como "sucio" y programa una reconstrucción:

```dart
class ContadorPage extends StatefulWidget {
  const ContadorPage({super.key});

  @override
  State<ContadorPage> createState() => _ContadorPageState();
}

class _ContadorPageState extends State<ContadorPage> {
  int _contador = 0;

  void _incrementar() {
    // setState marca el widget para reconstrucción
    setState(() {
      _contador++;
    });
    // El código después de setState se ejecuta inmediatamente
    // No esperes a que se reconstruya el widget
  }

  @override
  Widget build(BuildContext context) {
    print('build llamado'); // Se ejecuta en cada reconstrucción
    return Scaffold(
      appBar: AppBar(title: const Text('Contador')),
      body: Center(
        child: Text('Contador: $_contador'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementar,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

**Reglas de setState:**

```dart
// ✅ Correcto: setState solo con cambios de estado
void _correcto() {
  setState(() {
    _contador++;
  });
}

// ❌ Incorrecto: setState con operaciones costosas
void _incorrecto() {
  setState(() {
    _contador++;
    // ❌ No hacer operaciones costosas dentro de setState
    for (var i = 0; i < 1000000; i++) {
      // procesamiento pesado
    }
  });
}

// ✅ Correcto: operaciones costosas fuera de setState
void _correctoCostoso() async {
  // Hacer trabajo pesado fuera
  final resultado = await calcularAlgoCostoso();
  
  // Solo actualizar estado al final
  setState(() {
    _resultado = resultado;
  });
}

// ⚠️ Cuidado: setState en initState
@override
void initState() {
  super.initState();
  // ❌ No llamar setState directamente en initState
  // setState(() {});  // Error: widget no está en el árbol todavía
  
  // ✅ Correcto: usar addPostFrameCallback o Future
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Código que necesita el widget montado
    setState(() {
      // Actualizar estado
    });
  });
}
```

#### Lifting State Up (Elevar el estado)

Cuando múltiples widgets necesitan compartir estado, se "eleva" al ancestro común más cercano:

```dart
// Ejemplo: Lista de tareas compartida entre widgets

class Tarea {
  final String id;
  final String titulo;
  final bool completada;

  Tarea({
    required this.id,
    required this.titulo,
    this.completada = false,
  });

  Tarea copyWith({
    String? id,
    String? titulo,
    bool? completada,
  }) {
    return Tarea(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      completada: completada ?? this.completada,
    );
  }
}

// Widget padre que maneja el estado
class TareasPage extends StatefulWidget {
  const TareasPage({super.key});

  @override
  State<TareasPage> createState() => _TareasPageState();
}

class _TareasPageState extends State<TareasPage> {
  List<Tarea> _tareas = [];

  void _agregarTarea(String titulo) {
    setState(() {
      _tareas.add(Tarea(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        titulo: titulo,
      ));
    });
  }

  void _toggleTarea(String id) {
    setState(() {
      final index = _tareas.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tareas[index] = _tareas[index].copyWith(
          completada: !_tareas[index].completada,
        );
      }
    });
  }

  void _eliminarTarea(String id) {
    setState(() {
      _tareas.removeWhere((t) => t.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tareas')),
      body: Column(
        children: [
          // Pasar estado y callbacks a los hijos
          Expanded(
            child: TareasLista(
              tareas: _tareas,
              onToggle: _toggleTarea,
              onEliminar: _eliminarTarea,
            ),
          ),
          TareasInput(
            onAgregar: _agregarTarea,
          ),
        ],
      ),
    );
  }
}

// Widget hijo que solo muestra la lista
class TareasLista extends StatelessWidget {
  final List<Tarea> tareas;
  final Function(String) onToggle;
  final Function(String) onEliminar;

  const TareasLista({
    super.key,
    required this.tareas,
    required this.onToggle,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    if (tareas.isEmpty) {
      return const Center(child: Text('No hay tareas'));
    }

    return ListView.builder(
      itemCount: tareas.length,
      itemBuilder: (context, index) {
        final tarea = tareas[index];
        return ListTile(
          leading: Checkbox(
            value: tarea.completada,
            onChanged: (_) => onToggle(tarea.id),
          ),
          title: Text(
            tarea.titulo,
            style: TextStyle(
              decoration: tarea.completada 
                  ? TextDecoration.lineThrough 
                  : null,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => onEliminar(tarea.id),
          ),
        );
      },
    );
  }
}

// Widget hijo para añadir tareas
class TareasInput extends StatefulWidget {
  final Function(String) onAgregar;

  const TareasInput({super.key, required this.onAgregar});

  @override
  State<TareasInput> createState() => _TareasInputState();
}

class _TareasInputState extends State<TareasInput> {
  final _controller = TextEditingController();

  void _enviar() {
    if (_controller.text.isNotEmpty) {
      widget.onAgregar(_controller.text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Nueva tarea',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _enviar(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _enviar,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

---

### 2. Navegación básica

#### Navigator.push y Navigator.pop

Flutter usa una pila de navegación (stack) donde cada pantalla es una "ruta":

```dart
// Navegación básica
class PrimeraPantalla extends StatelessWidget {
  const PrimeraPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Primera Pantalla')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Ir a Segunda Pantalla'),
          onPressed: () {
            // Agregar nueva pantalla a la pila
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SegundaPantalla(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SegundaPantalla extends StatelessWidget {
  const SegundaPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Segunda Pantalla')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Volver'),
          onPressed: () {
            // Quitar pantalla de la pila
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
```

#### Pasar datos entre pantallas

```dart
// Pantalla que envía datos
class DetalleProductoPage extends StatelessWidget {
  final String productoId;
  final String nombre;
  final double precio;

  const DetalleProductoPage({
    super.key,
    required this.productoId,
    required this.nombre,
    required this.precio,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(nombre)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ID: $productoId'),
            Text('Precio: \$${precio.toStringAsFixed(2)}'),
            ElevatedButton(
              child: const Text('Volver'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

// Navegación con datos
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DetalleProductoPage(
      productoId: 'prod-001',
      nombre: 'Laptop',
      precio: 999.99,
    ),
  ),
);
```

#### Recibir datos de vuelta

```dart
// Pantalla que espera resultado
class SeleccionColorPage extends StatelessWidget {
  const SeleccionColorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar Color')),
      body: ListView(
        children: ['Rojo', 'Verde', 'Azul'].map((color) {
          return ListTile(
            title: Text(color),
            onTap: () {
              // Devolver resultado y cerrar
              Navigator.pop(context, color);
            },
          );
        }).toList(),
      ),
    );
  }
}

// Uso
Future<void> _seleccionarColor(BuildContext context) async {
  // Navigator.push devuelve un Future
  final resultado = await Navigator.push<String>(
    context,
    MaterialPageRoute(
      builder: (context) => const SeleccionColorPage(),
    ),
  );

  // resultado es null si se volvió sin seleccionar
  if (resultado != null) {
    print('Color seleccionado: $resultado');
    // Usar el resultado
  }
}
```

---

### 3. Rutas nombradas

#### Configuración de rutas

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App',
      
      // Ruta inicial
      initialRoute: '/',
      
      // Definición de rutas nombradas
      routes: {
        '/': (context) => const HomePage(),
        '/productos': (context) => const ProductosPage(),
        '/configuracion': (context) => const ConfiguracionPage(),
        '/perfil': (context) => const PerfilPage(),
      },
      
      // Manejador para rutas no definidas
      onGenerateRoute: (settings) {
        // Rutas dinámicas
        if (settings.name?.startsWith('/producto/') ?? false) {
          final id = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (context) => DetalleProductoPage(productoId: id),
          );
        }
        return null; // Usa el manejador por defecto
      },
      
      // Ruta cuando no se encuentra
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const NotFoundPage(),
        );
      },
    );
  }
}
```

#### Navegación con rutas nombradas

```dart
// Navegar a una ruta
Navigator.pushNamed(context, '/productos');

// Navegar y reemplazar (no se puede volver)
Navigator.pushReplacementNamed(context, '/login');

// Navegar y limpiar todo el stack
Navigator.pushNamedAndRemoveUntil(
  context,
  '/home',
  (route) => false, // Elimina todas las rutas anteriores
);

// Navegar con argumentos
Navigator.pushNamed(
  context,
  '/producto',
  arguments: {'id': '123', 'nombre': 'Laptop'},
);

// Recibir argumentos en la pantalla destino
class DetalleProductoPage extends StatelessWidget {
  const DetalleProductoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener argumentos
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final id = args?['id'] ?? 'desconocido';
    
    return Scaffold(
      appBar: AppBar(title: Text('Producto $id')),
      body: Center(child: Text('ID: $id')),
    );
  }
}

// Volver
Navigator.pop(context);

// Volver con resultado
Navigator.pop(context, 'resultado');
```

#### onGenerateRoute para argumentos tipados

```dart
// Definir clase para argumentos
class ProductoArguments {
  final String id;
  final String nombre;

  ProductoArguments({required this.id, required this.nombre});
}

// Configurar onGenerateRoute
onGenerateRoute: (settings) {
  switch (settings.name) {
    case '/producto':
      final args = settings.arguments as ProductoArguments;
      return MaterialPageRoute(
        builder: (context) => DetalleProductoPage(
          id: args.id,
          nombre: args.nombre,
        ),
      );
    default:
      return null;
  }
},

// Navegar con argumentos tipados
Navigator.pushNamed(
  context,
  '/producto',
  arguments: ProductoArguments(id: '123', nombre: 'Laptop'),
);
```

---

### 4. Hero animations

#### Hero básico

Las animaciones Hero permiten compartir elementos entre pantallas:

```dart
// Primera pantalla
class ProductosPage extends StatelessWidget {
  const ProductosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Productos')),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetalleProductoPage(
                    producto: product,
                  ),
                ),
              );
            },
            child: Hero(
              tag: 'producto-${product.id}', // Tag único
              child: Image.network(product.imagen),
            ),
          );
        },
      ),
    );
  }
}

// Segunda pantalla - mismo Hero con el mismo tag
class DetalleProductoPage extends StatelessWidget {
  final Producto producto;

  const DetalleProductoPage({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Hero(
            tag: 'producto-${producto.id}', // Mismo tag
            child: Image.network(producto.imagen),
          ),
          Text(producto.nombre),
          Text('\$${producto.precio}'),
        ],
      ),
    );
  }
}
```

#### Hero con placeholder

```dart
Hero(
  tag: 'producto-${producto.id}',
  // Placeholder mientras se carga
  placeholderBuilder: (context, heroSize, child) {
    return Container(
      width: heroSize.width,
      height: heroSize.height,
      color: Colors.grey[300],
      child: const Center(child: CircularProgressIndicator()),
    );
  },
  child: Image.network(
    producto.imagen,
    fit: BoxFit.cover,
  ),
);
```

#### Hero con flightShuttleBuilder

```dart
Hero(
  tag: 'producto-${producto.id}',
  flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
    // Widget personalizado durante la transición
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: flightDirection == HeroFlightDirection.push
              ? animation.value
              : 1 - animation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(animation.value * 16),
            ),
            child: toHeroContext.widget,
          ),
        );
      },
    );
  },
  child: Image.network(producto.imagen),
);
```

---

### 5. Formularios

#### TextField y TextEditingController

```dart
class FormularioBasico extends StatefulWidget {
  const FormularioBasico({super.key});

  @override
  State<FormularioBasico> createState() => _FormularioBasicoState();
}

class _FormularioBasicoState extends State<FormularioBasico> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    // IMPORTANTE: Liberar controllers
    _nombreController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _enviar() {
    final nombre = _nombreController.text;
    final email = _emailController.text;
    print('Nombre: $nombre, Email: $email');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Formulario Básico')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'Introduce tu nombre',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'ejemplo@email.com',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _enviar,
              child: const Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### Form y FormField

```dart
class FormularioValidado extends StatefulWidget {
  const FormularioValidado({super.key});

  @override
  State<FormularioValidado> createState() => _FormularioValidadoState();
}

class _FormularioValidadoState extends State<FormularioValidado> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validarNombre(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre es obligatorio';
    }
    if (value.length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }
    return null; // Válido
  }

  String? _validarEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es obligatorio';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Introduce un email válido';
    }
    return null;
  }

  String? _validarPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'La contraseña debe tener al menos una mayúscula';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'La contraseña debe tener al menos un número';
    }
    return null;
  }

  void _enviar() {
    if (_formKey.currentState!.validate()) {
      // Formulario válido
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Procesando...')),
      );
      // Enviar datos
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Formulario con Validación')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: _validarNombre,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validarEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: _validarPassword,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _enviar,
                child: const Text('Enviar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### FocusNode y Focus management

```dart
class FocusExample extends StatefulWidget {
  const FocusExample({super.key});

  @override
  State<FocusExample> createState() => _FocusExampleState();
}

class _FocusExampleState extends State<FocusExample> {
  final _nombreFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _nombreFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _fieldFocusChange(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Focus Management')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              focusNode: _nombreFocus,
              decoration: const InputDecoration(labelText: 'Nombre'),
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _fieldFocusChange(context, _nombreFocus, _emailFocus),
            ),
            const SizedBox(height: 16),
            TextField(
              focusNode: _emailFocus,
              decoration: const InputDecoration(labelText: 'Email'),
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _fieldFocusChange(context, _emailFocus, _passwordFocus),
            ),
            const SizedBox(height: 16),
            TextField(
              focusNode: _passwordFocus,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                _passwordFocus.unfocus();
                // Enviar formulario
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                FocusScope.of(context).unfocus(); // Quitar foco de todos
                // Enviar
              },
              child: const Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 6. Diálogos y sheets

#### AlertDialog

```dart
// Diálogo de confirmación
Future<bool?> _mostrarConfirmacion(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirmar acción'),
      content: const Text('¿Estás seguro de que quieres continuar?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Aceptar'),
        ),
      ],
    ),
  );
}

// Uso
final confirmado = await _mostrarConfirmacion(context);
if (confirmado == true) {
  // Acción confirmada
}

// Diálogo con formulario
Future<String?> _mostrarInputDialog(BuildContext context) async {
  final controller = TextEditingController();
  
  return await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Introduce nombre'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'Nombre',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('Aceptar'),
        ),
      ],
    ),
  );
}
```

#### BottomSheet

```dart
// BottomSheet simple
void _mostrarBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Opciones',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text('Galería'),
            onTap: () {
              Navigator.pop(context);
              // Abrir galería
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text('Cámara'),
            onTap: () {
              Navigator.pop(context);
              // Abrir cámara
            },
          ),
          ListTile(
            leading: const Icon(Icons.cancel),
            title: const Text('Cancelar'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    ),
  );
}

// BottomSheet con altura personalizada
void _mostrarBottomSheetGrande(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Permite altura personalizada
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.5, // 50% de la pantalla
      minChildSize: 0.25,    // 25% mínimo
      maxChildSize: 0.9,     // 90% máximo
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: ListView.builder(
          controller: scrollController,
          itemCount: 20,
          itemBuilder: (context, index) => ListTile(
            title: Text('Opción $index'),
          ),
        ),
      ),
    ),
  );
}
```

#### SnackBar

```dart
void _mostrarSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Operación completada'),
      duration: Duration(seconds: 3),
      action: SnackBarAction(
        label: 'Deshacer',
        onPressed: () {
          // Deshacer acción
        },
      ),
    ),
  );
}

// SnackBar con estilo personalizado
void _mostrarSnackBarPersonalizado(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white),
          SizedBox(width: 8),
          Text('Guardado correctamente'),
        ],
      ),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}
```

---

### 7. Ejercicios prácticos del Módulo 4

#### Ejercicio 1: App de notas

Crear una app de notas con:
- Lista de notas
- Añadir notas
- Editar notas
- Eliminar notas (con confirmación)

**Solución:**

```dart
class Nota {
  final String id;
  String titulo;
  String contenido;
  DateTime fechaCreacion;
  DateTime fechaModificacion;

  Nota({
    required this.id,
    required this.titulo,
    required this.contenido,
    DateTime? fechaCreacion,
    DateTime? fechaModificacion,
  })  : fechaCreacion = fechaCreacion ?? DateTime.now(),
        fechaModificacion = fechaModificacion ?? DateTime.now();

  void actualizar(String nuevoTitulo, String nuevoContenido) {
    titulo = nuevoTitulo;
    contenido = nuevoContenido;
    fechaModificacion = DateTime.now();
  }
}

class NotasApp extends StatefulWidget {
  const NotasApp({super.key});

  @override
  State<NotasApp> createState() => _NotasAppState();
}

class _NotasAppState extends State<NotasApp> {
  final List<Nota> _notas = [];

  void _agregarNota() async {
    final nuevaNota = await Navigator.push<Nota>(
      context,
      MaterialPageRoute(
        builder: (context) => const EditorNotaPage(),
      ),
    );

    if (nuevaNota != null) {
      setState(() {
        _notas.insert(0, nuevaNota);
      });
    }
  }

  void _editarNota(Nota nota) async {
    final notaEditada = await Navigator.push<Nota>(
      context,
      MaterialPageRoute(
        builder: (context) => EditorNotaPage(nota: nota),
      ),
    );

    if (notaEditada != null) {
      setState(() {
        final index = _notas.indexWhere((n) => n.id == notaEditada.id);
        if (index != -1) {
          _notas[index] = notaEditada;
        }
      });
    }
  }

  void _eliminarNota(Nota nota) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar nota'),
        content: Text('¿Eliminar "${nota.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() {
        _notas.removeWhere((n) => n.id == nota.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nota eliminada')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Notas')),
      body: _notas.isEmpty
          ? const Center(child: Text('No hay notas. ¡Añade una!'))
          : ListView.builder(
              itemCount: _notas.length,
              itemBuilder: (context, index) {
                final nota = _notas[index];
                return ListTile(
                  title: Text(nota.titulo),
                  subtitle: Text(
                    nota.contenido,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _eliminarNota(nota),
                  ),
                  onTap: () => _editarNota(nota),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarNota,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class EditorNotaPage extends StatefulWidget {
  final Nota? nota;

  const EditorNotaPage({super.key, this.nota});

  @override
  State<EditorNotaPage> createState() => _EditorNotaPageState();
}

class _EditorNotaPageState extends State<EditorNotaPage> {
  final _tituloController = TextEditingController();
  final _contenidoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.nota != null) {
      _tituloController.text = widget.nota!.titulo;
      _contenidoController.text = widget.nota!.contenido;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _contenidoController.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_tituloController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El título es obligatorio')),
      );
      return;
    }

    final nota = Nota(
      id: widget.nota?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: _tituloController.text,
      contenido: _contenidoController.text,
      fechaCreacion: widget.nota?.fechaCreacion,
    );

    Navigator.pop(context, nota);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nota == null ? 'Nueva Nota' : 'Editar Nota'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _guardar,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contenidoController,
                decoration: const InputDecoration(
                  labelText: 'Contenido',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

**Resumen del Módulo 4:**

En este módulo aprendiste:

✅ Gestión de estado local con setState
✅ Lifting State Up (elevar el estado)
✅ Navegación básica: push, pop, pasar datos
✅ Rutas nombradas y onGenerateRoute
✅ Hero animations para transiciones
✅ Formularios con TextField y Form
✅ Validación de formularios
✅ FocusNode y manejo de foco
✅ Diálogos (AlertDialog)
✅ BottomSheets
✅ SnackBars
✅ Ejercicio práctico: App de notas

**Próximo módulo:** Formularios y Validación## Módulo 5: Formularios y Validación (3 horas)

---

### 1. TextFormField y FormField

#### TextFormField básico

`TextFormField` es un `TextField` que sabe trabajar con `Form`:

```dart
class FormularioTextFormField extends StatefulWidget {
  const FormularioTextFormField({super.key});

  @override
  State<FormularioTextFormField> createState() => _FormularioTextFormFieldState();
}

class _FormularioTextFormFieldState extends State<FormularioTextFormField> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TextFormField')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // TextFormField básico
              TextFormField(
                decoration: const InputDecoration(
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
                onSaved: (value) {
                  // Se llama cuando form.save()
                  print('Nombre guardado: $value');
                },
              ),
              const SizedBox(height: 16),
              
              // TextFormField con tipos de input
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El email es obligatorio';
                  }
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Introduce un email válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // TextFormField para contraseña
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La contraseña es obligatoria';
                  }
                  if (value.length < 8) {
                    return 'Mínimo 8 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Botón de enviar
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Procesar formulario
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Formulario válido')),
                    );
                  }
                },
                child: const Text('Enviar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### InputDecoration completo

```dart
TextFormField(
  decoration: InputDecoration(
    // Etiqueta flotante
    labelText: 'Email',
    
    // Texto de pista (placeholder)
    hintText: 'ejemplo@correo.com',
    
    // Texto de ayuda (debajo del campo)
    helperText: 'No compartiremos tu email',
    
    // Icono al inicio
    prefixIcon: const Icon(Icons.email),
    
    // Icono al final
    suffixIcon: IconButton(
      icon: const Icon(Icons.clear),
      onPressed: () {
        // Limpiar campo
      },
    ),
    
    // Texto dentro del campo al inicio
    prefixText: '@',
    
    // Texto dentro del campo al final
    suffixText: '.com',
    
    // Contador de caracteres
    counterText: '0/100',
    
    // Borde por defecto
    border: const OutlineInputBorder(),
    
    // Borde cuando tiene foco
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 2),
    ),
    
    // Borde cuando hay error
    errorBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
    ),
    
    // Borde cuando está deshabilitado
    disabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
    ),
    
    // Color de fondo
    filled: true,
    fillColor: Colors.grey[100],
    
    // Alineación del contenido
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    
    // Icono de error
    errorIcon: const Icon(Icons.error, color: Colors.red),
    
    // Estilo del texto de error
    errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
    
    // Máximo de líneas para el error
    errorMaxLines: 2,
  ),
);
```

#### TextFormField con controlador

```dart
class TextFormFieldConControlador extends StatefulWidget {
  const TextFormFieldConControlador({super.key});

  @override
  State<TextFormFieldConControlador> createState() => _TextFormFieldConControladorState();
}

class _TextFormFieldConControladorState extends State<TextFormFieldConControlador> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Controladores')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                // Escuchar cambios
                onChanged: (value) {
                  print('Nombre cambiando: $value');
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final nombre = _nombreController.text;
                        final email = _emailController.text;
                        print('Nombre: $nombre, Email: $email');
                      }
                    },
                    child: const Text('Enviar'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: () {
                      _nombreController.clear();
                      _emailController.clear();
                    },
                    child: const Text('Limpiar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### 2. Validación personalizada

#### Validadores reutilizables

```dart
// archivo: validators.dart

class Validators {
  // Validador de campo requerido
  static String? required(String? value, [String? message]) {
    if (value == null || value.isEmpty) {
      return message ?? 'Este campo es obligatorio';
    }
    return null;
  }

  // Validador de longitud mínima
  static String? minLength(String? value, int min, [String? message]) {
    if (value == null || value.isEmpty) return required(value);
    if (value.length < min) {
      return message ?? 'Mínimo $min caracteres';
    }
    return null;
  }

  // Validador de longitud máxima
  static String? maxLength(String? value, int max, [String? message]) {
    if (value == null || value.isEmpty) return null;
    if (value.length > max) {
      return message ?? 'Máximo $max caracteres';
    }
    return null;
  }

  // Validador de email
  static String? email(String? value, [String? message]) {
    if (value == null || value.isEmpty) return required(value);
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return message ?? 'Introduce un email válido';
    }
    return null;
  }

  // Validador de teléfono
  static String? phone(String? value, [String? message]) {
    if (value == null || value.isEmpty) return required(value);
    final phoneRegex = RegExp(r'^\+?[0-9]{9,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return message ?? 'Introduce un teléfono válido';
    }
    return null;
  }

  // Validador de contraseña
  static String? password(String? value, [String? message]) {
    if (value == null || value.isEmpty) return required(value);
    if (value.length < 8) return 'Mínimo 8 caracteres';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Al menos una mayúscula';
    if (!value.contains(RegExp(r'[a-z]'))) return 'Al menos una minúscula';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Al menos un número';
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Al menos un carácter especial';
    }
    return null;
  }

  // Validador de número
  static String? numeric(String? value, [String? message]) {
    if (value == null || value.isEmpty) return required(value);
    if (double.tryParse(value) == null) {
      return message ?? 'Introduce un número válido';
    }
    return null;
  }

  // Validador de rango numérico
  static String? range(String? value, int min, int max, [String? message]) {
    if (value == null || value.isEmpty) return required(value);
    final num = int.tryParse(value);
    if (num == null) return 'Introduce un número válido';
    if (num < min || num > max) {
      return message ?? 'El valor debe estar entre $min y $max';
    }
    return null;
  }

  // Validador de coincidencia
  static String? match(String? value, String pattern, [String? message]) {
    if (value == null || value.isEmpty) return required(value);
    if (!RegExp(pattern).hasMatch(value)) {
      return message ?? 'Formato inválido';
    }
    return null;
  }

  // Validador de fecha
  static String? date(String? value, [String? message]) {
    if (value == null || value.isEmpty) return required(value);
    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return message ?? 'Formato de fecha inválido (YYYY-MM-DD)';
    }
  }

  // Combinar validadores
  static String? compose(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
```

#### Uso de validadores personalizados

```dart
class FormularioConValidadores extends StatefulWidget {
  const FormularioConValidadores({super.key});

  @override
  State<FormularioConValidadores> createState() => _FormularioConValidadoresState();
}

class _FormularioConValidadoresState extends State<FormularioConValidadores> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _edadController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _telefonoController.dispose();
    _edadController.dispose();
    super.dispose();
  }

  // Validador de confirmación de contraseña
  String? _validarConfirmacionPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  // Validador de edad
  String? _validarEdad(String? value) {
    final requiredResult = Validators.required(value, 'La edad es obligatoria');
    if (requiredResult != null) return requiredResult;

    final numericResult = Validators.numeric(value);
    if (numericResult != null) return numericResult;

    final edad = int.parse(value!);
    if (edad < 18) return 'Debes ser mayor de 18 años';
    if (edad > 120) return 'Edad inválida';

    return null;
  }

  void _enviar() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Procesar formulario
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Formulario enviado correctamente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Validadores')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => Validators.compose([
                  (v) => Validators.required(v, 'El nombre es obligatorio'),
                  (v) => Validators.minLength(v, 3),
                  (v) => Validators.maxLength(v, 50),
                ])(value),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: Validators.password,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordConfirmController,
                decoration: const InputDecoration(
                  labelText: 'Confirmar contraseña',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: _validarConfirmacionPassword,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixText: '+34 ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => Validators.phone(value?.replaceFirst('+34', '')),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _edadController,
                decoration: const InputDecoration(
                  labelText: 'Edad',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: _validarEdad,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _enviar,
                child: const Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### 3. Formularios complejos

#### Checkbox, Radio y Switch

```dart
class FormularioCheckboxRadio extends StatefulWidget {
  const FormularioCheckboxRadio({super.key});

  @override
  State<FormularioCheckboxRadio> createState() => _FormularioCheckboxRadioState();
}

class _FormularioCheckboxRadioState extends State<FormularioCheckboxRadio> {
  // Checkbox
  bool _aceptaTerminos = false;
  bool _recibeNewsletter = false;
  Set<String> _intereses = {};

  // Radio
  String? _genero;
  String _plan = 'basico';

  // Switch
  bool _notificaciones = true;
  bool _modoOscuro = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkbox, Radio, Switch')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === CHECKBOX ===
            const Text(
              'Checkbox',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            
            // Checkbox simple
            CheckboxListTile(
              title: const Text('Acepto los términos y condiciones'),
              subtitle: const Text('Requerido para continuar'),
              value: _aceptaTerminos,
              onChanged: (value) {
                setState(() {
                  _aceptaTerminos = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),

            CheckboxListTile(
              title: const Text('Recibir newsletter'),
              value: _recibeNewsletter,
              onChanged: (value) {
                setState(() {
                  _recibeNewsletter = value ?? false;
                });
              },
            ),

            const SizedBox(height: 16),

            // === CHECKBOX MÚLTIPLE ===
            const Text(
              'Intereses (selección múltiple)',
              style: TextStyle(fontSize: 16),
            ),
            Wrap(
              spacing: 8,
              children: ['Tecnología', 'Deportes', 'Música', 'Viajes'].map((interes) {
                return FilterChip(
                  label: Text(interes),
                  selected: _intereses.contains(interes),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _intereses.add(interes);
                      } else {
                        _intereses.remove(interes);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // === RADIO BUTTONS ===
            const Text(
              'Radio Buttons',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const Text('Género'),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Masculino'),
                    value: 'masculino',
                    groupValue: _genero,
                    onChanged: (value) {
                      setState(() {
                        _genero = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Femenino'),
                    value: 'femenino',
                    groupValue: _genero,
                    onChanged: (value) {
                      setState(() {
                        _genero = value;
                      });
                    },
                  ),
                ),
              ],
            ),

            const Text('Tipo de plan'),
            Column(
              children: ['basico', 'premium', 'enterprise'].map((plan) {
                return RadioListTile<String>(
                  title: Text(plan[0].toUpperCase() + plan.substring(1)),
                  subtitle: Text(_getPlanDescription(plan)),
                  value: plan,
                  groupValue: _plan,
                  onChanged: (value) {
                    setState(() {
                      _plan = value!;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // === SWITCH ===
            const Text(
              'Switch',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SwitchListTile(
              title: const Text('Notificaciones'),
              subtitle: const Text('Recibir notificaciones push'),
              value: _notificaciones,
              onChanged: (value) {
                setState(() {
                  _notificaciones = value;
                });
              },
            ),

            SwitchListTile(
              title: const Text('Modo oscuro'),
              value: _modoOscuro,
              onChanged: (value) {
                setState(() {
                  _modoOscuro = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getPlanDescription(String plan) {
    switch (plan) {
      case 'basico':
        return 'Funcionalidades básicas';
      case 'premium':
        return 'Todas las funcionalidades';
      case 'enterprise':
        return 'Soporte prioritario + extras';
      default:
        return '';
    }
  }
}
```

#### Dropdown y Select

```dart
class FormularioDropdown extends StatefulWidget {
  const FormularioDropdown({super.key});

  @override
  State<FormularioDropdown> createState() => _FormularioDropdownState();
}

class _FormularioDropdownState extends State<FormularioDropdown> {
  // Dropdown simple
  String? _paisSeleccionado;
  String? _ciudadSeleccionada;
  String? _profesionSeleccionada;

  // Dropdown múltiple
  Set<String> _habilidadesSeleccionadas = {};

  // Datos
  final List<String> _paises = ['España', 'México', 'Argentina', 'Colombia', 'Chile'];
  
  final Map<String, List<String>> _ciudadesPorPais = {
    'España': ['Madrid', 'Barcelona', 'Valencia', 'Sevilla'],
    'México': ['Ciudad de México', 'Guadalajara', 'Monterrey'],
    'Argentina': ['Buenos Aires', 'Córdoba', 'Rosario'],
    'Colombia': ['Bogotá', 'Medellín', 'Cali'],
    'Chile': ['Santiago', 'Valparaíso', 'Concepción'],
  };

  final List<String> _profesiones = [
    'Desarrollador',
    'Diseñador',
    'Product Manager',
    'Data Scientist',
    'DevOps',
  ];

  final List<String> _habilidades = [
    'Flutter',
    'React',
    'Node.js',
    'Python',
    'SQL',
    'Docker',
    'AWS',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dropdown y Select')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown simple
            const Text(
              'Dropdown simple',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            
            DropdownButtonFormField<String>(
              value: _paisSeleccionado,
              decoration: const InputDecoration(
                labelText: 'País',
                border: OutlineInputBorder(),
              ),
              hint: const Text('Selecciona un país'),
              items: _paises.map((pais) {
                return DropdownMenuItem(
                  value: pais,
                  child: Text(pais),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _paisSeleccionado = value;
                  _ciudadSeleccionada = null; // Reset ciudad
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Selecciona un país';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Dropdown dependiente
            DropdownButtonFormField<String>(
              value: _ciudadSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Ciudad',
                border: OutlineInputBorder(),
              ),
              hint: const Text('Selecciona una ciudad'),
              items: _paisSeleccionado == null
                  ? []
                  : _ciudadesPorPais[_paisSeleccionado]!.map((ciudad) {
                      return DropdownMenuItem(
                        value: ciudad,
                        child: Text(ciudad),
                      );
                    }).toList(),
              onChanged: _paisSeleccionado == null
                  ? null
                  : (value) {
                      setState(() {
                        _ciudadSeleccionada = value;
                      });
                    },
              disabledHint: const Text('Primero selecciona un país'),
            ),

            const SizedBox(height: 24),

            // Dropdown con búsqueda
            const Text(
              'Dropdown con búsqueda',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            DropdownMenu<String>(
              initialSelection: _profesionSeleccionada,
              label: const Text('Profesión'),
              enableFilter: true,
              requestFocusOnTap: true,
              dropdownMenuEntries: _profesiones.map((profesion) {
                return DropdownMenuEntry(
                  value: profesion,
                  label: profesion,
                );
              }).toList(),
              onSelected: (value) {
                setState(() {
                  _profesionSeleccionada = value;
                });
              },
            ),

            const SizedBox(height: 24),

            // Selección múltiple con chips
            const Text(
              'Selección múltiple',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _habilidades.map((habilidad) {
                final seleccionada = _habilidadesSeleccionadas.contains(habilidad);
                return FilterChip(
                  label: Text(habilidad),
                  selected: seleccionada,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _habilidadesSeleccionadas.add(habilidad);
                      } else {
                        _habilidadesSeleccionadas.remove(habilidad);
                      }
                    });
                  },
                  selectedColor: Colors.blue[100],
                  checkmarkColor: Colors.blue,
                );
              }).toList(),
            ),

            if (_habilidadesSeleccionadas.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Seleccionadas: ${_habilidadesSeleccionadas.join(", ")}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

#### Date y Time Picker

```dart
class FormularioFechaHora extends StatefulWidget {
  const FormularioFechaHora({super.key});

  @override
  State<FormularioFechaHora> createState() => _FormularioFechaHoraState();
}

class _FormularioFechaHoraState extends State<FormularioFechaHora> {
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;
  DateTimeRange? _rangoFechas;

  final _fechaController = TextEditingController();
  final _horaController = TextEditingController();

  Future<void> _seleccionarFecha(BuildContext context) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
      helpText: 'Selecciona una fecha',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      fieldLabelText: 'Fecha',
      fieldHintText: 'dd/mm/aaaa',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
        _fechaController.text = '${fecha.day}/${fecha.month}/${fecha.year}';
      });
    }
  }

  Future<void> _seleccionarHora(BuildContext context) async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada ?? TimeOfDay.now(),
      helpText: 'Selecciona una hora',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      hourLabelText: 'Hora',
      minuteLabelText: 'Minuto',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: const TimePickerThemeData(
              hourMinuteTextColor: Colors.blue,
              dialHandColor: Colors.blue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (hora != null) {
      setState(() {
        _horaSeleccionada = hora;
        _horaController.text = '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _seleccionarRangoFechas(BuildContext context) async {
    final rango = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _rangoFechas,
      locale: const Locale('es', 'ES'),
      helpText: 'Selecciona el rango',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      saveText: 'Guardar',
      fieldStartLabelText: 'Desde',
      fieldEndLabelText: 'Hasta',
    );

    if (rango != null) {
      setState(() {
        _rangoFechas = rango;
      });
    }
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _horaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fecha y Hora')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Selector de fecha
            TextFormField(
              controller: _fechaController,
              decoration: InputDecoration(
                labelText: 'Fecha',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _seleccionarFecha(context),
                ),
              ),
              readOnly: true,
              onTap: () => _seleccionarFecha(context),
            ),

            const SizedBox(height: 16),

            // Selector de hora
            TextFormField(
              controller: _horaController,
              decoration: InputDecoration(
                labelText: 'Hora',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () => _seleccionarHora(context),
                ),
              ),
              readOnly: true,
              onTap: () => _seleccionarHora(context),
            ),

            const SizedBox(height: 24),

            // Rango de fechas
            ElevatedButton.icon(
              onPressed: () => _seleccionarRangoFechas(context),
              icon: const Icon(Icons.date_range),
              label: const Text('Seleccionar rango de fechas'),
            ),

            if (_rangoFechas != null) ...[
              const SizedBox(height: 16),
              Text(
                'Del ${_rangoFechas!.start.day}/${_rangoFechas!.start.month}/${_rangoFechas!.start.year} '
                'al ${_rangoFechas!.end.day}/${_rangoFechas!.end.month}/${_rangoFechas!.end.year}',
                style: const TextStyle(fontSize: 16),
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

### 4. Ejercicios prácticos del Módulo 5

#### Ejercicio: Formulario de registro completo

Crear un formulario de registro con:
- Validación completa
- Selección de fecha de nacimiento
- Selección de país/ciudad dependientes
- Checkbox de términos
- Guardar y limpiar formulario

**Solución:**

```dart
class UsuarioRegistro {
  String nombre;
  String email;
  String password;
  DateTime? fechaNacimiento;
  String? pais;
  String? ciudad;
  Set<String> intereses;
  bool aceptaTerminos;

  UsuarioRegistro({
    this.nombre = '',
    this.email = '',
    this.password = '',
    this.fechaNacimiento,
    this.pais,
    this.ciudad,
    Set<String>? intereses,
    this.aceptaTerminos = false,
  }) : intereses = intereses ?? {};
}

class FormularioRegistroPage extends StatefulWidget {
  const FormularioRegistroPage({super.key});

  @override
  State<FormularioRegistroPage> createState() => _FormularioRegistroPageState();
}

class _FormularioRegistroPageState extends State<FormularioRegistroPage> {
  final _formKey = GlobalKey<FormState>();
  final _usuario = UsuarioRegistro();
  
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();

  final Map<String, List<String>> _ciudadesPorPais = {
    'España': ['Madrid', 'Barcelona', 'Valencia'],
    'México': ['CDMX', 'Guadalajara', 'Monterrey'],
    'Argentina': ['Buenos Aires', 'Córdoba'],
  };

  final List<String> _interesesDisponibles = [
    'Tecnología', 'Deportes', 'Música', 'Viajes', 'Cine', 'Libros'
  ];

  Future<void> _seleccionarFechaNacimiento() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _usuario.fechaNacimiento ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );

    if (fecha != null) {
      setState(() {
        _usuario.fechaNacimiento = fecha;
        _fechaNacimientoController.text = '${fecha.day}/${fecha.month}/${fecha.year}';
      });
    }
  }

  void _enviar() {
    if (_formKey.currentState!.validate()) {
      if (!_usuario.aceptaTerminos) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes aceptar los términos')),
        );
        return;
      }

      _formKey.currentState!.save();
      
      // Mostrar datos
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Registro exitoso'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nombre: ${_usuario.nombre}'),
              Text('Email: ${_usuario.email}'),
              Text('País: ${_usuario.pais}'),
              Text('Ciudad: ${_usuario.ciudad}'),
              Text('Intereses: ${_usuario.intereses.join(", ")}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _limpiar() {
    _formKey.currentState?.reset();
    setState(() {
      _usuario.fechaNacimiento = null;
      _usuario.pais = null;
      _usuario.ciudad = null;
      _usuario.intereses.clear();
      _usuario.aceptaTerminos = false;
      _fechaNacimientoController.clear();
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fechaNacimientoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Usuario')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Nombre
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  if (value.length < 3) {
                    return 'Mínimo 3 caracteres';
                  }
                  return null;
                },
                onSaved: (value) => _usuario.nombre = value ?? '',
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
                onSaved: (value) => _usuario.email = value ?? '',
              ),
              const SizedBox(height: 16),

              // Password
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: Validators.password,
                onSaved: (value) => _usuario.password = value ?? '',
              ),
              const SizedBox(height: 16),

              // Fecha de nacimiento
              TextFormField(
                controller: _fechaNacimientoController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de nacimiento',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _seleccionarFechaNacimiento,
                validator: (value) {
                  if (_usuario.fechaNacimiento == null) {
                    return 'Selecciona tu fecha de nacimiento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // País
              DropdownButtonFormField<String>(
                value: _usuario.pais,
                decoration: const InputDecoration(
                  labelText: 'País',
                  border: OutlineInputBorder(),
                ),
                items: _ciudadesPorPais.keys.map((pais) {
                  return DropdownMenuItem(value: pais, child: Text(pais));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _usuario.pais = value;
                    _usuario.ciudad = null;
                  });
                },
                validator: (value) => value == null ? 'Selecciona un país' : null,
              ),
              const SizedBox(height: 16),

              // Ciudad
              DropdownButtonFormField<String>(
                value: _usuario.ciudad,
                decoration: const InputDecoration(
                  labelText: 'Ciudad',
                  border: OutlineInputBorder(),
                ),
                items: _usuario.pais == null
                    ? []
                    : _ciudadesPorPais[_usuario.pais]!.map((ciudad) {
                        return DropdownMenuItem(value: ciudad, child: Text(ciudad));
                      }).toList(),
                onChanged: _usuario.pais == null
                    ? null
                    : (value) {
                        setState(() {
                          _usuario.ciudad = value;
                        });
                      },
                validator: (value) => value == null ? 'Selecciona una ciudad' : null,
              ),
              const SizedBox(height: 16),

              // Intereses
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Intereses', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _interesesDisponibles.map((interes) {
                  return FilterChip(
                    label: Text(interes),
                    selected: _usuario.intereses.contains(interes),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _usuario.intereses.add(interes);
                        } else {
                          _usuario.intereses.remove(interes);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Términos
              CheckboxListTile(
                title: const Text('Acepto los términos y condiciones'),
                value: _usuario.aceptaTerminos,
                onChanged: (value) {
                  setState(() {
                    _usuario.aceptaTerminos = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 24),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _enviar,
                      child: const Text('Registrar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _limpiar,
                      child: const Text('Limpiar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

**Resumen del Módulo 5:**

En este módulo aprendiste:

✅ TextFormField y FormField con validación
✅ InputDecoration completo
✅ Validadores personalizados reutilizables
✅ Checkbox, Radio, Switch
✅ Dropdown y selección múltiple
✅ Date y Time Picker
✅ Formularios complejos con dependencias
✅ Ejercicio práctico: Formulario de registro completo

**Próximo módulo:** HTTP y APIs REST## Módulo 6: HTTP y APIs REST (4 horas)

---

### 1. Paquete http

#### Instalación

Añadir en `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
```

#### Importar

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
```

#### GET request

```dart
// GET simple
Future<void> obtenerUsuarios() async {
  try {
    final response = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/users'),
    );

    if (response.statusCode == 200) {
      // Decodificar JSON
      final List<dynamic> data = json.decode(response.body);
      print('Usuarios: ${data.length}');
      
      for (var user in data) {
        print(' - ${user['name']} (${user['email']})');
      }
    } else {
      print('Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Excepción: $e');
  }
}

// GET con parámetros
Future<void> buscarUsuarios(String query) async {
  final uri = Uri.parse('https://jsonplaceholder.typicode.com/users')
      .replace(queryParameters: {'q': query, 'limit': '10'});

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print(data);
  }
}

// GET con headers
Future<void> obtenerDatosProtegidos() async {
  final response = await http.get(
    Uri.parse('https://api.ejemplo.com/datos'),
    headers: {
      'Authorization': 'Bearer tu-token-jwt',
      'Accept': 'application/json',
      'X-Custom-Header': 'valor',
    },
  );

  print('Status: ${response.statusCode}');
  print('Body: ${response.body}');
}
```

#### POST request

```dart
// POST con JSON
Future<void> crearUsuario(String nombre, String email) async {
  try {
    final response = await http.post(
      Uri.parse('https://jsonplaceholder.typicode.com/users'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'name': nombre,
        'email': email,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      print('Usuario creado con ID: ${data['id']}');
    } else {
      print('Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Excepción: $e');
  }
}

// POST con form-data
Future<void> enviarFormulario() async {
  final response = await http.post(
    Uri.parse('https://api.ejemplo.com/form'),
    body: {
      'nombre': 'Juan',
      'email': 'juan@ejemplo.com',
      'mensaje': 'Hola mundo',
    },
  );

  print('Status: ${response.statusCode}');
}

// POST con multipart (archivos)
Future<void> subirArchivo(File archivo) async {
  final request = http.MultipartRequest(
    'POST',
    Uri.parse('https://api.ejemplo.com/upload'),
  );

  request.files.add(
    await http.MultipartFile.fromPath('archivo', archivo.path),
  );

  request.fields['descripcion'] = 'Mi archivo';

  final response = await request.send();

  if (response.statusCode == 200) {
    final responseBody = await response.stream.bytesToString();
    print('Archivo subido: $responseBody');
  }
}
```

#### PUT y PATCH

```dart
// PUT - Reemplazar recurso completo
Future<void> actualizarUsuario(int id, String nombre, String email) async {
  final response = await http.put(
    Uri.parse('https://jsonplaceholder.typicode.com/users/$id'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'id': id,
      'name': nombre,
      'email': email,
    }),
  );

  if (response.statusCode == 200) {
    print('Usuario actualizado');
  }
}

// PATCH - Actualización parcial
Future<void> actualizarEmail(int id, String nuevoEmail) async {
  final response = await http.patch(
    Uri.parse('https://jsonplaceholder.typicode.com/users/$id'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'email': nuevoEmail}),
  );

  if (response.statusCode == 200) {
    print('Email actualizado');
  }
}
```

#### DELETE

```dart
Future<void> eliminarUsuario(int id) async {
  final response = await http.delete(
    Uri.parse('https://jsonplaceholder.typicode.com/users/$id'),
  );

  if (response.statusCode == 200) {
    print('Usuario eliminado');
  }
}
```

---

### 2. Modelos de datos

#### Clase modelo básica

```dart
class Usuario {
  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String website;
  final Direccion address;
  final Empresa company;

  Usuario({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.website,
    required this.address,
    required this.company,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
      website: json['website'],
      address: Direccion.fromJson(json['address']),
      company: Empresa.fromJson(json['company']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
      'website': website,
      'address': address.toJson(),
      'company': company.toJson(),
    };
  }

  Usuario copyWith({
    int? id,
    String? name,
    String? username,
    String? email,
    String? phone,
    String? website,
    Direccion? address,
    Empresa? company,
  }) {
    return Usuario(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      address: address ?? this.address,
      company: company ?? this.company,
    );
  }
}

class Direccion {
  final String street;
  final String suite;
  final String city;
  final String zipcode;
  final Geo geo;

  Direccion({
    required this.street,
    required this.suite,
    required this.city,
    required this.zipcode,
    required this.geo,
  });

  factory Direccion.fromJson(Map<String, dynamic> json) {
    return Direccion(
      street: json['street'],
      suite: json['suite'],
      city: json['city'],
      zipcode: json['zipcode'],
      geo: Geo.fromJson(json['geo']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'suite': suite,
      'city': city,
      'zipcode': zipcode,
      'geo': geo.toJson(),
    };
  }
}

class Geo {
  final String lat;
  final String lng;

  Geo({required this.lat, required this.lng});

  factory Geo.fromJson(Map<String, dynamic> json) {
    return Geo(lat: json['lat'], lng: json['lng']);
  }

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
}

class Empresa {
  final String name;
  final String catchPhrase;
  final String bs;

  Empresa({required this.name, required this.catchPhrase, required this.bs});

  factory Empresa.fromJson(Map<String, dynamic> json) {
    return Empresa(
      name: json['name'],
      catchPhrase: json['catchPhrase'],
      bs: json['bs'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'catchPhrase': catchPhrase, 'bs': bs};
  }
}
```

#### Modelo con json_serializable

Instalar dependencias en `pubspec.yaml`:

```yaml
dependencies:
  json_annotation: ^4.8.0

dev_dependencies:
  build_runner: ^2.4.0
  json_serializable: ^6.6.0
```

Crear el modelo:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'producto.g.dart';

@JsonSerializable()
class Producto {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final Rating rating;

  Producto({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
  });

  factory Producto.fromJson(Map<String, dynamic> json) => _$ProductoFromJson(json);
  Map<String, dynamic> toJson() => _$ProductoToJson(this);
}

@JsonSerializable()
class Rating {
  final double rate;
  final int count;

  Rating({required this.rate, required this.count});

  factory Rating.fromJson(Map<String, dynamic> json) => _$RatingFromJson(json);
  Map<String, dynamic> toJson() => _$RatingToJson(this);
}
```

Generar código:

```bash
flutter pub run build_runner build
```

---

### 3. Servicio API

#### Servicio genérico

```dart
class ApiService {
  final String baseUrl;
  final Map<String, String>? defaultHeaders;

  ApiService({
    this.baseUrl = 'https://jsonplaceholder.typicode.com',
    this.defaultHeaders,
  });

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    ...?defaultHeaders,
  };

  // GET
  Future<T> get<T>(
    String endpoint, {
    T Function(Map<String, dynamic>)? fromJson,
    Map<String, String>? queryParameters,
  }) async {
    try {
      Uri uri = Uri.parse('$baseUrl$endpoint');
      if (queryParameters != null) {
        uri = uri.replace(queryParameters: queryParameters);
      }

      final response = await http.get(uri, headers: _headers);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // GET lista
  Future<List<T>> getList<T>(
    String endpoint, {
    T Function(Map<String, dynamic>)? fromJson,
    Map<String, String>? queryParameters,
  }) async {
    try {
      Uri uri = Uri.parse('$baseUrl$endpoint');
      if (queryParameters != null) {
        uri = uri.replace(queryParameters: queryParameters);
      }

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (fromJson != null) {
          return data.map((item) => fromJson(item as Map<String, dynamic>)).toList();
        }
        return data.cast<T>();
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: response.body,
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST
  Future<T> post<T>(
    String endpoint, {
    required Map<String, dynamic> body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: json.encode(body),
      );

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PUT
  Future<T> put<T>(
    String endpoint, {
    required Map<String, dynamic> body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: json.encode(body),
      );

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE
  Future<void> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ApiException(
          statusCode: response.statusCode,
          message: response.body,
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Manejar respuesta
  T _handleResponse<T>(http.Response response, T Function(Map<String, dynamic>)? fromJson) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (fromJson != null) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return fromJson(data);
      }
      return json.decode(response.body) as T;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: response.body,
      );
    }
  }

  // Manejar errores
  Exception _handleError(dynamic error) {
    if (error is http.ClientException) {
      return NetworkException(message: error.message);
    }
    return error;
  }
}

// Excepciones personalizadas
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class NetworkException implements Exception {
  final String message;

  NetworkException({required this.message});

  @override
  String toString() => 'NetworkException: $message';
}
```

#### Servicio específico

```dart
class UsuarioService {
  final ApiService _api;

  UsuarioService({ApiService? api}) : _api = api ?? ApiService();

  Future<List<Usuario>> obtenerTodos() async {
    return await _api.getList<Usuario>(
      '/users',
      fromJson: (json) => Usuario.fromJson(json),
    );
  }

  Future<Usuario> obtenerPorId(int id) async {
    return await _api.get<Usuario>(
      '/users/$id',
      fromJson: (json) => Usuario.fromJson(json),
    );
  }

  Future<Usuario> crear(Usuario usuario) async {
    return await _api.post<Usuario>(
      '/users',
      body: usuario.toJson(),
      fromJson: (json) => Usuario.fromJson(json),
    );
  }

  Future<Usuario> actualizar(Usuario usuario) async {
    return await _api.put<Usuario>(
      '/users/${usuario.id}',
      body: usuario.toJson(),
      fromJson: (json) => Usuario.fromJson(json),
    );
  }

  Future<void> eliminar(int id) async {
    await _api.delete('/users/$id');
  }
}
```

---

### 4. Loading states y errores

#### Estados de carga

```dart
enum EstadoCarga { inicial, cargando, cargado, error }

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  final UsuarioService _service = UsuarioService();
  
  EstadoCarga _estado = EstadoCarga.inicial;
  List<Usuario> _usuarios = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    setState(() {
      _estado = EstadoCarga.cargando;
      _errorMessage = '';
    });

    try {
      final usuarios = await _service.obtenerTodos();
      setState(() {
        _usuarios = usuarios;
        _estado = EstadoCarga.cargado;
      });
    } catch (e) {
      setState(() {
        _estado = EstadoCarga.error;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios')),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _cargarUsuarios,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildBody() {
    switch (_estado) {
      case EstadoCarga.inicial:
        return const Center(child: Text('Cargando datos iniciales...'));

      case EstadoCarga.cargando:
        return const Center(child: CircularProgressIndicator());

      case EstadoCarga.cargado:
        if (_usuarios.isEmpty) {
          return const Center(child: Text('No hay usuarios'));
        }
        return ListView.builder(
          itemCount: _usuarios.length,
          itemBuilder: (context, index) {
            final usuario = _usuarios[index];
            return ListTile(
              leading: CircleAvatar(child: Text(usuario.name[0])),
              title: Text(usuario.name),
              subtitle: Text(usuario.email),
              trailing: const Icon(Icons.arrow_forward),
            );
          },
        );

      case EstadoCarga.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error al cargar',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _cargarUsuarios,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        );
    }
  }
}
```

#### Widget de loading reutilizable

```dart
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// Uso
LoadingOverlay(
  isLoading: _isLoading,
  message: 'Guardando...',
  child: ListView(...),
)
```

---

### 5. Ejercicios prácticos del Módulo 6

#### Ejercicio: App de productos con API

Crear una app que:
- Obtiene productos de una API REST
- Muestra lista con estados de carga
- Permite ver detalles
- Implementa búsqueda

**Solución:**

```dart
// models/producto.dart
class Producto {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final double rating;

  Producto({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      title: json['title'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      category: json['category'],
      image: json['image'],
      rating: (json['rating']['rate'] as num).toDouble(),
    );
  }
}

// services/producto_service.dart
class ProductoService {
  static const String baseUrl = 'https://fakestoreapi.com';

  Future<List<Producto>> obtenerTodos() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Producto.fromJson(json)).toList();
    }
    throw Exception('Error al cargar productos');
  }

  Future<Producto> obtenerPorId(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/products/$id'));

    if (response.statusCode == 200) {
      return Producto.fromJson(json.decode(response.body));
    }
    throw Exception('Error al cargar producto');
  }

  Future<List<Producto>> obtenerPorCategoria(String categoria) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/category/$categoria'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Producto.fromJson(json)).toList();
    }
    throw Exception('Error al cargar productos');
  }

  Future<List<String>> obtenerCategorias() async {
    final response = await http.get(Uri.parse('$baseUrl/products/categories'));

    if (response.statusCode == 200) {
      return List<String>.from(json.decode(response.body));
    }
    throw Exception('Error al cargar categorías');
  }
}

// pages/productos_page.dart
class ProductosPage extends StatefulWidget {
  const ProductosPage({super.key});

  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  final ProductoService _service = ProductoService();
  final TextEditingController _searchController = TextEditingController();

  List<Producto> _productos = [];
  List<Producto> _productosFiltrados = [];
  List<String> _categorias = [];
  String? _categoriaSeleccionada;

  EstadoCarga _estado = EstadoCarga.inicial;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _estado = EstadoCarga.cargando;
    });

    try {
      final productos = await _service.obtenerTodos();
      final categorias = await _service.obtenerCategorias();

      setState(() {
        _productos = productos;
        _productosFiltrados = productos;
        _categorias = categorias;
        _estado = EstadoCarga.cargado;
      });
    } catch (e) {
      setState(() {
        _estado = EstadoCarga.error;
        _errorMessage = e.toString();
      });
    }
  }

  void _filtrarProductos(String query) {
    setState(() {
      _productosFiltrados = _productos.where((p) {
        final coincideBusqueda = p.title.toLowerCase().contains(query.toLowerCase());
        final coincideCategoria = _categoriaSeleccionada == null ||
            p.category == _categoriaSeleccionada;
        return coincideBusqueda && coincideCategoria;
      }).toList();
    });
  }

  void _seleccionarCategoria(String? categoria) {
    setState(() {
      _categoriaSeleccionada = categoria;
      _filtrarProductos(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatos,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filtrarProductos('');
                        },
                      )
                    : null,
              ),
              onChanged: _filtrarProductos,
            ),
          ),

          // Filtro de categorías
          if (_categorias.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                FilterChip(
                    label: const Text('Todos'),
                    selected: _categoriaSeleccionada == null,
                    onSelected: (_) => _seleccionarCategoria(null),
                  ),
                  ..._categorias.map((cat) => FilterChip(
                    label: Text(cat[0].toUpperCase() + cat.substring(1)),
                    selected: _categoriaSeleccionada == cat,
                    onSelected: (_) => _seleccionarCategoria(cat),
                  )),
                ],
              ),
            ),

          // Lista de productos
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_estado) {
      case EstadoCarga.cargando:
        return const Center(child: CircularProgressIndicator());

      case EstadoCarga.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _cargarDatos,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        );

      case EstadoCarga.cargado:
        if (_productosFiltrados.isEmpty) {
          return const Center(child: Text('No se encontraron productos'));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: _productosFiltrados.length,
          itemBuilder: (context, index) {
            final producto = _productosFiltrados[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetalleProductoPage(producto: producto),
                  ),
                );
              },
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Image.network(
                        producto.image,
                        fit: BoxFit.contain,
                        width: double.infinity,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            producto.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${producto.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 16, color: Colors.amber),
                              Text(producto.rating.toStringAsFixed(1)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );

      default:
        return const Center(child: Text('Estado inicial'));
    }
  }
}

class DetalleProductoPage extends StatelessWidget {
  final Producto producto;

  const DetalleProductoPage({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(producto.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              producto.image,
              height: 300,
              fit: BoxFit.contain,
              width: double.infinity,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '\$${producto.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          Text(producto.rating.toStringAsFixed(1)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Chip(
                    label: Text(producto.category[0].toUpperCase() + producto.category.substring(1)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    producto.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Añadido al carrito')),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Añadir al carrito'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

**Resumen del Módulo 6:**

En este módulo aprendiste:

✅ Paquete http y peticiones GET/POST/PUT/DELETE
✅ Headers y autenticación
✅ Modelos de datos con fromJson/toJson
✅ json_serializable para generación automática
✅ Servicio API genérico
✅ Manejo de estados de carga (loading, error, success)
✅ Widget de loading overlay
✅ Ejercicio práctico: App de productos con API REST

**Próximo módulo:** Persistencia de Datos## Módulo 7: Persistencia de Datos (3 horas)

---

### 1. SharedPreferences

#### Instalación

```yaml
dependencies:
  shared_preferences: ^2.2.0
```

#### Conceptos básicos

`SharedPreferences` permite almacenar datos simples de forma persistente:
- Tipos: `String`, `int`, `double`, `bool`, `List<String>`
- Almacenamiento: clave-valor
- Uso ideal: preferencias, configuraciones, flags

#### Servicio de SharedPreferences

```dart
class PreferenciasService {
  static const String _keyTema = 'tema';
  static const String _keyIdioma = 'idioma';
  static const String _keyNotificaciones = 'notificaciones';
  static const String _keyUsuarioId = 'usuario_id';
  static const String _keyOnboarding = 'onboarding_completado';
  static const String _keyUltimaSincronizacion = 'ultima_sincronizacion';

  late final SharedPreferences _prefs;

  // Inicializar (llamar en main)
  Future<void> inicializar() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Getters
  String? get tema => _prefs.getString(_keyTema);
  String? get idioma => _prefs.getString(_keyIdioma);
  bool get notificaciones => _prefs.getBool(_keyNotificaciones) ?? true;
  String? get usuarioId => _prefs.getString(_keyUsuarioId);
  bool get onboardingCompletado => _prefs.getBool(_keyOnboarding) ?? false;
  DateTime? get ultimaSincronizacion {
    final timestamp = _prefs.getInt(_keyUltimaSincronizacion);
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  // Setters
  Future<bool> setTema(String tema) => _prefs.setString(_keyTema, tema);
  Future<bool> setIdioma(String idioma) => _prefs.setString(_keyIdioma, idioma);
  Future<bool> setNotificaciones(bool valor) => _prefs.setBool(_keyNotificaciones, valor);
  Future<bool> setUsuarioId(String id) => _prefs.setString(_keyUsuarioId, id);
  Future<bool> setOnboardingCompletado(bool valor) => _prefs.setBool(_keyOnboarding, valor);
  Future<bool> setUltimaSincronizacion(DateTime fecha) =>
      _prefs.setInt(_keyUltimaSincronizacion, fecha.millisecondsSinceEpoch);

  // Eliminar
  Future<bool> eliminarUsuarioId() => _prefs.remove(_keyUsuarioId);
  Future<bool> limpiarTodo() => _prefs.clear();

  // Verificar existencia
  bool existe(String key) => _prefs.containsKey(key);
}
```

#### Uso en la app

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefsService = PreferenciasService();
  await prefsService.inicializar();
  
  runApp(MyApp(prefsService: prefsService));
}

// app.dart
class MyApp extends StatefulWidget {
  final PreferenciasService prefsService;

  const MyApp({super.key, required this.prefsService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _tema = 'system';
  bool _notificaciones = true;

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  void _cargarPreferencias() {
    setState(() {
      _tema = widget.prefsService.tema ?? 'system';
      _notificaciones = widget.prefsService.notificaciones;
    });
  }

  Future<void> _cambiarTema(String tema) async {
    await widget.prefsService.setTema(tema);
    setState(() {
      _tema = tema;
    });
  }

  Future<void> _toggleNotificaciones() async {
    final nuevoValor = !_notificaciones;
    await widget.prefsService.setNotificaciones(nuevoValor);
    setState(() {
      _notificaciones = nuevoValor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App',
      theme: _getTheme(_tema),
      home: HomePage(),
    );
  }

  ThemeData _getTheme(String tema) {
    switch (tema) {
      case 'light':
        return ThemeData.light();
      case 'dark':
        return ThemeData.dark();
      default:
        return ThemeData.system();
    }
  }
}
```

#### Página de configuración

```dart
class ConfiguracionPage extends StatefulWidget {
  final PreferenciasService prefsService;

  const ConfiguracionPage({super.key, required this.prefsService});

  @override
  State<ConfiguracionPage> createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfiguracionPage> {
  String _tema = 'system';
  bool _notificaciones = true;
  String _idioma = 'es';

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  void _cargarPreferencias() {
    setState(() {
      _tema = widget.prefsService.tema ?? 'system';
      _notificaciones = widget.prefsService.notificaciones;
      _idioma = widget.prefsService.idioma ?? 'es';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        children: [
          // Tema
          ListTile(
            title: const Text('Tema'),
            subtitle: Text(_getTemaLabel(_tema)),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => _mostrarDialogoTema(),
          ),

          // Notificaciones
          SwitchListTile(
            title: const Text('Notificaciones'),
            subtitle: const Text('Recibir notificaciones push'),
            value: _notificaciones,
            onChanged: _toggleNotificaciones,
          ),

          // Idioma
          ListTile(
            title: const Text('Idioma'),
            subtitle: Text(_getIdiomaLabel(_idioma)),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => _mostrarDialogoIdioma(),
          ),

          const Divider(),

          // Limpiar datos
          ListTile(
            title: const Text('Limpiar datos', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Eliminar todas las preferencias'),
            onTap: () => _confirmarLimpiarDatos(),
          ),
        ],
      ),
    );
  }

  String _getTemaLabel(String tema) {
    switch (tema) {
      case 'light':
        return 'Claro';
      case 'dark':
        return 'Oscuro';
      default:
        return 'Sistema';
    }
  }

  String _getIdiomaLabel(String idioma) {
    switch (idioma) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      default:
        return 'Español';
    }
  }

  Future<void> _mostrarDialogoTema() async {
    final resultado = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Sistema'),
              value: 'system',
              groupValue: _tema,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<String>(
              title: const Text('Claro'),
              value: 'light',
              groupValue: _tema,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<String>(
              title: const Text('Oscuro'),
              value: 'dark',
              groupValue: _tema,
              onChanged: (value) => Navigator.pop(context, value),
            ),
          ],
        ),
      ),
    );

    if (resultado != null) {
      await widget.prefsService.setTema(resultado);
      setState(() {
        _tema = resultado;
      });
    }
  }

  Future<void> _mostrarDialogoIdioma() async {
    final resultado = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar idioma'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Español'),
              value: 'es',
              groupValue: _idioma,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: _idioma,
              onChanged: (value) => Navigator.pop(context, value),
            ),
          ],
        ),
      ),
    );

    if (resultado != null) {
      await widget.prefsService.setIdioma(resultado);
      setState(() {
        _idioma = resultado;
      });
    }
  }

  Future<void> _toggleNotificaciones(bool valor) async {
    await widget.prefsService.setNotificaciones(valor);
    setState(() {
      _notificaciones = valor;
    });
  }

  Future<void> _confirmarLimpiarDatos() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Limpiar datos?'),
        content: const Text('Se eliminarán todas las preferencias guardadas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await widget.prefsService.limpiarTodo();
      _cargarPreferencias();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos eliminados')),
        );
      }
    }
  }
}
```

---

### 2. SQLite con sqflite

#### Instalación

```yaml
dependencies:
  sqflite: ^2.3.0
  path: ^1.8.0
```

#### Modelo de datos

```dart
class Tarea {
  final int? id;
  final String titulo;
  final String? descripcion;
  final bool completada;
  final DateTime fechaCreacion;
  final DateTime? fechaCompletada;
  final int prioridad; // 0=baja, 1=media, 2=alta

  Tarea({
    this.id,
    required this.titulo,
    this.descripcion,
    this.completada = false,
    DateTime? fechaCreacion,
    this.fechaCompletada,
    this.prioridad = 1,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  factory Tarea.fromMap(Map<String, dynamic> map) {
    return Tarea(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      descripcion: map['descripcion'] as String?,
      completada: map['completada'] == 1,
      fechaCreacion: DateTime.parse(map['fecha_creacion'] as String),
      fechaCompletada: map['fecha_completada'] != null
          ? DateTime.parse(map['fecha_completada'] as String)
          : null,
      prioridad: map['prioridad'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'completada': completada ? 1 : 0,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_completada': fechaCompletada?.toIso8601String(),
      'prioridad': prioridad,
    };
  }

  Tarea copyWith({
    int? id,
    String? titulo,
    String? descripcion,
    bool? completada,
    DateTime? fechaCreacion,
    DateTime? fechaCompletada,
    int? prioridad,
  }) {
    return Tarea(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      completada: completada ?? this.completada,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaCompletada: fechaCompletada ?? this.fechaCompletada,
      prioridad: prioridad ?? this.prioridad,
    );
  }
}
```

#### Servicio de base de datos

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;
  static const String _tableName = 'tareas';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tareas.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descripcion TEXT,
        completada INTEGER DEFAULT 0,
        fecha_creacion TEXT NOT NULL,
        fecha_completada TEXT,
        prioridad INTEGER DEFAULT 1
      )
    ''');

    // Índices para búsquedas frecuentes
    await db.execute('CREATE INDEX idx_completada ON $_tableName (completada)');
    await db.execute('CREATE INDEX idx_prioridad ON $_tableName (prioridad)');
    await db.execute('CREATE INDEX idx_fecha ON $_tableName (fecha_creacion)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Manejar migraciones
    if (oldVersion < 2) {
      // Añadir columna en versión 2
      // await db.execute('ALTER TABLE $_tableName ADD COLUMN nueva_columna TEXT');
    }
  }
}
```

#### Repositorio de tareas

```dart
class TareasRepository {
  final DatabaseService _dbService;
  static const String _tableName = 'tareas';

  TareasRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService();

  // CRUD Operations

  Future<int> insertar(Tarea tarea) async {
    final db = await _dbService.database;
    return await db.insert(_tableName, tarea.toMap());
  }

  Future<Tarea?> obtenerPorId(int id) async {
    final db = await _dbService.database;
    final maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Tarea.fromMap(maps.first);
  }

  Future<List<Tarea>> obtenerTodos({
    bool? completada,
    int? prioridad,
    String? ordenarPor,
    bool descendente = false,
  }) async {
    final db = await _dbService.database;

    String? where;
    List<dynamic>? whereArgs;

    if (completada != null && prioridad != null) {
      where = 'completada = ? AND prioridad = ?';
      whereArgs = [completada ? 1 : 0, prioridad];
    } else if (completada != null) {
      where = 'completada = ?';
      whereArgs = [completada ? 1 : 0];
    } else if (prioridad != null) {
      where = 'prioridad = ?';
      whereArgs = [prioridad];
    }

    final orderBy = ordenarPor != null
        ? '$ordenarPor ${descendente ? 'DESC' : 'ASC'}'
        : 'fecha_creacion DESC';

    final maps = await db.query(
      _tableName,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );

    return maps.map((map) => Tarea.fromMap(map)).toList();
  }

  Future<int> actualizar(Tarea tarea) async {
    final db = await _dbService.database;
    return await db.update(
      _tableName,
      tarea.toMap(),
      where: 'id = ?',
      whereArgs: [tarea.id],
    );
  }

  Future<int> eliminar(int id) async {
    final db = await _dbService.database;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> eliminarCompletadas() async {
    final db = await _dbService.database;
    return await db.delete(
      _tableName,
      where: 'completada = ?',
      whereArgs: [1],
    );
  }

  Future<int> contar({bool? completada}) async {
    final db = await _dbService.database;

    if (completada != null) {
      final result = await db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName WHERE completada = ?',
        [completada ? 1 : 0],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    }

    final result = await db.rawQuery('SELECT COUNT(*) FROM $_tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Búsqueda
  Future<List<Tarea>> buscar(String query) async {
    final db = await _dbService.database;
    final maps = await db.query(
      _tableName,
      where: 'titulo LIKE ? OR descripcion LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'fecha_creacion DESC',
    );
    return maps.map((map) => Tarea.fromMap(map)).toList();
  }

  // Transacciones
  Future<void> marcarTodasCompletadas() async {
    final db = await _dbService.database;
    await db.transaction((txn) async {
      await txn.update(
        _tableName,
        {
          'completada': 1,
          'fecha_completada': DateTime.now().toIso8601String(),
        },
      );
    });
  }
}
```

#### Página de tareas con SQLite

```dart
class TareasSQLitePage extends StatefulWidget {
  const TareasSQLitePage({super.key});

  @override
  State<TareasSQLitePage> createState() => _TareasSQLitePageState();
}

class _TareasSQLitePageState extends State<TareasSQLitePage> {
  final TareasRepository _repository = TareasRepository();
  List<Tarea> _tareas = [];
  bool _isLoading = true;
  String _filtro = 'todas'; // todas, pendientes, completadas

  @override
  void initState() {
    super.initState();
    _cargarTareas();
  }

  Future<void> _cargarTareas() async {
    setState(() => _isLoading = true);

    try {
      final tareas = await _repository.obtenerTodos(
        completada: _filtro == 'pendientes'
            ? false
            : _filtro == 'completadas'
                ? true
                : null,
        ordenarPor: 'prioridad',
        descendente: true,
      );

      setState(() {
        _tareas = tareas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _agregarTarea() async {
    final controller = TextEditingController();
    final descripcionController = TextEditingController();
    int prioridad = 1;

    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nueva tarea'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              const Text('Prioridad'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ChoiceChip(
                    label: const Text('Baja'),
                    selected: prioridad == 0,
                    onSelected: (selected) => setState(() => prioridad = 0),
                  ),
                  ChoiceChip(
                    label: const Text('Media'),
                    selected: prioridad == 1,
                    onSelected: (selected) => setState(() => prioridad = 1),
                  ),
                  ChoiceChip(
                    label: const Text('Alta'),
                    selected: prioridad == 2,
                    onSelected: (selected) => setState(() => prioridad = 2),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (resultado == true && controller.text.isNotEmpty) {
      final tarea = Tarea(
        titulo: controller.text,
        descripcion: descripcionController.text,
        prioridad: prioridad,
      );

      await _repository.insertar(tarea);
      _cargarTareas();
    }
  }

  Future<void> _toggleCompletada(Tarea tarea) async {
    final tareaActualizada = tarea.copyWith(
      completada: !tarea.completada,
      fechaCompletada: !tarea.completada ? DateTime.now() : null,
    );

    await _repository.actualizar(tareaActualizada);
    _cargarTareas();
  }

  Future<void> _eliminarTarea(Tarea tarea) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar tarea?'),
        content: Text('Se eliminará "${tarea.titulo}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _repository.eliminar(tarea.id!);
      _cargarTareas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas (SQLite)'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (valor) {
              setState(() => _filtro = valor);
              _cargarTareas();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'todas', child: Text('Todas')),
              const PopupMenuItem(value: 'pendientes', child: Text('Pendientes')),
              const PopupMenuItem(value: 'completadas', child: Text('Completadas')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tareas.isEmpty
              ? const Center(child: Text('No hay tareas'))
              : ListView.builder(
                  itemCount: _tareas.length,
                  itemBuilder: (context, index) {
                    final tarea = _tareas[index];
                    return ListTile(
                      leading: Checkbox(
                        value: tarea.completada,
                        onChanged: (_) => _toggleCompletada(tarea),
                      ),
                      title: Text(
                        tarea.titulo,
                        style: tarea.completada
                            ? const TextStyle(decoration: TextDecoration.lineThrough)
                            : null,
                      ),
                      subtitle: tarea.descripcion != null
                          ? Text(tarea.descripcion!)
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Chip(
                            label: Text(
                              ['Baja', 'Media', 'Alta'][tarea.prioridad],
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: [
                              Colors.green[100],
                              Colors.orange[100],
                              Colors.red[100],
                            ][tarea.prioridad],
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _eliminarTarea(tarea),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarTarea,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

---

### 3. Hive (NoSQL)

#### Instalación

```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
```

#### Inicialización

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ProductoHiveAdapter());
  await Hive.openBox<ProductoHive>('productos');
  await Hive.openBox('config');
  runApp(const MyApp());
}
```

#### Modelo con Hive

```dart
part 'producto_hive.g.dart';

@HiveType(typeId: 0)
class ProductoHive extends HiveObject {
  @HiveField(0)
  String nombre;

  @HiveField(1)
  double precio;

  @HiveField(2)
  String categoria;

  @HiveField(3)
  bool disponible;

  @HiveField(4)
  DateTime fechaCreacion;

  @HiveField(5)
  List<String> etiquetas;

  ProductoHive({
    required this.nombre,
    required this.precio,
    required this.categoria,
    this.disponible = true,
    DateTime? fechaCreacion,
    List<String>? etiquetas,
  })  : fechaCreacion = fechaCreacion ?? DateTime.now(),
        etiquetas = etiquetas ?? [];
}

// Generar código con:
// flutter pub run build_runner build
```

#### Servicio con Hive

```dart
class ProductoHiveService {
  static const String _boxName = 'productos';
  Box<ProductoHive>? _box;

  Future<Box<ProductoHive>> get box async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<ProductoHive>(_boxName);
    return _box!;
  }

  Future<void> agregar(ProductoHive producto) async {
    final b = await box;
    await b.add(producto);
  }

  Future<void> actualizar(ProductoHive producto) async {
    await producto.save();
  }

  Future<void> eliminar(ProductoHive producto) async {
    await producto.delete();
  }

  Future<List<ProductoHive>> obtenerTodos() async {
    final b = await box;
    return b.values.toList();
  }

  Future<List<ProductoHive>> obtenerPorCategoria(String categoria) async {
    final b = await box;
    return b.values.where((p) => p.categoria == categoria).toList();
  }

  Future<List<ProductoHive>> buscar(String query) async {
    final b = await box;
    final lowerQuery = query.toLowerCase();
    return b.values.where((p) {
      return p.nombre.toLowerCase().contains(lowerQuery) ||
          p.categoria.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
```

---

### 4. Almacenamiento de archivos

#### Escribir y leer archivos

```dart
class ArchivoService {
  final Future<Directory> Function() _getDirectorio;

  ArchivoService({Future<Directory> Function()? getDirectorio})
      : _getDirectorio = getDirectorio ?? getApplicationDocumentsDirectory;

  Future<String> get _rutaBase async {
    final dir = await _getDirectorio();
    return dir.path;
  }

  Future<File> _crearArchivo(String nombre) async {
    final ruta = await _rutaBase;
    return File('$ruta/$nombre');
  }

  Future<void> escribirJson(String nombreArchivo, Map<String, dynamic> data) async {
    final archivo = await _crearArchivo(nombreArchivo);
    await archivo.writeAsString(json.encode(data));
  }

  Future<Map<String, dynamic>?> leerJson(String nombreArchivo) async {
    try {
      final archivo = await _crearArchivo(nombreArchivo);
      if (!await archivo.exists()) return null;
      final contenido = await archivo.readAsString();
      return json.decode(contenido);
    } catch (e) {
      return null;
    }
  }

  Future<void> escribirString(String nombreArchivo, String contenido) async {
    final archivo = await _crearArchivo(nombreArchivo);
    await archivo.writeAsString(contenido);
  }

  Future<String?> leerString(String nombreArchivo) async {
    try {
      final archivo = await _crearArchivo(nombreArchivo);
      if (!await archivo.exists()) return null;
      return await archivo.readAsString();
    } catch (e) {
      return null;
    }
  }

  Future<void> eliminar(String nombreArchivo) async {
    final archivo = await _crearArchivo(nombreArchivo);
    if (await archivo.exists()) {
      await archivo.delete();
    }
  }

  Future<bool> existe(String nombreArchivo) async {
    final archivo = await _crearArchivo(nombreArchivo);
    return archivo.exists();
  }
}
```

---

### 5. Ejercicios prácticos del Módulo 7

#### Ejercicio: App de notas con SQLite

Crear una app de notas con:
- CRUD completo (Crear, Leer, Actualizar, Eliminar)
- Búsqueda por título
- Filtros por categoría
- Ordenamiento por fecha

**Solución completa incluida en el módulo.**

---

**Resumen del Módulo 7:**

En este módulo aprendiste:

✅ SharedPreferences para datos simples
✅ Servicio de preferencias reutilizable
✅ SQLite con sqflite para datos relacionales
✅ Modelos y repositorios
✅ CRUD completo con SQLite
✅ Hive como alternativa NoSQL
✅ Almacenamiento de archivos
✅ Ejercicio práctico: App de tareas con SQLite

**Próximo módulo:** Arquitectura y Patrones## Módulo 8: Arquitectura y Patrones (4 horas)

---

### 1. Separación de responsabilidades

#### Estructura de carpetas recomendada

```
lib/
├── main.dart                    # Punto de entrada
├── app.dart                     # Configuración de la app
│
├── core/                        # Código compartido
│   ├── constants/               # Constantes
│   ├── theme/                   # Tema y estilos
│   ├── utils/                   # Utilidades
│   └── errors/                  # Manejo de errores
│
├── data/                        # Capa de datos
│   ├── models/                  # Modelos de datos
│   ├── repositories/            # Repositorios
│   ├── datasources/             # Fuentes de datos
│   │   ├── local/               # BD local
│   │   └── remote/              # API remota
│   └── services/                # Servicios externos
│
├── domain/                      # Capa de dominio (opcional)
│   ├── entities/                # Entidades de negocio
│   ├── repositories/            # Interfaces de repositorio
│   └── usecases/                # Casos de uso
│
├── presentation/                # Capa de presentación
│   ├── pages/                   # Pantallas
│   ├── widgets/                 # Widgets reutilizables
│   ├── providers/               # Estado (Provider, BLoC, etc.)
│   └── routes/                  # Navegación
│
└── config/                      # Configuración
    ├── env.dart                 # Variables de entorno
    └── routes.dart              # Rutas nombradas
```

#### Ejemplo práctico: App de productos

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── api_constants.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── colors.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   └── formatters.dart
│   └── errors/
│       ├── exceptions.dart
│       └── failures.dart
│
├── data/
│   ├── models/
│   │   ├── producto_model.dart
│   │   └── usuario_model.dart
│   ├── repositories/
│   │   ├── producto_repository_impl.dart
│   │   └── usuario_repository_impl.dart
│   ├── datasources/
│   │   ├── local/
│   │   │   └── producto_local_datasource.dart
│   │   └── remote/
│   │       └── producto_remote_datasource.dart
│   └── services/
│       └── api_client.dart
│
├── domain/
│   ├── entities/
│   │   └── producto.dart
│   ├── repositories/
│   │   └── producto_repository.dart
│   └── usecases/
│       ├── get_productos.dart
│       └── add_producto.dart
│
├── presentation/
│   ├── pages/
│   │   ├── home/
│   │   │   ├── home_page.dart
│   │   │   └── home_controller.dart
│   │   └── producto/
│   │       ├── producto_detail_page.dart
│   │       └── producto_list_page.dart
│   ├── widgets/
│   │   ├── producto_card.dart
│   │   └── loading_overlay.dart
│   ├── providers/
│   │   ├── producto_provider.dart
│   │   └── auth_provider.dart
│   └── routes/
│       ├── app_router.dart
│       └── routes.dart
│
└── config/
    ├── env.dart
    └── dependencies.dart
```

---

### 2. Patrón Repository

#### Definición

El patrón Repository separa la lógica de acceso a datos de la lógica de negocio.

#### Implementación

```dart
// domain/repositories/producto_repository.dart
abstract class ProductoRepository {
  Future<List<Producto>> obtenerTodos();
  Future<Producto> obtenerPorId(int id);
  Future<void> guardar(Producto producto);
  Future<void> eliminar(int id);
}

// data/datasources/remote/producto_remote_datasource.dart
class ProductoRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  ProductoRemoteDataSource({
    required this.client,
    this.baseUrl = 'https://api.ejemplo.com',
  });

  Future<List<Map<String, dynamic>>> obtenerTodos() async {
    final response = await client.get(Uri.parse('$baseUrl/productos'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }
    throw ServerException();
  }

  Future<Map<String, dynamic>> obtenerPorId(int id) async {
    final response = await client.get(Uri.parse('$baseUrl/productos/$id'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw ServerException();
  }
}

// data/datasources/local/producto_local_datasource.dart
class ProductoLocalDataSource {
  final DatabaseService dbService;

  ProductoLocalDataSource({required this.dbService});

  Future<List<Map<String, dynamic>>> obtenerTodos() async {
    final db = await dbService.database;
    return await db.query('productos');
  }

  Future<void> guardar(Map<String, dynamic> producto) async {
    final db = await dbService.database;
    await db.insert('productos', producto);
  }

  Future<void> eliminar(int id) async {
    final db = await dbService.database;
    await db.delete('productos', where: 'id = ?', whereArgs: [id]);
  }
}

// data/repositories/producto_repository_impl.dart
class ProductoRepositoryImpl implements ProductoRepository {
  final ProductoRemoteDataSource remoteDataSource;
  final ProductoLocalDataSource localDataSource;
  final ConnectivityService connectivityService;

  ProductoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivityService,
  });

  @override
  Future<List<Producto>> obtenerTodos() async {
    if (await connectivityService.estaConectado()) {
      try {
        final remoteData = await remoteDataSource.obtenerTodos();
        // Cachear datos
        for (var data in remoteData) {
          await localDataSource.guardar(data);
        }
        return remoteData.map((json) => ProductoModel.fromJson(json)).toList();
      } catch (e) {
        // Fallback a cache local
        return await _obtenerDelCache();
      }
    } else {
      return await _obtenerDelCache();
    }
  }

  Future<List<Producto>> _obtenerDelCache() async {
    final localData = await localDataSource.obtenerTodos();
    return localData.map((json) => ProductoModel.fromJson(json)).toList();
  }

  @override
  Future<Producto> obtenerPorId(int id) async {
    // Intentar primero remoto, luego local
    try {
      final data = await remoteDataSource.obtenerPorId(id);
      return ProductoModel.fromJson(data);
    } catch (e) {
      final localData = await localDataSource.obtenerTodos();
      final producto = localData.firstWhere((p) => p['id'] == id);
      return ProductoModel.fromJson(producto);
    }
  }

  @override
  Future<void> guardar(Producto producto) async {
    final model = ProductoModel.fromEntity(producto);
    await remoteDataSource.guardar(model.toJson());
    await localDataSource.guardar(model.toJson());
  }

  @override
  Future<void> eliminar(int id) async {
    await remoteDataSource.eliminar(id);
    await localDataSource.eliminar(id);
  }
}
```

---

### 3. Provider para estado

#### Instalación

```yaml
dependencies:
  provider: ^6.1.0
```

#### ChangeNotifier básico

```dart
class ProductoProvider extends ChangeNotifier {
  final ProductoRepository repository;
  
  List<Producto> _productos = [];
  EstadoCarga _estado = EstadoCarga.inicial;
  String _errorMessage = '';

  ProductoProvider({required this.repository});

  // Getters
  List<Producto> get productos => _productos;
  EstadoCarga get estado => _estado;
  String get errorMessage => _errorMessage;

  Future<void> cargarProductos() async {
    _estado = EstadoCarga.cargando;
    notifyListeners();

    try {
      _productos = await repository.obtenerTodos();
      _estado = EstadoCarga.cargado;
    } catch (e) {
      _errorMessage = e.toString();
      _estado = EstadoCarga.error;
    }

    notifyListeners();
  }

  Future<void> agregarProducto(Producto producto) async {
    try {
      await repository.guardar(producto);
      _productos.add(producto);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void filtrarPorCategoria(String categoria) {
    // Filtrar sin modificar la lista original
    // El getter devuelve la lista filtrada
  }
}

enum EstadoCarga { inicial, cargando, cargado, error }
```

#### MultiProvider

```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => DatabaseService()),
        Provider(create: (_) => ConnectivityService()),
        ProxyProvider2<DatabaseService, ConnectivityService, ProductoRepository>(
          create: (_) => ProductoRepositoryImpl(
            remoteDataSource: ProductoRemoteDataSource(),
            localDataSource: ProductoLocalDataSource(),
            connectivityService: ConnectivityService(),
          ),
        ),
        ChangeNotifierProxyProvider<ProductoRepository, ProductoProvider>(
          create: (_) => ProductoProvider(repository: ProductoRepository()),
          update: (_, repository, previous) {
            return previous ?? ProductoProvider(repository: repository);
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}
```

#### Consumo en widgets

```dart
class ProductoListPage extends StatelessWidget {
  const ProductoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Productos')),
      body: Consumer<ProductoProvider>(
        builder: (context, provider, child) {
          switch (provider.estado) {
            case EstadoCarga.inicial:
            case EstadoCarga.cargando:
              return const Center(child: CircularProgressIndicator());
            
            case EstadoCarga.error:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${provider.errorMessage}'),
                    ElevatedButton(
                      onPressed: () => provider.cargarProductos(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            
            case EstadoCarga.cargado:
              if (provider.productos.isEmpty) {
                return const Center(child: Text('No hay productos'));
              }
              return ListView.builder(
                itemCount: provider.productos.length,
                itemBuilder: (context, index) {
                  final producto = provider.productos[index];
                  return ProductoCard(producto: producto);
                },
              );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddProductoPage()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

---

### 4. BLoC/Cubit

#### Instalación

```yaml
dependencies:
  flutter_bloc: ^8.1.0
  equatable: ^2.0.5
```

#### Estados con Equatable

```dart
abstract class ProductoState extends Equatable {
  const ProductoState();

  @override
  List<Object?> get props => [];
}

class ProductoInitial extends ProductoState {}

class ProductoLoading extends ProductoState {}

class ProductoLoaded extends ProductoState {
  final List<Producto> productos;

  const ProductoLoaded(this.productos);

  @override
  List<Object?> get props => [productos];
}

class ProductoError extends ProductoState {
  final String message;

  const ProductoError(this.message);

  @override
  List<Object?> get props => [message];
}
```

#### Eventos

```dart
abstract class ProductoEvent extends Equatable {
  const ProductoEvent();

  @override
  List<Object?> get props => [];
}

class LoadProductos extends ProductoEvent {}

class AddProducto extends ProductoEvent {
  final Producto producto;

  const AddProducto(this.producto);

  @override
  List<Object?> get props => [producto];
}

class DeleteProducto extends ProductoEvent {
  final int id;

  const DeleteProducto(this.id);

  @override
  List<Object?> get props => [id];
}

class SearchProductos extends ProductoEvent {
  final String query;

  const SearchProductos(this.query);

  @override
  List<Object?> get props => [query];
}
```

#### BLoC

```dart
class ProductoBloc extends Bloc<ProductoEvent, ProductoState> {
  final ProductoRepository repository;

  ProductoBloc({required this.repository}) : super(ProductoInitial()) {
    on<LoadProductos>(_onLoadProductos);
    on<AddProducto>(_onAddProducto);
    on<DeleteProducto>(_onDeleteProducto);
    on<SearchProductos>(_onSearchProductos);
  }

  Future<void> _onLoadProductos(
    LoadProductos event,
    Emitter<ProductoState> emit,
  ) async {
    emit(ProductoLoading());
    try {
      final productos = await repository.obtenerTodos();
      emit(ProductoLoaded(productos));
    } catch (e) {
      emit(ProductoError(e.toString()));
    }
  }

  Future<void> _onAddProducto(
    AddProducto event,
    Emitter<ProductoState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProductoLoaded) {
      try {
        await repository.guardar(event.producto);
        emit(ProductoLoaded([...currentState.productos, event.producto]));
      } catch (e) {
        emit(ProductoError(e.toString()));
      }
    }
  }

  Future<void> _onDeleteProducto(
    DeleteProducto event,
    Emitter<ProductoState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProductoLoaded) {
      try {
        await repository.eliminar(event.id);
        emit(ProductoLoaded(
          currentState.productos.where((p) => p.id != event.id).toList(),
        ));
      } catch (e) {
        emit(ProductoError(e.toString()));
      }
    }
  }

  Future<void> _onSearchProductos(
    SearchProductos event,
    Emitter<ProductoState> emit,
  ) async {
    emit(ProductoLoading());
    try {
      final productos = await repository.obtenerTodos();
      final filtrados = productos
          .where((p) => p.nombre.toLowerCase().contains(event.query.toLowerCase()))
          .toList();
      emit(ProductoLoaded(filtrados));
    } catch (e) {
      emit(ProductoError(e.toString()));
    }
  }
}
```

#### Cubit (versión simplificada)

```dart
class ProductoCubit extends Cubit<ProductoState> {
  final ProductoRepository repository;

  ProductoCubit({required this.repository}) : super(ProductoInitial());

  Future<void> cargarProductos() async {
    emit(ProductoLoading());
    try {
      final productos = await repository.obtenerTodos();
      emit(ProductoLoaded(productos));
    } catch (e) {
      emit(ProductoError(e.toString()));
    }
  }

  Future<void> agregarProducto(Producto producto) async {
    final currentState = state;
    if (currentState is ProductoLoaded) {
      try {
        await repository.guardar(producto);
        emit(ProductoLoaded([...currentState.productos, producto]));
      } catch (e) {
        emit(ProductoError(e.toString()));
      }
    }
  }

  Future<void> eliminarProducto(int id) async {
    final currentState = state;
    if (currentState is ProductoLoaded) {
      try {
        await repository.eliminar(id);
        emit(ProductoLoaded(
          currentState.productos.where((p) => p.id != id).toList(),
        ));
      } catch (e) {
        emit(ProductoError(e.toString()));
      }
    }
  }
}
```

#### Uso en widgets con BlocBuilder

```dart
class ProductoListPage extends StatelessWidget {
  const ProductoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Productos')),
      body: BlocBuilder<ProductoBloc, ProductoState>(
        builder: (context, state) {
          if (state is ProductoLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductoError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  ElevatedButton(
                    onPressed: () => context.read<ProductoBloc>().add(LoadProductos()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else if (state is ProductoLoaded) {
            if (state.productos.isEmpty) {
              return const Center(child: Text('No hay productos'));
            }
            return ListView.builder(
              itemCount: state.productos.length,
              itemBuilder: (context, index) {
                final producto = state.productos[index];
                return ProductoCard(producto: producto);
              },
            );
          }
          return const Center(child: Text('Estado inicial'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<ProductoBloc>().add(LoadProductos()),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
```

---

### 5. Clean Architecture (opcional)

#### Estructura

```
lib/
├── domain/                      # Capa de dominio (sin dependencias externas)
│   ├── entities/
│   │   └── producto.dart        # Entidad pura
│   ├── repositories/
│   │   └── producto_repository.dart  # Interface
│   └── usecases/
│       ├── get_productos.dart
│       └── add_producto.dart
│
├── data/                        # Capa de datos
│   ├── models/
│   │   └── producto_model.dart  # Modelo con fromJson/toJson
│   ├── repositories/
│   │   └── producto_repository_impl.dart  # Implementación
│   └── datasources/
│       ├── local/
│       └── remote/
│
└── presentation/                # Capa de presentación
    ├── pages/
    ├── widgets/
    └── providers/
```

#### Entidad de dominio

```dart
class Producto {
  final int id;
  final String nombre;
  final double precio;
  final String descripcion;
  final String categoria;

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.descripcion,
    required this.categoria,
  });
}
```

#### Caso de uso

```dart
class GetProductos {
  final ProductoRepository repository;

  GetProductos(this.repository);

  Future<Either<Failure, List<Producto>>> call() async {
    return await repository.obtenerTodos();
  }
}

class AddProducto {
  final ProductoRepository repository;

  AddProducto(this.repository);

  Future<Either<Failure, void>> call(Producto producto) async {
    return await repository.guardar(producto);
  }
}
```

---

### 6. Ejercicios prácticos del Módulo 8

#### Ejercicio: App con arquitectura completa

Crear una app de tareas con:
- Patrón Repository
- Provider o BLoC para estado
- Clean Architecture

**Estructura final:**

```
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   └── errors/
├── data/
│   ├── models/
│   ├── repositories/
│   └── datasources/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── pages/
│   ├── widgets/
│   └── providers/
└── main.dart
```

---

**Resumen del Módulo 8:**

En este módulo aprendiste:

✅ Estructura de carpetas profesional
✅ Separación de responsabilidades
✅ Patrón Repository
✅ Provider con ChangeNotifier
✅ BLoC/Cubit para estado
✅ Clean Architecture (introducción)
✅ Ejercicio: Arquitectura completa

**Próximo módulo:** Testing## Módulo 9: Testing (3 horas)

---

### 1. Tipos de tests en Flutter

Flutter tiene tres niveles de testing:

| Tipo | Velocidad | Costo | Cobertura |
|------|-----------|-------|-----------|
| Unit Tests | Rápida | Bajo | Lógica aislada |
| Widget Tests | Media | Medio | UI componentes |
| Integration Tests | Lenta | Alto | Flujos completos |

---

### 2. Unit Tests

#### Estructura de tests

```dart
// test/models/usuario_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/models/usuario.dart';

void main() {
  group('Usuario', () {
    group('fromJson', () {
      test('debe crear un Usuario desde JSON válido', () {
        // Arrange
        final json = {
          'id': 1,
          'nombre': 'Juan',
          'email': 'juan@ejemplo.com',
        };

        // Act
        final usuario = Usuario.fromJson(json);

        // Assert
        expect(usuario.id, 1);
        expect(usuario.nombre, 'Juan');
        expect(usuario.email, 'juan@ejemplo.com');
      });

      test('debe manejar valores nulos', () {
        final json = <String, dynamic>{};

        expect(
          () => Usuario.fromJson(json),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group('toJson', () {
      test('debe convertir Usuario a JSON', () {
        final usuario = Usuario(
          id: 1,
          nombre: 'Juan',
          email: 'juan@ejemplo.com',
        );

        final json = usuario.toJson();

        expect(json['id'], 1);
        expect(json['nombre'], 'Juan');
        expect(json['email'], 'juan@ejemplo.com');
      });
    });

    group('copyWith', () {
      test('debe crear copia con valores modificados', () {
        final usuario = Usuario(
          id: 1,
          nombre: 'Juan',
          email: 'juan@ejemplo.com',
        );

        final copia = usuario.copyWith(nombre: 'Pedro');

        expect(copia.id, 1);
        expect(copia.nombre, 'Pedro');
        expect(copia.email, 'juan@ejemplo.com');
      });
    });
  });
}
```

#### Test de servicios

```dart
// test/services/producto_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:mi_app/services/producto_service.dart';
import 'package:mi_app/models/producto.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  late ProductoService service;
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    service = ProductoService(client: mockClient);
  });

  group('ProductoService', () {
    group('obtenerTodos', () {
      test('debe retornar lista de productos cuando la respuesta es 200', () async {
        // Arrange
        final json = '[{"id":1,"nombre":"Producto 1","precio":100}]';
        when(() => mockClient.get(any()))
            .thenAnswer((_) async => http.Response(json, 200));

        // Act
        final productos = await service.obtenerTodos();

        // Assert
        expect(productos.length, 1);
        expect(productos[0].nombre, 'Producto 1');
        verify(() => mockClient.get(any())).called(1);
      });

      test('debe lanzar excepción cuando la respuesta es 404', () async {
        // Arrange
        when(() => mockClient.get(any()))
            .thenAnswer((_) async => http.Response('Not found', 404));

        // Act & Assert
        expect(
          () => service.obtenerTodos(),
          throwsA(isA<Exception>()),
        );
      });

      test('debe lanzar excepción cuando hay error de red', () async {
        // Arrange
        when(() => mockClient.get(any()))
            .thenThrow(http.ClientException('Network error'));

        // Act & Assert
        expect(
          () => service.obtenerTodos(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('crear', () {
      test('debe crear producto y retornarlo', () async {
        // Arrange
        final producto = Producto(id: 0, nombre: 'Nuevo', precio: 50);
        final json = '{"id":1,"nombre":"Nuevo","precio":50}';

        when(() => mockClient.post(any(), body: any(named: 'body')))
            .thenAnswer((_) async => http.Response(json, 201));

        // Act
        final creado = await service.crear(producto);

        // Assert
        expect(creado.id, 1);
        expect(creado.nombre, 'Nuevo');
      });
    });
  });
}
```

#### Test de validadores

```dart
// test/utils/validators_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/utils/validators.dart';

void main() {
  group('Validators', () {
    group('required', () {
      test('debe retornar null para valor válido', () {
        expect(Validators.required('valor'), isNull);
      });

      test('debe retornar mensaje para valor null', () {
        expect(Validators.required(null), 'Este campo es obligatorio');
      });

      test('debe retornar mensaje para string vacío', () {
        expect(Validators.required(''), 'Este campo es obligatorio');
      });

      test('debe retornar mensaje personalizado', () {
        expect(Validators.required(null, 'Requerido'), 'Requerido');
      });
    });

    group('email', () {
      test('debe aceptar emails válidos', () {
        expect(Validators.email('test@ejemplo.com'), isNull);
        expect(Validators.email('usuario.nombre@dominio.es'), isNull);
      });

      test('debe rechazar emails inválidos', () {
        expect(Validators.email('sin-arroba'), isNotNull);
        expect(Validators.email('@dominio.com'), isNotNull);
        expect(Validators.email('usuario@'), isNotNull);
      });
    });

    group('password', () {
      test('debe aceptar contraseñas válidas', () {
        expect(Validators.password('Abc123!@'), isNull);
        expect(Validators.password('Password123!'), isNull);
      });

      test('debe rechazar contraseñas cortas', () {
        expect(Validators.password('Ab1!'), 'Mínimo 8 caracteres');
      });

      test('debe rechazar sin mayúscula', () {
        expect(Validators.password('abc123!@'), 'Al menos una mayúscula');
      });

      test('debe rechazar sin número', () {
        expect(Validators.password('Abcdef!@'), 'Al menos un número');
      });
    });

    group('compose', () {
      test('debe ejecutar validadores en orden', () {
        final validador = Validators.compose([
          Validators.required,
          Validators.minLength(3),
        ]);

        expect(validador(null), 'Este campo es obligatorio');
        expect(validador('ab'), 'Mínimo 3 caracteres');
        expect(validador('abc'), isNull);
      });
    });
  });
}
```

---

### 3. Widget Tests

#### Test básico de widget

```dart
// test/widgets/producto_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/models/producto.dart';
import 'package:mi_app/widgets/producto_card.dart';

void main() {
  group('ProductoCard', () {
    final producto = Producto(
      id: 1,
      nombre: 'Laptop',
      precio: 999.99,
      descripcion: 'Laptop gaming',
      categoria: 'Electrónica',
    );

    testWidgets('debe mostrar nombre y precio del producto', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductoCard(producto: producto),
          ),
        ),
      );

      expect(find.text('Laptop'), findsOneWidget);
      expect(find.text('\$999.99'), findsOneWidget);
    });

    testWidgets('debe llamar onTap cuando se presiona', (tester) async {
      var presionado = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductoCard(
              producto: producto,
              onTap: () => presionado = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      expect(presionado, isTrue);
    });

    testWidgets('debe mostrar imagen si existe', (tester) async {
      final productoConImagen = Producto(
        id: 1,
        nombre: 'Laptop',
        precio: 999.99,
        imagen: 'https://ejemplo.com/laptop.jpg',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductoCard(producto: productoConImagen),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });
  });
}
```

#### Test de formularios

```dart
// test/widgets/login_form_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/widgets/login_form.dart';

void main() {
  group('LoginForm', () {
    testWidgets('debe mostrar error cuando email está vacío', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: LoginForm())),
      );

      // Presionar botón sin llenar campos
      await tester.tap(find.text('Iniciar sesión'));
      await tester.pump();

      expect(find.text('El email es obligatorio'), findsOneWidget);
    });

    testWidgets('debe mostrar error cuando contraseña es muy corta', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: LoginForm())),
      );

      // Llenar email
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@ejemplo.com',
      );

      // Llenar contraseña corta
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'abc',
      );

      await tester.tap(find.text('Iniciar sesión'));
      await tester.pump();

      expect(find.text('Mínimo 8 caracteres'), findsOneWidget);
    });

    testWidgets('debe llamar onLogin con credenciales válidas', (tester) async {
      String? email;
      String? password;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginForm(
              onLogin: (e, p) {
                email = e;
                password = p;
              },
            ),
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@ejemplo.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'Password123!',
      );

      await tester.tap(find.text('Iniciar sesión'));
      await tester.pumpAndSettle();

      expect(email, 'test@ejemplo.com');
      expect(password, 'Password123!');
    });

    testWidgets('debe ocultar contraseña por defecto', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: LoginForm())),
      );

      final passwordField = tester.widget<TextField>(
        find.byKey(const Key('password_field')),
      );

      expect(passwordField.obscureText, isTrue);
    });

    testWidgets('debe alternar visibilidad de contraseña', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: LoginForm())),
      );

      // Verificar que está oculta
      var passwordField = tester.widget<TextField>(
        find.byKey(const Key('password_field')),
      );
      expect(passwordField.obscureText, isTrue);

      // Tap en el icono de visibilidad
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      // Verificar que ahora es visible
      passwordField = tester.widget<TextField>(
        find.byKey(const Key('password_field')),
      );
      expect(passwordField.obscureText, isFalse);
    });
  });
}
```

#### Test de navegación

```dart
// test/widgets/navegacion_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/pages/home_page.dart';
import 'package:mi_app/pages/detail_page.dart';

void main() {
  group('Navegación', () {
    testWidgets('debe navegar a la página de detalle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
          routes: {
            '/detail': (context) => const DetailPage(),
          },
        ),
      );

      // Tap en un elemento
      await tester.tap(find.text('Ver detalles'));
      await tester.pumpAndSettle();

      // Verificar que estamos en la página de detalle
      expect(find.byType(DetailPage), findsOneWidget);
      expect(find.text('Página de detalle'), findsOneWidget);
    });

    testWidgets('debe volver a la página anterior', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
          routes: {
            '/detail': (context) => const DetailPage(),
          },
        ),
      );

      // Ir a detalle
      await tester.tap(find.text('Ver detalles'));
      await tester.pumpAndSettle();

      // Volver
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verificar que estamos en home
      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}
```

---

### 4. Integration Tests

#### Configuración

```yaml
# pubspec.yaml
dev_dependencies:
  integration_test:
    sdk: flutter
  flutter_driver:
    sdk: flutter
```

#### Test de integración

```dart
// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mi_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Flujo de login', () {
    testWidgets('login exitoso', (tester) async {
      // Iniciar app
      app.main();
      await tester.pumpAndSettle();

      // Llenar formulario
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@ejemplo.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'Password123!',
      );

      // Tap en login
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Verificar que estamos en home
      expect(find.text('Bienvenido'), findsOneWidget);
    });

    testWidgets('crear y eliminar producto', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@ejemplo.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'Password123!',
      );
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Ir a crear producto
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Llenar formulario
      await tester.enterText(
        find.byKey(const Key('nombre_field')),
        'Producto Test',
      );
      await tester.enterText(
        find.byKey(const Key('precio_field')),
        '100',
      );

      // Guardar
      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle();

      // Verificar que aparece en la lista
      expect(find.text('Producto Test'), findsOneWidget);

      // Eliminar
      await tester.longPress(find.text('Producto Test'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();

      // Verificar que ya no existe
      expect(find.text('Producto Test'), findsNothing);
    });
  });
}
```

---

### 5. Mocking con Mocktail

#### Mock de dependencias

```dart
// test/mocks/mocks.dart
import 'package:mocktail/mocktail.dart';
import 'package:mi_app/services/api_service.dart';
import 'package:mi_app/services/storage_service.dart';
import 'package:mi_app/repositories/producto_repository.dart';

class MockApiService extends Mock implements ApiService {}
class MockStorageService extends Mock implements StorageService {}
class MockProductoRepository extends Mock implements ProductoRepository {}

// Registrar fakes para matchers
class FakeProducto extends Fake implements Producto {}
class FakeProductoId extends Fake implements int {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeProducto());
    registerFallbackValue(FakeProductoId());
  });
}
```

#### Test con mocks

```dart
// test/providers/producto_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mi_app/providers/producto_provider.dart';
import 'package:mi_app/models/producto.dart';
import 'package:mi_app/repositories/producto_repository.dart';

class MockProductoRepository extends Mock implements ProductoRepository {}

void main() {
  late ProductoProvider provider;
  late MockProductoRepository mockRepository;

  setUp(() {
    mockRepository = MockProductoRepository();
    provider = ProductoProvider(repository: mockRepository);
  });

  group('ProductoProvider', () {
    final productos = [
      Producto(id: 1, nombre: 'Producto 1', precio: 100),
      Producto(id: 2, nombre: 'Producto 2', precio: 200),
    ];

    group('cargarProductos', () {
      test('debe cargar productos exitosamente', () async {
        // Arrange
        when(() => mockRepository.obtenerTodos())
            .thenAnswer((_) async => productos);

        // Act
        await provider.cargarProductos();

        // Assert
        expect(provider.productos.length, 2);
        expect(provider.estado, EstadoCarga.cargado);
        verify(() => mockRepository.obtenerTodos()).called(1);
      });

      test('debe manejar error correctamente', () async {
        // Arrange
        when(() => mockRepository.obtenerTodos())
            .thenThrow(Exception('Error de red'));

        // Act
        await provider.cargarProductos();

        // Assert
        expect(provider.estado, EstadoCarga.error);
        expect(provider.errorMessage, contains('Error de red'));
      });
    });

    group('agregarProducto', () {
      test('debe agregar producto exitosamente', () async {
        // Arrange
        when(() => mockRepository.guardar(any()))
            .thenAnswer((_) async {});
        when(() => mockRepository.obtenerTodos())
            .thenAnswer((_) async => productos);

        // Pre-cargar productos
        await provider.cargarProductos();

        // Act
        final nuevo = Producto(id: 3, nombre: 'Nuevo', precio: 300);
        await provider.agregarProducto(nuevo);

        // Assert
        expect(provider.productos.length, 3);
      });
    });
  });
}
```

---

### 6. Cobertura de tests

#### Ejecutar tests con cobertura

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

#### Configuración de coverage

```yaml
# pubspec.yaml
dev_dependencies:
  coverage: ^1.6.0
```

#### Excluir archivos de cobertura

```dart
// coverage.dart
// Archivos a excluir en analysis_options.yaml
```

---

### 7. Good Practices

#### Nombrar tests descriptivamente

```dart
void main() {
  group('ProductoRepository', () {
    group('obtenerTodos', () {
      test('retorna lista de productos cuando la API responde correctamente', () {
        // ...
      });

      test('retorna lista vacía cuando no hay productos', () {
        // ...
      });

      test('lanza ApiException cuando la API falla', () {
        // ...
      });

      test('retorna productos del cache cuando no hay conexión', () {
        // ...
      });
    });
  });
}
```

#### UsarAAA pattern

```dart
test('descripcion del test', () async {
  // Arrange (preparar)
  final producto = Producto(id: 1, nombre: 'Test', precio: 100);
  when(() => mockRepo.guardar(any())).thenAnswer((_) async => true);

  // Act (actuar)
  final resultado = await service.guardar(producto);

  // Assert (verificar)
  expect(resultado, isTrue);
  verify(() => mockRepo.guardar(producto)).called(1);
});
```

#### Tests independientes

```dart
void main() {
  late Service service;
  late MockRepo mockRepo;

  setUp(() {
    mockRepo = MockRepo();
    service = Service(repository: mockRepo);
  });

  tearDown(() {
    reset(mockRepo);
  });

  test('test 1', () {
    // Cada test empieza con estado limpio
  });

  test('test 2', () {
    // Cada test empieza con estado limpio
  });
}
```

---

### 8. Ejercicios prácticos del Módulo 9

#### Ejercicio: Tests completos para una app de tareas

Crear tests para:
1. Modelos (fromJson, toJson, copyWith)
2. Repositorio (CRUD con mocks)
3. Provider (estados y transiciones)
4. Widgets (renderizado y interacciones)

**Solución incluida en el módulo.**

---

**Resumen del Módulo 9:**

En este módulo aprendiste:

✅ Tipos de tests: Unit, Widget, Integration
✅ Unit tests para modelos y servicios
✅ Mocking con Mocktail
✅ Widget tests para UI
✅ Integration tests para flujos completos
✅ Cobertura de tests
✅ Good practices y patrones AAA

**Próximo módulo:** Publicación