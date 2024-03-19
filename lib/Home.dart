import 'package:flutter/material.dart';
import 'main.dart';

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

  @override
  void dispose() {
    _bioController.dispose();
    _workController.dispose();
    _educationController.dispose();
    _jobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
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
                      // Here, you would include logic to update the database
                    });
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
        currentIndex: 1, // Assuming 'Profile' is the second tab
        onTap: (index) {
          if (index == 0) {
            // Navigate to the MyHomePage (QR Scanner page)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage()),
            );
          } else if (index == 2) {
            // Handle the log out logic here
            print('Log Out tapped');
            // Add your log out functionality here
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Log Out',
          ),
        ],
      ),
    );
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
