import '../media_models/carousel_media_model.dart';
import '../media_models/image_media_model.dart';
import '../media_models/media_model.dart';
import '../media_models/video_media_model.dart';

abstract base class AdDataModel {
  String get token;
  String get adId;
  String get destinationUrl;
  String get destinationUrlStatus;
  MediaModel? get mediaModel;
  Map get reportsData;
  int get impressionsCount;
  int get clicksCount;
  String get category;

  static List<String> getTokensList(tokensJson) {
    return (tokensJson as List?)?.map((e) => e.toString()).toList() ?? [];
  }

  static MediaModel? getMediaFromJson(element) {
    if (element['imageData'] != null) {
      return UrlImageMediaModel.fromJson(element['imageData']);
    } else if (element['videoData'] != null) {
      return URLVideoMediaModel.fromJson(element['videoData']);
    } else if (element['carouselData'] != null) {
      return UrlCarouselMediaModel.fromJson(element['carouselData']);
    } else {
      return null;
    }
  }
}
