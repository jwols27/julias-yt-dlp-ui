import 'package:flutter/material.dart';
import 'package:julias_yt_dlp_ui/models/yt_dlp_item.dart';

class YoutubeTable extends StatelessWidget {
  const YoutubeTable(
      {super.key,
      required this.items,
      required this.idSelecionado,
      required this.onSelected});

  final List<YtDlpItem> items;
  final String? idSelecionado;
  final Function(String?) onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: DataTable(
          showCheckboxColumn: false,
          columns: [
            DataColumn(label: Text('ID ')),
            DataColumn(label: Text('Extensão')),
            DataColumn(label: Text('Resolução')),
            DataColumn(label: Text('Tamanho estimado')),
            DataColumn(label: const SizedBox()),
          ],
          rows: items
              .map((y) => DataRow(
                    color: WidgetStateColor.resolveWith((states) =>
                        y.id == idSelecionado
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: .25)
                            : Colors.transparent),
                    cells: [
                      DataCell(Text(y.id)),
                      DataCell(Text(y.ext)),
                      DataCell(Text(y.res)),
                      DataCell(Text(y.tam)),
                      DataCell(Icon(
                        y.acodec ? Icons.volume_up : Icons.volume_off,
                        color: Colors.black45,
                      )),
                    ],
                    onSelectChanged: (_) {
                      onSelected(y.id);
                    },
                  ))
              .toList()),
    );
  }
}
