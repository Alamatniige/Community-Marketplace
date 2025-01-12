import 'package:flutter/material.dart';
import 'package:techhub/controller/signup_controller.dart';
import 'package:techhub/model/user_model.dart';
import 'package:techhub/view/signin.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});

  final _controller = SignUpController();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Center(
                child: Column(
                  children: const [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.black,
                      child: Icon(
                        Icons.headset_mic,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Tech-Hub",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Sign Up Text
              Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              //Name TextField
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: UnderlineInputBorder(),
                ),
              ),
              SizedBox(height: 5),
              // Username TextField
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: UnderlineInputBorder(),
                ),
              ),
              SizedBox(height: 5),
              // Email Address TextField
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  border: UnderlineInputBorder(),
                ),
              ),
              SizedBox(height: 5),
              // Password TextField
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: UnderlineInputBorder(),
                ),
              ),
              SizedBox(height: 5),
              // Confirm Password TextField
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: UnderlineInputBorder(),
                ),
              ),
              SizedBox(height: 5),
              // Sign Up Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final fullName = _fullNameController.text.trim();
                    final username = _usernameController.text.trim();
                    final email = _emailController.text.trim();
                    final password = _passwordController.text.trim();
                    final confirmPassword = _confirmPasswordController.text.trim();

                    if (fullName.isNotEmpty &&
                        username.isNotEmpty &&
                        email.isNotEmpty &&
                        password.isNotEmpty &&
                        confirmPassword.isNotEmpty) {
                      if (password == confirmPassword) {
                        try {
                          // Call the signUp method
                          await _controller.signUp(fullName, username, email, password);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Sign-up successful!')),
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => SignInPage()),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Sign-up failed: $e')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Passwords do not match')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('All fields are required')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Sign In Text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? "),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignInPage()),
                      );
                    },
                    child: Text(
                      'Sign In',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
