//import 'dart:io';
import 'package:flutter/material.dart';
import '../models/height_models/ad_height_normalization.dart';
import '../models/media_models/image_media_model.dart';
import '../models/media_models/media_model.dart';
import 'package:universal_io/io.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'helper.dart';

class ImageAdWidget extends StatefulWidget {
  final ImageMediaModel model;
  final Color loadingColor;
  final bool fullScreenMode;
  final double reservedHeight;
  final BoxConstraints? constraints;
  final HeightConstraint? heightConstraint;

  const ImageAdWidget({
    super.key,
    required this.model,
    this.loadingColor = Colors.blue,
    this.fullScreenMode = false,
    this.heightConstraint,
    this.reservedHeight = 0,
    this.constraints,
  });

  @override
  State<ImageAdWidget> createState() => _ImageAdWidgetState();
}

class _ImageAdWidgetState extends State<ImageAdWidget> {
  Widget _getImageWidget(double? height, double? width) {
    if (widget.model is LocalImageMediaModel) {
      if (kIsWeb) {
        return const SizedBox.shrink();
      }
      final model = widget.model as LocalImageMediaModel;
      return Image.file(
        File(model.path),
        height: height,
        width: width,
        fit: BoxFit.contain,
      );
    } else if (widget.model is UrlImageMediaModel) {
      UrlImageMediaModel model = widget.model as UrlImageMediaModel;
      return Image.network(
        model.url,
        key: ValueKey(model.hashCode),
        height: height,
        width: width,
        fit: BoxFit.contain,
        frameBuilder:
            (
              BuildContext context,
              Widget child,
              int? frame,
              bool wasSynchronouslyLoaded,
            ) {
              if (wasSynchronouslyLoaded) {
                return child;
              }
              return AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: const Duration(seconds: 1),
                curve: Curves.easeOut,
                child: child,
              );
            },
        loadingBuilder:
            (BuildContext ctx, Widget child, ImageChunkEvent? progress) {
              if (progress == null) {
                return child;
              }
              return SizedBox(
                height: height,
                width: width,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(
                        color: widget.loadingColor,
                        value: progress.expectedTotalBytes != null
                            ? (progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!)
                            : null,
                      ),
                    ),
                  ),
                ),
              );
            },
        errorBuilder: (context, exception, stacktrace) {
          return Container(
            color: Colors.black,
            width: width,
            height: height,
            child: const Center(
              child: Icon(Icons.image_not_supported, color: Colors.red),
            ),
          );
        },
      );
    } else if (widget.model is MemoryImageMediaModel) {
      MemoryImageMediaModel model = widget.model as MemoryImageMediaModel;
      return Image.memory(
        model.bytes,
        height: height,
        width: width,
        fit: BoxFit.contain,
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget get mainWidget {
    if (widget.fullScreenMode) {
      return _getImageWidget(null, null);
    }
    return AdsHelper.getScaledMediaDimensions(
      constraints: widget.constraints,
      mediaHeight: widget.model.height,
      mediaWidth: widget.model.width,
      heightConstraint: widget.heightConstraint,
      reservedHeight: widget.reservedHeight,
      builder: (double? height, double? width) {
        return _getImageWidget(height, width);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: mainWidget);
  }
}
