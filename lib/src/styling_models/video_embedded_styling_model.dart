import 'package:flutter/material.dart';
import '../../../voyant_ads_sdk.dart';
import 'ad_list_tile_style.dart';

/// Styling model for video embedded ads.
///
/// Used when ads are displayed inside a video player with
/// overlay UI elements such as CTA and metadata.
class VideoEmbeddedAdStylingModel {
  /// Footer tile styling (CTA + metadata overlay).
  final AdListTileStyle footerTileStyle;

  /// Style for action button / CTA.
  final TextStyle actionStyle;

  /// Size of advertiser logo.
  final double logoSize;

  /// Background color behind logo.
  final Color logoBackgroundColor;

  /// Loading indicator color.
  final Color loadingColor;

  /// Overlay color applied on video content.
  final Color overlayColor;

  /// Color used for elements displayed on overlay.
  final Color onOverlayColor;

  /// Background color behind video/media.
  final Color mediaBackgroundColor;

  /// Creates a styling configuration for embedded video ads.
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

  /// Default styling for embedded video ads.
  ///
  /// Optimized for overlay-based controls on top of video playback.
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
