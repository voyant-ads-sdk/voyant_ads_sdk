import 'package:flutter/foundation.dart';

import '../media_models/image_media_model.dart';
import '../media_models/media_model.dart';
import 'ad_data_model.dart';

final class VideoEmbeddedAdDataModel extends AdDataModel {
  @override
  final String adId;
  final ImageMediaModel logoModel;
  final String footerTitle;
  final String footerSubtitle;
  @override
  final String destinationUrl;
  final String? actionText;
  @override
  final MediaModel mediaModel;
  @override
  final String token;
  @override
  final String destinationUrlStatus;
  @override
  final Map reportsData;
  @override
  final int impressionsCount;
  @override
  final int clicksCount;
  @override
  final String category;

  VideoEmbeddedAdDataModel({
    required this.adId,
    required this.logoModel,
    required this.footerTitle,
    required this.footerSubtitle,
    required this.destinationUrl,
    this.actionText,
    required this.mediaModel,
    required this.token,
    required this.destinationUrlStatus,
    required this.reportsData,
    required this.impressionsCount,
    required this.clicksCount,
    required this.category,
  });

  static List<VideoEmbeddedAdDataModel> fromJson(json) {
    try {
      List<VideoEmbeddedAdDataModel> res = [];
      if (json is List) {
        for (var element in json) {
          final List<String> tokens = AdDataModel.getTokensList(
            element['tokens'],
          );
          if (tokens.isNotEmpty) {
            UrlImageMediaModel? logoMedia = UrlImageMediaModel.fromJson(
              element['logoData'],
            );
            MediaModel? mediaModel = AdDataModel.getMediaFromJson(element);
            if (mediaModel == null) continue;
            if (logoMedia == null) continue;
            if (element['category'] == null) continue;
            for (String token in tokens) {
              res.add(
                VideoEmbeddedAdDataModel(
                  adId: element['campId'],
                  category: element['category'],
                  logoModel: logoMedia,
                  mediaModel: mediaModel,
                  footerTitle: element['secondaryTitle'],
                  footerSubtitle: element['secondarySubtitle'],
                  actionText: element['actionText'],
                  destinationUrl: element['destinationURL'],
                  token: token,
                  destinationUrlStatus: element['urlStatus'],
                  reportsData: element['reportsData'] ?? {},
                  impressionsCount: element['impressionsCount'] ?? 0,
                  clicksCount: element['clicksCount'] ?? 0,
                ),
              );
            }
          }
        }
      }
      return res;
    } catch (e) {
      if (kDebugMode) print(e);
      return [];
    }
  }
}
