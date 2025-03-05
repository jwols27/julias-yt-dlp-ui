import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SkeletonNetworkImage extends StatelessWidget {
  const SkeletonNetworkImage({super.key, required this.url, required this.bone, required this.renderWidget});
  final String url;
  final Bone bone;
  final Widget Function(Widget child) renderWidget;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      frameBuilder: (_, Widget child, int? frame, __) {
        if (frame != null) return child;
        return bone;
      },
      loadingBuilder: (_, Widget child, __) {
        return Skeletonizer.zone(enabled: true, child: renderWidget(child));
      },
    );
  }
}
