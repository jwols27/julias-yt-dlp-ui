import 'package:flutter/material.dart';
import 'package:julia_conversion_tool/models/yt_dlp_video_status.dart';

class DownloadModal extends StatelessWidget {
  const DownloadModal({super.key, required this.video});

  final YtDlpVideoStatus video;

  String get texto {
    switch (video.status) {
      case VideoStatus.carregando:
        return 'Carregando...';
      case VideoStatus.video:
        return 'Baixando vídeo...';
      case VideoStatus.audio:
        return 'Baixando áudio...';
      case VideoStatus.videoAudio:
        return 'Baixando arquivo...';
      case VideoStatus.combinando:
        return 'Combinando vídeo e áudio...';
      case VideoStatus.convertendo:
        return 'Convertendo...';
    }
  }

  bool get mostrarBarra {
    return video.status != VideoStatus.carregando &&
        video.status != VideoStatus.combinando &&
        video.status != VideoStatus.convertendo;
  }

  String get progresso {
    return '${video.progresso.toStringAsFixed(2)}%';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              texto,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            if (mostrarBarra) ...[
              const SizedBox(height: 16),
              ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 400),
                  child: LinearProgressIndicator(
                      minHeight: 8, value: video.progresso / 100)),
              const SizedBox(height: 8),
              Text(progresso),
            ]
          ],
        ),
      ),
    );
  }
}
