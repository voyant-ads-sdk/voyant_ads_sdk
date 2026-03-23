import 'package:flutter/material.dart';
import '../../../voyant_ads_sdk.dart';
import 'ad_list_tile_style.dart';

class VideoEmbeddedAdStylingModel {
  final AdListTileStyle footerTileStyle;
  final TextStyle actionStyle;
  final double logoSize;
  final Color logoBackgroundColor;
  final Color loadingColor;
  final Color overlayColor;
  final Color onOverlayColor;
  final Color mediaBackgroundColor;

  VideoEmbeddedAdStylingModel({
    required this.footerTileStyle,
    required this.actionStyle,
    this.logoSize = 40,
    this.logoBackgroundColor = Colors.blue,
    this.loadingColor = Colors.indigo,
    this.overlayColor = Colors.black,
    this.onOverlayColor = Colors.white,
    this.mediaBackgroundColor = Colors.black,
  });

  static VideoEmbeddedAdStylingModel defaultVideoEmbeddedAdStyling({
    double defaultTitleFontSize = 14,
    double defaultSubtitleFontSize = 12,
    double defaultActionFontSize = 14,
  }) {
    return VideoEmbeddedAdStylingModel(
      actionStyle: TextStyle(
        color: Colors.white,
        fontSize: defaultActionFontSize,
      ),
      footerTileStyle: AdListTileStyle(
        tileTitleAlignment: MainAxisAlignment.spaceEvenly,
        tileElementsAlignment: CrossAxisAlignment.center,
        tileColor: Colors.black.withValues(alpha: 0.1),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: defaultTitleFontSize,
        ),
        subtitleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: defaultSubtitleFontSize,
        ),
      ),
      overlayColor: Colors.black.withValues(alpha: 0.1),
      onOverlayColor: Colors.white,
    );
  }
}
