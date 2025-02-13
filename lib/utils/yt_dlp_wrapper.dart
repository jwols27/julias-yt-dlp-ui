import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:julia_conversion_tool/app_config.dart';
import 'package:julia_conversion_tool/models/jexception.dart';
import 'package:julia_conversion_tool/models/yt_dlp_models.dart';
import 'package:julia_conversion_tool/utils/ffmpeg_wrapper.dart';

class YtDlpWrapper {
  String? ytDlp;

  final _statusProgressoController = StreamController<YtDlpVideoStatus>.broadcast();

  Stream<YtDlpVideoStatus> get statusProgresso => _statusProgressoController.stream;

  YtDlpWrapper();

  // encontra ou cria o yt-dlp
  Future<void> _extrairYtDlp() async {
    if (ytDlp != null) return;
    try {
      final cmdYtDlp = await Process.run('yt-dlp', ['--version']);
      if (cmdYtDlp.exitCode != 0) throw YtDlpException(cmdYtDlp.stderr);
      ytDlp = 'yt-dlp';
      return;
    } catch (e) {
      if (kDebugMode) print("erro tentando encontrar yt-dlp: $e");
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
        await Process.run(caminhoExecutavel, ['-U']);
      }
    } catch (e) {
      throw StateError('Erro ao extrair yt-dlp: $e');
    }
  }

  Future<YtDlpResponse> baixarVideo(String url, {required YtDlpParams parametros}) async {
    try {
      await _extrairYtDlp();

      String caminho = AppConfig.instance.destino;

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
      bool h26x = false;

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

            String? vcodec = jsonInfo['vcodec'] as String?;
            String? acodec = jsonInfo['acodec'] as String?;
            if (vcodec?.contains(RegExp(r'((?:he|a)vc)')) ?? false) h26x = true;

            VideoStatus status = YtDlpVideoStatus.getFormato(vcodec, acodec);

            dynamic jsonProgress = json['progress'];
            int baixado = (jsonProgress['downloaded_bytes'] as int?) ?? 0;
            int total = (jsonProgress['total_bytes'] as int?) ?? 1;
            double progresso = (baixado / total) * 100;

            _statusProgressoController.add(YtDlpVideoStatus(status, progresso));
          }
          if (linha.startsWith('[Merger]')) {
            _statusProgressoController.add(YtDlpVideoStatus(VideoStatus.combinando, 0));
          }
          if (linha.startsWith('[ExtractAudio]')) {
            _statusProgressoController.add(YtDlpVideoStatus(VideoStatus.convertendo, 0));
          }
        }
      });

      final stderrBuffer = StringBuffer();
      resultado.stderr.listen(
        (data) {
          stderrBuffer.write(String.fromCharCodes(data));
        },
      );

      int exitCode = await resultado.exitCode;
      if (exitCode != 0) throw YtDlpException('Erro ao baixar o arquivo: $stderrBuffer');
      if (existe) throw AlreadyExistsException();

      if (parametros.converterH26x && !h26x) {
        _statusProgressoController.add(YtDlpVideoStatus(VideoStatus.convertendo, 0));
        String titulo = await _getNomeArquivo(url, parametros.argumentos);
        FFmpegWrapper.converterParaH264(titulo, caminho);
      }
    } on AlreadyExistsException catch (e) {
      return YtDlpResponse(e.toString(), ResponseStatus.info);
    } catch (e) {
      return YtDlpResponse(e.toString(), ResponseStatus.error);
    }
    return YtDlpResponse('Arquivo baixado com sucesso! 😄', ResponseStatus.success);
  }

  Future<String> _getNomeArquivo(String url, List<String> argumentos) async {
    try {
      List<String> args = [
        ...argumentos,
        '--get-filename',
        '-o',
        '%(title)s.%(ext)s',
        url,
      ];
      var resultado = await Process.run(ytDlp!, args);
      String titulo = resultado.stdout;
      return titulo.trim();
    } catch (e) {
      throw YtDlpException('Erro ao obter o nome do arquivo: $e');
    }
  }

  Future<YtDlpResponse> listarOpcoes(String url) async {
    try {
      await _extrairYtDlp();

      String formatacaoSaida = [
        '{"info":%(.{id,title,thumbnail,channel,channel_url,timestamp,view_count})j',
        '"formatos":%(formats.:.{format_id,ext,resolution,height,filesize,filesize_approx,fps,acodec})j}'
      ].join(',');

      var resultado = await Process.run(ytDlp!, ['-O', formatacaoSaida, url]);

      if (resultado.exitCode != 0) {
        throw YtDlpException('Erro ao procurar opções: ${resultado.stderr}');
      }

      YtDlpVideo video = _transformarOpcoes(resultado.stdout, url);
      return YtDlpResponse.video(
          '${video.items.length} opções encontradas!', ResponseStatus.success, video);
    } catch (e) {
      return YtDlpResponse(e.toString(), ResponseStatus.error);
    }
  }

  YtDlpVideo _transformarOpcoes(String output, String url) {
    dynamic json = jsonDecode(output);
    final Iterable formatos = json['formatos'];
    final info = json['info'];

    List<YtDlpItem> items = formatos.map((j) => YtDlpItem.fromJson(j)).toList();
    // remove formatos que não são vídeo ou áudio
    YtDlpVideo video =
        YtDlpVideo.fromJson(info, items.where((j) => j.ext != 'mhtml').toList(), url);

    return video;
  }
}
