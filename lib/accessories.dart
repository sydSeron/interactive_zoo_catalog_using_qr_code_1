import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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

String linkToFileName(String link) {
  Uri uri = Uri.parse(link);
  String path = uri.pathSegments.last;

  String fileName = path
      .replaceAll('%3A', ':') // Replace %3A (colon)
      .replaceAll('%20', ' ') // Replace %20 (space)
      .replaceAll('%2F', '/'); // Optionally, handle other encodings

  return fileName;
}

Future<bool> isLoggedCorrectly (String username) async {
  FirebaseFirestore? firestore;

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  firestore = FirebaseFirestore.instance;

  try {
    QuerySnapshot querySnapshot = (await firestore?.collection('users')
        .where('username', isEqualTo: username)
        .get()) as QuerySnapshot<Object?>;
    if (querySnapshot == null || querySnapshot.size <= 0) {
      return false;
    }
    return true;
  } catch (e) {
    print(e);
    return false;
  }
}