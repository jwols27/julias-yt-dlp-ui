import 'dart:io';
import 'package:flutter/foundation.dart';

class FFmpegWrapper {
  // checa se ffmpeg e ffprobe estão instalados na máquina
  static Future<(bool, bool)> verificarDependencias() async {
    bool ffmpeg = false;
    bool ffprobe = false;
    try {
      final cmdFFmpeg = await Process.run('ffmpeg', ['-version']);
      ffmpeg = cmdFFmpeg.exitCode == 0;
    } catch (e) {
      if (kDebugMode) {
        print("ffmpg error: $e");
      }
    }

    try {
      final cmdFFprobe = await Process.run('ffprobe', ['-version']);
      ffprobe = cmdFFprobe.exitCode == 0;
    } catch (e) {
      if (kDebugMode) {
        print("ffprobe error: $e");
      }
    }
    return (ffmpeg, ffprobe);
  }
}