import 'package:flutter/material.dart';
import 'dart:math';

void showLoadingDialog(BuildContext context, String text) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissing the dialog
    builder: (BuildContext context) {
      return AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text(text),
          ],
        ),
      );
    },
  );
}

void showOKDialog(BuildContext context, String text, VoidCallback onOkPressed) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Text(text),
        actions: [
          TextButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              onOkPressed(); // Call the custom function
            },
          ),
        ],
      );
    },
  );
}

String generateRandomString(int length) {
  const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  Random random = Random();

  return List.generate(
      length, (index) => characters[random.nextInt(characters.length)])
      .join();
}