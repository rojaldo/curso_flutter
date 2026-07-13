/// Configuración de Supabase para la app.
///
/// Estas claves (URL + publishable key) son públicas: cualquier cliente las
/// termina viendo. La seguridad se controla con Row Level Security (RLS) en
/// Postgres, no con estas claves. La publishable key solo permite operaciones
/// que las políticas RLS autoricen para usuarios anónimos o autenticados.
///
/// Proyecto: mi-app-demo (ref: fgucnazxghfvxqlyxfwf, región: eu-west-1).
class SupabaseConfig {
  static const String url = 'https://fgucnazxghfvxqlyxfwf.supabase.co';
  // Publishable key (nuevo formato sb_publishable_*). Reemplaza al anon key
  // legacy, que está deprecado y se eliminará en una major futura.
  static const String publishableKey =
      'sb_publishable_-7GlB8nd6_Ad_YIUQ59JLA_0J8tTKGs';

  SupabaseConfig._();
}