import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:julia_conversion_tool/classes/status_snackbar.dart';
import 'package:julia_conversion_tool/classes/yt_dlp_video.dart';
import 'package:julia_conversion_tool/services/yt_dlp.dart';
import 'package:url_launcher/url_launcher.dart';

class YoutubePage extends StatefulWidget {
  const YoutubePage({super.key});

  @override
  State<YoutubePage> createState() => _YoutubePageState();
}

List<String> formatos = [
  "avi",
  "flv",
  "m4a",
  "mkv",
  "mov",
  "mp3",
  "mp4",
  "mpg",
  "ogg",
  "wav",
  "webm",
  "wma",
  "wmv"
];

String padrao = 'Padrão';

class _YoutubePageState extends State<YoutubePage> {
  YtDlpWrapper ytdlp = YtDlpWrapper();
  TextEditingController linkYoutubeController = TextEditingController();
  TextEditingController extensaoController = TextEditingController();
  String? valorExtensao;
  TextEditingController resolucaoController = TextEditingController();
  String? valorResolucao;
  TextEditingController formatoController = TextEditingController();
  TextEditingController idController = TextEditingController();
  bool converter = false;
  bool mostrarTabela = false;
  bool carregando = false;
  YtDlpVideo? video;
  List<String> extensoes = [padrao];
  List<String> resolucoes = [padrao];
  String? idSelecionado;

  void baixarYoutube(BuildContext context) async {
    String endereco = linkYoutubeController.text;
    YtDlpParameters parametros = YtDlpParameters();

    if (valorExtensao == 'Melhor áudio' || valorResolucao == 'Somente áudio') {
      parametros.bestAudio = true;
    }
    if (valorExtensao != null &&
        extensoes.any((r) => r == valorExtensao) &&
        valorExtensao != padrao) {
      parametros.ext = valorExtensao;
    }
    if (valorResolucao != null &&
        resolucoes.any((r) => r == valorResolucao) &&
        valorResolucao != padrao) {
      if (valorResolucao != 'Somente áudio') {
        List<String> x = valorResolucao!.split('p');
        parametros.resolution = x.first;
        parametros.fps = x.last;
      } else {
        parametros.resolution = valorResolucao;
      }
    }

    StatusSnackbar snackbar1 =
        await ytdlp.baixarVideo(endereco, parametros: parametros);
    if (context.mounted) snackbar1.showSnackbar(context);
  }

  void listarYoutube() async {
    setState(() {
      carregando = true;
    });
    String endereco = linkYoutubeController.text;
    StatusSnackbar snackbar2;
    YtDlpVideo? ytVideo;
    (ytVideo, snackbar2) = await ytdlp.listarOpcoes(endereco);
    snackbar2.showSnackbar(context);

    resetarOpcoes();
    if (ytVideo == null) return;
    setState(() {
      video = ytVideo;
      List<String> extList = video!.items.map((x) => x.ext).toSet().toList();
      if (video!.items.any((y) => y.res == 'Somente áudio')) {
        extensoes.add('Melhor áudio');
      }
      extensoes.addAll(extList);
      filtrarResolucoes(resolucaoController.text);
      carregando = false;
    });
  }

  void filtrarResolucoes(String? ext) {
    if (ext == padrao) {
      resolucoes.addAll(video!.items.map((y) => y.res).toSet().toList());
    } else {
      resolucoes.addAll(video!.items
          .where((x) => x.ext == ext)
          .map((y) => y.res)
          .toSet()
          .toList());
    }
  }

  void escolherExtensao(String? ext) {
    resolucoes = [padrao];
    resolucaoController.text = padrao;
    valorResolucao = null;
    setState(() {
      filtrarResolucoes(ext);
    });
    valorExtensao = ext;
  }

  void escolherResolucao(String? res) {
    valorResolucao = res;
  }

  void resetarOpcoes({bool softReset = false}) {
    setState(() {
      extensaoController.text = padrao;
      resolucaoController.text = padrao;
      if (!softReset) {
        valorExtensao = null;
        valorResolucao = null;
        extensoes = [padrao];
        resolucoes = [padrao];
        formatoController.clear();
      }
    });
  }

  Widget get urlWidget {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: linkYoutubeController,
            builder: (context, value, child) {
              return OutlinedButton.icon(
                onPressed: linkYoutubeController.text.isNotEmpty
                    ? listarYoutube
                    : null,
                label: const Text('Listar opções'),
                icon: Icon(Icons.manage_search, size: 24),
              );
            },
          ),
          Expanded(
            flex: 10,
            child: TextField(
              controller: linkYoutubeController,
              onChanged: (String x) {
                if (video != null) video = null;
                resetarOpcoes();
              },
              decoration: const InputDecoration(
                labelText: "Link do YouTube",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          FilledButton.icon(
            onPressed: linkYoutubeController.text.isNotEmpty
                ? () => baixarYoutube(context)
                : null,
            label: Text('Baixar do YouTube'),
            icon: Icon(Icons.file_download, size: 24),
          ),
        ],
      ),
    );
  }

  Widget get opcoesWidget {
    return Row(
      spacing: 20,
      children: [
        DropdownMenu<String>(
          width: 200,
          label: Text('Extensão'),
          initialSelection: extensoes.first,
          controller: extensaoController,
          dropdownMenuEntries: extensoes
              .map<DropdownMenuEntry<String>>((String value) {
                return DropdownMenuEntry<String>(value: value, label: value);
              })
              .toSet()
              .toList(),
          onSelected: escolherExtensao,
          enabled: extensoes.length > 1,
          enableFilter: false,
          enableSearch: false,
          requestFocusOnTap: false,
        ),
        DropdownMenu<String>(
          width: 200,
          label: Text('Resolução'),
          controller: resolucaoController,
          initialSelection: 'Padrão',
          dropdownMenuEntries: resolucoes
              .map<DropdownMenuEntry<String>>((String value) {
                return DropdownMenuEntry<String>(value: value, label: value);
              })
              .toSet()
              .toList(),
          onSelected: escolherResolucao,
          enabled: (video?.items.length ?? 0) > 1,
          enableFilter: false,
          enableSearch: false,
          requestFocusOnTap: false,
        ),
      ],
    );
  }

  Widget get checkboxesWidget {
    return Column(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints.loose(Size(400, double.infinity)),
          child: CheckboxListTile(
            value: mostrarTabela,
            enabled: (video?.items.length ?? 0) > 1,
            onChanged: (bool? value) {
              setState(() {
                mostrarTabela = value!;
              });
            },
            title: const Text('Mostrar tabela'),
            subtitle: const Text(
                'Mostrar informações avançadas em formato de tabela'),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints.loose(Size(400, double.infinity)),
          child: CheckboxListTile(
            value: converter,
            enabled: (video?.items.length ?? 0) > 1,
            onChanged: (bool? value) {
              setState(() {
                converter = value!;
              });
            },
            title: const Text('Converter'),
            subtitle: const Text('Habilitar conversão para outros formatos'),
          ),
        ),
      ],
    );
  }

  Widget get videoPreviewWidget {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Flexible(
            child: InkWell(
                onTap: () => launchUrl(Uri.parse(video!.url)),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(video!.thumbnail)))),
        Flexible(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                  onTap: () => launchUrl(Uri.parse(video!.url)),
                  child: Text(video!.title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 24))),
              InkWell(
                onTap: () => launchUrl(Uri.parse(video!.channelUrl)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2,
                  children: [
                    Icon(
                      Icons.account_circle,
                      color: Colors.blue,
                      size: 18,
                    ),
                    Text(video!.channel, style: TextStyle(color: Colors.blue)),
                  ],
                ),
              ),
              Text('${video!.numViews} visualizações'),
              Text(video!.timeAgo),
            ],
          ),
        ),
      ],
    );
  }

  Widget get formatoWidget {
    return Row(
      children: [
        DropdownMenu<String>(
          width: 420,
          label: Text('Formato'),
          controller: formatoController,
          dropdownMenuEntries:
              formatos.map<DropdownMenuEntry<String>>((String value) {
            return DropdownMenuEntry<String>(value: value, label: value);
          }).toList(),
          enabled: converter,
          enableFilter: false,
          enableSearch: false,
          requestFocusOnTap: false,
          onSelected: (_) {
            setState(() {});
          },
        ),
        if (formatoController.text.isNotEmpty)
          IconButton(
            onPressed: () {
              setState(() {
                formatoController.clear();
              });
            },
            icon: Icon(Icons.clear),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        urlWidget,
        if (carregando)
          Expanded(
              child: SpinKitWave(
            color: Theme.of(context).colorScheme.inversePrimary,
            size: 50.0,
          )),
        if (!carregando) const SizedBox(height: 20),
        if (video != null && !carregando) videoPreviewWidget,
        if (!carregando) const SizedBox(height: 5),
        if (video != null && !carregando) const Divider(),
        if (!carregando) const SizedBox(height: 20),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20,
                  children: [
                    Visibility(
                        visible: video != null && !carregando,
                        child: opcoesWidget),
                    Visibility(
                        visible: video != null && !carregando,
                        child: checkboxesWidget),
                    Visibility(
                      visible: converter && video != null && !carregando,
                      child: formatoWidget,
                    ),
                  ],
                ),
              ),
              if (video != null && mostrarTabela && !carregando)
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    child: DataTable(
                        showCheckboxColumn: false,
                        columns: [
                          DataColumn(label: Text('ID ')),
                          DataColumn(label: Text('Extensão')),
                          DataColumn(label: Text('Resolução')),
                          DataColumn(label: Text('Tamanho estimado')),
                        ],
                        rows: video!.items
                            .map((y) => DataRow(
                                  color: WidgetStateColor.resolveWith(
                                      (states) => y.id == idSelecionado
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
                                  ],
                                  onSelectChanged: (newValue) {
                                    setState(() {
                                      idSelecionado =
                                          y.id == idSelecionado ? null : y.id;
                                    });
                                  },
                                ))
                            .toList()),
                  ),
                )
            ],
          ),
        ),
      ],
    );
  }
}
