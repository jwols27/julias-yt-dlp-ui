import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:julia_conversion_tool/classes/status_snackbar.dart';
import 'package:julia_conversion_tool/classes/yt_dlp_video.dart';
import 'package:julia_conversion_tool/pages/components/youtube_components.dart';
import 'package:julia_conversion_tool/services/yt_dlp.dart';

class YoutubePage extends StatefulWidget {
  const YoutubePage({super.key, required this.tabController});

  final TabController tabController;

  @override
  State<YoutubePage> createState() => _YoutubePageState();
}

List<String> formatos = [
  "aac",
  "alac",
  "m4a",
  "mp3",
  "mpg",
  "opus",
  "wav",
];

String padrao = 'Padrão';

class _YoutubePageState extends State<YoutubePage> {
  YtDlpWrapper ytdlp = YtDlpWrapper();
  bool temDeps = true;
  String youtubeUrl = '';
  String? valorExtensao;
  String? valorResolucao;
  TextEditingController extController = TextEditingController();
  TextEditingController resController = TextEditingController();
  TextEditingController formatoController = TextEditingController();
  bool converter = false;
  bool mostrarTabela = false;
  bool carregando = false;
  bool erroFormato = false;
  YtDlpVideo? video;
  List<String> extensoes = [];
  List<String> resolucoes = [];
  String? idSelecionado;

  bool get pronto => video != null && !carregando;

  @override
  void initState() {
    super.initState();
    verificarDependencias();
  }

  void verificarDependencias() async {
    bool ffmpeg, ffprobe;
    (ffmpeg, ffprobe) = await ytdlp.verificarDependencias();
    temDeps = ffmpeg && ffprobe;
    Future.delayed(Duration(seconds: 1), () {
      if (!temDeps) _mostrarDialogoDeps(ffmpeg, ffprobe);
    });
  }

  void _mostrarDialogoDeps(bool ffmpeg, bool ffprobe) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DependenciesModal(
            ffmpeg: ffmpeg,
            ffprobe: ffprobe,
            redirecionar: () => widget.tabController.animateTo(1));
      },
    );
  }

  void baixarYoutube(BuildContext context) async {
    if (converter && formatoController.text.isEmpty) {
      setState(() {
        erroFormato = true;
      });
      return;
    }

    YtDlpParameters parametros = YtDlpParameters();

    if (formatoController.text.isNotEmpty)
      parametros.format = formatoController.text;
    if (idSelecionado != null) parametros.id = idSelecionado;
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
        await ytdlp.baixarVideo(youtubeUrl, parametros: parametros);
    if (context.mounted) snackbar1.showSnackbar(context);
  }

  void listarYoutube() async {
    setState(() {
      carregando = true;
    });
    StatusSnackbar snackbar2;
    YtDlpVideo? ytVideo;
    (ytVideo, snackbar2) = await ytdlp.listarOpcoes(youtubeUrl);
    snackbar2.showSnackbar(context);

    resetarOpcoes();

    setState(() {
      video = ytVideo;
      if (video == null) {
        carregando = false;
        return;
      }
      List<String> extList = video!.items.map((x) => x.ext).toSet().toList();
      if (video!.items.any((y) => y.res == 'Somente áudio')) {
        extensoes.add('Melhor áudio');
      }
      extensoes.addAll(extList);
      filtrarResolucoes(valorResolucao);
      carregando = false;
    });
  }

  void filtrarResolucoes(String? ext) {
    if (ext == null) {
      resolucoes = video!.items.map((y) => y.res).toSet().toList();
    } else {
      resolucoes = video!.items
          .where((x) => x.ext == ext)
          .map((y) => y.res)
          .toSet()
          .toList();
    }
  }

  void escolherExtensao(String? ext) {
    resolucoes.clear();
    resController.text = padrao;
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
      extController.text = padrao;
      resController.text = padrao;
      valorExtensao = null;
      valorResolucao = null;
      if (!softReset) {
        extensoes.clear();
        resolucoes.clear();
        formatoController.clear();
      }
    });
  }

  void youtubeUrlOnChanged(String x) {
    if (video != null) video = null;
    youtubeUrl = x;
    resetarOpcoes();
  }

  void tabelaCheckboxOnChanged(bool? value) {
    setState(() {
      mostrarTabela = value!;
    });
  }

  void converterCheckboxOnChanged(bool? value) {
    setState(() {
      converter = value!;
    });
  }

  void tableOnSelected(String? id) {
    setState(() {
      idSelecionado = id == idSelecionado ? null : id;
    });
    resetarOpcoes(softReset: true);
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
          errorText: erroFormato ? 'Escolha um formato' : null,
          onSelected: (_) {
            setState(() {
              erroFormato = false;
            });
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
        YoutubeUrlWidget(
            listarYoutube: listarYoutube,
            baixarYoutube: baixarYoutube,
            onChanged: youtubeUrlOnChanged),
        if (carregando)
          Expanded(
              child: SpinKitWave(
            color: Theme.of(context).colorScheme.inversePrimary,
            size: 50.0,
          )),
        if (pronto) ...[
          const SizedBox(height: 20),
          VideoPreview(video: video!),
          const SizedBox(height: 5),
          const Divider(),
          const SizedBox(height: 20),
        ],
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
                        visible: pronto,
                        child: Row(
                          spacing: 20,
                          children: [
                            YoutubeOpcaoDownload(
                                lista: extensoes,
                                title: 'Extensão',
                                onSelected: escolherExtensao,
                                controller: extController,
                                enabled: idSelecionado == null),
                            YoutubeOpcaoDownload(
                                lista: resolucoes,
                                title: 'Resolução',
                                onSelected: escolherResolucao,
                                controller: resController,
                                enabled: idSelecionado == null),
                          ],
                        )),
                    if (pronto)
                      Column(
                        children: [
                          YoutubeCheckbox(
                              value: mostrarTabela,
                              enabled: (video?.items.length ?? 0) > 1,
                              onChanged: tabelaCheckboxOnChanged,
                              title: 'Mostrar tabela',
                              subtitle:
                                  'Mostrar informações avançadas em formato de tabela'),
                          if (temDeps)
                            YoutubeCheckbox(
                                value: converter,
                                enabled: (video?.items.length ?? 0) > 1,
                                onChanged: converterCheckboxOnChanged,
                                title: 'Converter',
                                subtitle:
                                    'Habilitar conversão para outros formatos'),
                        ],
                      ),
                    Visibility(
                      visible: converter && pronto && temDeps,
                      child: formatoWidget,
                    ),
                  ],
                ),
              ),
              if (video != null && mostrarTabela && !carregando)
                Expanded(
                    flex: 5,
                    child: YoutubeTable(
                        items: video!.items,
                        idSelecionado: idSelecionado,
                        onSelected: tableOnSelected))
            ],
          ),
        ),
      ],
    );
  }
}
