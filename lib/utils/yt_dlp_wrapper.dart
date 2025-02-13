import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:julia_conversion_tool/app_config.dart';
import 'package:julia_conversion_tool/models/yt_dlp_item.dart';
import 'package:julia_conversion_tool/models/yt_dlp_params.dart';
import 'package:julia_conversion_tool/models/yt_dlp_response.dart';
import 'package:julia_conversion_tool/models/yt_dlp_video.dart';
import 'package:julia_conversion_tool/models/yt_dlp_video_status.dart';
import 'package:path_provider/path_provider.dart';

class YtDlpWrapper {
  String? ytDlp;

  final _statusProgressoController =
      StreamController<YtDlpVideoStatus>.broadcast();

  Stream<YtDlpVideoStatus> get statusProgresso =>
      _statusProgressoController.stream;

  YtDlpWrapper();

  // encontra ou cria o yt-dlp
  Future<void> _extrairYtDlp() async {
    if (ytDlp != null) return;
    try {
      final cmdYtDlp = await Process.run('yt-dlp', ['--version']);
      if (cmdYtDlp.exitCode == 0) {
        ytDlp = 'yt-dlp';
        if (kDebugMode) print("yt-dlp é nativo");
        return;
      }
    } catch (e) {
      if (kDebugMode) print("yt-dlp error: $e");
    }

    // se não existe nativamente, usar o que vem nos 'assets/yt-dlp/'
    try {
      final Directory tempDir = await getTemporaryDirectory();
      String nome = Platform.isWindows ? 'yt-dlp.exe' : 'yt-dlp';

      final String caminhoExecutavel =
          '${tempDir.path}${Platform.isWindows ? '\\' : '/'}$nome';
      ytDlp = caminhoExecutavel;

      final File arquivo = File(caminhoExecutavel);
      if (!arquivo.existsSync()) {
        final ByteData data = await rootBundle.load('assets/yt-dlp/$nome');
        await arquivo.writeAsBytes(data.buffer.asUint8List());
        if (Platform.isLinux || Platform.isMacOS) {
          await Process.run('chmod', ['+x', caminhoExecutavel]);
        }
        await Process.run(caminhoExecutavel, ['-U'], runInShell: true);
      }
    } catch (e) {
      throw StateError('Erro ao extrair yt-dlp: $e');
    }
  }

  Future<YtDlpResponse> baixarVideo(String url,
      {required YtDlpParams parametros}) async {
    try {
      await _extrairYtDlp();

      final Directory? pastaDownloads = await getDownloadsDirectory();
      String caminho = AppConfig.instance.destino.isNotEmpty
          ? AppConfig.instance.destino
          : (pastaDownloads?.path ?? './');

      String formatacaoSaida =
          '{"info":%(info.{vcodec,acodec})j,"progress":%(progress.{status,downloaded_bytes,total_bytes})j}';
      List<String> definicoes = [
        '-P',
        caminho,
        '--newline',
        '--progress-template',
        formatacaoSaida,
        '-o',
        '%(title)s.%(ext)s',
        url
      ];

      List<String> args = [
        ...parametros.configuracoes,
        ...parametros.argumentos,
        ...definicoes
      ];

      if (kDebugMode) print([ytDlp, ...args].join(' '));
      var resultado = await Process.start(ytDlp!, args);

      bool existe = false;

      resultado.stdout.listen((data) {
        final linhas = String.fromCharCodes(data).split('\n');
        for (final String linha in linhas) {
          if (linha.contains('has already been downloaded')) {
            existe = true;
            return;
          }
          if (linha.startsWith('{')) {
            dynamic json = jsonDecode(linha);
            dynamic jsonInfo = json['info'];

            VideoStatus status = YtDlpVideoStatus.getFormato(
                jsonInfo['vcodec'] as String?, jsonInfo['acodec'] as String?);

            dynamic jsonProgress = json['progress'];
            int baixado = (jsonProgress['downloaded_bytes'] as int?) ?? 0;
            int total = (jsonProgress['total_bytes'] as int?) ?? 1;
            double progresso = (baixado / total) * 100;

            _statusProgressoController.add(YtDlpVideoStatus(status, progresso));
          }
          if (linha.startsWith('[Merger]')) {
            _statusProgressoController
                .add(YtDlpVideoStatus(VideoStatus.combinando, 0));
          }
          if (linha.startsWith('[ExtractAudio]')) {
            _statusProgressoController
                .add(YtDlpVideoStatus(VideoStatus.convertendo, 0));
          }
        }
      });

      final stderrBuffer = StringBuffer();
      resultado.stderr.listen(
        (data) {
          stderrBuffer.write(String.fromCharCodes(data));
        },
      );

      if (existe) throw AlreadyExistsException();

      int exitCode = await resultado.exitCode;
      if (exitCode != 0) {
        throw Exception('Erro ao baixar o arquivo: $stderrBuffer');
      }
    } on AlreadyExistsException catch (_) {
      return YtDlpResponse(
          'Este arquivo já existe na sua máquina.', ResponseStatus.info);
    } catch (e) {
      return YtDlpResponse(e.toString(), ResponseStatus.error);
    }
    return YtDlpResponse(
        'Arquivo baixado com sucesso!', ResponseStatus.success);
  }

  Future<YtDlpResponse> listarOpcoes(String url) async {
    try {
      await _extrairYtDlp();

      String formatacaoSaida = [
        '%(.{id,title,thumbnail,channel,channel_url,timestamp,view_count})#j',
        '%(formats.:.{format_id,ext,resolution,height,filesize,filesize_approx,fps,acodec})#j'
      ].join('ytdlpsplit');

      var resultado = await Process.run(ytDlp!, ['-O', formatacaoSaida, url]);

      if (resultado.exitCode != 0) {
        throw Exception('Erro ao procurar opções: ${resultado.stderr}');
      }

      YtDlpVideo video = _transformarOpcoes(resultado.stdout, url);
      return YtDlpResponse.video('${video.items.length} opções encontradas!',
          ResponseStatus.success, video);
    } catch (e) {
      return YtDlpResponse(e.toString(), ResponseStatus.error);
    }
  }

  YtDlpVideo _transformarOpcoes(String output, String url) {
    List<String> splitJson = output.split('ytdlpsplit');

    Iterable jsonFormats = jsonDecode(splitJson.last);
    List<YtDlpItem> items =
        jsonFormats.map((j) => YtDlpItem.fromJson(j)).toList();

    final jsonVideo = jsonDecode(splitJson.first);
    // remove formatos que não são vídeo ou áudio
    YtDlpVideo video = YtDlpVideo.fromJson(
        jsonVideo, items.where((j) => j.ext != 'mhtml').toList(), url);

    return video;
  }
}
