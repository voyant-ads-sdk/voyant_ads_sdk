import 'image_media_model.dart';
import 'media_model.dart';

class LocalCarouselMediaModel implements CarouselMediaModel {
  @override
  final List<LocalImageMediaModel> imagesList;

  LocalCarouselMediaModel({required this.imagesList});
}

class UrlCarouselMediaModel implements CarouselMediaModel {
  @override
  final List<UrlImageMediaModel> imagesList;

  UrlCarouselMediaModel({required this.imagesList});

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

class MemoryCarouselMediaModel implements CarouselMediaModel {
  @override
  final List<MemoryImageMediaModel> imagesList;

  MemoryCarouselMediaModel({required this.imagesList});
}
