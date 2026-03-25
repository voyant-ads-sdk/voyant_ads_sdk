/// Base abstraction for all media types used in ads.
///
/// Media can be images, carousels, or videos.
sealed class MediaModel {}

/// Base model for image-based media.
///
/// Represents a single image with optional dimensions.
abstract class ImageMediaModel extends MediaModel {
  /// Height of the image in pixels (if known).
  double? get height;

  /// Width of the image in pixels (if known).
  double? get width;
}

/// Model for carousel media.
///
/// Represents a collection of images displayed in sequence.
abstract class CarouselMediaModel extends MediaModel {
  /// List of images included in the carousel.
  List<ImageMediaModel> get imagesList;
}

/// Model for video-based media.
///
/// Used for embedded or fullscreen video ads.
abstract class VideoMediaModel extends MediaModel {
  /// Height of the video in pixels.
  final double? videoHeight;

  /// Width of the video in pixels.
  final double? videoWidth;

  /// Creates a video media model.
  VideoMediaModel({required this.videoHeight, required this.videoWidth});
}
