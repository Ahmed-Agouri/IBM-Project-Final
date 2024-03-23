import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'main.dart';
import 'profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Ar_view_Screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isEditing = false;
  final _bioController = TextEditingController(text: "User bio information placeholder");
  final _workController = TextEditingController(text: "Work experience information placeholder");
  final _educationController = TextEditingController(text: "Education history information placeholder");
  final _jobController = TextEditingController(text: "Current job information placeholder");
  String _fullName = 'User';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _workController.dispose();
    _educationController.dispose();
    _jobController.dispose();
    super.dispose();
  }

  void _fetchUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;
      final userRef = FirebaseDatabase.instance.ref().child('AppDB/BusinessCard/$uid');
      final snapshot = await userRef.get();

      if (snapshot.exists) {
        final userData = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _bioController.text = userData['bio'] ?? 'No bio information';
          _workController.text = userData['jobHistory'] ?? 'No work experience information';
          _educationController.text = userData['educationHistory'] ?? 'No education history information';
          _jobController.text = userData['currentJob'] ?? 'No current job information';
          _fullName = userData['fullName'] ?? 'User';
        });
      } else {
        print('User data not found.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // This will pop the current route off the navigation stack
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              'Hi, User!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            if (!_isEditing)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  child: Text('EDIT PROFILE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Set the button color to blue
                    shape: StadiumBorder(),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                ),
              ),
            if (_isEditing)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                    });
                    _updateUserData();
                  },
                  child: Text('CONFIRM CHANGES'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Confirm button in green
                    shape: StadiumBorder(),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                ),
              ),
            SizedBox(height: 20),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildEditableTextSection('Brief Bio', _bioController),
                  SizedBox(height: 20),
                  buildEditableTextSection('Work Experience', _workController),
                  SizedBox(height: 20),
                  buildEditableTextSection('Education History', _educationController),
                  SizedBox(height: 20),
                  buildEditableTextSection('Current Job', _jobController),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Assuming 'Profile' is still the second tab
        onTap: (index) {
          switch (index) {
            case 0:
            // Navigate to MyHomePage (QR Scanner page)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LocalAndWebObjectsWidget()),
              );
            // Already on Profile page
              break;
            case 2:
            // Log Out logic here

              // Implement your log out functionality
              break;
            case 3:
            // Navigate to AR View
              print('Log Out tapped');

              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Scan QR Code',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_rounded),
            label: 'Ar Enviroment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _updateUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;
      final userRef = FirebaseDatabase.instance.ref().child('AppDB/BusinessCard/$uid');
      final snapshot = await userRef.get();



      // Create a map of the data to update
      if (snapshot.exists) {
        final Map<String, dynamic> updates = {};
        updates['bio'] = _bioController.text;
        updates['jobHistory'] = _workController.text;
        updates['educationHistory'] = _educationController.text;
        updates['currentJob'] = _jobController.text;
        // Perform the update operation
        await userRef.update(updates).then((_) {
          print('User data updated successfully.');
        }).catchError((error) {
          // Handle any errors that occur during the update
          print('Error updating user data: $error');
        });
      } else{print('User data not found.');}
    }
  }

  Widget buildEditableTextSection(String title, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        _isEditing
            ? TextField(
          controller: controller,
          style: TextStyle(fontSize: 16),
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            isDense: true, // Added for less aggressive expansion
          ),
          maxLines: null, // Allow multiline entry
        )
            : Text(
          controller.text,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
