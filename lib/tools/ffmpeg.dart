import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:julia_conversion_tool/classes/snackbar.dart';

class FFmpegWrapper {
  late String ffmpeg;

  FFmpegWrapper() {
    ffmpeg = 'ffmpeg';
    if (Platform.isWindows) {
      //ffmpeg = r'C:\path\to\ffmpeg.exe';
    }
  }

  Future<StatusSnackbar> converter(String entrada) async {
    final String saida = '${p.dirname(entrada)}/audio.mp3';

    var resultado = await Process.run(
      ffmpeg,
      ['-i', entrada, '-q:a', '0', '-map', 'a', saida],
    );

    if (resultado.exitCode == 0) {
      print('Arquivo convertido com sucesso! MP3 salvo em: $saida');
      return StatusSnackbar('Arquivo convertido com sucesso!', ResponseStatus.success);
    } else {
      print('Erro durante a conversão: ${resultado.stderr}');
      return StatusSnackbar('Erro durante a conversão', ResponseStatus.error);
    }
  }
}

