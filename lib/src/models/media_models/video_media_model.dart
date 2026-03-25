import '../../widgets/helper.dart';
import 'media_model.dart';

/// Video media loaded from a remote URL.
///
/// Used for streaming video ads or network-based media delivery.
class URLVideoMediaModel implements VideoMediaModel {
  /// Remote video URL.
  final String url;
  @override
  final double? videoHeight;
  @override
  final double? videoWidth;

  /// Creates a URL-based video media model.
  URLVideoMediaModel({required this.url, this.videoHeight, this.videoWidth});

  /// Parses a video model from JSON response.
  ///
  /// Returns null if parsing fails.
  static URLVideoMediaModel? fromJson(json) {
    try {
      return URLVideoMediaModel(
        url: "https://${json['objectKey']}",
        videoHeight: AdsHelper.getDouble(json['height']),
        videoWidth: AdsHelper.getDouble(json['width']),
      );
    } catch (e) {
      return null;
    }
  }
}

/// Video media loaded from local storage.
///
/// Useful for cached or pre-downloaded video ads.
class MemoryVideoMediaModel implements VideoMediaModel {
  /// Local file path of the video.
  final String path;
  @override
  final double? videoHeight;
  @override
  final double? videoWidth;

  /// Creates a local video media model.
  MemoryVideoMediaModel({
    required this.path,
    this.videoHeight,
    this.videoWidth,
  });
}
