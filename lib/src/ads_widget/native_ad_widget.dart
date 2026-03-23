import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../voyant_ads_sdk.dart';
import '../models/data_models/native_ad_data_model.dart';
import '../widgets/brand_logo_widget.dart';
import '../widgets/carousel_ad_widget.dart';
import '../widgets/helper.dart';
import '../widgets/image_ad_widget.dart';
import '../widgets/video_ad_widget.dart';

class NativeAdWidget extends StatefulWidget {
  final NativeAdStylingModel styling;
  final Widget? placeholderWidget;
  final NativeAdDataModel? initialData;
  final NativeAdDataModel? Function() fetchAd;
  final HeightConstraint heightConstraint;
  final double width;
  final Function(NativeAdDataModel adModel, EventType eventType)
  registerImpression;

  const NativeAdWidget({
    super.key,
    required this.styling,
    this.initialData,
    this.placeholderWidget,
    required this.registerImpression,
    required this.heightConstraint,
    this.width = double.infinity,
    required this.fetchAd,
  });

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  final double _minHeight = 200;
  final double _minWidth = 200;
  Timer? timer;
  bool hadImpression = false;
  late final Color _overlayColor;
  NativeAdModelWrapper? currentModel;
  String uniqueId = Uuid().v4();
  //
  Timer? refreshTimer;
  VisibilityInfo? visibilityInfo;
  final int _refreshSeconds = 30;
  final int _retrySeconds = 10;

  @override
  void initState() {
    super.initState();
    _overlayColor = widget.styling.overlayColor.withValues(alpha: 0.5);
    NativeAdDataModel? firstAd = widget.initialData ?? widget.fetchAd();
    if (firstAd != null) {
      currentModel = NativeAdModelWrapper(
        adModel: firstAd,
        reservedHeight: _reservedHeight(firstAd),
      );
    }
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
    if (kDebugMode) print("debug: _tryRefreshAd: called");
    final newAd = widget.fetchAd();
    if (newAd == null) {
      if (kDebugMode) print("debug: _tryRefreshAd: new ad null");
      refreshTimer?.cancel();
      refreshTimer = Timer(Duration(seconds: _retrySeconds), _tryRefreshAd);
      return;
    }
    if (!mounted) return;
    if (kDebugMode) print("debug: _tryRefreshAd: new ad recived");
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
      currentModel = NativeAdModelWrapper(
        adModel: newAd,
        reservedHeight: _reservedHeight(newAd),
      );
    });
  }

  double _reservedHeight(NativeAdDataModel ad) {
    return widget.styling.headerTileStyle.tileHeight +
        widget.styling.footerTileStyle.tileHeight +
        _getDescriptionSize(ad) +
        widget.styling.mediaPadding.top +
        widget.styling.mediaPadding.bottom;
  }

  Widget get _nullWidget {
    if (widget.placeholderWidget != null) {
      return widget.placeholderWidget!;
    }
    return const SizedBox.shrink();
  }

  Widget _bottomTile(NativeAdDataModel adModel) {
    Uri url = Uri.parse("https://${adModel.destinationUrl}");
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
    NativeAdDataModel adModel,
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

  Widget _getMediaWidget(
    NativeAdModelWrapper wrapper,
    BoxConstraints constraints,
  ) {
    if (wrapper.adModel.mediaModel is VideoMediaModel) {
      return Container(
        margin: widget.styling.mediaPadding,
        color: widget.styling.mediaBackgroundColor,
        child: VideoAdWidget(
          model: wrapper.adModel.mediaModel as VideoMediaModel,
          fullScreenMode: false,
          mediaBackgroundColor: widget.styling.mediaBackgroundColor,
          loadingColor: widget.styling.loadingColor,
          onOverlayColor: widget.styling.onOverlayColor,
          overlayColor: _overlayColor,
          heightConstraint: widget.heightConstraint,
          constraints: constraints,
          reservedHeight: wrapper.reservedHeight,
        ),
      );
    } else if (wrapper.adModel.mediaModel is CarouselMediaModel) {
      return Container(
        margin: widget.styling.mediaPadding,
        color: widget.styling.mediaBackgroundColor,
        child: CarouselAdWidget(
          model: wrapper.adModel.mediaModel as CarouselMediaModel,
          fullScreenMode: false,
          loadingColor: widget.styling.loadingColor,
          heightConstraint: widget.heightConstraint,
          constraints: constraints,
          reservedHeight: wrapper.reservedHeight,
        ),
      );
    } else if (wrapper.adModel.mediaModel is ImageMediaModel) {
      return Container(
        margin: widget.styling.mediaPadding,
        color: widget.styling.mediaBackgroundColor,
        child: ImageAdWidget(
          model: wrapper.adModel.mediaModel as ImageMediaModel,
          fullScreenMode: false,
          loadingColor: widget.styling.loadingColor,
          heightConstraint: widget.heightConstraint,
          constraints: constraints,
          reservedHeight: wrapper.reservedHeight,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  double _getDescriptionSize(NativeAdDataModel adModel) {
    if (adModel.adDescription == null) return 0;
    Size size = AdsHelper.calculateTextSize(
      text: adModel.adDescription!,
      style: widget.styling.descriptionStyle,
      context: context,
    );
    return size.height +
        widget.styling.headerTileStyle.contentPadding.top +
        widget.styling.headerTileStyle.contentPadding.bottom;
  }

  Widget _getMainWidget(
    BoxConstraints constraints,
    NativeAdModelWrapper? adModel,
  ) {
    if (adModel == null) {
      return _nullWidget;
    }
    return VisibilityDetector(
      key: ValueKey('${adModel.adModel.adId}_$uniqueId'),
      onVisibilityChanged: (info) {
        visibilityInfo = info;
        _handleNativeAdVisibility(info, adModel.adModel);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AdListTile(
            style: widget.styling.headerTileStyle,
            leading: Container(
              padding: const EdgeInsets.all(2),
              color: widget.styling.logoBackgroundColor,
              child: BrandLogoWidget(
                model: adModel.adModel.logoModel,
                height: widget.styling.logoSize,
                width: widget.styling.logoSize,
              ),
            ),
            title: "${adModel.adModel.headerTitle} • Sponsored",
            subtitle: adModel.adModel.headerSubtitle,
          ),
          if (adModel.adModel.adDescription != null)
            Container(
              alignment: Alignment.centerLeft,
              color: widget.styling.headerTileStyle.tileColor,
              padding: EdgeInsets.only(
                bottom: widget.styling.headerTileStyle.contentPadding.bottom,
                left: widget.styling.headerTileStyle.contentPadding.left,
                right: widget.styling.headerTileStyle.contentPadding.right,
              ),
              child: Text(
                adModel.adModel.adDescription!,
                style: widget.styling.descriptionStyle,
              ),
            ),
          _getMediaWidget(adModel, constraints),
          _bottomTile(adModel.adModel),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: widget.styling.elevation,
      child: SizedBox(
        width: widget.width,
        child: LayoutBuilder(
          builder: (BuildContext ctx2, BoxConstraints constraints) {
            return _getMainWidget(constraints, currentModel);
          },
        ),
      ),
    );
  }
}

class NativeAdModelWrapper {
  final NativeAdDataModel adModel;
  final double reservedHeight;

  NativeAdModelWrapper({required this.adModel, required this.reservedHeight});
}
