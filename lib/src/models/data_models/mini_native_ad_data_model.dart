import 'package:flutter/foundation.dart';

import '../../../voyant_ads_sdk.dart';
import 'ad_data_model.dart';

final class MiniNativeAdDataModel extends AdDataModel {
  final ImageMediaModel logoModel;
  final String title;
  final String subtitle;
  @override
  final String adId;
  @override
  final String destinationUrl;
  @override
  final String destinationUrlStatus;
  @override
  MediaModel? mediaModel;
  @override
  final Map reportsData;
  @override
  final int impressionsCount;
  @override
  final int clicksCount;
  @override
  final String category;
  @override
  final String token;

  MiniNativeAdDataModel({
    required this.adId,
    required this.logoModel,
    required this.title,
    required this.subtitle,
    required this.destinationUrl,
    required this.destinationUrlStatus,
    required this.reportsData,
    required this.impressionsCount,
    required this.clicksCount,
    required this.category,
    required this.token,
  });

  static List<MiniNativeAdDataModel> fromJson(json) {
    try {
      List<MiniNativeAdDataModel> res = [];
      if (json is List) {
        for (var element in json) {
          final List<String> tokens =
              (element['tokens'] as List?)?.map((e) => e.toString()).toList() ??
              [];
          if (tokens.isNotEmpty) {
            UrlImageMediaModel? media = UrlImageMediaModel.fromJson(
              element['logoData'],
            );
            if (media != null && element['category'] != null) {
              for (String token in tokens) {
                res.add(
                  MiniNativeAdDataModel(
                    adId: element['campId'],
                    category: element['category'],
                    logoModel: media,
                    title: element['primaryTitle'],
                    subtitle: element['primarySubtitle'],
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
