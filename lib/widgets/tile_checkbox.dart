import 'package:flutter/material.dart';

class TileCheckbox extends StatelessWidget {
  const TileCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.subtitle,
    this.enabled = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
    this.width = 400,
  });

  final bool value;
  final bool enabled;
  final Function(bool?) onChanged;
  final String title;
  final String? subtitle;
  final double width;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.loose(Size(width, double.infinity)),
      child: Padding(
          padding: padding,
          child: ListTile(
            title: Text(title),
            subtitle: subtitle != null ? Text(subtitle!) : null,
            onTap: enabled
                ? () {
                    onChanged(!value);
                  }
                : null,
            leading: Checkbox(
              value: value,
              onChanged: enabled ? onChanged : null,
            ),
          )),
    );
  }
}
