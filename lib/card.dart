import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class BusinessCard {
  String bio;
  String workExperience;
  String educationHistory;
  String currentJob;

  BusinessCard({required this.bio,
    required this.workExperience,
    required this.educationHistory,
    required this.currentJob});

  Map<String, dynamic> toMap() {
    return {
      'bio': bio,
      'workExperience': workExperience,
      'educationHistory': educationHistory,
      'currentJob': currentJob,
    };
  }
}

Future<void> createAndAddBusinessCard(String bio, String workExperience, String educationHistory, String currentJob) async {
  final ref = FirebaseDatabase.instance.ref('BusinessCards');
  BusinessCard card = BusinessCard(
    bio: bio,
    workExperience: workExperience,
    educationHistory: educationHistory,
    currentJob: currentJob,
  );
  await ref.push().set(card.toMap());

  // Create a Watson file after the business card is added to the database
  String cardDetails = 'Bio: $bio, Work Experience: $workExperience, Education History: $educationHistory, Current Job: $currentJob';
  await callWatsonTextToSpeechAndUploadToFirebase(cardDetails);
}

Future<List<BusinessCard>> getAllBusinessCards() async {
  final ref = FirebaseDatabase.instance.ref('BusinessCards');
  final snapshot = await ref.get();

  if (snapshot.exists) {
    final data = snapshot.value as Map<dynamic, dynamic>;
    final List<BusinessCard> cards = [];
    for (final key in data.keys) {
      final cardData = data[key] as Map<dynamic, dynamic>;
      cards.add(BusinessCard(
        bio: cardData['bio'] as String,
        workExperience: cardData['workExperience'] as String,
        educationHistory: cardData['educationHistory'] as String,
        currentJob: cardData['currentJob'] as String,
      ));
    }
    return cards;
  } else {
    return [];
  }
}

Future<BusinessCard?> getBusinessCardById(String id) async {
  final ref = FirebaseDatabase.instance.ref('BusinessCards/$id');
  final snapshot = await ref.get();

  if (snapshot.exists) {
    final data = snapshot.value as Map<dynamic, dynamic>;
    return BusinessCard(
      bio: data['bio'] as String,
      workExperience: data['workExperience'] as String,
      educationHistory: data['educationHistory'] as String,
      currentJob: data['currentJob'] as String,
    );
  } else {
    return null;
  }
}

Future<void> updateBusinessCard(String id, BusinessCard updatedCard) async {
  final ref = FirebaseDatabase.instance.ref('BusinessCards/$id');
  await ref.update(updatedCard.toMap());
}

Future<void> deleteBusinessCard(String id) async {
  final ref = FirebaseDatabase.instance.ref('BusinessCards/$id');
  await ref.remove();
}