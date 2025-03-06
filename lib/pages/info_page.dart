import 'package:flutter/material.dart';
import 'package:julias_yt_dlp_ui/app_config.dart';
import 'package:julias_yt_dlp_ui/widgets/skeleton_network_image.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  Color juliaColor(BuildContext context) {
    return AppConfig.instance.modoEscuro.value ? Theme.of(context).colorScheme.onPrimary : Colors.deepPurple[300]!;
  }

  Widget imageContainer(Widget child, Color color) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 4),
      ),
      child: CircleAvatar(
        radius: 96,
        child: ClipOval(child: child),
      ),
    );
  }

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
                  SkeletonNetworkImage(
                      url: 'https://github.com/jwols27.png',
                      bone: const Bone.circle(
                        size: 192,
                      ),
                      renderWidget: (child) => imageContainer(child, juliaColor(context))),
                  const SizedBox(height: 10),
                  InkWell(
                      onTap: () => launchUrl(Uri.parse('https://github.com/jwols27')),
                      child: Text(
                        'Júlia P. Wolschick',
                        style: TextStyle(fontSize: 18, color: juliaColor(context), fontWeight: FontWeight.bold),
                      )),
                  Text('Criadora da interface que você está usando agora.', textAlign: TextAlign.center),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 250),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  SkeletonNetworkImage(
                      url: 'https://github.com/yt-dlp.png',
                      bone: const Bone.circle(
                        size: 192,
                      ),
                      renderWidget: (child) => imageContainer(child, Colors.red[300]!)),
                  const SizedBox(height: 10),
                  InkWell(
                      onTap: () => launchUrl(Uri.parse('https://github.com/yt-dlp')),
                      child: Text('yt-dlp',
                          style: TextStyle(fontSize: 18, color: Colors.red[300]!, fontWeight: FontWeight.bold))),
                  Text('Grupo que fez a ferramenta usada para baixar vídeos do YouTube.', textAlign: TextAlign.center),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 60),
        const Text('Agradecimentos especiais', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('José, por me dar a ideia de fazer esse aplicativo.')
      ],
    );
  }
}
