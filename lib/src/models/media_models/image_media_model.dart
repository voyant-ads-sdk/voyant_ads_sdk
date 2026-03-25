import 'dart:typed_data';
import '../../widgets/helper.dart';
import 'media_model.dart';

/// Image media loaded from a local file path.
///
/// Useful for offline ads or bundled assets.
class LocalImageMediaModel implements ImageMediaModel {
  /// File path of the image.
  final String path;

  /// File path of the image.
  final double? imageHeight;

  /// Optional image width.
  final double? imageWidth;

  /// Creates a local image media model.
  LocalImageMediaModel({required this.path, this.imageHeight, this.imageWidth});

  @override
  double? get height => imageHeight;

  @override
  double? get width => imageWidth;
}

/// Image media loaded from a remote URL.
///
/// Used for network-based ad assets.
class UrlImageMediaModel implements ImageMediaModel {
  /// Remote image URL.
  final String url;

  /// Optional image height.
  final double? imageHeight;

  /// Optional image width.
  final double? imageWidth;

  /// Creates a URL image media model.
  UrlImageMediaModel({required this.url, this.imageHeight, this.imageWidth});

  @override
  double? get height => imageHeight;

  @override
  double? get width => imageWidth;

  /// Creates a [UrlImageMediaModel] from JSON response.
  ///
  /// Returns null if parsing fails.
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

/// Image media loaded from memory (raw bytes).
///
/// Useful for dynamically generated or downloaded images.
class MemoryImageMediaModel implements ImageMediaModel {
  /// Raw image bytes.
  final Uint8List bytes;

  /// Optional image height.
  final double? imageHeight;

  /// Optional image width.
  final double? imageWidth;

  /// Creates a memory-based image media model.
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
