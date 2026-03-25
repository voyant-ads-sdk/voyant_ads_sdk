import 'package:flutter/material.dart';
import '../../../voyant_ads_sdk.dart';
import 'ad_list_tile_style.dart';

/// Styling model for Rewarding (reward-based) ads.
///
/// Used for full-screen, user-initiated ad flows where
/// users receive a reward upon successful completion.
class RewardingAdStylingModel {
  /// Style for header title text.
  final TextStyle headerTitleStyle;

  /// Style for header subtitle text.
  final TextStyle headerSubtitleStyle;

  /// Footer tile styling (CTA + metadata).
  final AdListTileStyle footerTileStyle;

  /// Style for ad description text.
  final TextStyle descriptionStyle;

  /// Style for action button / CTA.
  final TextStyle actionStyle;

  /// Size of advertiser logo.
  final double logoSize;

  /// Background color behind logo.
  final Color logoBackgroundColor;

  /// Loading indicator color.
  final Color loadingColor;

  /// Overlay color applied on media.
  final Color overlayColor;

  /// Color for elements displayed on overlay.
  final Color onOverlayColor;

  /// Background color behind media.
  final Color mediaBackgroundColor;

  /// Creates a rewarding ad styling configuration.
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

  /// Default styling for rewarding ads.
  ///
  /// Optimized for full-screen dark UI with clear CTA visibility.
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
