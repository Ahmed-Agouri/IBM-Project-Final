//modified the entire starter template, just as a heads-up
//new structure with the latest updates can be found below:

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:untitled/submit_data_form.dart';
import 'chat_bot.dart';
import 'qr_scanner_overlay.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'generate_qr_screen.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import 'profile.dart';
import 'ar_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          databaseURL: 'https://ibm-group-c-default-rtdb.europe-west1.firebasedatabase.app/',
          apiKey: 'AIzaSyCZle2D58-dsDmpA26KkNOvU08cU-iV7S4',
          appId: '1:191934931736:android:759aef3382482a206b346d',
          messagingSenderId: '191934931736',
          projectId: 'ibm-group-c',
          storageBucket: 'ibm-group-c.appspot.com')
  );
  runApp(const MyApp());
}


//function that makes an API request to the IBM Watson API;
//wrote at a global level throughout the main.dart file to be easier to call
Future<String?> callWatsonTextToSpeechAndUploadToFirebase(String text) async {
  final String apiUrl = "https://api.au-syd.text-to-speech.watson.cloud.ibm.com/instances/6eb0c481-1029-4b17-82ec-e9b06c0a7852/v1/synthesize";
  final String apiKey = "C08t-Tj-IlPwIpzbYQZSyXYH4qNIzjiz3LXfdEODOQNO";

  try {
    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Basic ${base64Encode(utf8.encode("apikey:$apiKey"))}",
      },
      body: jsonEncode({"text": text, "accept": "audio/wav", "voice": "en-US_AllisonV3Voice"}),
    );

    //DO NOT DELETE THESE COMMANDS!!!!
    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body.substring(0, 100)}");

    if (response.statusCode == 200) {
      String fileName = 'WatsonTTS/${Uuid().v4()}.wav';
      Reference ref = FirebaseStorage.instance.ref().child(fileName);

      SettableMetadata metadata = SettableMetadata(contentType: 'audio/wav');
      await ref.putData(response.bodyBytes, metadata);

      String downloadURL = await ref.getDownloadURL();
      print("Uploaded audio URL: $downloadURL");
      return downloadURL;
      // final audioPlayer = AudioPlayer();
      // await audioPlayer.play(BytesSource(response.bodyBytes));
    } else {
      print("Failed to call Watson TTS: ${response.body}");
      return null;
    }
  } catch (e) {
    print("Error calling Watson TTS: $e");
    return null;
  }
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'flutter',
      home: MyHomePage(),
    );
  }
}

// Future<File> saveAudioToTempFile(Uint8List audioBytes) async {
//   final tempDir = await getTemporaryDirectory();
//   final tempFile = File('${tempDir.path}/watsonTtsAudio.mp3');
//   await tempFile.writeAsBytes(audioBytes);
//   return tempFile;
// }
//
// Future<String> uploadAudioToFirebaseStorage(File audioFile) async {
//   final storageRef = FirebaseStorage.instance.ref('WatsonTTS/${DateTime.now().millisecondsSinceEpoch}.mp3');
//
//   try {
//     await storageRef.putFile(audioFile);
//     final String downloadUrl = await storageRef.getDownloadURL();
//     return downloadUrl;
//   } catch (e) {
//     print(e);
//     return '';
//   }
// }

// Future<void> playAudioFromBytes(Uint8List audioBytes) async {
//   final tempDir = await getTemporaryDirectory();
//   final file = File('${tempDir.path}/watson-tts-audio.wav');
//
//   await file.writeAsBytes(audioBytes);
//
//   final audioPlayer = AudioPlayer();
//   await audioPlayer.play(DeviceFileSource(file.path));
// }


// Future<void> getWatsonTtsAndUpload(String text) async {
//   // Assume this function calls Watson TTS and returns audio bytes
//   Uint8List audioBytes = await callWatsonTextToSpeechAndPlay(text);
//
//   // Save the audio bytes to a temporary file
//   File audioFile = await saveAudioToTempFile(audioBytes);
//
//   // Upload the audio file to Firebase Storage and get the URL
//   String downloadUrl = await uploadAudioToFirebaseStorage(audioFile);
//
//   print("Uploaded audio URL: $downloadUrl");
//
//   // Optionally, save this URL to Firebase Realtime Database
//   // await saveAudioUrlToDatabase(downloadUrl);
// }

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String>? cardData = [];
  MobileScannerController cameraController = MobileScannerController();
  String? userID;

  @override
  void initState() {
    super.initState();
    fetchCardData();
  }

  Future<Map<dynamic, dynamic>> fetchCardData([String? rawValue]) async {
    List<String>? card = await QueryFunctions.getCardData(userID);
    Map<dynamic, dynamic> cardMap = {};
    if (card != null) {
      for (var entry in card) {
        var splitEntry = entry.split(':');
        if (splitEntry.length == 2) {
          cardMap[splitEntry[0].trim()] = splitEntry[1].trim();
        }
      }
    }
    setState(() {
      cardData = card;
    });
    return cardMap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QRScanner'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GenerateQRScreen()),
              );
            },
            icon: const Icon(Icons.qr_code),
          ),
          IconButton(
            onPressed: () {
              cameraController.switchCamera();
            },
            icon: const Icon(Icons.camera_rear_outlined),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            allowDuplicates: false,
            controller: cameraController,
            onDetect: (barcode, args) async {
              final String? barcodeValue = barcode.rawValue;
              await fetchCardData(barcode.rawValue);
              debugPrint('Barcode Found! $barcodeValue !');
              print("cardData after scan: $cardData");


              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ArScreen()),
              );
            }

            ,
          ),
          QRScannerOverlay(overlayColour: Colors.black.withOpacity(0.5)),
          ConfirmationButtons(fetchCardData: fetchCardData),
        ],
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Positioned(
            right: 30,
            bottom: 80,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InsertDataPage()),
                );
              },
              child: const Icon(Icons.add),
            ),
          ),
          Positioned(
            left: 30,
            bottom: 80,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RelTimeData()),
                );
              },
              child: const Icon(Icons.data_object),
            ),
          ),
        ],
      ),
    );
  }
}



class RelTimeData extends StatelessWidget {
  RelTimeData({super.key});
  // Adjusted reference to include 'AppDB/Users'
  final ref = FirebaseDatabase.instance.ref('AppDB/Users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Real time database"),
      ),
      body: Column(
        children: [
          Expanded(
              child: FirebaseAnimatedList(
                  query: ref,
                  itemBuilder: (context, snapshot, animation, index) {
                    // Assuming 'User_Email' and 'Last_Name' are direct children of each user node
                    return Card(
                      color: Colors.white10,
                      child: ListTile(
                        title: Text(snapshot.child('First_Name').value.toString()),
                        subtitle: Text(snapshot.child('Last_Name').value.toString()),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min, // This is needed to keep the Row tight around its children
                          children: [
                            Text(snapshot.child('User_Email').value.toString()), // Assuming you still want to display this here
                            IconButton(
                              icon: const Icon(Icons.volume_up),
                              onPressed: () async {
                                // final tts = FlutterTts();
                                String userDetail = " ${snapshot.child('First_Name').value},  ${snapshot.child('Last_Name').value}, and my email address is: ${snapshot.child('User_Email').value}";
                                await callWatsonTextToSpeechAndUploadToFirebase(userDetail);
                                // await tts.setLanguage("en-UK");
                                // await tts.setPitch(1);
                                // await tts.speak(userDetail);
                                // Here, instead of just speaking, you'd also generate and upload the audio file, see Step 3.
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }
              )
          ),
        ],
      ),
    );
  }
}



//write 2 functions
//1. Function that returns the User ID
//2. A function that takes the user ID and prints out to the screen the business card


//1. push test data onto the database, using the push() function so that it generates a new UUID
// - wanna push a User, a Business Card, and a Profile
//2. once we figure out how to access a record by its UUID