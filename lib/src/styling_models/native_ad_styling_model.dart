import 'package:flutter/material.dart';
import 'ad_list_tile_style.dart';

/// Styling model for full Native ads.
///
/// Controls layout, media presentation, overlays, text styles,
/// and overall appearance of native ad components.
class NativeAdStylingModel {
  /// Header tile styling (top section of the ad).
  final AdListTileStyle headerTileStyle;

  /// Footer tile styling (bottom section of the ad).
  final AdListTileStyle footerTileStyle;

  /// Text style for the ad description.
  final TextStyle descriptionStyle;

  /// Text style for the action button or CTA.
  final TextStyle actionStyle;

  /// Size of the advertiser logo.
  final double logoSize;

  /// Background color behind the logo.
  final Color logoBackgroundColor;

  /// Color used for loading indicators.
  final Color loadingColor;

  /// Overlay color applied on media (e.g., video/image).
  final Color overlayColor;

  /// Color of elements displayed on top of overlay.
  final Color onOverlayColor;

  /// Background color behind media content.
  final Color mediaBackgroundColor;

  /// Padding around the media component.
  final EdgeInsets mediaPadding;

  /// Elevation applied to the ad container.
  final double elevation;

  /// Creates a [NativeAdStylingModel] with customizable styling options.
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

  /// Provides a default styling configuration for Native ads.
  ///
  /// Allows optional customization of font sizes.
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
