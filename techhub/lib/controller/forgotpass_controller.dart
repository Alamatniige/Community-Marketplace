import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPassController {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }
}
