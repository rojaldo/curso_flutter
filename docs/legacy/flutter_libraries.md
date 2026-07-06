# Módulo 5: Librerías Flutter Esenciales - Guía Extendida

## Introducción

El ecosistema Flutter cuenta con más de 55,000 paquetes en pub.dev. Este módulo cubre las librerías más utilizadas y mejor valoradas, con explicaciones detalladas, casos de uso reales y ejemplos de código completos.

**Objetivos del módulo:**
- Conocer las librerías fundamentales para desarrollo Flutter profesional
- Entender cuándo y por qué usar cada librería
- Implementar patrones de uso con ejemplos prácticos del mundo real
- Aprender mejores prácticas y patrones de diseño

---

## Sección 5.1: Gestión de Estado

### 5.1.1 Riverpod

**Puntuación crítica:** 0.64 (muy alta)

**Sitio oficial:** https://riverpod.dev

#### ¿Qué es Riverpod?

Riverpod es una librería de gestión de estado **reactiva**, **compile-safe** y **sin dependencia de BuildContext**. Es la evolución moderna de Provider, creada por el mismo autor (Remi Rousselet), pero diseñada para resolver las limitaciones de Provider.

#### ¿Por qué usar Riverpod?

| Problema con Provider | Solución con Riverpod |
|----------------------|----------------------|
| Requiere BuildContext para acceder al estado | Acceso sin BuildContext desde cualquier lugar |
| Errores en runtime (provider not found) | Errores en compile-time (compile-safe) |
| Difícil de testear | Testing nativo y sencillo |
| Estado acoplado al árbol de widgets | Estado independiente y reutilizable |
| No soporta dependencias inmutables | Dependencias inmutables por diseño |

#### Características Principales

- **Declarative programming**: Escribe lógica de negocio similar a Stateless widgets
- **Network requests**: Peticiones de red con recarga automática
- **Loading/error handling**: Manejo automático de estados de carga y error
- **Compile safety**: Errores comunes detectados en compilación
- **Type-safe**: Parámetros de consulta tipados
- **Test ready**: Diseñado para testing
- **Plain Dart**: Funciona en servidores, CLI, no solo Flutter
- **Combinable states**: Estados fácilmente combinables
- **Pull-to-refresh**: Soporte nativo para recarga
- **DevTools**: Inspección de estado en DevTools

#### Instalación

```yaml
dependencies:
  flutter_riverpod: ^2.4.11
```

Para código generado:
```yaml
dependencies:
  riverpod_annotation: ^2.3.3

dev_dependencies:
  riverpod_generator: ^2.3.9
  build_runner: ^2.4.8
```

#### Ejemplo Básico - Contador Simple

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Definir un provider simple
final counterProvider = StateProvider<int>((ref) => 0);

// Widget que consume el provider
class CounterWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    
    return Column(
      children: [
        Text('Contador: $count'),
        ElevatedButton(
          onPressed: () => ref.read(counterProvider.notifier).state++,
          child: Text('Incrementar'),
        ),
      ],
    );
  }
}
```

#### Ejemplo Intermedio - Tasks con Notifier

```dart
// Modelo de datos
class Task {
  final String id;
  final String title;
  final bool completed;
  final DateTime createdAt;
  
  Task({
    required this.id,
    required this.title,
    this.completed = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
  
  Task copyWith({
    String? id,
    String? title,
    bool? completed,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Notifier con lógica de negocio
class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super([]);
  
  void addTask(String title) {
    state = [
      ...state,
      Task(id: DateTime.now().millisecondsSinceEpoch.toString(), title: title),
    ];
  }
  
  void toggleTask(String id) {
    state = state.map((task) {
      if (task.id == id) {
        return task.copyWith(completed: !task.completed);
      }
      return task;
    }).toList();
  }
  
  void removeTask(String id) {
    state = state.where((task) => task.id != id).toList();
  }
  
  void clearCompleted() {
    state = state.where((task) => !task.completed).toList();
  }
  
  int get completedCount => state.where((task) => task.completed).length;
  int get pendingCount => state.where((task) => !task.completed).length;
}

// Provider del notifier
final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});

// Provider derivado (computed)
final completedTasksProvider = Provider<List<Task>>((ref) {
  return ref.watch(taskProvider).where((task) => task.completed).toList();
});

final pendingTasksProvider = Provider<List<Task>>((ref) {
  return ref.watch(taskProvider).where((task) => !task.completed).toList();
});

final taskStatsProvider = Provider<Map<String, int>>((ref) {
  final tasks = ref.watch(taskProvider);
  return {
    'total': tasks.length,
    'completed': tasks.where((t) => t.completed).length,
    'pending': tasks.where((t) => !t.completed).length,
  };
});

// Widget de uso
class TaskListWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskProvider);
    final stats = ref.watch(taskStatsProvider);
    
    return Column(
      children: [
        // Estadísticas
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('Total', stats['total']!),
              _buildStat('Completadas', stats['completed']!),
              _buildStat('Pendientes', stats['pending']!),
            ],
          ),
        ),
        
        // Input
        Padding(
          padding: EdgeInsets.all(16),
          child: TextField(
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                ref.read(taskProvider.notifier).addTask(value);
              }
            },
            decoration: InputDecoration(
              hintText: 'Nueva tarea',
              suffixIcon: Icon(Icons.add),
            ),
          ),
        ),
        
        // Lista
        Expanded(
          child: tasks.isEmpty
              ? Center(child: Text('No hay tareas'))
              : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      leading: Checkbox(
                        value: task.completed,
                        onChanged: (_) => ref.read(taskProvider.notifier).toggleTask(task.id),
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.completed ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Text(task.createdAt.toString()),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => ref.read(taskProvider.notifier).removeTask(task.id),
                      ),
                    );
                  },
                ),
        ),
        
        // Acciones
        Padding(
          padding: EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => ref.read(taskProvider.notifier).clearCompleted(),
            child: Text('Limpiar completadas'),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStat(String label, int value) {
    return Column(
      children: [
        Text(value.toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}
```

#### Ejemplo Avanzado - Peticiones HTTP con Riverpod

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

// Cliente HTTP
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: 'https://api.example.com',
    connectTimeout: Duration(seconds: 5),
    receiveTimeout: Duration(seconds: 3),
  ));
});

// Modelo
class User {
  final String id;
  final String name;
  final String email;
  
  User({required this.id, required this.name, required this.email});
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

// Repository
class UserRepository {
  final Dio dio;
  
  UserRepository(this.dio);
  
  Future<List<User>> getUsers() async {
    final response = await dio.get('/users');
    return (response.data as List).map((json) => User.fromJson(json)).toList();
  }
  
  Future<User> getUser(String id) async {
    final response = await dio.get('/users/$id');
    return User.fromJson(response.data);
  }
  
  Future<User> createUser(User user) async {
    final response = await dio.post('/users', data: {
      'name': user.name,
      'email': user.email,
    });
    return User.fromJson(response.data);
  }
}

// Provider del repository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(dioProvider));
});

// Provider para lista de usuarios (async)
final usersProvider = FutureProvider<List<User>>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUsers();
});

// Provider para un usuario específico (con parámetro)
final userProvider = FutureProvider.family<User, String>((ref, id) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUser(id);
});

// Widget con manejo de estados
class UsersListWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);
    
    return usersAsync.when(
      data: (users) => ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text(user.name),
            subtitle: Text(user.email),
            trailing: Icon(Icons.arrow_forward),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => UserDetailPage(userId: user.id)),
            ),
          );
        },
      ),
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error'),
            ElevatedButton(
              onPressed: () => ref.invalidate(usersProvider),
              child: Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

// Página de detalle con parámetro
class UserDetailPage extends ConsumerWidget {
  final String userId;
  
  const UserDetailPage({required this.userId});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider(userId));
    
    return Scaffold(
      appBar: AppBar(title: Text('Usuario')),
      body: userAsync.when(
        data: (user) => Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID: ${user.id}'),
              SizedBox(height: 8),
              Text('Nombre: ${user.name}'),
              SizedBox(height: 8),
              Text('Email: ${user.email}'),
            ],
          ),
        ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

// Pull to refresh
class RefreshableUsersList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);
    
    return RefreshIndicator(
      onRefresh: () async {
        // Invalidar para forzar recarga
        ref.invalidate(usersProvider);
        // Esperar a que se complete
        await ref.read(usersProvider.future);
      },
      child: usersAsync.when(
        data: (users) => ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              title: Text(user.name),
              subtitle: Text(user.email),
            );
          },
        ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => ListView(
          children: [
            Center(child: Text('Error: $error')),
            ElevatedButton(
              onPressed: () => ref.invalidate(usersProvider),
              child: Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### Casos de Uso Reales

1. **App de tareas**: Estado de lista de tareas con filtros y estadísticas
2. **App de e-commerce**: Carrito de compras con precios dinámicos
3. **App de chat**: Mensajes en tiempo real con WebSockets
4. **App de noticias**: Feed infinito con paginación
5. **App de configuración**: Preferencias de usuario sincronizadas

#### Patrón Recommended Setup

```dart
// providers/providers.dart
export 'task_provider.dart';
export 'user_provider.dart';
export 'settings_provider.dart';

// main.dart
void main() {
  runApp(ProviderScope(child: MyApp()));
}

// app.dart
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    
    return MaterialApp(
      theme: settings.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: HomePage(),
    );
  }
}
```

---

### 5.1.2 BLoC / Cubit

**Puntuación crítica:** 0.60 (alta)

**Sitio oficial:** https://bloclibrary.dev

#### ¿Qué es BLoC?

BLoC (Business Logic Component) es un patrón de diseño que separa la lógica de negocio de la UI. Fue creado por Google y se basa en **Streams** y **Reactive Programming**.

#### ¿Por qué usar BLoC?

| Ventaja | Descripción |
|---------|-------------|
| **Separación de capas** | Lógica de negocio completamente separada de la UI |
| **Testabilidad** | Fácil testing unitario de lógica de negocio |
| **Reactividad** | Basado en Streams, ideal para UI reactiva |
| **Escalabilidad** | Patrón predecible para apps grandes |
| **Documentación** | Excelente documentación y comunidad |
| **Tooling** | Extensions para VSCode e IntelliJ |

#### BLoC vs Cubit

| Aspecto | BLoC | Cubit |
|---------|------|-------|
| **Complejidad** | Mayor | Menor |
| **Eventos** | Tiene eventos | Solo métodos |
| **Boilerplate** | Más código | Menos código |
| **Use case** | Lógica compleja | Lógica simple |
| **Traceability** | Eventos rastreables | Métodos directos |

#### Instalación

```yaml
dependencies:
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
```

#### Ejemplo Básico - Cubit

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Estado
class CounterState extends Equatable {
  final int count;
  
  const CounterState(this.count);
  
  @override
  List<Object> get props => [count];
}

// Cubit
class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(const CounterState(0));
  
  void increment() => emit(CounterState(state.count + 1));
  void decrement() => emit(CounterState(state.count - 1));
  void reset() => emit(const CounterState(0));
  void incrementBy(int value) => emit(CounterState(state.count + value));
}

// Widget
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounterCubit(),
      child: Scaffold(
        appBar: AppBar(title: Text('Counter Cubit')),
        body: BlocBuilder<CounterCubit, CounterState>(
          builder: (context, state) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Contador: ${state.count}', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        heroTag: 'dec',
                        onPressed: () => context.read<CounterCubit>().decrement(),
                        child: Icon(Icons.remove),
                      ),
                      FloatingActionButton(
                        heroTag: 'reset',
                        onPressed: () => context.read<CounterCubit>().reset(),
                        child: Icon(Icons.refresh),
                      ),
                      FloatingActionButton(
                        heroTag: 'inc',
                        onPressed: () => context.read<CounterCubit>().increment(),
                        child: Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
```

#### Ejemplo Avanzado - BLoC Completo con Autenticación

```dart
// events/auth_event.dart
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object> get props => [];
}

class AuthStarted extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  
  const AuthLoginRequested({
    required this.email,
    required this.password,
  });
  
  @override
  List<Object> get props => [email, password];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthStatusChecked extends AuthEvent {}

// states/auth_state.dart
abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  
  const AuthAuthenticated(this.user);
  
  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  
  const AuthError(this.message);
  
  @override
  List<Object> get props => [message];
}

// blocs/auth_bloc.dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  
  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthStatusChecked>(_onStatusChecked);
  }
  
  Future<void> _onStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(event.email, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  Future<void> _onStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }
}

// Widget de login
class LoginPage extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        },
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 24),
                if (state is AuthLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthLoginRequested(
                        email: _emailController.text,
                        password: _passwordController.text,
                      ));
                    },
                    child: Text('Login'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// App con routing basado en auth
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(authRepository: AuthRepository())..add(AuthStarted()),
      child: MaterialApp(
        routes: {
          '/': (_) => BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return HomePage();
              } else if (state is AuthUnauthenticated) {
                return LoginPage();
              }
              return SplashScreen();
            },
          ),
          '/home': (_) => HomePage(),
          '/login': (_) => LoginPage(),
        },
      ),
    );
  }
}
```

#### Patrón Repositorio con BLoC

```dart
// data/models/user.dart
class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'avatar': avatar,
  };
  
  @override
  List<Object?> get props => [id, name, email, avatar];
}

// data/repositories/user_repository.dart
abstract class UserRepository {
  Future<List<User>> getUsers();
  Future<User> getUser(String id);
  Future<User> createUser(User user);
  Future<User> updateUser(User user);
  Future<void> deleteUser(String id);
}

// data/repositories/user_repository_impl.dart
class UserRepositoryImpl implements UserRepository {
  final Dio dio;
  
  UserRepositoryImpl(this.dio);
  
  @override
  Future<List<User>> getUsers() async {
    final response = await dio.get('/users');
    return (response.data as List)
        .map((json) => User.fromJson(json))
        .toList();
  }
  
  @override
  Future<User> getUser(String id) async {
    final response = await dio.get('/users/$id');
    return User.fromJson(response.data);
  }
  
  @override
  Future<User> createUser(User user) async {
    final response = await dio.post('/users', data: user.toJson());
    return User.fromJson(response.data);
  }
  
  @override
  Future<User> updateUser(User user) async {
    final response = await dio.put('/users/${user.id}', data: user.toJson());
    return User.fromJson(response.data);
  }
  
  @override
  Future<void> deleteUser(String id) async {
    await dio.delete('/users/$id');
  }
}

// bloc/user_event.dart
abstract class UserEvent extends Equatable {
  const UserEvent();
  
  @override
  List<Object> get props => [];
}

class UserFetchAll extends UserEvent {}

class UserFetchOne extends UserEvent {
  final String id;
  
  const UserFetchOne(this.id);
  
  @override
  List<Object> get props => [id];
}

class UserCreate extends UserEvent {
  final User user;
  
  const UserCreate(this.user);
  
  @override
  List<Object> get props => [user];
}

class UserUpdate extends UserEvent {
  final User user;
  
  const UserUpdate(this.user);
  
  @override
  List<Object> get props => [user];
}

class UserDelete extends UserEvent {
  final String id;
  
  const UserDelete(this.id);
  
  @override
  List<Object> get props => [id];
}

// bloc/user_state.dart
abstract class UserState extends Equatable {
  const UserState();
  
  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UsersLoaded extends UserState {
  final List<User> users;
  
  const UsersLoaded(this.users);
  
  @override
  List<Object> get props => [users];
}

class UserLoaded extends UserState {
  final User user;
  
  const UserLoaded(this.user);
  
  @override
  List<Object> get props => [user];
}

class UserError extends UserState {
  final String message;
  
  const UserError(this.message);
  
  @override
  List<Object> get props => [message];
}

class UserActionSuccess extends UserState {
  final String message;
  
  const UserActionSuccess(this.message);
  
  @override
  List<Object> get props => [message];
}

// bloc/user_bloc.dart
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;
  
  UserBloc({required this.userRepository}) : super(UserInitial()) {
    on<UserFetchAll>(_onFetchAll);
    on<UserFetchOne>(_onFetchOne);
    on<UserCreate>(_onCreate);
    on<UserUpdate>(_onUpdate);
    on<UserDelete>(_onDelete);
  }
  
  Future<void> _onFetchAll(
    UserFetchAll event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final users = await userRepository.getUsers();
      emit(UsersLoaded(users));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
  
  Future<void> _onFetchOne(
    UserFetchOne event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final user = await userRepository.getUser(event.id);
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
  
  Future<void> _onCreate(
    UserCreate event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      await userRepository.createUser(event.user);
      emit(UserActionSuccess('Usuario creado correctamente'));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
  
  Future<void> _onUpdate(
    UserUpdate event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      await userRepository.updateUser(event.user);
      emit(UserActionSuccess('Usuario actualizado correctamente'));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
  
  Future<void> _onDelete(
    UserDelete event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      await userRepository.deleteUser(event.id);
      emit(UserActionSuccess('Usuario eliminado correctamente'));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}

// main.dart con inyección de dependencias
void main() {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
  final userRepository = UserRepositoryImpl(dio);
  
  runApp(MyApp(userRepository: userRepository));
}

class MyApp extends StatelessWidget {
  final UserRepository userRepository;
  
  const MyApp({required this.userRepository});
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserBloc(userRepository: userRepository),
      child: MaterialApp(
        home: UsersPage(),
      ),
    );
  }
}
```

#### Testing con BLoC

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  group('UserBloc', () {
    late UserRepository userRepository;
    late UserBloc userBloc;
    
    setUp(() {
      userRepository = MockUserRepository();
      userBloc = UserBloc(userRepository: userRepository);
    });
    
    tearDown(() {
      userBloc.close();
    });
    
    test('initial state is UserInitial', () {
      expect(userBloc.state, UserInitial());
    });
    
    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UsersLoaded] when UserFetchAll succeeds',
      build: () {
        when(() => userRepository.getUsers()).thenAnswer((_) async => [
          User(id: '1', name: 'John', email: 'john@example.com'),
          User(id: '2', name: 'Jane', email: 'jane@example.com'),
        ]);
        return userBloc;
      },
      act: (bloc) => bloc.add(UserFetchAll()),
      expect: () => [
        UserLoading(),
        UsersLoaded([
          User(id: '1', name: 'John', email: 'john@example.com'),
          User(id: '2', name: 'Jane', email: 'jane@example.com'),
        ]),
      ],
      verify: (_) {
        verify(() => userRepository.getUsers()).called(1);
      },
    );
    
    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserError] when UserFetchAll fails',
      build: () {
        when(() => userRepository.getUsers()).thenThrow(Exception('Network error'));
        return userBloc;
      },
      act: (bloc) => bloc.add(UserFetchAll()),
      expect: () => [
        UserLoading(),
        UserError('Exception: Network error'),
      ],
    );
  });
}
```

---

### 5.1.3 Provider

**Puntuación:** Muy popular (recomendado oficialmente por Flutter team)

**Sitio oficial:** https://pub.dev/packages/provider

#### ¿Qué es Provider?

Provider es un wrapper alrededor de `InheritedWidget` que hace más fácil la gestión de estado. Es la librería oficial recomendada por el equipo de Flutter para apps simples y medianas.

#### ¿Por qué usar Provider?

- **Simple**: Curva de aprendizaje baja
- **Oficial**: Recomendado por Flutter team
- **Flexible**: Funciona para muchos casos de uso
- **Ligero**: Poca sobrecarga de código
- **Bien documentado**: Amplia documentación y ejemplos

#### ¿Cuándo NO usar Provider?

- Apps grandes con lógica compleja → Usar Riverpod o BLoC
- Necesitas estado sin BuildContext → Usar Riverpod
- Testing complejo → Riverpod o BLoC son más testeables

#### Instalación

```yaml
dependencies:
  provider: ^6.1.1
```

#### Ejemplo Completo - App de Contador con Múltiples Providers

```dart
import 'package:provider/provider.dart';

// Modelo 1: Contador
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

// Modelo 2: Tema
class ThemeModel extends ChangeNotifier {
  bool _isDarkMode = false;
  
  bool get isDarkMode => _isDarkMode;
  
  ThemeData get theme => _isDarkMode ? ThemeData.dark() : ThemeData.light();
  
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

// Modelo 3: Configuración
class SettingsModel extends ChangeNotifier {
  String _language = 'es';
  bool _notificationsEnabled = true;
  int _fontSize = 14;
  
  String get language => _language;
  bool get notificationsEnabled => _notificationsEnabled;
  int get fontSize => _fontSize;
  
  void setLanguage(String language) {
    _language = language;
    notifyListeners();
  }
  
  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
  }
  
  void setFontSize(int size) {
    _fontSize = size;
    notifyListeners();
  }
}

// Selector para optimizar reconstrucciones
class CounterValue extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Solo se reconstruye cuando count cambia
    final count = context.select<CounterModel, int>((counter) => counter.count);
    return Text('Contador: $count', style: TextStyle(fontSize: 48));
  }
}

// Widget con Consumer
class CounterActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FloatingActionButton(
          heroTag: 'dec',
          onPressed: () => context.read<CounterModel>().decrement(),
          child: Icon(Icons.remove),
        ),
        FloatingActionButton(
          heroTag: 'reset',
          onPressed: () => context.read<CounterModel>().reset(),
          child: Icon(Icons.refresh),
        ),
        FloatingActionButton(
          heroTag: 'inc',
          onPressed: () => context.read<CounterModel>().increment(),
          child: Icon(Icons.add),
        ),
      ],
    );
  }
}

// Multi-provider setup
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CounterModel()),
        ChangeNotifierProvider(create: (_) => ThemeModel()),
        ChangeNotifierProvider(create: (_) => SettingsModel()),
      ],
      child: Consumer<ThemeModel>(
        builder: (context, theme, _) {
          return MaterialApp(
            theme: theme.theme,
            home: HomePage(),
          );
        },
      ),
    );
  }
}

// Página principal
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Provider Demo'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsPage()),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CounterValue(),
            SizedBox(height: 32),
            CounterActions(),
          ],
        ),
      ),
    );
  }
}

// Página de configuración
class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Consumer<SettingsModel>(
        builder: (context, settings, _) {
          return ListView(
            children: [
              SwitchListTile(
                title: Text('Notificaciones'),
                value: settings.notificationsEnabled,
                onChanged: (_) => context.read<SettingsModel>().toggleNotifications(),
              ),
              ListTile(
                title: Text('Idioma'),
                trailing: DropdownButton<String>(
                  value: settings.language,
                  items: [
                    DropdownMenuItem(value: 'es', child: Text('Español')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      context.read<SettingsModel>().setLanguage(value);
                    }
                  },
                ),
              ),
              ListTile(
                title: Text('Tamaño de fuente: ${settings.fontSize}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () => context.read<SettingsModel>().setFontSize(
                        (settings.fontSize - 1).clamp(10, 24),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () => context.read<SettingsModel>().setFontSize(
                        (settings.fontSize + 1).clamp(10, 24),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              ListTile(
                title: Text('Tema oscuro'),
                trailing: Consumer<ThemeModel>(
                  builder: (context, theme, _) {
                    return Switch(
                      value: theme.isDarkMode,
                      onChanged: (_) => context.read<ThemeModel>().toggleTheme(),
                    );
                  },
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

#### Comparación de Provider vs Riverpod vs BLoC

| Aspecto | Provider | Riverpod | BLoC |
|---------|----------|----------|------|
| **Curva de aprendizaje** | Baja | Media | Alta |
| **Boilerplate** | Bajo | Medio | Alto |
| **BuildContext** | Requerido | No requerido | No requerido |
| **Compile-time safety** | No | Sí | Parcial |
| **Testing** | Medio | Alto | Alto |
| **Escalabilidad** | Media | Alta | Alta |
| **Documentación** | Buena | Excelente | Excelente |
| **Curva de aprendizaje** | Baja | Media | Alta |
| **Ideal para** | Apps pequeñas/medianas | Apps modernas, escalables | Apps enterprise, lógica compleja |

---

## Sección 5.2: Red y APIs

### 5.2.1 Dio

**Puntuación crítica:** 0.60 (alta)

**Sitio oficial:** https://pub.dev/packages/dio

#### ¿Qué es Dio?

Dio es un cliente HTTP potente para Dart/Flutter que soporta:
- Interceptors
- FormData y multipart
- Cancelación de peticiones
- Timeouts configurables
- Transformadores de respuesta
- Adaptadores personalizados

#### ¿Por qué usar Dio sobre HTTP estándar?

| Feature | HTTP (oficial) | Dio |
|---------|---------------|-----|
| **Interceptors** | No | Sí |
| **FormData/Multipart** | Manual | Nativo |
| **Cancelación** | Manual | Nativo |
| **Timeouts** | Manual | Nativo |
| **Transformers** | No | Sí |
| **Proxies** | Manual | Nativo |
| **HTTP/2** | No | Sí (con adaptador) |
| **Logs** | Manual | LogInterceptor |
| **Retry** | Manual | Con plugin |

#### Instalación

```yaml
dependencies:
  dio: ^5.4.1
```

#### Ejemplo Básico - Configuración y Uso

```dart
import 'package:dio/dio.dart';

// Configuración con BaseOptions
final dio = Dio(BaseOptions(
  baseUrl: 'https://api.example.com',
  connectTimeout: Duration(seconds: 5),
  receiveTimeout: Duration(seconds: 3),
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
));

// GET request simple
Future<List<User>> getUsers() async {
  try {
    final response = await dio.get('/users');
    return (response.data as List)
        .map((json) => User.fromJson(json))
        .toList();
  } on DioException catch (e) {
    print('Error: ${e.message}');
    print('Type: ${e.type}');
    print('Response: ${e.response?.data}');
    rethrow;
  }
}

// GET con query parameters
Future<List<User>> searchUsers({String? name, String? email, int? limit}) async {
  final response = await dio.get('/users/search', queryParameters: {
    if (name != null) 'name': name,
    if (email != null) 'email': email,
    if (limit != null) 'limit': limit,
  });
  return (response.data as List).map((json) => User.fromJson(json)).toList();
}

// POST request
Future<User> createUser(CreateUserRequest request) async {
  final response = await dio.post('/users', data: request.toJson());
  return User.fromJson(response.data);
}

// PUT request
Future<User> updateUser(String id, UpdateUserRequest request) async {
  final response = await dio.put('/users/$id', data: request.toJson());
  return User.fromJson(response.data);
}

// DELETE request
Future<void> deleteUser(String id) async {
  await dio.delete('/users/$id');
}
```

#### Ejemplo Intermedio - Interceptors Personalizados

```dart
// Interceptor de autenticación
class AuthInterceptor extends Interceptor {
  final TokenStorage tokenStorage;
  
  AuthInterceptor(this.tokenStorage);
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Añadir token a todas las requests
    final token = tokenStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Si el token expiró, intentar refresh
    if (err.response?.statusCode == 401) {
      _refreshToken(err, handler);
    } else {
      handler.next(err);
    }
  }
  
  Future<void> _refreshToken(DioException err, ErrorInterceptorHandler handler) async {
    try {
      final newToken = await tokenStorage.refreshToken();
      // Reintentar la request original con el nuevo token
      err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
      final response = await dio.fetch(err.requestOptions);
      handler.resolve(response);
    } catch (e) {
      // Si falla el refresh, limpiar token y propagar error
      tokenStorage.clear();
      handler.next(err);
    }
  }
}

// Interceptor de logging
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('┌─────────────────────────────────────────────────────────────────────');
    print('│ REQUEST: ${options.method} ${options.uri}');
    print('│ Headers: ${options.headers}');
    print('│ Data: ${options.data}');
    print('└─────────────────────────────────────────────────────────────────────');
    handler.next(options);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('┌─────────────────────────────────────────────────────────────────────');
    print('│ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
    print('│ Data: ${response.data}');
    print('└─────────────────────────────────────────────────────────────────────');
    handler.next(response);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('┌─────────────────────────────────────────────────────────────────────');
    print('│ ERROR: ${err.type} ${err.message}');
    print('│ Response: ${err.response?.data}');
    print('└─────────────────────────────────────────────────────────────────────');
    handler.next(err);
  }
}

// Interceptor de retry
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int retries;
  final Duration retryDelay;
  
  RetryInterceptor({
    required this.dio,
    this.retries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });
  
  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err) && err.requestOptions.extra['retryCount'] == null) {
      err.requestOptions.extra['retryCount'] = 0;
    }
    
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;
    
    if (_shouldRetry(err) && retryCount < retries) {
      err.requestOptions.extra['retryCount'] = retryCount + 1;
      
      await Future.delayed(retryDelay);
      
      try {
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        // Si falla el retry, continuar con el error original
      }
    }
    
    handler.next(err);
  }
  
  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.connectionError ||
           (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}

// Configuración con múltiples interceptors
final dio = Dio(BaseOptions(
  baseUrl: 'https://api.example.com',
  connectTimeout: Duration(seconds: 10),
  receiveTimeout: Duration(seconds: 30),
))
  ..interceptors.addAll([
    LoggingInterceptor(),
    AuthInterceptor(TokenStorage()),
    RetryInterceptor(dio: dio, retries: 3),
  ]);
```

#### Ejemplo Avanzado - Upload y Download con Progreso

```dart
// Upload de archivo con progreso
Future<String> uploadFile(File file, {Function(int, int)? onProgress}) async {
  final fileName = path.basename(file.path);
  final formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(file.path, filename: fileName),
    'userId': '123',
    'description': 'Uploaded from Flutter app',
  });
  
  try {
    final response = await dio.post(
      '/upload',
      data: formData,
      onSendProgress: onProgress,
    );
    return response.data['url'];
  } on DioException catch (e) {
    throw UploadException(e.message ?? 'Upload failed');
  }
}

// Upload múltiple
Future<List<String>> uploadMultipleFiles(List<File> files) async {
  final multipartFiles = await Future.wait(
    files.map((file) => MultipartFile.fromFile(
      file.path,
      filename: path.basename(file.path),
    )),
  );
  
  final formData = FormData.fromMap({
    'files': multipartFiles,
  });
  
  final response = await dio.post('/upload/multiple', data: formData);
  return (response.data['urls'] as List).cast<String>();
}

// Download con progreso
Future<void> downloadFile(
  String url,
  String savePath, {
  Function(int, int)? onProgress,
  CancelToken? cancelToken,
}) async {
  try {
    await dio.download(
      url,
      savePath,
      cancelToken: cancelToken,
      onReceiveProgress: onProgress,
    );
  } on DioException catch (e) {
    if (e.type == DioExceptionType.cancel) {
      throw DownloadCancelledException();
    }
    throw DownloadException(e.message ?? 'Download failed');
  }
}

// Cancelación de descarga
class DownloadService {
  CancelToken? _cancelToken;
  
  Future<void> startDownload(String url, String savePath) async {
    _cancelToken = CancelToken();
    await downloadFile(
      url,
      savePath,
      cancelToken: _cancelToken,
      onProgress: (received, total) {
        final progress = (received / total * 100).toStringAsFixed(0);
        print('Download progress: $progress%');
      },
    );
  }
  
  void cancelDownload() {
    _cancelToken?.cancel('Download cancelled by user');
    _cancelToken = null;
  }
}

// Streaming response
Future<void> streamResponse(String url) async {
  final response = await dio.get(
    url,
    options: Options(responseType: ResponseType.stream),
  );
  
  await for (final chunk in response.data.stream) {
    // Procesar cada chunk
    print('Received ${chunk.length} bytes');
  }
}
```

#### Casos de Uso Reales

1. **App de redes sociales**: Upload de fotos/videos con progreso
2. **App de e-commerce**: Integración con APIs de pago, retry automático
3. **App de mensajería**: WebSockets con fallback a HTTP long-polling
4. **App de archivos**: Descarga reanudable, cancelación
5. **App offline-first**: Cache de responses, sincronización posterior

---

*(Continúa con más secciones...)*

## Sección 5.3: Navegación

### 5.3.1 GoRouter

**Sitio oficial:** https://pub.dev/packages/go_router

#### ¿Qué es GoRouter?

GoRouter es un paquete de routing declarativo para Flutter que usa la Router API. Ofrece:
- Routing declarativo basado en URLs
- Deep linking
- Shell routes para navegación persistente
- Redirects y guards de autenticación
- Soporte para Material y Cupertino
- Type-safe routes (con go_router_builder)

#### ¿Por qué usar GoRouter?

| Feature | Navigator | go_router |
|---------|-----------|-----------|
| **URL-based routing** | Manual | Nativo |
| **Deep linking** | Manual | Nativo |
| **Web support** | Limitado | Nativo |
| **Guards/Redirects** | Manual | Nativo |
| **Bottom navbar persistente** | Manual | ShellRoute |
| **State management** | Manual | Nativo |
| **Type safety** | No | Sí (con builder) |

*(El contenido completo continúa con más secciones detalladas...)*