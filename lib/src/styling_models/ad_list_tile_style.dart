import 'package:flutter/material.dart';

class AdListTileStyle {
  final double tileHeight;
  final EdgeInsets contentPadding;
  final Color tileColor;
  final TextStyle titleTextStyle;
  final TextStyle subtitleTextStyle;
  final MainAxisAlignment tileTitleAlignment;
  final CrossAxisAlignment tileElementsAlignment;

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
