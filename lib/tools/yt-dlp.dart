import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'package:julia_conversion_tool/classes/opcaoYoutube.dart';
import 'package:julia_conversion_tool/classes/snackbar.dart';


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
      print('Erro ao extrair binário - yt-dlp: $e');
    }
  }

  Future<StatusSnackbar> baixarVideo(String url) async {
    try {
      await _extrairBinario();

      final Directory? pastaDownloads = await getDownloadsDirectory();
      String caminho = pastaDownloads == null ? '' : '${pastaDownloads.path}/';

      List<String> argumentos = ['-o', '$caminho%(title)s.%(ext)s', url];

      var resultado = await Process.run(ytDlp, argumentos);

      if (resultado.exitCode == 0) {
        transformarOpcoes(resultado.stdout);

        return StatusSnackbar('Vídeo baixado com sucesso!', ResponseStatus.success);
      } else {
        print('Erro ao baixar: ${resultado.stderr}');
        return StatusSnackbar('Erro ao baixar o vídeo', ResponseStatus.error);
      }
    } catch (e) {
      print('Erro: $e');
      return StatusSnackbar(e.toString(), ResponseStatus.error);
    }
  }

  Future<(List<OpcaoYoutube>, StatusSnackbar)> listarOpcoes(String url) async {
    List<OpcaoYoutube> lista = [];
    try {
      await _extrairBinario();

      var resultado = await Process.run(ytDlp, ['-F', url]);

      if (resultado.exitCode == 0) {
        lista.addAll(transformarOpcoes(resultado.stdout));
        return (lista, StatusSnackbar('${lista.length} opções encontradas!', ResponseStatus.success));
      } else {
        print('Erro: ${resultado.stderr}');
        return (lista, StatusSnackbar('Erro ao procurar opções', ResponseStatus.error));
      }
    } catch (e) {
      print('Error: $e');
      return (lista, StatusSnackbar('Erro', ResponseStatus.error));
    }
  }

  List<OpcaoYoutube> transformarOpcoes(String output) {
    List<String> lines = output.split('\n');
    List<OpcaoYoutube> opcoes = [];

    bool inicio = false;
    for (var line in lines) {
      if (!inicio) {
        inicio = line.startsWith('ID');
        continue;
      }

      RegExp regex = RegExp(r'(\S+)\s+(\S+)\s+(audio only|\S+)');
      var match = regex.firstMatch(line);

      if (match != null) {
        String id = match.group(1)!;
        String ext = match.group(2)!;
        String resolution = match.group(3)!;

        opcoes.add(OpcaoYoutube(id, ext, resolution));
      }
    }
    return opcoes;
  }
}

// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.


























