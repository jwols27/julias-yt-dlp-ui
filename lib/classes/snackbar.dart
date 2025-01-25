import 'package:flutter/material.dart';

enum ResponseStatus {
  success, error, info
}

class StatusSnackbar {
  String message;
  ResponseStatus status;

  StatusSnackbar(this.message, this.status);

  void showSnackbar(BuildContext context) {
    Color? color;
    switch(status) {
      case ResponseStatus.success: color = Theme.of(context).primaryColor; break;
      case ResponseStatus.error: color = Colors.red[800]; break;
      case ResponseStatus.info: color = Colors.blue; break;
    }
    SnackBar snackBar = SnackBar(
      backgroundColor: color,
      content: Text(message),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

