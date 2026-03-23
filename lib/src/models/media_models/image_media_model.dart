import 'dart:typed_data';
import '../../widgets/helper.dart';
import 'media_model.dart';

class LocalImageMediaModel implements ImageMediaModel {
  final String path;
  final double? imageHeight;
  final double? imageWidth;

  LocalImageMediaModel({required this.path, this.imageHeight, this.imageWidth});

  @override
  double? get height => imageHeight;

  @override
  double? get width => imageWidth;
}

class UrlImageMediaModel implements ImageMediaModel {
  final String url;
  final double? imageHeight;
  final double? imageWidth;

  UrlImageMediaModel({required this.url, this.imageHeight, this.imageWidth});

  @override
  double? get height => imageHeight;

  @override
  double? get width => imageWidth;

  static UrlImageMediaModel? fromJson(json) {
    try {
      return UrlImageMediaModel(
        url: "https://${json['objectKey']}",
        imageHeight: AdsHelper.getDouble(json['height']),
        imageWidth: AdsHelper.getDouble(json['width']),
      );
    } catch (e) {
      return null;
    }
  }
}

class MemoryImageMediaModel implements ImageMediaModel {
  final Uint8List bytes;
  final double? imageHeight;
  final double? imageWidth;

  MemoryImageMediaModel({
    required this.bytes,
    this.imageHeight,
    this.imageWidth,
  });

  @override
  double? get height => imageHeight;

  @override
  double? get width => imageWidth;
}
