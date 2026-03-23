import 'package:flutter/material.dart';
import 'ad_list_tile_style.dart';

class MiniNativeAdStylingModel {
  final AdListTileStyle tileStyle;
  final Color actionButtonColor;
  final double logoSize;
  final Color logoBackgroundColor;
  final Color loadingColor;
  final Color actionButtonIconColor;
  final double elevation;

  MiniNativeAdStylingModel({
    required this.tileStyle,
    this.logoSize = 40,
    this.actionButtonColor = Colors.indigo,
    this.logoBackgroundColor = Colors.indigo,
    this.loadingColor = Colors.indigo,
    this.actionButtonIconColor = Colors.indigo,
    this.elevation = 5,
  });

  static MiniNativeAdStylingModel defaultMiniNativeAdStyling({
    double defaultTitleFontSize = 13,
    double defaultSubtitleFontSize = 12,
    double defaultActionFontSize = 14,
  }) {
    return MiniNativeAdStylingModel(
      elevation: 20,
      tileStyle: AdListTileStyle(
        tileHeight: 55,
        tileTitleAlignment: MainAxisAlignment.center,
        tileElementsAlignment: CrossAxisAlignment.center,
        tileColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: defaultTitleFontSize,
        ),
        subtitleTextStyle: TextStyle(
          color: Colors.grey,
          fontSize: defaultSubtitleFontSize,
        ),
      ),
    );
  }
}
