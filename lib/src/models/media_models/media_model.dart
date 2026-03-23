sealed class MediaModel {}

abstract class ImageMediaModel extends MediaModel {
  double? get height;
  double? get width;
}

abstract class CarouselMediaModel extends MediaModel {
  List<ImageMediaModel> get imagesList;
}

abstract class VideoMediaModel extends MediaModel {
  final double? videoHeight;
  final double? videoWidth;
  // final int fileSize;

  VideoMediaModel({
    required this.videoHeight,
    required this.videoWidth,
    // required this.fileSize,
  });
}
