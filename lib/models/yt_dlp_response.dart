import 'package:flutter/material.dart';
import 'package:julia_conversion_tool/models/yt_dlp_video.dart';

enum ResponseStatus { success, error, info }

class YtDlpResponse {
  String message;
  ResponseStatus status;
  YtDlpVideo? video;

  YtDlpResponse(this.message, this.status);

  YtDlpResponse.video(this.message, this.status, this.video);

  Color? get _snackbarColor {
    switch (status) {
      case ResponseStatus.success:
        return Colors.green[800];
      case ResponseStatus.error:
        return Colors.red[800];
      case ResponseStatus.info:
        return Colors.blue;
    }
  }

  SnackBar get _snackbar => SnackBar(
        backgroundColor: _snackbarColor,
        content: Text(message),
      );

  void showSnackbar(BuildContext context) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(_snackbar);
  }
}

class AlreadyExistsException implements Exception {}
