import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  final SupabaseClient client;

  SupabaseService._internal()
      : client = SupabaseClient(
          'https://juasfqvgaytghlyjvgyl.supabase.co',
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp1YXNmcXZnYXl0Z2hseWp2Z3lsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzY2OTIxNzMsImV4cCI6MjA1MjI2ODE3M30.ZHau11pVVWhC7diqm_JoEp7XQs8Ap8OL5J816yqR3w0',
        );

  factory SupabaseService() {
    return _instance;
  }

  SupabaseClient get supabaseClient => client;
}
