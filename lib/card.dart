import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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

  BusinessCard(
      {required this.bio,
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

  factory BusinessCard.fromMap(Map<dynamic, dynamic> cardData) {
    return BusinessCard(
      bio: cardData['bio'] as String,
      workExperience: cardData['workExperience'] as String,
      educationHistory: cardData['educationHistory'] as String,
      currentJob: cardData['currentJob'] as String,
    );
  }
}

Future<List<BusinessCard>> getAllBusinessCards() async {
  try {
    final ref = FirebaseDatabase.instance.ref('BusinessCards');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      final List<BusinessCard> cards = [];
      for (final key in data.keys) {
        final cardData = data[key] as Map<dynamic, dynamic>;
        cards
            .add(BusinessCard.fromMap(cardData));
      }
      return cards;
    } else {
      return [];
    }
  } catch (e) {
    print('Error getting all business cards: $e');
    return [];
  }
}

Future<BusinessCard?> getBusinessCardById(String id) async {
  try {
    final ref = FirebaseDatabase.instance.ref('BusinessCards/$id');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      return BusinessCard.fromMap(data);
    } else {
      return null;
    }
  } catch (e) {
    print('Error getting business card by id: $e');
    return null;
  }
}
