import 'package:flutter/material.dart';

/// Styling configuration for an ad list tile.
///
/// Controls layout, spacing, colors, and text appearance
/// for tiles used in ad UI components.
class AdListTileStyle {
  /// Height of the tile container.
  final double tileHeight;

  /// Padding inside the tile.
  final EdgeInsets contentPadding;

  /// Background color of the tile.
  final Color tileColor;

  /// Text style for the title.
  final TextStyle titleTextStyle;

  /// Text style for the subtitle.
  final TextStyle subtitleTextStyle;

  /// Alignment of title and subtitle within the tile.
  final MainAxisAlignment tileTitleAlignment;

  /// Cross-axis alignment of elements inside the tile.
  final CrossAxisAlignment tileElementsAlignment;

  /// Creates an [AdListTileStyle] with customizable layout and styling options.
  AdListTileStyle({
    this.tileHeight = 60,
    this.tileColor = Colors.blue,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 5,
    ),
    required this.titleTextStyle,
    required this.subtitleTextStyle,
    this.tileTitleAlignment = MainAxisAlignment.spaceEvenly,
    this.tileElementsAlignment = CrossAxisAlignment.start,
  });
}
