import 'package:flutter/material.dart';
import 'package:julias_yt_dlp_ui/models/yt_dlp_video.dart';
import 'package:julias_yt_dlp_ui/themes.dart';

enum ResponseStatus { success, error, info }

class YtDlpResponse {
  String message;
  ResponseStatus status;
  YtDlpVideo? video;

  YtDlpResponse(this.message, this.status);

  YtDlpResponse.video(this.message, this.status, this.video);

  Color? _snackbarColor(BuildContext context) {
    final statusColors = Theme.of(context).extension<StatusColors>()!;
    switch (status) {
      case ResponseStatus.success:
        return statusColors.positive;
      case ResponseStatus.error:
        return statusColors.negative;
      case ResponseStatus.info:
        return statusColors.info;
    }
  }

  SnackBar _snackbar(BuildContext context) => SnackBar(
        backgroundColor: _snackbarColor(context),
        content: Text(message),
      );

  void showSnackbar(BuildContext context) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(_snackbar(context));
  }
}
