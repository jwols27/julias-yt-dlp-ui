import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:julias_yt_dlp_ui/app_constants.dart' as constants;
import 'package:julias_yt_dlp_ui/models/yt_dlp_params.dart';
import 'package:julias_yt_dlp_ui/models/yt_dlp_response.dart';
import 'package:julias_yt_dlp_ui/models/yt_dlp_video.dart';
import 'package:julias_yt_dlp_ui/models/yt_dlp_video_status.dart';
import 'package:julias_yt_dlp_ui/pages/youtube_page/widgets/youtube_widgets.dart';
import 'package:julias_yt_dlp_ui/utils/ffmpeg_wrapper.dart';
import 'package:julias_yt_dlp_ui/utils/yt_dlp_wrapper.dart';
import 'package:julias_yt_dlp_ui/widgets/modal_dependencias.dart';

class YoutubePage extends StatefulWidget {
  const YoutubePage({super.key, required this.tabController});

  final TabController tabController;

  @override
  State<YoutubePage> createState() => _YoutubePageState();
}

class _YoutubePageState extends State<YoutubePage> {
  YtDlpWrapper ytdlp = YtDlpWrapper();
  bool temDeps = false;
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
    var (ffmpeg, ffprobe) = await FFmpegWrapper.verificarDependencias();
    temDeps = ffmpeg && ffprobe;
    if (!temDeps) {
      Future.delayed(Duration(seconds: 1), () {
        _mostrarDialogoDeps(ffmpeg, ffprobe);
      });
    }
  }

  void _mostrarDialogoDeps(bool ffmpeg, bool ffprobe) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ModalDependencias(
            ffmpeg: ffmpeg, ffprobe: ffprobe, redirecionar: () => widget.tabController.animateTo(1));
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

    YtDlpParams parametros = YtDlpParams(idSelecionado, valorExtensao, formatoController.text, valorResolucao);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StreamBuilder<YtDlpVideoStatus>(
          stream: ytdlp.statusProgresso,
          builder: (context, snapshot) {
            final x = snapshot.data ?? YtDlpVideoStatus(VideoStatus.carregando, 0);
            return ModalDownload(video: x);
          },
        );
      },
    );

    YtDlpResponse res = await ytdlp.baixarVideo(youtubeUrl, parametros: parametros);
    if (context.mounted) {
      res.showSnackbar(context);
      Navigator.pop(context);
    }
  }

  void listarYoutube() async {
    setState(() {
      carregando = true;
    });

    YtDlpResponse res = await ytdlp.listarOpcoes(youtubeUrl);
    if (!mounted) return;
    res.showSnackbar(context);

    resetarOpcoes();

    setState(() {
      video = res.video;
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
      resolucoes = video!.items.where((x) => x.ext == ext).map((y) => y.res).toSet().toList();
    }
  }

  void escolherExtensao(String? ext) {
    resolucoes.clear();
    resController.text = constants.padrao;
    valorResolucao = null;
    valorExtensao = ext == constants.padrao ? null : ext;
    setState(() {
      filtrarResolucoes(valorExtensao);
    });
  }

  void escolherResolucao(String? res) {
    valorResolucao = res == constants.padrao ? null : res;
  }

  void resetarOpcoes({bool softReset = false}) {
    if (!mounted) return;
    setState(() {
      extController.text = constants.padrao;
      resController.text = constants.padrao;
      valorExtensao = null;
      valorResolucao = null;
      if (!softReset) {
        extensoes.clear();
        resolucoes.clear();
        formatoController.clear();
        converter = false;
        idSelecionado = null;
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
      formatoController.clear();
    });
  }

  void tableOnSelected(String? id) {
    setState(() {
      idSelecionado = id == idSelecionado ? null : id;
    });
    resetarOpcoes(softReset: true);
  }

  void formatoOnSelected(_) {
    setState(() {
      erroFormato = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        YoutubeUrlWidget(listarYoutube: listarYoutube, baixarYoutube: baixarYoutube, onChanged: youtubeUrlOnChanged),
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
                    if (pronto) ...[
                      const SizedBox(height: 20),
                      YoutubeCheckbox(
                          value: mostrarTabela,
                          enabled: (video?.items.length ?? 0) > 1,
                          onChanged: tabelaCheckboxOnChanged,
                          title: 'Mostrar tabela',
                          subtitle: 'Mostrar informações avançadas em formato de tabela'),
                      if (temDeps) ...[
                        YoutubeCheckbox(
                            value: converter,
                            enabled: (video?.items.length ?? 0) > 1,
                            onChanged: converterCheckboxOnChanged,
                            title: 'Converter',
                            subtitle: 'Habilitar conversão para outros formatos'),
                      ]
                    ],
                    const SizedBox(height: 20),
                    Visibility(
                      visible: converter && pronto && temDeps,
                      child: YoutubeOpcaoFormato(
                          controller: formatoController,
                          enabled: converter,
                          onSelected: formatoOnSelected,
                          error: erroFormato),
                    ),
                  ],
                ),
              ),
              if (video != null && mostrarTabela && !carregando)
                Expanded(
                    flex: 5,
                    child: YoutubeTable(items: video!.items, idSelecionado: idSelecionado, onSelected: tableOnSelected))
            ],
          ),
        ),
      ],
    );
  }
}
