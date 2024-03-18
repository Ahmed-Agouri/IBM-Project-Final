import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_passwordController.text == _confirmPasswordController.text) {
        try {
          // Sign up user with Firebase Authentication
          final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );

          // Store additional user details in Firebase Realtime Database under the existing Users table
          final uid = userCredential.user!.uid; // Get the unique user ID
          await _dbRef.child('AppDB/Users/$uid').set({ // Adjusted the path to directly store under Users/UID
            'firstName': _firstNameController.text,
            'lastName': _lastNameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
          });

          // Optional: Navigate to a new page or show a success message
          Navigator.of(context).pop(); // Or navigate to another page
          print("User registered and data saved successfully");
        } catch (e) {
          print("Error during sign up or data saving: $e"); // Enhanced error logging
        }
      } else {
        print('Passwords do not match.'); // Handle password mismatch
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(labelText: 'First Name', border: OutlineInputBorder()),
                    validator: (value) => value!.isEmpty ? 'Please enter your first name' : null,
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()),
                    validator: (value) => value!.isEmpty ? 'Please enter your last name' : null,
                  ),
                  SizedBox(height: 16.0),
                  // The rest of the TextFormField widgets remain unchanged
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value!.isEmpty || !value.contains('@') ? 'Enter a valid email' : null,
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                    obscureText: true,
                    validator: (value) => value!.length < 6 ? 'Password must be at least 6 characters' : null,
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(labelText: 'Confirm Password', border: OutlineInputBorder()),
                    obscureText: true,
                    validator: (value) => value != _passwordController.text ? 'Passwords do not match' : null,
                  ),
                  SizedBox(height: 24.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: Size(double.infinity, 50)),
                    onPressed: _signUp,
                    child: Text('Sign Up', style: TextStyle(fontSize: 16.0)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
