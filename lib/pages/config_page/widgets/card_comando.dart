import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CardComando extends StatefulWidget {
  const CardComando({super.key, required this.texto, this.padding = 0});
  final String texto;
  final double padding;

  @override
  State<CardComando> createState() => _CardcomandoState();
}

class _CardcomandoState extends State<CardComando> {
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
    return Card.filled(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide.none,
      ),
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            const SizedBox(width: 4),
            Padding(
              padding: EdgeInsets.symmetric(vertical: widget.padding),
              child: Text(widget.texto),
            ),
            IconButton(
                iconSize: 16,
                onPressed: () {
                  copiarTexto(widget.texto);
                },
                icon: Icon(Icons.copy))
          ],
        ),
      ),
    );
  }
}
