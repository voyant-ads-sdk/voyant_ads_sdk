import 'package:flutter/foundation.dart';

import '../media_models/image_media_model.dart';
import '../media_models/media_model.dart';
import 'ad_data_model.dart';

final class NativeFullScreenAdDataModel extends AdDataModel {
  @override
  final String adId;
  final ImageMediaModel logoModel;
  final String headerTitle;
  final String headerSubtitle;
  final String? adDescription;
  final String? footerTitle;
  final String? footerSubtitle;
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

  NativeFullScreenAdDataModel({
    required this.adId,
    required this.logoModel,
    required this.headerTitle,
    required this.headerSubtitle,
    this.adDescription,
    this.footerTitle,
    this.footerSubtitle,
    required this.destinationUrl,
    required this.mediaModel,
    this.actionText,
    required this.token,
    required this.destinationUrlStatus,
    required this.reportsData,
    required this.impressionsCount,
    required this.clicksCount,
    required this.category,
  });

  static List<NativeFullScreenAdDataModel> fromJson(json) {
    try {
      List<NativeFullScreenAdDataModel> res = [];
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
                NativeFullScreenAdDataModel(
                  adId: element['campId'],
                  category: element['category'],
                  logoModel: logoMedia,
                  mediaModel: mediaModel,
                  headerTitle: element['primaryTitle'],
                  headerSubtitle: element['primarySubtitle'],
                  adDescription: element['description'],
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
          } else {}
        }
      }
      return res;
    } catch (e) {
      if (kDebugMode) print(e);
      return [];
    }
  }
}
