import 'package:flutter/material.dart';

class DependenciesModal extends StatelessWidget {
  const DependenciesModal(
      {super.key,
      required this.ffmpeg,
      required this.ffprobe,
      required this.redirecionar});

  final bool ffmpeg;
  final bool ffprobe;
  final Function redirecionar;

  String get depsFaltando {
    List<String> deps = [];
    if (!ffmpeg) deps.add('FFmpeg');
    if (!ffprobe) deps.add('FFprobe');
    return deps.join(' e ');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dependências faltando!'),
      content: Column(
          spacing: 1,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'As seguintes dependências não estão instaladas na sua máquina: $depsFaltando.'),
            Text('Você não poderá usar a ferramenta de conversão.'),
            const SizedBox(height: 5),
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                redirecionar();
              },
              child: Text('Como eu instalo isso?',
                  style: TextStyle(color: Colors.blue)),
            ),
          ]),
      actions: [
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Entendido'),
        ),
      ],
    );
  }
}
