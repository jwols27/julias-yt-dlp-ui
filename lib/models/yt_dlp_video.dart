import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:julia_conversion_tool/models/yt_dlp_item.dart';

class YtDlpVideo {
  String id;
  String title;
  String url;
  String thumbnail;
  String channel;
  String channelUrl;
  int timestamp;
  int viewCount;
  List<YtDlpItem> items;

  YtDlpVideo(
      {required this.id, required this.title, required this.url, required this.thumbnail, required this.channel, required this.channelUrl, required this.items, required this.timestamp, required this.viewCount});

  String get timeAgo {
    timeago.setLocaleMessages('pt_BR', timeago.PtBrMessages());
    DateTime data = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return timeago.format(data, locale: 'pt_BR');
  }

  String get numViews {
    NumberFormat numberFormat = NumberFormat.decimalPattern('pt_BR')..maximumFractionDigits = 1;
    if (viewCount >= 1000000000) {
      return '${numberFormat.format(viewCount / 1000000000)} bi';
    } else if (viewCount >= 1000000) {
      return '${numberFormat.format(viewCount / 1000000)} mi';
    } else if (viewCount >= 1000) {
      return '${numberFormat.format(viewCount / 1000)} mil';
    } else {
      return numberFormat.format(viewCount);
    }
  }

  factory YtDlpVideo.fromJson(Map<String, dynamic> json, List<YtDlpItem> items, String url){
    return YtDlpVideo(
      id: json['id'] as String,
      title: json['title'] as String,
      url: url,
      thumbnail: json['thumbnail'] as String,
      channel: json['channel'] as String,
      channelUrl: json['channel_url'] as String,
      items: items,
      timestamp: json['timestamp'] as int,
      viewCount: json['view_count'] as int,
    );
  }
}