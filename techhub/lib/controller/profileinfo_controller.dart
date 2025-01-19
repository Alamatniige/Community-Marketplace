import 'package:supabase_flutter/supabase_flutter.dart';
class ProfileinfoController {
  static final ProfileinfoController _instance = ProfileinfoController._internal();
  factory ProfileinfoController() => _instance;
  ProfileinfoController._internal();

  Future<void> setProfileInfo(String? userId, String name, String username, String phone) async {
    final supabase = Supabase.instance.client;

    try {
      final currentUser = supabase.auth.currentUser;
      
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }
      
      final userToUpdateId = userId ?? currentUser.id;
      print('Attempting to update user with ID: $userToUpdateId');

      final response = await supabase
          .from('user')
          .upsert({
            'id': userToUpdateId,
            'fullname': name,
            'username': username,
            'contactnum': phone,
          }, onConflict: 'id')
          .select()
          .single();

      print('Update response: $response');
      
    } catch (error) {
      print('Error during the update operation: $error');
      rethrow;
    }
  }
}