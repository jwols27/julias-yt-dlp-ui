import 'package:flutter/material.dart';
import 'package:julia_conversion_tool/classes/yt_dlp_video.dart';
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
        Flexible(
            child: InkWell(
                onTap: () => launchUrl(Uri.parse(video.url)),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(video.thumbnail)))),
        Flexible(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                  onTap: () => launchUrl(Uri.parse(video.url)),
                  child: Text(video.title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 24))),
              InkWell(
                onTap: () => launchUrl(Uri.parse(video.channelUrl)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2,
                  children: [
                    Icon(
                      Icons.account_circle,
                      color: Colors.blue,
                      size: 18,
                    ),
                    Text(video.channel, style: TextStyle(color: Colors.blue)),
                  ],
                ),
              ),
              Text('${video.numViews} visualizações'),
              Text(video.timeAgo),
            ],
          ),
        ),
      ],
    );
  }
}
