import 'package:flutter/material.dart';
import 'ad_list_tile_style.dart';

class NativeAdStylingModel {
  final AdListTileStyle headerTileStyle;
  final AdListTileStyle footerTileStyle;
  final TextStyle descriptionStyle;
  final TextStyle actionStyle;
  final double logoSize;
  final Color logoBackgroundColor;
  final Color loadingColor;
  final Color overlayColor;
  final Color onOverlayColor;
  final Color mediaBackgroundColor;
  final EdgeInsets mediaPadding;
  final double elevation;

  NativeAdStylingModel({
    this.mediaPadding = EdgeInsets.zero,
    required this.headerTileStyle,
    required this.footerTileStyle,
    required this.descriptionStyle,
    required this.actionStyle,
    this.logoSize = 40,
    this.logoBackgroundColor = Colors.indigo,
    this.loadingColor = Colors.indigo,
    this.overlayColor = Colors.black,
    this.onOverlayColor = Colors.white,
    this.mediaBackgroundColor = Colors.black,
    this.elevation = 5,
  });

  static NativeAdStylingModel defaultNativeAdStyling({
    double defaultTitleFontSize = 13,
    double defaultSubtitleFontSize = 12,
    double defaultActionFontSize = 14,
  }) {
    return NativeAdStylingModel(
      headerTileStyle: AdListTileStyle(
        tileHeight: 55,
        tileTitleAlignment: MainAxisAlignment.start,
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
      footerTileStyle: AdListTileStyle(
        tileTitleAlignment: MainAxisAlignment.spaceEvenly,
        tileElementsAlignment: CrossAxisAlignment.center,
        tileColor: Colors.indigo,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: defaultTitleFontSize,
        ),
        subtitleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: defaultSubtitleFontSize,
        ),
      ),
      descriptionStyle: TextStyle(
        color: Colors.black,
        fontSize: defaultSubtitleFontSize,
        fontWeight: FontWeight.normal,
      ),
      actionStyle: TextStyle(
        color: Colors.white,
        fontSize: defaultActionFontSize,
      ),
    );
  }
}
