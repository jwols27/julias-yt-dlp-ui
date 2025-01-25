import 'package:flutter/material.dart';
import 'package:julia_conversion_tool/classes/opcaoYoutube.dart';
import 'package:julia_conversion_tool/classes/snackbar.dart';
import 'package:julia_conversion_tool/tools/yt-dlp.dart';

class YoutubePage extends StatefulWidget {
  const YoutubePage({super.key});

  @override
  State<YoutubePage> createState() => _YoutubePageState();
}

class _YoutubePageState extends State<YoutubePage> {
  YtDlpWrapper ytdlp = YtDlpWrapper();
  TextEditingController linkYoutubeController = TextEditingController();

  void baixarYoutube() async {
    String endereco = linkYoutubeController.text;
    StatusSnackbar snackbar;
    List<OpcaoYoutube> lista = [];
    (lista, snackbar) = await ytdlp.listarOpcoes(endereco);
    snackbar.showSnackbar(context);
    print(lista);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Expanded(
                flex: 10,
                child: TextField(
                  controller: linkYoutubeController,
                  decoration: const InputDecoration(
                    labelText: "Endereço",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: linkYoutubeController,
                builder: (context, value, child) {
                  return FilledButton.icon(
                    onPressed: linkYoutubeController.text.isNotEmpty ? baixarYoutube : null,
                    label: Text('Baixar do YouTube'),
                    icon: Icon(Icons.file_download, size: 24),
                  );
                },
              ),
            ],
          ),
        )
      ],
    );
  }
}
