// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
//
//
//
// class User {
//
//   //object properties
//   final String firstName;
//   final String lastName;
//   final String userEmail;
//
//   //object constructor here
//   User(
//       {required this.firstName,
//       required this.lastName,
//       required this.userEmail});
//
//
//   //map the data for the object and retrieve it then from the database down here
//   factory User.fromMap(Map<dynamic, dynamic> data) {
//     return User(
//         firstName: data['First_Name'] ?? '',
//         lastName: data['Last_Name'] ?? '',
//         userEmail: data['User_Email'] ?? ''
//     );
//   }
//
//
//
//
// }