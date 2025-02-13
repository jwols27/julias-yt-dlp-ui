import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:julia_conversion_tool/app_config.dart';

import 'package:julia_conversion_tool/pages/config_page/widgets/config_card.dart';
import 'package:julia_conversion_tool/utils/ffmpeg_wrapper.dart';
import 'package:julia_conversion_tool/pages/config_page/widgets/linux_tab.dart';
import 'package:julia_conversion_tool/pages/config_page/widgets/windows_tab.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> with TickerProviderStateMixin {
  late final TabController _tabController;
  bool carregando = false;
  bool? temFFmpeg;
  bool? temFFprobe;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: Platform.isLinux ? 1 : 0);
    verificarDependencias();
  }

  void verificarDependencias({bool repetir = false}) async {
    setState(() {
      if (!repetir && AppConfig.instance.temDeps) {
        temFFmpeg = true;
        temFFprobe = true;
        return;
      }
      carregando = true;
      if (repetir) {
        temFFmpeg = null;
        temFFprobe = null;
      }
    });
    var (ffmpeg, ffprobe) = await FFmpegWrapper.verificarDependencias();
    Future.delayed(Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        temFFmpeg = ffmpeg;
        temFFprobe = ffprobe;
        carregando = false;
      });
    });
  }

  Color badgeColor(bool? x) {
    if (x == null) return Colors.yellow;
    if (x) return Colors.green;
    return Colors.red;
  }

  Widget get iconeRecarregar {
    if (carregando) {
      return SpinKitWave(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        size: 19.0,
      );
    }
    return Icon(Icons.refresh, size: 24);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card.outlined(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Badge(
                  smallSize: 8,
                  backgroundColor: badgeColor(temFFmpeg),
                  child: Text('FFmpeg   '),
                ),
              ),
            ),
            Card.outlined(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Badge(
                  smallSize: 8,
                  backgroundColor: badgeColor(temFFprobe),
                  child: Text('FFprobe   '),
                ),
              ),
            ),
            const SizedBox(width: 6),
            FilledButton.tonalIcon(
                onPressed: () => verificarDependencias(repetir: true),
                label: Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Text('Verificar novamente'),
                ),
                icon: iconeRecarregar)
          ],
        ),
        const SizedBox(height: 24),
        ConfigCard(),
        const SizedBox(height: 36),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 585),
          child: Card.outlined(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TabBar(
                    controller: _tabController,
                    splashBorderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.0),
                      topRight: Radius.circular(12.0),
                    ),
                    tabs: const [
                      Tab(
                        height: 50,
                        icon: FaIcon(FontAwesomeIcons.windows, size: 36),
                      ),
                      Tab(
                        height: 50,
                        icon: FaIcon(FontAwesomeIcons.linux, size: 36),
                      ),
                    ]),
                Expanded(
                  child: TabBarView(controller: _tabController, children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: WindowsTab(),
                      ),
                    ),
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: LinuxTab(),
                      ),
                    ),
                  ]),
                )
                //Text('data')
              ],
            ),
          ),
        )
      ],
    );
  }
}
