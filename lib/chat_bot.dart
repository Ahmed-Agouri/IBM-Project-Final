import 'package:flutter/material.dart';

class ConfirmationButtons extends StatelessWidget {
  final Future<Map<dynamic, dynamic>> Function() fetchCardData;

  const ConfirmationButtons({super.key, required this.fetchCardData});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          child: const Text('Yes'),
          onPressed: () async {
            Map<dynamic, dynamic>? cardData = await fetchCardData();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Card Data'),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: cardData.entries.map((entry) {
                        return Text('${entry.key}: ${entry.value}');
                      }).toList(),
                    ),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          child: const Text('No'),
          onPressed: () {
            // Close the dialog or perform any other action
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}