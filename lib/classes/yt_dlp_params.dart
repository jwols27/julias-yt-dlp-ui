import 'package:julia_conversion_tool/app_config.dart';

String padrao = 'Padrão';

class YtDlpParams {
  final String? _id;
  final String? _extensao;
  final String _formato;
  final String? _resolucaoFps;

  String? _resolucao;
  String? _fps;

  YtDlpParams(
      this._id, this._extensao, this._formato, this._resolucaoFps){
    if (_resolucaoFps == null || _resolucaoFps == padrao) return;
    if (_resolucaoFps.contains('p')) {
      List<String> x = _resolucaoFps.split('p');
      _resolucao = x.first;
      _fps = x.last;
    } else {
      _resolucao = _resolucaoFps;
    }
  }

  bool get somenteAudio => _extensao == 'Melhor áudio' || _resolucao == 'Somente áudio';

  bool get inalterado {
    return _extensao == null &&
        _resolucao == null &&
        _id == null &&
        _fps == null &&
        _formato.isEmpty;
  }

  List<String> get configuracoes {
    List<String> configs = [];
    if (!AppConfig.instance.mtime) configs.add('--no-mtime');
    return configs;
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
    } return '';
  }

  List<String> get argumentos {
    if (inalterado) return [];
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