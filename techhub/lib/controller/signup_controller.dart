import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techhub/model/user_model.dart';

class SignUpController {
  Future<void> signUp(String fullName, String username, String email, String password) async {
    final user = UserModel(
      fullName: fullName,
      username: username,
      email: email,
      password: password,
    );

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: user.email,
        password: user.password,
      );

      if (response.user != null) {
        // Include the auth user's ID when creating the user record
        await Supabase.instance.client.from('user').insert({
          'id': response.user!.id,  // Add this line
          'fullname': user.fullName,
          'username': user.username,
          'email': user.email,
          'password': user.password,
        });
        
        print('User created with ID: ${response.user!.id}');
      } else if (response.session == null) {
        throw Exception(
            'Sign-up successful but email confirmation is required. Please verify your email.');
      } else {
        throw Exception('User sign-up failed for unknown reasons.');
      }
    } catch (e) {
      throw Exception('Error during sign-up: $e');
    }
  }
}