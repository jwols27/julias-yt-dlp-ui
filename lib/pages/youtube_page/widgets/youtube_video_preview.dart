import 'package:flutter/material.dart';
import 'package:julias_yt_dlp_ui/models/yt_dlp_video.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoPreview extends StatelessWidget {
  const VideoPreview({super.key, required this.video});
  final YtDlpVideo video;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        InkWell(
            onTap: () => launchUrl(Uri.parse(video.url)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 384,
                height: 216,
                alignment: Alignment.center,
                color: Theme.of(context).colorScheme.outlineVariant,
                child: FadeInImage.memoryNetwork(
                  fadeInDuration: Duration(milliseconds: 100),
                  placeholder: kTransparentImage,
                  image: video.thumbnail,
                  fit: BoxFit.cover,
                ),
              ),
            )),
        Flexible(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                  onTap: () => launchUrl(Uri.parse(video.url)),
                  child: Text(video.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24))),
              const SizedBox(height: 4),
              InkWell(
                onTap: () => launchUrl(Uri.parse(video.channelUrl)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2,
                  children: [
                    Icon(
                      Icons.account_circle,
                      color: Colors.blue,
                      size: 24,
                    ),
                    Text(video.channel, style: TextStyle(color: Colors.blue, fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text('${video.numViews} visualizações', style: TextStyle(fontSize: 16)),
              Text(video.timeAgo, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }
}
