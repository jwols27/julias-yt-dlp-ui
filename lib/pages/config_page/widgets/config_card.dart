import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:julia_conversion_tool/app_config.dart';

class ConfigCard extends StatefulWidget {
  const ConfigCard({super.key});

  @override
  State<ConfigCard> createState() => _ConfigCardState();
}

class _ConfigCardState extends State<ConfigCard> {
  TextEditingController destinoController =
  TextEditingController(text: AppConfig.instance.destino);

  void onDestinoChange(String? value) {
    AppConfig.instance.setDestino(value ?? '');
  }

  void onPickerPress() async {
    String? pasta = await FilePicker.platform.getDirectoryPath();
    if (pasta != null) {
      destinoController.text = pasta;
      onDestinoChange(pasta);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
        child: Column(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    Tooltip(
                      message: 'Escolher destino',
                      child: IconButton.outlined(
                        constraints: BoxConstraints(minWidth: 50),
                        icon: Icon(Icons.folder_copy, size: 24),
                        onPressed: onPickerPress,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: destinoController,
                        onChanged: onDestinoChange,
                        decoration: const InputDecoration(
                          labelText: "Endereço",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                value: AppConfig.instance.mtime,
                onChanged: (bool? value) {
                  setState(() {
                    AppConfig.instance.setMtime(value ?? false);
                  });
                },
                title: Text('Habilitar --mtime'),
                subtitle: Text(
                    'Utiliza o cabeçalho "Modificado pela última vez" do YouTube para definir a data/hora que o arquivo foi modificado no sistema.'),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                value: AppConfig.instance.h26x,
                onChanged: (bool? value) {
                  setState(() {
                    AppConfig.instance.setH26x(value ?? false);
                  });
                },
                title: Text('Priorizar H264/H265'),
                subtitle: Text(
                    'Tenta baixar vídeo com codec H264/H265, senão o aplicativo vai tentar converter seu codec para H264.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
