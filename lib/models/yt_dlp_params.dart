import 'package:julia_conversion_tool/app_config.dart';
import 'package:julia_conversion_tool/app_constants.dart' as constants;

class YtDlpParams {
  final String? _id;
  final String? _extensao;
  final String _formato;
  final String? _resolucaoFps;

  String? _resolucao;
  String? _fps;

  YtDlpParams(this._id, this._extensao, this._formato, this._resolucaoFps) {
    if (_resolucaoFps == null || _resolucaoFps == constants.padrao) return;
    if (_resolucaoFps.contains('p')) {
      List<String> x = _resolucaoFps.split('p');
      _resolucao = x.first;
      _fps = x.last;
    } else {
      _resolucao = _resolucaoFps;
    }
  }

  bool get _parametroEscolhido => _extensao != null || _resolucao != null;

  String get _extensoesEscolhidas {
    List<String> espec = [];
    if (_extensao != null) espec.add('ext:$_extensao');
    if (_resolucao != null) espec.add('res:$_resolucao');
    if (_fps != null) espec.add('fps:$_fps');
    return espec.join(',');
  }

  String get _extensaoAudio {
    if (_resolucao == 'Somente áudio' && _extensao != null) {
      return '[ext=$_extensao]';
    }
    return '';
  }

  bool get somenteAudio =>
      _extensao == 'Melhor áudio' || _resolucao == 'Somente áudio';

  bool get _habilitarH26x =>
      AppConfig.instance.h26x &&
      !somenteAudio &&
      _formato.isEmpty &&
      _id == null &&
      (_extensao == null || constants.extensoesH264.any((e) => e == _extensao));

  bool get converterH26x => _habilitarH26x && AppConfig.instance.temDeps;

  List<String> get configuracoes {
    List<String> configs = [];
    if (!AppConfig.instance.mtime) configs.add('--no-mtime');
    if (_habilitarH26x) {
      // prioriza h265 e h264
      // se não achar nesses codecs, procura o melhor possivel
      String regex = r"(bv*[vcodec~='^((he|a)vc|h26[45])']+ba) / (bv*+ba/b)";
      configs.addAll(['-f', regex]);
    }
    return configs;
  }

  List<String> get argumentos {
    List<String> args = [];

    if (_formato.isNotEmpty) args.addAll(['-x', '--audio-format', _formato]);
    if (_id != null) return [...args, '-f', _id];
    if (somenteAudio) {
      args.addAll(['-f', 'ba$_extensaoAudio']);
      return args;
    }
    if (_parametroEscolhido) {
      args.add('-S');
      args.add(_extensoesEscolhidas);
    }
    return args;
  }
}
