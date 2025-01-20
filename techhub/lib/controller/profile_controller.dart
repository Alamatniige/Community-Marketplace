import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileController {
  final _supabase = Supabase.instance.client;
  User? _currentUser;
  Map<String, dynamic>? _userData;

  // Getters
  User? get currentUser => _currentUser;
  Map<String, dynamic>? get userData => _userData;
  bool get isAuthenticated => _currentUser != null;

  Future<void> initializeProfile() async {
    try {
      // Get the current user from the session
      _currentUser = _supabase.auth.currentUser;      
      if (_currentUser != null) {
        // Query user data using the current user's email directly, ensuring it’s not null
        final email = _currentUser!.email;
        if (email != null) {
          final response = await _supabase
              .from('user')
              .select()
              .eq('email', email) 
              .single();
          
          _userData = response;
          print('User data loaded successfully: ${_userData?['fullname']}');
        } else {
          print('Error: Current user email is null');
        }
      }
    } catch (e) {
      print('Error initializing profile: $e');
      throw Exception('Failed to load profile: $e');
    }
  }

  Future<void> updateProfile({
    String? name,
    String? username,
    String? email,
  }) async {
    try {
      if (_currentUser == null) throw Exception('No authenticated user');

      final updates = {
        if (name != null) 'fullName': name,
        if (username != null) 'username': username,
      };

      // Update the user data in the 'user' table
      final email = _currentUser!.email;
      if (email != null) {
        await _supabase
            .from('user')
            .update(updates)
            .eq('email', email); // Now 'email' is non-nullable

        // If email is updated, update it in Supabase Auth
        await _supabase.auth.updateUser(
          UserAttributes(
            email: email,
          ),
        );
            } else {
        print('Error: Current user email is null');
      }

      await initializeProfile(); // Re-fetch the updated profile data
      print('Profile updated successfully');
    } catch (e) {
      print('Error updating profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      _currentUser = null;
      _userData = null;
      print('Sign-out successful');
    } catch (e) {
      print('Sign-out error: $e');
      throw Exception('Error during sign-out: $e');
    }
  }

  // Getter for user name
  String get userName => _userData?['fullname'] ?? 'No Name';
  
  // Getter for user email
  String get userEmail => _userData?['email'] ?? '';
  
  // Getter for user username
  String get userUsername => _userData?['username'] ?? '';
}
