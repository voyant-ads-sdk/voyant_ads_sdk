import 'image_media_model.dart';
import 'media_model.dart';

/// Carousel media using local image assets.
///
/// Useful for offline or bundled carousel ads.
class LocalCarouselMediaModel implements CarouselMediaModel {
  /// List of local images in the carousel.
  @override
  final List<LocalImageMediaModel> imagesList;

  /// Creates a local carousel media model.
  LocalCarouselMediaModel({required this.imagesList});
}

/// Carousel media loaded from remote URLs.
///
/// Used for network-delivered ad carousels.
class UrlCarouselMediaModel implements CarouselMediaModel {
  /// List of remote images in the carousel.
  @override
  final List<UrlImageMediaModel> imagesList;

  /// Creates a URL-based carousel media model.
  UrlCarouselMediaModel({required this.imagesList});

  /// Parses a carousel from JSON response.
  ///
  /// Skips invalid image entries and returns null if parsing fails.
  static UrlCarouselMediaModel? fromJson(json) {
    try {
      List<UrlImageMediaModel> imagesList = [];
      for (var element in json) {
        UrlImageMediaModel? image = UrlImageMediaModel.fromJson(element);
        if (image != null) {
          imagesList.add(image);
        }
      }
      return UrlCarouselMediaModel(imagesList: imagesList);
    } catch (e) {
      return null;
    }
  }
}

/// Carousel media using in-memory images.
///
/// Useful for dynamically generated or preloaded content.
class MemoryCarouselMediaModel implements CarouselMediaModel {
  /// List of in-memory images in the carousel.
  @override
  final List<MemoryImageMediaModel> imagesList;

  /// Creates a memory-based carousel media model.
  MemoryCarouselMediaModel({required this.imagesList});
}
