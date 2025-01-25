import 'package:flutter/material.dart';
import 'package:julia_conversion_tool/arquivo.dart';
import 'package:julia_conversion_tool/info.dart';
import 'package:julia_conversion_tool/youtube.dart';

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
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.file_open), text: 'Converter Arquivo',),
              Tab(icon: Icon(Icons.subscriptions), text: 'Baixar do YouTube'),
              Tab(icon: Icon(Icons.info), text: 'Créditos'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Padding(
              padding: EdgeInsets.all(20.0),
              child: ArquivoPage(),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: YoutubePage(),
            ),
            InfoPage(),
          ],
        ),
      ),
    );
  }
}
