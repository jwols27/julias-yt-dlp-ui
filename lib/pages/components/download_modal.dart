import 'package:flutter/material.dart';

class DownloadModal extends StatelessWidget {
  const DownloadModal(
      {super.key, required this.progresso, required this.atingido});

  final double progresso;
  final bool atingido;

  String get texto {
    return 'Baixando ${atingido ? 'áudio' : 'vídeo'}...';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              texto,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 400),
                child: LinearProgressIndicator(
                    minHeight: 8, value: progresso / 100)),
            const SizedBox(height: 8),
            Text('$progresso%'),
          ],
        ),
      ),
    );
  }
}
