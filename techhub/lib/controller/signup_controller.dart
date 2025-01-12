import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techhub/model/user_model.dart';

class SignUpController {
  final supabase = Supabase.instance.client;

  Future<void> signUp(String fullName, String username, String email, String password) async {
    // Create a UserModel instance
    final user = UserModel(
      fullName: fullName,
      username: username,
      email: email,
      password: password,
    );

    try {
      // Sign up the user with email and password
      final response = await supabase.auth.signUp(
        email: user.email,
        password: user.password,
      );

      // Ensure the response contains a valid user
      if (response.user == null) {
        throw Exception('Failed to sign up. Please try again.');
      }

      // Insert additional user data into the "profiles" table
      final insertResponse = await supabase.from('user').insert({
        'fullName': user.fullName,
        'username': user.username,
        'email': user.email,
        'password': user.password,
      });

      // If insertResponse doesn't return data, it's considered an error
      if (insertResponse.data == null) {
        throw Exception('Error inserting user profile.');
      }

      // Optional: Handle the successful sign-up process (e.g., navigate to the login page)

    } catch (e) {
      // Throw a detailed exception for debugging or displaying in UI
      throw Exception('Sign-up failed: $e');
    }
  }
}
