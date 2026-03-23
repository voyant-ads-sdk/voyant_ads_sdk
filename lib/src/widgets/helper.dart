import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../voyant_ads_sdk.dart';
import '../models/height_models/ad_height_normalization.dart';
import 'string_extensions.dart';
import 'video_ad_widget.dart';

sealed class AdsHelper {
  //single tab only
  static Size calculateTextSize({
    required String text,
    required TextStyle style,
    required BuildContext context,
  }) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr, //Directionality.of(context),
      textScaler: TextScaler.noScaling, //MediaQuery.of(context).textScaler,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  static double? getDouble(var data) {
    if (data == null) {
      return null;
    } else if (data is double) {
      return data;
    } else if (data is int) {
      return data.toDouble();
    } else if (data is String) {
      return data.getDoubleValue;
    } else {
      return double.parse(data);
    }
  }

  static int? getInt(var data) {
    if (data == null) {
      return null;
    } else if (data is double) {
      return data.toInt();
    } else if (data is int) {
      return data;
    } else if (data is String) {
      return data.getIntValue;
    } else {
      return int.parse(data);
    }
  }

  static bool getBool(var data) {
    if (data is bool) {
      return data;
    } else if (data is String) {
      if (data == "1" || data == "true") {
        return true;
      } else {
        return false;
      }
    } else if (data is int) {
      if (data == 1) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  static Widget getScaledMediaDimensions({
    BoxConstraints? constraints,
    double? mediaHeight,
    double? mediaWidth,
    required double reservedHeight,
    HeightConstraint? heightConstraint,
    required Widget Function(double? height, double? width) builder,
  }) {
    if (constraints == null || heightConstraint == null) {
      return builder(null, null);
    }
    // 1️⃣ Resolve usable maxHeight
    double maxHeight;
    if (heightConstraint is FixedHeightConstraint) {
      maxHeight = heightConstraint.height;
    } else if (heightConstraint is MaxHeightConstraint) {
      maxHeight = heightConstraint.height;
    } else {
      maxHeight = constraints.maxHeight;
    }
    //maxHeight = maxHeight.clamp(0, constraints.maxHeight) - reservedHeight;
    maxHeight = math.max(
      0.0,
      math.min(maxHeight, constraints.maxHeight) - reservedHeight,
    );
    if (maxHeight <= 0) {
      return builder(0, constraints.maxWidth);
    }
    // 2️⃣ If media size missing → reserve space only
    if (mediaWidth == null || mediaHeight == null) {
      return builder(maxHeight, constraints.maxWidth);
    }
    // 3️⃣ Aspect-fit media
    return _commonDimensionAdjustments(
      mediaHeight: mediaHeight,
      mediaWidth: mediaWidth,
      maxHeight: maxHeight,
      constraints: constraints,
      builder: builder,
    );
  }

  static Widget _commonDimensionAdjustments({
    required double mediaHeight,
    required double mediaWidth,
    required double maxHeight,
    required BoxConstraints constraints,
    required Widget Function(double? height, double? width) builder,
  }) {
    final aspect = mediaWidth / mediaHeight;
    double height = math.min(mediaHeight, maxHeight);
    double width = height * aspect;
    if (width > constraints.maxWidth) {
      width = constraints.maxWidth;
      height = width / aspect;
    }
    return builder(height, width);
  }

  static Widget getOverlayTextButtonWidget(
    String text, {
    Function()? onTap,
    Color? overlayColor,
    Color? onOverlayColor,
  }) {
    return MouseRegion(
      cursor: onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: overlayColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            text,
            style: TextStyle(color: onOverlayColor, fontSize: 13),
          ),
        ),
      ),
    );
  }

  static Widget getAdSkipByDurationWidget(
    ValueNotifier<DurationState> durationState, {
    required int adSkipDuration,
    Color? overlayColor,
    Color? onOverlayColor,
    required Function() onSkip,
  }) {
    return ValueListenableBuilder(
      valueListenable: durationState,
      builder: (ctx3, DurationState duration, _) {
        if (duration.total.inSeconds < adSkipDuration) {
          return AdsHelper.getOverlayTextButtonWidget(
            'Video ends in ${duration.total.inSeconds - duration.progress.inSeconds}',
            overlayColor: overlayColor,
            onOverlayColor: onOverlayColor,
          );
        }
        int temp = adSkipDuration - duration.progress.inSeconds;
        if (temp < 0) {
          return AdsHelper.getOverlayTextButtonWidget(
            'Skip Now (Ends in ${duration.total.inSeconds - duration.progress.inSeconds})',
            onTap: onSkip,
            overlayColor: overlayColor,
            onOverlayColor: onOverlayColor,
          );
        } else {
          return AdsHelper.getOverlayTextButtonWidget(
            'Skip in $temp',
            overlayColor: overlayColor,
            onOverlayColor: onOverlayColor,
          );
        }
      },
    );
  }
}

class MediaWidgetWrapper {
  final Widget data;
  final bool isExpanded;

  MediaWidgetWrapper(this.data, this.isExpanded);
}
