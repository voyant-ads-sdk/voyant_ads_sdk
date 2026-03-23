import 'package:flutter/material.dart';
import '../../../voyant_ads_sdk.dart';
import '../../models/data_models/video_embedded_ad_data_model.dart';
import '../../widgets/brand_logo_widget.dart';

class BottomTileWidget extends StatelessWidget {
  final VideoEmbeddedAdDataModel adModel;
  final VideoEmbeddedAdStylingModel styling;
  final Function(VideoEmbeddedAdDataModel adModel, EventType eventType)
  registerImpression;

  const BottomTileWidget({
    super.key,
    required this.adModel,
    required this.styling,
    required this.registerImpression,
  });

  @override
  Widget build(BuildContext context) {
    final overlayColor = styling.overlayColor.withValues(alpha: 0.5);
    return Container(
      color: overlayColor,
      child: AdListTile(
        leading: Container(
          padding: const EdgeInsets.all(2),
          color: styling.logoBackgroundColor,
          child: BrandLogoWidget(
            model: adModel.logoModel,
            height: styling.logoSize,
            width: styling.logoSize,
          ),
        ),
        title: "${adModel.footerTitle} • Sponsored",
        style: styling.footerTileStyle,
        subtitle: adModel.footerSubtitle,
        trailing: SizedBox(
          height: 30,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              side: BorderSide(width: 1, color: styling.onOverlayColor),
              textStyle: styling.actionStyle,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              visualDensity: VisualDensity.compact,
              minimumSize: const Size(0, 0),
            ),
            child: Text(
              adModel.actionText ?? 'VISIT',
              style: styling.actionStyle,
            ),
            onPressed: () {
              VoyantAds.instance.showAdTapWidget(
                adModel: adModel,
                context: context,
                onContinue: () {
                  registerImpression(adModel, EventType.click);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
