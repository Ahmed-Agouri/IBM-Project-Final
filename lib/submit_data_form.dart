// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:uuid/uuid.dart';
// import 'dart:math';
// import 'profile.dart';
//
// class InsertDataPage extends StatefulWidget {
//   @override
//   _InsertDataPageState createState() => _InsertDataPageState();
// }
//
// class _InsertDataPageState extends State<InsertDataPage> {
//   final _formKey = GlobalKey<FormState>();
//   String _firstName = '';
//   String _lastName = '';
//   String _email = '';
//   String _job_Title = '';
//   String _Phone_Number = '';
//
//
//
//   //use a static password for now, will be updated as we go
//   String _password = 'Random1234';
//   final dbRef = FirebaseDatabase.instance.ref();
//
//   void _submitData() {
//     if(_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();
//       var uuid = Uuid();
//
//       // Users entry here
//       final userRef = dbRef.child('AppDB/Users').push();
//       final userEntry = {
//         "First_Name": _firstName,
//         "Last_Name": _lastName,
//         "User_Email": _email,
//         "User_Password": _password, //USE FIREBASE AUTH TO HANDLE PASSWORDS SECURELY
//       };
//       final userID = userRef.key; // Get the generated user ID
//       userRef.set(userEntry); // Push user entry to Users node
//
//       // Business card entry here
//       final cardEntry = {
//         "Job_Title": _job_Title,
//         "Phone_Number": _Phone_Number,
//         "User_ID": userID, // Use the generated user ID as the User_ID
//       };
//       dbRef.child('AppDB/BusinessCard').push().set(cardEntry); // Push card entry to BusinessCard node
//
//       // Get back to the previous screen after submission
//       Navigator.of(context).pop();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Insert Data'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'First Name'),
//                 onSaved: (value) {
//                   _firstName = value!;
//                 },
//                 validator: (value) {
//                   return value!.isEmpty ? 'Please enter your first name' : null;
//                 },
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Last Name'),
//                 onSaved: (value) {
//                   _lastName = value!;
//                 },
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your Last Name';
//                   }
//                   return null; // Indicates the input is valid
//                 },
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Email'),
//                 onSaved: (value) {
//                   _email = value!;
//                 },
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your email';
//                   }
//                   return null; // Indicates the input is valid
//                 },
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Job Title'),
//                 onSaved: (value) {
//                   _job_Title = value!;
//                 },
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your Job Title';
//                   }
//                   return null; // Indicates the input is valid
//                 },
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'phone number'),
//                 onSaved: (value) {
//                   _Phone_Number = value!;
//                 },
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your phone number';
//                   }
//                   return null; // Indicates the input is valid
//                 },
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 16.0),
//                 child: ElevatedButton(
//                   onPressed: _submitData,
//                   child: Text('Submit'),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
// }