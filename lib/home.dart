import 'package:flutter/material.dart';
import 'package:julia_conversion_tool/pages/pages.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.subscriptions), text: 'Baixar do YouTube'),
              Tab(icon: Icon(Icons.file_open), text: 'Converter Arquivo',),
              Tab(icon: Icon(Icons.info), text: 'Créditos'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Padding(
              padding: EdgeInsets.all(30.0),
              child: YoutubePage(),
            ),
            Padding(
              padding: EdgeInsets.all(30.0),
              child: ArquivoPage(),
            ),
            InfoPage(),
          ],
        ),
      ),
    );
  }
}
