import 'package:flutter/material.dart';
import 'package:techhub/view/address.dart';
import 'package:techhub/view/changeemail.dart';
import 'package:techhub/view/changepass.dart';
import 'package:techhub/view/personalinfo.dart';
import 'package:techhub/view/sellitem.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, // Set background color of the app bar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Go back when the back button is pressed
          },
        ),
        title: const Text('Tech Hub', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Section
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Person Name',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            // List Items (Personal Information, Address, Password)
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: const Text('Personal Information'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PersonalInfoPage()));
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Address Info'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddressInfoPage()),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Change Password'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordPage()));
                      },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Change Email Address'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangeEmailAddressPage()));
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Sell an Item'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
Navigator.push(context, MaterialPageRoute(builder: (context) => const SellPage()));
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Sign Out'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Handle onTap if needed
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
