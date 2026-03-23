import 'package:flutter/material.dart';
import 'ad_list_tile_style.dart';

class NativeFullScreenAdStylingModel {
  final AdListTileStyle headerTileStyle;
  final AdListTileStyle footerTileStyle;
  final TextStyle descriptionStyle;
  final TextStyle actionStyle;
  final double logoSize;
  final Color logoBackgroundColor;
  final Color loadingColor;
  final Color mediaBackgroundColor;
  final Color overlayColor;
  final Color onOverlayColor;
  final EdgeInsets mediaPadding;

  NativeFullScreenAdStylingModel({
    required this.descriptionStyle,
    required this.actionStyle,
    this.logoSize = 40,
    this.logoBackgroundColor = Colors.indigo,
    this.loadingColor = Colors.indigo,
    this.overlayColor = Colors.black,
    this.onOverlayColor = Colors.white,
    this.mediaBackgroundColor = Colors.black,
    this.mediaPadding = EdgeInsets.zero,
    required this.headerTileStyle,
    required this.footerTileStyle,
  });

  static NativeFullScreenAdStylingModel defaultNativeFullScreenAdStyling({
    double defaultTitleFontSize = 13,
    double defaultSubtitleFontSize = 12,
    double defaultActionFontSize = 14,
  }) {
    return NativeFullScreenAdStylingModel(
      headerTileStyle: AdListTileStyle(
        tileHeight: 55,
        tileTitleAlignment: MainAxisAlignment.start,
        tileElementsAlignment: CrossAxisAlignment.center,
        tileColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: defaultTitleFontSize,
        ),
        subtitleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: defaultSubtitleFontSize,
        ),
      ),
      footerTileStyle: AdListTileStyle(
        tileTitleAlignment: MainAxisAlignment.spaceEvenly,
        tileElementsAlignment: CrossAxisAlignment.center,
        tileColor: Colors.transparent,
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
        color: Colors.white,
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
