import 'package:flutter/material.dart';
import 'package:julia_conversion_tool/app_constants.dart' as constants
    show formatosConversao;

class YoutubeOpcaoFormato extends StatefulWidget {
  const YoutubeOpcaoFormato(
      {super.key,
      required this.controller,
      required this.enabled,
      required this.error,
      required this.onSelected});

  final Function(String?) onSelected;
  final TextEditingController controller;
  final bool enabled;
  final bool error;

  @override
  State<YoutubeOpcaoFormato> createState() => _YoutubeOpcaoFormatoState();
}

class _YoutubeOpcaoFormatoState extends State<YoutubeOpcaoFormato> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DropdownMenu<String>(
          width: 420,
          label: Text('Formato'),
          controller: widget.controller,
          dropdownMenuEntries: constants.formatosConversao
              .map<DropdownMenuEntry<String>>((String value) {
            return DropdownMenuEntry<String>(value: value, label: value);
          }).toList(),
          enabled: widget.enabled,
          enableFilter: false,
          enableSearch: false,
          requestFocusOnTap: false,
          errorText: widget.error ? 'Escolha um formato' : null,
          onSelected: widget.onSelected,
        ),
        if (widget.controller.text.isNotEmpty)
          IconButton(
            onPressed: () {
              setState(() {
                widget.controller.clear();
              });
            },
            icon: Icon(Icons.clear),
          ),
      ],
    );
  }
}
