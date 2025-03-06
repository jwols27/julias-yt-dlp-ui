import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:julias_yt_dlp_ui/pages/config_page/widgets/card_comando.dart';
import 'package:url_launcher/url_launcher.dart';

class WindowsTab extends StatefulWidget {
  const WindowsTab({super.key});

  @override
  State<WindowsTab> createState() => _WindowsTabState();
}

class _WindowsTabState extends State<WindowsTab> {
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

  @override
  Widget build(BuildContext context) {
    ThemeData tema = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Text(
          'Instalando FFmpeg/FFprobe no Windows',
          style: tema.textTheme.headlineSmall,
        ),
        const Divider(),
        RichText(
            textAlign: TextAlign.center,
            text: TextSpan(style: tema.textTheme.bodyLarge, children: [
              TextSpan(
                text: '1. Baixe o arquivo ',
              ),
              TextSpan(text: 'ffmpeg-release-full.7z ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launchUrl(Uri.parse('https://www.gyan.dev/ffmpeg/builds/'));
                    },
                  text: 'deste site',
                  style: TextStyle(color: tema.colorScheme.onPrimary)),
              TextSpan(text: '.'),
            ])),
        RichText(
            text: TextSpan(text: '2. Extraia o arquivo usando a opção ', style: tema.textTheme.bodyLarge, children: [
          TextSpan(text: 'Extrair aqui', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: ', o resultado será uma pasta.')
        ])),
        RichText(
            text: TextSpan(text: '3. Renomeie essa pasta para ', style: tema.textTheme.bodyLarge, children: [
          TextSpan(text: 'FFmpeg', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: '.')
        ])),
        RichText(
            text: TextSpan(
                text: '4. Mova a pasta que você renomeou para seu disco local \'C:\'.',
                style: tema.textTheme.bodyLarge)),
        RichText(
            text: TextSpan(text: '5. Procure o aplicativo ', style: tema.textTheme.bodyLarge, children: [
          TextSpan(text: 'Prompt de Comando', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: ' e execute ele como administrador.')
        ])),
        RichText(
            text:
                TextSpan(text: '6. Execute o seguinte comando no prompt de comando:', style: tema.textTheme.bodyLarge)),
        CardComando(texto: r'setx /m PATH "C:\ffmpeg\bin;%PATH%"'),
        RichText(
            text: TextSpan(
                text:
                    'E pronto! Isso é tudo que você precisa fazer para instalar o FFmpeg e o FFprobe. Se você quiser testar se funcionou, feche o prompt de comando e abra um novo. Agora execute o seguinte comando:',
                style: tema.textTheme.bodyLarge)),
        CardComando(texto: 'ffmpeg -version'),
      ],
    );
  }
}
