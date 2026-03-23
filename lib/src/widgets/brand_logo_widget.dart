import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../models/media_models/image_media_model.dart';
import '../models/media_models/media_model.dart';

class BrandLogoWidget extends StatefulWidget {
  final ImageMediaModel model;
  final double? height;
  final double? width;
  final Color loadingColor;
  const BrandLogoWidget({
    super.key,
    required this.model,
    this.height,
    this.width,
    this.loadingColor = Colors.white,
  });

  @override
  State<BrandLogoWidget> createState() => _BrandLogoWidgetState();
}

class _BrandLogoWidgetState extends State<BrandLogoWidget> {
  Widget get mainWidget {
    if (widget.model is LocalImageMediaModel) {
      if (kIsWeb) {
        return const SizedBox.shrink();
      }
      LocalImageMediaModel model = widget.model as LocalImageMediaModel;
      return Image.file(
        File(model.path),
        fit: BoxFit.cover,
        width: widget.width,
        height: widget.height,
      );
    } else if (widget.model is UrlImageMediaModel) {
      UrlImageMediaModel model = widget.model as UrlImageMediaModel;
      return Image.network(
        model.url,
        height: widget.height,
        width: widget.width,
        fit: BoxFit.cover,
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
                width: widget.width,
                height: widget.height,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: CircularProgressIndicator(
                    color: widget.loadingColor,
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
        errorBuilder: (context, exception, stacktrace) {
          return Container(
            color: Colors.black,
            width: widget.width,
            height: widget.height,
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
        fit: BoxFit.cover,
        width: widget.width,
        height: widget.height,
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return mainWidget;
  }
}
