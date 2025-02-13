import 'package:flutter/material.dart';

class YoutubeCheckbox extends StatelessWidget {
  const YoutubeCheckbox({
    super.key,
    required this.value,
    required this.enabled,
    required this.onChanged,
    required this.title,
    required this.subtitle,
  });

  final bool value;
  final bool enabled;
  final Function(bool?) onChanged;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.loose(Size(400, double.infinity)),
      child: CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        value: value,
        enabled: enabled,
        onChanged: onChanged,
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
