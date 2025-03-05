import 'package:flutter/material.dart';
import 'package:julias_yt_dlp_ui/app_constants.dart' as constants show padrao;

class YoutubeOpcaoDownload extends StatefulWidget {
  const YoutubeOpcaoDownload(
      {super.key,
      required this.lista,
      required this.title,
      required this.onSelected,
      required this.controller,
      required this.enabled});

  final List<String> lista;
  final String title;
  final Function(String?) onSelected;
  final TextEditingController controller;
  final bool enabled;

  @override
  State<YoutubeOpcaoDownload> createState() => _YoutubeOpcaoDownloadState();
}

class _YoutubeOpcaoDownloadState extends State<YoutubeOpcaoDownload> {
  List<String> get items => [constants.padrao, ...widget.lista];

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      width: 200,
      label: Text(widget.title),
      initialSelection: items.first,
      controller: widget.controller,
      dropdownMenuEntries: items
          .map<DropdownMenuEntry<String>>((String value) {
            return DropdownMenuEntry<String>(value: value, label: value);
          })
          .toSet()
          .toList(),
      onSelected: widget.onSelected,
      enabled: items.length > 1 && widget.enabled,
      enableFilter: false,
      enableSearch: false,
      requestFocusOnTap: false,
    );
  }
}
