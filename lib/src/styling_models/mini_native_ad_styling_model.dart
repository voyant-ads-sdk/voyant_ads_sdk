import 'package:flutter/material.dart';
import 'ad_list_tile_style.dart';

/// Styling model for Mini Native ads.
///
/// Defines layout, colors, elevation, and UI behavior
/// for compact ad placements typically used in lists or feeds.
class MiniNativeAdStylingModel {
  /// Tile styling configuration for layout and text.
  final AdListTileStyle tileStyle;

  /// Background color of the action button.
  final Color actionButtonColor;

  /// Size of the logo displayed in the ad.
  final double logoSize;

  /// Background color behind the logo.
  final Color logoBackgroundColor;

  /// Color used for loading indicators.
  final Color loadingColor;

  /// Icon color inside the action button.
  final Color actionButtonIconColor;

  /// Elevation applied to the ad container.
  final double elevation;

  /// Creates a [MiniNativeAdStylingModel] with customizable styling options.
  MiniNativeAdStylingModel({
    required this.tileStyle,
    this.logoSize = 40,
    this.actionButtonColor = Colors.indigo,
    this.logoBackgroundColor = Colors.indigo,
    this.loadingColor = Colors.indigo,
    this.actionButtonIconColor = Colors.indigo,
    this.elevation = 5,
  });

  /// Provides a default styling configuration for Mini Native ads.
  ///
  /// Allows optional customization of font sizes.
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
