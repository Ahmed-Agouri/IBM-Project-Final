import 'package:flutter/material.dart';
import 'card.dart';
import 'main.dart';
import 'package:audioplayers/audioplayers.dart';

class ConfirmationButtons extends StatefulWidget {
  final Future<Map<dynamic, dynamic>> Function() fetchCardData;
  final AudioPlayer player = AudioPlayer();

  ConfirmationButtons({super.key, required this.fetchCardData});

  @override
  _ConfirmationButtonsState createState() => _ConfirmationButtonsState();
}

class _ConfirmationButtonsState extends State<ConfirmationButtons> {
  final List<String> fieldOrder = [
    'bio',
    'workExperience',
    'educationHistory',
    'currentJob'
  ];
  String currentField = 'bio';

  Future<void> playAudioForUser(String id, String field) async {
    BusinessCard? card = await getBusinessCardById(id);
    if (card != null) {
      String audioFileUrl;
      switch (field) {
        case 'bio':
          audioFileUrl = card.bio;
          break;
        case 'workExperience':
          audioFileUrl = card.workExperience;
          break;
        case 'educationHistory':
          audioFileUrl = card.educationHistory;
          break;
        case 'currentJob':
          audioFileUrl = card.currentJob;
          break;
        default:
          throw Exception('Invalid field: $field');
      }
      int result = widget.player.play(audioFileUrl as Source) as int;
      if (result == 1) {
        // success
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const SizedBox(width: 20),
        ElevatedButton(
          child: const Text('Read'),
          onPressed: () async {
            Map<dynamic, dynamic>? cardData = await widget.fetchCardData();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return AlertDialog(
                      title: const Text('Card Data'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            DropdownButton<String>(
                              value: currentField,
                              onChanged: (String? newValue) {
                                setState(() {
                                  currentField = newValue!;
                                });
                              },
                              items: fieldOrder.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                            Text('${currentField}: ${cardData[currentField] ?? "No information provided"}'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Read aloud'),
                          onPressed: () async {
                            String cardDataString;
                            if (cardData[currentField] == null || cardData[currentField] == '') {
                              cardDataString = 'No information provided for $currentField.';
                            } else {
                              cardDataString = '${currentField}: ${cardData[currentField]}';
                            }
                            String audioFileUrl = await getWatsonTtsAndUpload(cardDataString) as String;
                            int result = await widget.player.play(audioFileUrl as Source) as int;
                            if (result == 1) {
                              // success
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}