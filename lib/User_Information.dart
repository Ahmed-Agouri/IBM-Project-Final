import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/Home.dart';

class BusinessCardPage extends StatefulWidget {
  @override
  _BusinessCardPageState createState() => _BusinessCardPageState();
}

class _BusinessCardPageState extends State<BusinessCardPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _currentJobController = TextEditingController();
  final TextEditingController _educationHistoryController = TextEditingController();
  final TextEditingController _jobHistoryController = TextEditingController();
  final TextEditingController _linkedinLinkController = TextEditingController();

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _saveBusinessCard() async {
    // Ensure the form is valid before proceeding
    if (_formKey.currentState!.validate()) {
      final User? user = _auth.currentUser;
      final uid = user?.uid; // Ensure you handle null (user not logged in scenario)

      if (uid != null) {
        await _dbRef.child('AppDB/BusinessCard/$uid').set({
          'bio': _bioController.text,
          'currentJob': _currentJobController.text,
          'educationHistory': _educationHistoryController.text,
          'jobHistory': _jobHistoryController.text,
          'linkedinLink': _linkedinLinkController.text,
        });

        // Handle success (e.g., show a success message or navigate to another page)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        // Handle user not logged in scenario
        print("User is not logged in.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Business Card Details'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _bioController,
                  decoration: InputDecoration(labelText: 'Bio', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Please enter your bio' : null,
                ),
                SizedBox(height: 10), // Adds space between fields
                TextFormField(
                  controller: _currentJobController,
                  decoration: InputDecoration(labelText: 'Current Job', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Please enter your current job' : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _educationHistoryController,
                  decoration: InputDecoration(labelText: 'Education History', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Please enter your education history' : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _jobHistoryController,
                  decoration: InputDecoration(labelText: 'Job History', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Please enter your job history' : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _linkedinLinkController,
                  decoration: InputDecoration(labelText: 'LinkedIn Link', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Please enter your LinkedIn link' : null,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.blue, // Text Color (Foreground color)
                  ),
                  onPressed: _saveBusinessCard,
                  child: Text('Save Business Card'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
