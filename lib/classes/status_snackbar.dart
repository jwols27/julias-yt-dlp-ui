import 'package:flutter/material.dart';

enum ResponseStatus {
  success, error, info
}

class StatusSnackbar {
  String message;
  ResponseStatus status;

  StatusSnackbar(this.message, this.status);

  Color? get snackbarColor {
    switch(status) {
      case ResponseStatus.success: return Colors.green[800];
      case ResponseStatus.error: return Colors.red[800];
      case ResponseStatus.info: return Colors.blue;
    }
  }

  void showSnackbar(BuildContext context) {
    SnackBar snackBar = SnackBar(
      backgroundColor: snackbarColor,
      content: Text(message),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

