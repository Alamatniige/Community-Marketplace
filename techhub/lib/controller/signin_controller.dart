import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInController {
  final _supabase = Supabase.instance.client;
  Session? _currentSession;
  User? _currentUser;

  Session? get currentSession => _currentSession;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<void> initializeSession() async {
    try {
      // Get current session if it exists
      _currentSession = _supabase.auth.currentSession;
      _currentUser = _currentSession?.user;

      // Listen to auth state changes
      _supabase.auth.onAuthStateChange.listen((AuthState data) {
        final Session? session = data.session;
        final AuthChangeEvent event = data.event;

        switch (event) {
          case AuthChangeEvent.signedIn:
            _currentSession = session;
            _currentUser = session?.user;
            print('User signed in: ${_currentUser?.email}');
            break;
          case AuthChangeEvent.signedOut:
            _currentSession = null;
            _currentUser = null;
            print('User signed out');
            break;
          case AuthChangeEvent.tokenRefreshed:
            _currentSession = session;
            print('Session token refreshed');
            break;
          default:
            break;
        }
      });
    } catch (e) {
      print('Error initializing session: $e');
      throw Exception('Session initialization failed: $e');
    }
  }
  
  Future<void> signIn(String email, String password, {bool rememberMe = false}) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        _currentSession = response.session;
        _currentUser = response.user;
        print('Sign-in successful: ${response.user?.email}');

        // Save credentials if "Remember Me" is checked
        if (rememberMe) {
          await saveCredentials(email, password);
        } else {
          await clearCredentials();
        }
      } else {
        throw Exception('Sign-in failed: Invalid credentials');
      }
    } catch (e) {
      print('Sign-in error: $e');
      throw Exception('Error during sign-in: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      _currentSession = null;
      _currentUser = null;
      print('Sign-out successful');
    } catch (e) {
      print('Sign-out error: $e');
      throw Exception('Error during sign-out: $e');
    }
  }

  Future<void> saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
    print('Credentials saved.');
  }

  Future<Map<String, String?>> loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final password = prefs.getString('password');
    return {'email': email, 'password': password};
  }

  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');
    print('Credentials cleared.');
  }
}
