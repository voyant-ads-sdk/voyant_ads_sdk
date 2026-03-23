import 'dart:async';
import 'package:flutter/material.dart';
import '../../../voyant_ads_sdk.dart';
import '../../models/data_models/video_embedded_ad_data_model.dart';
import '../../widgets/helper.dart';
import '../../widgets/image_ad_widget.dart';

class EmbeddedImageAd extends StatefulWidget {
  final VideoEmbeddedAdDataModel adModel;
  final VideoEmbeddedAdStylingModel styling;
  final Widget bottomTileWidget;
  final Function() onCompletion;

  const EmbeddedImageAd({
    super.key,
    required this.adModel,
    required this.styling,
    required this.onCompletion,
    required this.bottomTileWidget,
  });

  @override
  State<EmbeddedImageAd> createState() => _EmbeddedImageAdState();
}

class _EmbeddedImageAdState extends State<EmbeddedImageAd> {
  final int adSkipDuration = 8;
  final ValueNotifier<int> timeElapsed = ValueNotifier<int>(0);
  Timer? timeElapsedTimer;
  late final Color _overlayColor;

  @override
  void initState() {
    super.initState();
    _overlayColor = widget.styling.overlayColor.withValues(alpha: 0.5);
    timeElapsedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      timeElapsed.value = timeElapsed.value + 1;
      if (timeElapsed.value >= adSkipDuration) {
        timer.cancel();
        widget.onCompletion.call();
      }
    });
  }

  @override
  void dispose() {
    timeElapsed.dispose();
    timeElapsedTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.styling.mediaBackgroundColor,
      child: Stack(
        children: [
          ImageAdWidget(
            model: widget.adModel.mediaModel as ImageMediaModel,
            fullScreenMode: true,
            loadingColor: widget.styling.loadingColor,
          ),
          Positioned(
            top: 5,
            right: 5,
            child: ValueListenableBuilder(
              valueListenable: timeElapsed,
              builder: (ctx, int duration, _) {
                return AdsHelper.getOverlayTextButtonWidget(
                  'Ad ends in ${adSkipDuration - duration}',
                  overlayColor: _overlayColor,
                  onOverlayColor: widget.styling.onOverlayColor,
                );
              },
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: widget.bottomTileWidget,
          ),
        ],
      ),
    );
  }
}
