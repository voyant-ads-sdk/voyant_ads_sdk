import 'dart:async';
import 'package:flutter/material.dart';
import '../../../voyant_ads_sdk.dart';
import '../../models/data_models/video_embedded_ad_data_model.dart';
import '../../widgets/carousel_ad_widget.dart';
import '../../widgets/helper.dart';

class EmbeddedCarouselAd extends StatefulWidget {
  final VideoEmbeddedAdDataModel adModel;
  final VideoEmbeddedAdStylingModel styling;
  final Widget bottomTileWidget;
  final Function() onCompletion;

  const EmbeddedCarouselAd({
    super.key,
    required this.adModel,
    required this.styling,
    required this.onCompletion,
    required this.bottomTileWidget,
  });

  @override
  State<EmbeddedCarouselAd> createState() => _EmbeddedCarousalAdState();
}

class _EmbeddedCarousalAdState extends State<EmbeddedCarouselAd> {
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
          CarouselAdWidget(
            model: widget.adModel.mediaModel as CarouselMediaModel,
            fullScreenMode: true,
            loadingColor: widget.styling.loadingColor,
            footerWidget: widget.bottomTileWidget,
            showDots: true,
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
