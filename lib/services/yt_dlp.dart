import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:julia_conversion_tool/app_config.dart';
import 'package:julia_conversion_tool/classes/status_snackbar.dart';
import 'package:julia_conversion_tool/classes/yt_dlp_item.dart';
import 'package:julia_conversion_tool/classes/yt_dlp_video.dart';
import 'package:path_provider/path_provider.dart';

interface class YtDlpParameters {
  String? ext;
  String? resolution;
  bool? bestAudio;
  String? format;
  String? id;
  String? fps;

  YtDlpParameters(
      {this.ext,
      this.resolution,
      this.bestAudio,
      this.format,
      this.id,
      this.fps});

  bool get padrao {
    return ext == null &&
        resolution == null &&
        bestAudio == null &&
        id == null &&
        fps == null &&
        format == null;
  }

  List<String> get configuracoes {
    List<String> configs = [];
    if (!AppConfig.instance.mtime) configs.add('--no-mtime');
    return configs;
  }

  List<String> get argumentos {
    List<String> args = configuracoes;
    if (padrao) return args;
    if (format != null) args.addAll(['-x', '--audio-format', format!]);
    if (id != null) return [...args, '-f', id!];
    if (bestAudio == true) {
      bool exten = resolution == 'Somente áudio' && ext != null;
      args.addAll(['-f', 'ba${exten ? '[ext:$ext]' : ''}']);
      return args;
    }
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

  final _progressStreamController = StreamController<double>.broadcast();

  Stream<double> get progressStream => _progressStreamController.stream;

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
      String caminho = AppConfig.instance.destino.isNotEmpty
          ? AppConfig.instance.destino
          : (pastaDownloads?.path ?? './');

      List<String> argumentos = parametros.argumentos;

      argumentos.addAll([
        '-P',
        caminho,
        '--newline',
        '--progress-template',
        'download:[download] %(progress._percent_str)s',
        '-o',
        '%(title)s.%(ext)s',
        url
      ]);

      if (kDebugMode) print([ytDlp, ...argumentos].join(' '));
      var resultado = await Process.start(ytDlp, argumentos);

      bool existe = false;
      resultado.stdout.transform(utf8.decoder).listen((data) {
        final lines = data.split('\n');
        for (final line in lines) {
          if (line.startsWith('[download]') && !existe) {
            final progresso = line.split(' ').last.replaceAll('%', '');
            final numero = double.tryParse(progresso) ?? 0.0;
            if (line.contains('has already been downloaded')) {
              existe = true;
            }
            _progressStreamController.add(numero);
          }
        }
      });

      final stderrBuffer = StringBuffer();
      resultado.stderr.transform(utf8.decoder).listen(
        (data) {
          stderrBuffer.write(data);
        },
      );

      int exitCode = await resultado.exitCode;

      if (exitCode == 0) {
        if (existe) {
          return StatusSnackbar(
              'Este arquivo já existe na sua máquina.', ResponseStatus.info);
        } else {
          return StatusSnackbar(
              'Arquivo baixado com sucesso!', ResponseStatus.success);
        }
      } else {
        return StatusSnackbar(
            'Erro ao baixar o arquivo: $stderrBuffer', ResponseStatus.error);
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
        '%(.{title,thumbnail,channel,channel_url,timestamp,view_count})#jytdlpsplit%(formats.:.{format_id,ext,resolution,height,filesize,filesize_approx,fps})#j',
        url
      ]);

      if (resultado.exitCode == 0) {
        video = transformarOpcoes(resultado.stdout, url);
        return (
          video,
          StatusSnackbar('${video.items.length} opções encontradas!',
              ResponseStatus.success)
        );
      } else {
        return (
          video,
          StatusSnackbar('Erro ao procurar opções: ${resultado.stderr}',
              ResponseStatus.error)
        );
      }
    } catch (e) {
      return (video, StatusSnackbar('Erro: $e}', ResponseStatus.error));
    }
  }

  YtDlpVideo transformarOpcoes(String output, String url) {
    List<String> splitJson = output.split('ytdlpsplit');

    Iterable jsonFormats = jsonDecode(splitJson.last);
    List<YtDlpItem> items =
        jsonFormats.map((j) => YtDlpItem.fromJson(j)).toList();

    final jsonVideo = jsonDecode(splitJson.first);
    YtDlpVideo video = YtDlpVideo.fromJson(
        jsonVideo, items.where((j) => j.ext != 'mhtml').toList(), url);

    return video;
  }

  Future<(bool, bool)> verificarDependencias() async {
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
