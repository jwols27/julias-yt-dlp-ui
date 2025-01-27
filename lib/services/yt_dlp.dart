import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:julia_conversion_tool/classes/yt_dlp_item.dart';
import 'package:julia_conversion_tool/classes/yt_dlp_video.dart';
import 'package:path_provider/path_provider.dart';

import 'package:julia_conversion_tool/classes/status_snackbar.dart';

interface class YtDlpParameters {
  String? ext;
  String? resolution;
  bool? bestAudio;
  String? format;
  String? id;
  String? fps;

  YtDlpParameters(
      {this.ext, this.resolution, this.bestAudio, this.format, this.id, this.fps});

  bool get padrao {
    return ext == null &&
        resolution == null &&
        bestAudio == null &&
        id == null && fps == null && format == null;
  }

  List<String> get argumentos {
    List<String> args = [];
    if (padrao) return args;

    if (format != null) args.addAll(['-x', '--audio-format', format!]);
    if (bestAudio == true) {
      bool exten = resolution == 'Somente áudio' && ext != null;
      return ['-f', 'ba${exten ? '[ext:$ext]' : ''}'];
    }
    if (id != null) return ['-f', id!];
    if (ext != null || resolution != null) {
      args.add('-S');
      List<String> espec = [];
      if (ext != null) espec.add('ext:$ext');
      if (resolution != null) espec.add('res:$resolution');
      if (fps != null) espec.add('fps:$fps');
      args.add(espec.join(','));
    }
    return args;
  }
}

class YtDlpWrapper {
  late String ytDlp;

  YtDlpWrapper();

  Future<void> _extrairBinario() async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      String nome = 'yt-dlp${Platform.isWindows ? '.exe' : ''}';

      ytDlp = '${tempDir.path}/$nome';

      final File arquivo = File(ytDlp);
      if (!arquivo.existsSync()) {
        final ByteData data = await rootBundle.load('assets/yt-dlp/$nome');
        await arquivo.writeAsBytes(data.buffer.asUint8List());
        if (Platform.isLinux || Platform.isMacOS) {
          await Process.run('chmod', ['+x', ytDlp]);
        }
      }
    } catch (e) {
      throw StateError('Erro ao extrair binário - yt-dlp: $e');
    }
  }

  Future<StatusSnackbar> baixarVideo(String url,
      {required YtDlpParameters parametros}) async {
    try {
      await _extrairBinario();

      final Directory? pastaDownloads = await getDownloadsDirectory();
      String caminho = pastaDownloads == null ? '' : '${pastaDownloads.path}/';

      List<String> argumentos = parametros.argumentos;

      argumentos.addAll(['-P', caminho, '-o', '%(title)s.%(ext)s', url]);

      //print([ytDlp, ...argumentos].join(' '));
      var resultado = await Process.run(ytDlp, argumentos);

      if (resultado.exitCode == 0) {
        return StatusSnackbar(
            'Vídeo baixado com sucesso!', ResponseStatus.success);
      } else {
        return StatusSnackbar('Erro ao baixar o vídeo: ${resultado.stderr}', ResponseStatus.error);
      }
    } catch (e) {
      return StatusSnackbar(e.toString(), ResponseStatus.error);
    }
  }

  Future<(YtDlpVideo?, StatusSnackbar)> listarOpcoes(String url) async {
    YtDlpVideo? video;
    try {
      await _extrairBinario();

      var resultado = await Process.run(ytDlp, [
        '-O',
        '%(.{title,thumbnail,channel,channel_url,timestamp,view_count})#jytdplsplit%(formats.:.{format_id,ext,resolution,height,filesize,filesize_approx,fps})#j',
        url
      ]);

      if (resultado.exitCode == 0) {
        video = transformarOpcoes(resultado.stdout, url);
        return (
          video,
          StatusSnackbar(
              '${video.items.length} opções encontradas!', ResponseStatus.success)
        );
      } else {
        return (
          video,
          StatusSnackbar('Erro ao procurar opções: ${resultado.stderr}', ResponseStatus.error)
        );
      }
    } catch (e) {
      return (video, StatusSnackbar('Erro: $e}', ResponseStatus.error));
    }
  }

  YtDlpVideo transformarOpcoes(String output, String url) {
    List<String> splitJson = output.split('ytdplsplit');

    Iterable jsonFormats = jsonDecode(splitJson.last);
    List<YtDlpItem> items = jsonFormats.map((j) => YtDlpItem.fromJson(j)).toList();

    final jsonVideo = jsonDecode(splitJson.first);
    YtDlpVideo video = YtDlpVideo.fromJson(jsonVideo, items.where((j) => j.ext != 'mhtml').toList(), url);

    return video;
  }

  Future<(bool, bool)> verificarDependencias() async {
    bool ffmpeg = false; bool ffprobe = false;
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
