import 'package:flutter/material.dart';
import '../../../voyant_ads_sdk.dart';
import 'ad_list_tile_style.dart';

class RewardingAdStylingModel {
  final TextStyle headerTitleStyle;
  final TextStyle headerSubtitleStyle;
  final AdListTileStyle footerTileStyle;
  final TextStyle descriptionStyle;
  final TextStyle actionStyle;
  final double logoSize;
  final Color logoBackgroundColor;
  final Color loadingColor;
  final Color overlayColor;
  final Color onOverlayColor;
  final Color mediaBackgroundColor;

  RewardingAdStylingModel({
    required this.descriptionStyle,
    required this.actionStyle,
    this.logoSize = 100,
    this.logoBackgroundColor = Colors.blue,
    this.loadingColor = Colors.indigo,
    this.overlayColor = Colors.black,
    this.onOverlayColor = Colors.white,
    this.mediaBackgroundColor = Colors.black,
    required this.footerTileStyle,
    required this.headerTitleStyle,
    required this.headerSubtitleStyle,
  });

  static RewardingAdStylingModel defaultRewardingStyling({
    double defaultTitleFontSize = 13,
    double defaultSubtitleFontSize = 12,
    double defaultActionFontSize = 14,
  }) {
    return RewardingAdStylingModel(
      headerTitleStyle: TextStyle(
        color: Colors.white,
        fontSize: defaultTitleFontSize,
      ),
      headerSubtitleStyle: TextStyle(
        color: Colors.white,
        fontSize: defaultSubtitleFontSize,
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
        color: Colors.white,
        fontSize: defaultSubtitleFontSize,
      ),
      actionStyle: TextStyle(
        color: Colors.white,
        fontSize: defaultActionFontSize,
      ),
    );
  }
}
