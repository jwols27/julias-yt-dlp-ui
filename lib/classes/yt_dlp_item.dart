class YtDlpItem {
  String id;
  String ext;
  String resolucao;
  int? height;
  int? tamanho;
  int? tamanhoEstimado;
  int? fps;

  YtDlpItem(
      {required this.id,
      required this.ext,
      required this.resolucao,
      this.height,
      this.tamanho,
      this.tamanhoEstimado,
      this.fps});

  String get res {
    if (resolucao == 'audio only') {
      return 'Somente áudio';
    }
    return '${height?.toString() ?? '-'}p${(fps ?? 0) >= 5 ? fps : ''}';
  }

  String get tam {
    int x = tamanho ?? tamanhoEstimado ?? 0;
    if (x == 0) return '~';
    double kib = x / 1024;
    if (x < 1048576) return '${kib.toStringAsFixed(2)} Kib';
    double mib = kib / 1024;
    return '${mib.toStringAsFixed(2)} Mib';
  }

  factory YtDlpItem.fromJson(Map<String, dynamic> json) {
    int? fps1;
    if (json['fps'] is double) {
      fps1 = (json['fps'] as double).toInt();
    } else {
      fps1 = json['fps'] as int?;
    }

    return YtDlpItem(
      id: json['format_id'] as String,
      ext: json['ext'] as String,
      resolucao: json['resolution'] as String,
      height: json['height'] as int?,
      tamanho: json['filesize'] as int?,
      tamanhoEstimado: json['filesize_approx'] as int?,
      fps: (fps1 ?? 0) > 10 ? fps1 : null,
    );
  }
}
