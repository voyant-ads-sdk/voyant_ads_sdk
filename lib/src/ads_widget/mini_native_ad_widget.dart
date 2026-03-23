import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../voyant_ads_sdk.dart';
import '../models/data_models/mini_native_ad_data_model.dart';
import '../widgets/brand_logo_widget.dart';

class MiniNativeAdWidget extends StatefulWidget {
  final MiniNativeAdStylingModel styling;
  final Widget? placeholderWidget;
  final MiniNativeAdDataModel? initialData;
  final MiniNativeAdDataModel? Function() fetchAd;
  final Function(MiniNativeAdDataModel adModel, EventType eventType)
  registerImpression;

  const MiniNativeAdWidget({
    super.key,
    this.initialData,
    this.placeholderWidget,
    required this.styling,
    required this.registerImpression,
    required this.fetchAd,
  });

  @override
  State<MiniNativeAdWidget> createState() => _MiniNativeAdWidgetState();
}

class _MiniNativeAdWidgetState extends State<MiniNativeAdWidget> {
  bool hadImpression = false;
  Timer? timer;
  final double _minHeight = 35;
  final double _minWidth = 150;
  VisibilityInfo? visibilityInfo;
  String uniqueId = Uuid().v4();
  Timer? refreshTimer;
  MiniNativeAdDataModel? currentAd;
  final int _refreshSeconds = 30;
  final int _retrySeconds = 10;

  @override
  void initState() {
    super.initState();
    currentAd = widget.initialData;
  }

  @override
  void dispose() {
    timer?.cancel();
    refreshTimer?.cancel();
    super.dispose();
  }

  void _startRefreshTimer() {
    if (kDebugMode) print("debug: _startRefreshTimer: starting:=>");
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
      // 🔥 retry faster (10s)
      refreshTimer?.cancel();
      refreshTimer = Timer(Duration(seconds: _retrySeconds), _tryRefreshAd);
      return;
    }
    if (kDebugMode) print("debug: _tryRefreshAd: new ad recived");
    // ✅ got new ad → restart normal 45s cycle
    refreshTimer?.cancel();
    refreshTimer = Timer.periodic(
      Duration(seconds: _refreshSeconds),
      (_) => _tryRefreshAd(),
    );
    setState(() {
      uniqueId = Uuid().v4();
      currentAd = newAd;
      hadImpression = false;
    });
  }

  Widget get _nullWidget {
    if (widget.placeholderWidget != null) {
      return widget.placeholderWidget!;
    }
    return const SizedBox.shrink();
  }

  _handleNativeAdVisibility(
    VisibilityInfo visibilityInfo,
    MiniNativeAdDataModel adModel,
  ) {
    if (hadImpression) {
      return;
    }
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
        _startRefreshTimer();
      });
    } else {
      timer?.cancel();
      timer = null;
    }
  }

  Widget _getMainWidget() {
    if (currentAd == null) {
      return _nullWidget;
    }
    return VisibilityDetector(
      key: ValueKey('${currentAd!.adId}_$uniqueId'),
      child: AdListTile(
        title: "${currentAd!.title} • Sponsored",
        subtitle: currentAd!.subtitle,
        style: widget.styling.tileStyle,
        leading: Container(
          padding: const EdgeInsets.all(2),
          color: widget.styling.logoBackgroundColor,
          child: BrandLogoWidget(
            model: currentAd!.logoModel,
            height: widget.styling.logoSize,
            width: widget.styling.logoSize,
          ),
        ),
        trailing: IconButton(
          splashRadius: 5,
          visualDensity: VisualDensity.comfortable,
          splashColor: widget.styling.actionButtonIconColor,
          icon: Icon(Icons.chevron_right),
          iconSize: 22,
          color: widget.styling.actionButtonIconColor,
          onPressed: () {
            VoyantAds.instance.showAdTapWidget(
              adModel: currentAd!,
              context: context,
              onContinue: () {
                widget.registerImpression(currentAd!, EventType.click);
              },
            );
          },
        ),
      ),
      onVisibilityChanged: (info) {
        if (currentAd != null) {
          visibilityInfo = info;
          _handleNativeAdVisibility(info, currentAd!);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: widget.styling.elevation,
      child: _getMainWidget(),
    );
  }
}
