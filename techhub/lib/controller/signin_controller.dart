import 'package:supabase_flutter/supabase_flutter.dart';

class SignInController {
  final _supabase = Supabase.instance.client;
  Session? _currentSession;
  User? _currentUser;

  // Getters for session info
  Session? get currentSession => _currentSession;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // Initialize and check for existing session
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

  Future<void> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        _currentSession = response.session;
        _currentUser = response.user;
        print('Sign-in successful: ${response.user?.email}');
      } else {
        throw Exception('Sign-in failed: Invalid credentials');
      }
    } catch (e) {
      print('Sign-in error: $e');
      throw Exception('Error during sign-in: $e');
    }
  }

Future<void> ensureUserRecord(User authUser) async {
  final supabase = Supabase.instance.client;
  
  try {
    final existingUser = await supabase
        .from('user')
        .select()
        .eq('id', authUser.id)
        .maybeSingle();  // Ensure single result
    
    if (existingUser == null) {
      // User does not exist in the database, create new record
      final response = await supabase
          .from('user')
          .insert({
            'id': authUser.id,  // Use auth ID
            'email': authUser.email,
            'fullName': '',
            'username': '',
            'contactNum': '',
          })
          .select();
      print('New user created: $response');
    } else {
      print('User already exists: ${existingUser['id']}');
    }
  } catch (error) {
    print('Error ensuring user record: $error');
    rethrow;
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

  Future<void> refreshSession() async {
    try {
      _currentSession = _supabase.auth.currentSession;
      _currentUser = _currentSession?.user;
      print('Session refreshed for user: ${_currentUser?.email}');
    } catch (e) {
      print('Session refresh error: $e');
      throw Exception('Error refreshing session: $e');
    }
  }
}
