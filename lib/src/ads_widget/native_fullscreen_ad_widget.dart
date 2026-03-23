import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../voyant_ads_sdk.dart';
import '../models/data_models/native_fullscreen_ad_data_model.dart';
import '../widgets/brand_logo_widget.dart';
import '../widgets/carousel_ad_widget.dart';
import '../widgets/image_ad_widget.dart';
import '../widgets/video_ad_widget.dart';

class NativeFullScreenAdWidget extends StatefulWidget {
  final NativeFullScreenAdStylingModel styling;
  final Widget? placeholderWidget;
  final NativeFullScreenAdDataModel? initialData;
  final NativeFullScreenAdDataModel? Function() fetchAd;
  final Function(NativeFullScreenAdDataModel adModel, EventType eventType)
  registerImpression;

  const NativeFullScreenAdWidget({
    super.key,
    required this.styling,
    this.placeholderWidget,
    this.initialData,
    required this.fetchAd,
    required this.registerImpression,
  });

  @override
  State<NativeFullScreenAdWidget> createState() =>
      _NativeFullScreenAdWidgetState();
}

class _NativeFullScreenAdWidgetState extends State<NativeFullScreenAdWidget> {
  final double _minHeight = 200;
  final double _minWidth = 200;
  Timer? timer;
  bool hadImpression = false;
  late final Color _overlayColor;
  String uniqueId = Uuid().v4();
  //
  NativeFullScreenAdDataModel? currentAd;
  Timer? refreshTimer;
  final int _refreshSeconds = 30;
  final int _retrySeconds = 10;

  @override
  void initState() {
    super.initState();
    _overlayColor = widget.styling.overlayColor.withValues(alpha: 0.5);
    currentAd = widget.initialData ?? widget.fetchAd();
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    timer?.cancel();
    super.dispose();
  }

  void _startRefreshTimer() {
    refreshTimer?.cancel();
    refreshTimer = Timer.periodic(
      Duration(seconds: _refreshSeconds),
      (_) => _tryRefreshAd(),
    );
  }

  void _tryRefreshAd() {
    final newAd = widget.fetchAd();
    if (newAd == null) {
      refreshTimer?.cancel();
      refreshTimer = Timer(Duration(seconds: _retrySeconds), _tryRefreshAd);
      return;
    }
    if (!mounted) return;
    refreshTimer?.cancel();
    refreshTimer = Timer.periodic(
      Duration(seconds: _refreshSeconds),
      (_) => _tryRefreshAd(),
    );
    timer?.cancel();
    timer = null;
    setState(() {
      uniqueId = Uuid().v4();
      hadImpression = false;
      currentAd = newAd;
    });
  }

  Widget get _nullWidget {
    if (widget.placeholderWidget != null) {
      return widget.placeholderWidget!;
    }
    return const SizedBox.shrink();
  }

  Widget bottomTile(NativeFullScreenAdDataModel adModel) {
    Uri url = Uri.parse(adModel.destinationUrl);
    String tempUrl = adModel.destinationUrl;
    if (url.scheme != '') {
      tempUrl = url.origin;
    }
    return AdListTile(
      title: adModel.footerTitle ?? adModel.headerTitle,
      style: widget.styling.footerTileStyle,
      subtitle: adModel.footerSubtitle != null
          ? adModel.footerSubtitle!
          : tempUrl,
      trailing: SizedBox(
        height: 30,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            side: BorderSide(width: 1, color: widget.styling.onOverlayColor),
            textStyle: TextStyle(color: widget.styling.onOverlayColor),
          ),
          child: Text(
            adModel.actionText ?? 'VISIT',
            style: widget.styling.actionStyle,
          ),
          onPressed: () {
            VoyantAds.instance.showAdTapWidget(
              adModel: adModel,
              context: context,
              onContinue: () {
                widget.registerImpression(adModel, EventType.click);
              },
            );
          },
        ),
      ),
    );
  }

  _handleNativeAdVisibility(
    VisibilityInfo visibilityInfo,
    NativeFullScreenAdDataModel adModel,
  ) {
    if (hadImpression) return;
    if (visibilityInfo.size.width < _minWidth ||
        visibilityInfo.size.height < _minHeight) {
      timer?.cancel();
      timer = null;
      return;
    }
    if (visibilityInfo.visibleFraction >= 0.75) {
      timer ??= Timer(const Duration(seconds: 1), () {
        widget.registerImpression(adModel, EventType.impression);
        hadImpression = true;
        timer = null;
        _startRefreshTimer();
      });
    } else {
      timer?.cancel();
      timer = null;
    }
  }

  Widget _getMainWidget(NativeFullScreenAdDataModel adModel) {
    if (adModel.mediaModel is VideoMediaModel) {
      return Container(
        color: widget.styling.mediaBackgroundColor,
        margin: widget.styling.mediaPadding,
        child: VideoAdWidget(
          mediaBackgroundColor: widget.styling.mediaBackgroundColor,
          model: adModel.mediaModel as VideoMediaModel,
          fullScreenMode: true,
          loadingColor: widget.styling.loadingColor,
          footerWidget: getBottomWidget(adModel),
          onOverlayColor: widget.styling.onOverlayColor,
          overlayColor: _overlayColor,
        ),
      );
    } else if (adModel.mediaModel is CarouselMediaModel) {
      return Container(
        margin: widget.styling.mediaPadding,
        color: widget.styling.mediaBackgroundColor,
        child: CarouselAdWidget(
          model: adModel.mediaModel as CarouselMediaModel,
          fullScreenMode: true,
          loadingColor: widget.styling.loadingColor,
          footerWidget: getBottomWidget(adModel),
        ),
      );
    } else if (adModel.mediaModel is ImageMediaModel) {
      return Container(
        margin: widget.styling.mediaPadding,
        color: widget.styling.mediaBackgroundColor,
        child: Stack(
          children: [
            ImageAdWidget(
              model: adModel.mediaModel as ImageMediaModel,
              fullScreenMode: true,
              loadingColor: widget.styling.loadingColor,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: getBottomWidget(adModel),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget getBottomWidget(NativeFullScreenAdDataModel adModel) {
    return Container(
      color: _overlayColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (adModel.adDescription != null)
            Padding(
              padding: EdgeInsets.only(
                top: widget.styling.headerTileStyle.contentPadding.top,
                left: widget.styling.headerTileStyle.contentPadding.left,
                right: widget.styling.headerTileStyle.contentPadding.right,
              ),
              child: Text(
                adModel.adDescription!,
                style: widget.styling.descriptionStyle,
              ),
            ),
          AdListTile(
            leading: Container(
              padding: const EdgeInsets.all(2),
              color: widget.styling.logoBackgroundColor,
              child: BrandLogoWidget(
                model: adModel.logoModel,
                height: widget.styling.logoSize,
                width: widget.styling.logoSize,
              ),
            ),
            title: "${adModel.headerTitle} • Sponsored",
            subtitle: adModel.headerSubtitle,
            style: widget.styling.headerTileStyle,
          ),
          bottomTile(adModel),
        ],
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   if (currentAd != null) {
  //     return VisibilityDetector(
  //       key: ValueKey('${widget.initialData!.adId}_$uniqueId'),
  //       onVisibilityChanged: (info) =>
  //           _handleNativeAdVisibility(info, widget.initialData!),
  //       child: _getMainWidget(widget.initialData!),
  //     );
  //   } else {
  //     return _nullWidget;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    if (currentAd != null) {
      return VisibilityDetector(
        key: ValueKey('${currentAd!.adId}_$uniqueId'),
        onVisibilityChanged: (info) =>
            _handleNativeAdVisibility(info, currentAd!),
        child: _getMainWidget(currentAd!),
      );
    } else {
      return _nullWidget;
    }
  }
}
