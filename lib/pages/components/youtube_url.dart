import 'package:flutter/material.dart';

class YoutubeUrlWidget extends StatefulWidget {
  const YoutubeUrlWidget(
      {super.key,
      required this.listarYoutube,
      required this.baixarYoutube,
      required this.onChanged});

  final VoidCallback listarYoutube;
  final Function(BuildContext) baixarYoutube;
  final Function(String) onChanged;

  @override
  State<YoutubeUrlWidget> createState() => _YoutubeUrlWidgetState();
}

class _YoutubeUrlWidgetState extends State<YoutubeUrlWidget> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              return OutlinedButton.icon(
                onPressed:
                    controller.text.isNotEmpty ? widget.listarYoutube : null,
                label: const Text('Listar opções'),
                icon: Icon(Icons.manage_search, size: 24),
              );
            },
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: widget.onChanged,
              decoration: const InputDecoration(
                labelText: "Link do YouTube",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          FilledButton.icon(
            onPressed: controller.text.isNotEmpty
                ? () => widget.baixarYoutube(context)
                : null,
            label: Text('Baixar do YouTube'),
            icon: Icon(Icons.file_download, size: 24),
          ),
        ],
      ),
    );
  }
}
