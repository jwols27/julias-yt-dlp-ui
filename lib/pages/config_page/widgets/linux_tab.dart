import 'package:flutter/material.dart';
import 'package:julias_yt_dlp_ui/pages/config_page/widgets/card_comando.dart';

class LinuxTab extends StatefulWidget {
  const LinuxTab({super.key});

  @override
  State<LinuxTab> createState() => _LinuxTabState();
}

class _LinuxTabState extends State<LinuxTab> {
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
        CardComando(texto: 'apt update\napt install ffmpeg', padding: 8),
        Text(
          'Arch Linux',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        CardComando(texto: 'pacman -S ffmpeg'),
        Text(
          'Fedora',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        CardComando(texto: 'dnf install ffmpeg'),
        Text(
          'openSUSE',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        CardComando(texto: 'sudo zypper install ffmpeg-4'),
      ],
    );
  }
}
