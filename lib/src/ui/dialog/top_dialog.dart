import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TopDialog {
  static void errorMessage(BuildContext context, String message) async {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          content: Text(message),
        );
      },
    );
  }
}
