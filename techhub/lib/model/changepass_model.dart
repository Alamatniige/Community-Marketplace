import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordModel {
  final supabase = Supabase.instance.client;

  // Verify current password
  Future<bool> verifyCurrentPassword(String email, String currentPassword) async {
    try {
      final authResponse = await supabase.auth.signInWithPassword(
        email: email,
        password: currentPassword,
      );
      
      return authResponse.user != null;
    } on AuthException catch (e) {
      print('Password verification error: ${e.message}');
      return false;
    }
  }

  // Update password
  Future<bool> updatePassword(String newPassword) async {
    try {
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return true;
    } on AuthException catch (e) {
      print('Password update error: ${e.message}');
      return false;
    }
  }

  // Send password reset email (using Supabase's resetPasswordForEmail method)
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(
        email,
      );
      return true;
    } on AuthException catch (e) {
      print('Password reset email error: ${e.message}');
      return false;
    }
  }

  // Send OTP to the email (magic link)
  Future<bool> sendOTP(String email) async {
    try {
      // You can use Supabase's magic link feature here
      await supabase.auth.signInWithOtp(
        email: email,
      );
      return true;
    } on AuthException catch (e) {
      print('Error sending OTP: ${e.message}');
      return false;
    }
  }

  // Verify OTP (similar to magic link verification)
  Future<bool> verifyOTP(String inputOtp) async {
    try {
      final response = await supabase.auth.verifyOTP(
        type: OtpType.email,
        token: inputOtp,
        email: null,
      );
      return response.user != null;
    } on AuthException catch (e) {
      print('Error verifying OTP: ${e.message}');
      return false;
    }
  }

  sendOtpToEmail(String email) {}
}
