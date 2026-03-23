import '../../widgets/helper.dart';
import 'media_model.dart';

class URLVideoMediaModel implements VideoMediaModel {
  final String url;
  @override
  final double? videoHeight;
  @override
  final double? videoWidth;
  // @override
  // final int fileSize;

  URLVideoMediaModel({
    required this.url,
    this.videoHeight,
    this.videoWidth,
    // required this.fileSize,
  });

  static URLVideoMediaModel? fromJson(json) {
    try {
      return URLVideoMediaModel(
        url: "https://${json['objectKey']}",
        videoHeight: AdsHelper.getDouble(json['height']),
        videoWidth: AdsHelper.getDouble(json['width']),
        // fileSize: AdsHelper.getInt(json['fileSize']),
      );
    } catch (e) {
      return null;
    }
  }
}

class MemoryVideoMediaModel implements VideoMediaModel {
  final String path;
  @override
  final double? videoHeight;
  @override
  final double? videoWidth;
  // @override
  // final int fileSize;

  MemoryVideoMediaModel({
    required this.path,
    this.videoHeight,
    this.videoWidth,
    // required this.fileSize,
  });
}
