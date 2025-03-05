import 'package:flutter/material.dart';
import 'package:julias_yt_dlp_ui/pages/config_page/config_page.dart';
import 'package:julias_yt_dlp_ui/pages/info_page.dart';
import 'package:julias_yt_dlp_ui/pages/youtube_page/youtube_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.subscriptions), text: 'Baixar do YouTube'),
            Tab(
              icon: Icon(Icons.settings),
              text: 'Configurações',
            ),
            Tab(icon: Icon(Icons.info), text: 'Créditos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: YoutubePage(
              tabController: _tabController,
            ),
          ),
          SingleChildScrollView(
            child: const Padding(
              padding: EdgeInsets.all(30.0),
              child: ConfigPage(),
            ),
          ),
          const InfoPage(),
        ],
      ),
    );
  }
}
