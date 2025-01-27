import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LinuxTab extends StatefulWidget {
  const LinuxTab({super.key});

  @override
  State<LinuxTab> createState() => _LinuxTabState();
}

class _LinuxTabState extends State<LinuxTab> {

  void copiarTexto(String texto) async {
    await Clipboard.setData(ClipboardData(text: texto));
    if (context.mounted) {
      SnackBar snackBar = SnackBar(
        content: Text('Texto copiado para sua área de transferência.'),
      );
      mostrarSnackbar(snackBar);
    }
  }

  void mostrarSnackbar(SnackBar snackBar) {
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget comandoCard (String texto, {double padding = 0}) {
    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            const SizedBox(width: 4),
            Padding(
              padding: EdgeInsets.symmetric(vertical: padding),
              child: Text(texto),
            ),
            IconButton(
                iconSize: 16,
                onPressed: () { copiarTexto(texto); },
                icon: Icon(Icons.copy))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Text(
          'Instalando FFmpeg/FFprobe no Linux',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const Divider(),
        Text(
          'Ubuntu/Debian',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        comandoCard('apt update\napt install ffmpeg', padding: 8),
        Text(
          'Arch Linux',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        comandoCard('pacman -S ffmpeg'),
        Text(
          'Fedora',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        comandoCard('dnf install ffmpeg'),
        Text(
          'openSUSE',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        comandoCard('sudo zypper install ffmpeg-4'),
      ],
    );
  }
}
