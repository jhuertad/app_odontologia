/// Variables y configuración de entorno para Supabase y Cloudflare R2
class Env {
  Env._();

  // Valores predeterminados o inyectados desde variables de entorno
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://placeholder.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'placeholder-anon-key',
  );

  static const String r2PublicDomain = String.fromEnvironment(
    'R2_PUBLIC_DOMAIN',
    defaultValue: 'https://rx.placeholder.com',
  );
}
