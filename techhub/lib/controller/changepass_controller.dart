import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techhub/model/changepass_model.dart';

final supabase = Supabase.instance.client;

class ChangePasswordController {
  final ChangePasswordModel _model = ChangePasswordModel();
  
  // Change password logic
  Future<bool> changePassword(String email, String currentPassword, String newPassword, String confirmPassword) async {
    try {
      bool isCurrentPasswordValid = await _model.verifyCurrentPassword(email, currentPassword);
      if (!isCurrentPasswordValid) {
        throw Exception('Current password is incorrect');
      }

      bool isPasswordUpdated = await _model.updatePassword(newPassword);
      
      return isPasswordUpdated;
    } catch (e) {
      print('Password change error: $e');
      return false;
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      return await _model.sendPasswordResetEmail(email);
    } catch (e) {
      print('Error sending reset email: $e');
      return false;
    }
  }

  // Send OTP to the email
 Future<bool> sendOTP(String email) async {
  try {
    // Use Supabase's signInWithOtp method to send OTP (magic link)
    await supabase.auth.signInWithOtp(email: email);
    
    // Return true if no exceptions were thrown
    return true;
  } on AuthException catch (e) {
    // Handle any authentication errors
    print('Error sending OTP: ${e.message}');
    return false;
  } catch (e) {
    // Catch any other errors
    print('Unexpected error: $e');
    return false;
  }
}


  // Verify OTP entered by the user
  Future<bool> verifyOTP(String inputOtp) async {
    try {
      // Logic to verify OTP (e.g., using Supabase or an API)
      bool isVerified = await _model.verifyOTP(inputOtp);
      return isVerified;  // Return true if OTP is verified, false otherwise
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;  // Return false on error
    }
  }

  // Dispose resources if needed
  void dispose() {
    // Add any resource disposal logic if necessary
  }
}
