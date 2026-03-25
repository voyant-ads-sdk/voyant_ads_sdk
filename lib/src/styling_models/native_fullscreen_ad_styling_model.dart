import 'package:flutter/material.dart';
import 'ad_list_tile_style.dart';

/// Styling model for Native Fullscreen ads.
///
/// Designed for immersive, edge-to-edge ad experiences with
/// overlay-based UI and high-visibility layouts.
class NativeFullScreenAdStylingModel {
  /// Header tile styling (top overlay section).
  final AdListTileStyle headerTileStyle;

  /// Header tile styling (top overlay section).
  final AdListTileStyle footerTileStyle;

  /// Text style for ad description.
  final TextStyle descriptionStyle;

  /// Text style for action button / CTA.
  final TextStyle actionStyle;

  /// Size of the advertiser logo.
  final double logoSize;

  /// Background color behind logo.
  final Color logoBackgroundColor;

  /// Loading indicator color.
  final Color loadingColor;

  /// Background color behind media content.
  final Color mediaBackgroundColor;

  /// Overlay color applied on media (e.g., dim effect).
  final Color overlayColor;

  /// Color used for elements displayed on overlay.
  final Color onOverlayColor;

  /// Padding around media content.
  final EdgeInsets mediaPadding;

  /// Creates a fullscreen native ad styling configuration.
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

  /// Default styling for fullscreen native ads.
  ///
  /// Optimized for dark overlays and immersive UI.
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
