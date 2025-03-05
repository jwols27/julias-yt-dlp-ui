import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:julias_yt_dlp_ui/app_config.dart';
import 'package:julias_yt_dlp_ui/models/jexception.dart';

class FFmpegWrapper {
  // checa se ffmpeg e ffprobe estão instalados na máquina
  static Future<(bool, bool)> verificarDependencias() async {
    bool ffmpeg = false;
    bool ffprobe = false;
    try {
      final cmdFFmpeg = await Process.run('ffmpeg', ['-version']);
      ffmpeg = cmdFFmpeg.exitCode == 0;
      if (!ffmpeg) throw FFmpegException(cmdFFmpeg.stderr);
    } catch (e) {
      if (kDebugMode) {
        print("ffmpg error: $e");
      }
    }

    try {
      final cmdFFprobe = await Process.run('ffprobe', ['-version']);
      ffprobe = cmdFFprobe.exitCode == 0;
      if (!ffprobe) throw FFmpegException(cmdFFprobe.stderr);
    } catch (e) {
      if (kDebugMode) {
        print("ffprobe error: $e");
      }
    }
    AppConfig.instance.setTemDeps(ffmpeg && ffprobe);
    return (ffmpeg, ffprobe);
  }

  static void converterParaH264(String nome, String caminho) async {
    try {
      String caminhoDest = '$caminho/$nome';
      String caminhoCopia = '$caminho/output$nome';
      List<String> argsConversao = ['-i', caminhoDest, '-vcodec', 'libx264', '-acodec', 'aac', caminhoCopia];
      final cmdConversao = await Process.run('ffmpeg', argsConversao);
      if (cmdConversao.exitCode != 0) throw FFmpegException(cmdConversao.stderr);

      File input = File(caminhoDest);
      File output = File(caminhoCopia);

      if (input.existsSync()) input.deleteSync();
      if (output.existsSync()) output.renameSync(caminhoDest);
    } catch (e) {
      throw FFmpegException('Erro ao converter para H264: $e');
    }
  }
}
