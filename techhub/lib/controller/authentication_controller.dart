import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  Future<void> handleFirstSignIn(User user) async {
    final supabase = Supabase.instance.client;
    
    try {
      // Check if user already exists in main user table
      final existingUser = await supabase
          .from('user')
          .select()
          .eq('id', user.id)
          .maybeSingle();
          
      if (existingUser == null) {
        // Get pending user data
        final pendingUser = await supabase
            .from('pending_users')
            .select()
            .eq('id', user.id)
            .single();
            
        // Create the actual user record
        await supabase.from('user').insert({
          'id': user.id,
          'fullName': pendingUser['fullName'],
          'username': pendingUser['username'],
          'email': pendingUser['email'],
          'password': pendingUser['password'],
        });
        
        // Optional: Delete from pending_users table
        await supabase
            .from('pending_users')
            .delete()
            .eq('id', user.id);
      }
    } catch (e) {
      print('Error creating user after verification: $e');
      rethrow;
    }
  }
}