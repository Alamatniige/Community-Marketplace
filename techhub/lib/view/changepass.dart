import 'package:flutter/material.dart';
import 'package:techhub/controller/changepass_controller.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final ChangePasswordController _controller = ChangePasswordController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  // Add state variables for UI control
  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _sendOtp() async {
    // Validate email before sending OTP
    if (_emailController.text.isEmpty || 
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
            .hasMatch(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      bool otpSent = await _controller.sendOTP(_emailController.text);
      if (otpSent) {
        setState(() {
          _isOtpSent = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent to your email')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send OTP')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _verifyOtp(String inputOtp) async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool isVerified = await _controller.verifyOTP(inputOtp);
      if (isVerified) {
        setState(() {
          _isOtpVerified = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP Verified Successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  } 

  void _changePassword() async {
    // Validate all fields before changing password
    if (_emailController.text.isEmpty ||
        _currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // Check if passwords match
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      bool success = await _controller.changePassword(
        _emailController.text,
        _currentPasswordController.text,
        _newPasswordController.text,
        _confirmPasswordController.text
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully')),
        );
        // Optionally navigate back or to another screen
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to change password')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Change Password', style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Update Your Password',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Email Field
              const Text(
                'Email',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Enter your email',
                  enabled: !_isOtpSent, // Disable if OTP is sent
                ),
              ),
              const SizedBox(height: 16),
              // Send OTP Button
              if (!_isOtpSent)
              Center(
                child: ElevatedButton(
                  onPressed: _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text(
                    'Send OTP',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              
              // Show remaining fields only after OTP is sent and verified
              if (_isOtpSent && _isOtpVerified) ...[
                // Current Password Field
                const Text(
                  'Current Password',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter current password',
                  ),
                ),
                const SizedBox(height: 16),
                // New Password Field
                const Text(
                  'New Password',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter new password',
                  ),
                ),
                const SizedBox(height: 16),
                // Confirm New Password Field
                const Text(
                  'Confirm New Password',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Re-enter new password',
                  ),
                ),
                const SizedBox(height: 24),
                // Change Password Button
                Center(
                  child: ElevatedButton(
                    onPressed: _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text(
                      'Change Password',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
              // Verify OTP Button
              if (_isOtpSent && !_isOtpVerified)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Show a dialog to enter the OTP
                    showDialog(
                      context: context,
                      builder: (context) {
                        final TextEditingController otpController = TextEditingController();
                        return AlertDialog(
                          title: const Text('Enter OTP'),
                          content: TextField(
                            controller: otpController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter the OTP sent to your email',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                _verifyOtp(otpController.text);
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: const Text('Verify'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text(
                    'Verify OTP',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}