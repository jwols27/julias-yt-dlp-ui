import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:transparent_image/transparent_image.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          spacing: 40,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 250),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  CircleAvatar(
                    radius: 96,
                    child: ClipOval(
                      child: FadeInImage.memoryNetwork(
                        fadeInDuration: Duration(milliseconds: 100),
                        placeholder: kTransparentImage,
                        image: 'https://github.com/jwols27.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  InkWell(
                      onTap: () =>
                          launchUrl(Uri.parse('https://github.com/jwols27')),
                      child: Text('Júlia P. Wolschick',
                          style: TextStyle(
                              fontSize: 18, color: Colors.purple[300]))),
                  Text('Criadora da interface que você está usando agora.',
                      textAlign: TextAlign.center),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 250),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  CircleAvatar(
                    radius: 96,
                    child: ClipOval(
                      child: FadeInImage.memoryNetwork(
                        fadeInDuration: Duration(milliseconds: 100),
                        placeholder: kTransparentImage,
                        image: 'https://github.com/yt-dlp.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  InkWell(
                      onTap: () =>
                          launchUrl(Uri.parse('https://github.com/yt-dlp')),
                      child: Text('yt-dlp',
                          style: TextStyle(fontSize: 18, color: Colors.blue))),
                  Text(
                      'Grupo que fez a ferramenta usada para baixar vídeos do YouTube.',
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 60),
        const Text('Agradecimentos especiais',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('José, por me dar a ideia de fazer esse aplicativo.')
      ],
    );
  }
}
