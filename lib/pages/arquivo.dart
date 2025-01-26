import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:julia_conversion_tool/services/ffmpeg.dart';

class ArquivoPage extends StatefulWidget {
  const ArquivoPage({super.key});

  @override
  State<ArquivoPage> createState() => _ArquivoPageState();
}

class _ArquivoPageState extends State<ArquivoPage> {
  FFmpegWrapper ffmpeg = FFmpegWrapper();
  TextEditingController enderecoArquivoController = TextEditingController();

  void selecionarArquivo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      //allowedExtensions: ['mp4', 'mp3', 'webm', 'avi', 'wmv', 'amv', 'm4v', 'mkv'],
    );

    if (result != null) {
      enderecoArquivoController.text = result.files.single.path!;
    } else {}
  }

  void converter() {
    ffmpeg.converter(enderecoArquivoController.text);
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
              OutlinedButton.icon(
                  onPressed: selecionarArquivo,
                  label: const Text('Selecionar arquivo'),
                  icon: Icon(Icons.attach_file, size: 24),
              ),
              Expanded(
                flex: 10,
                child: TextField(
                  controller: enderecoArquivoController,
                  decoration: const InputDecoration(
                    labelText: "Endereço",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: enderecoArquivoController,
                builder: (context, value, child) {
                  return FilledButton.icon(
                    onPressed: enderecoArquivoController.text.isNotEmpty ? converter : null,
                    label: Text('Converter'),
                    icon: Icon(Icons.video_file, size: 24),
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
