import 'package:flutter/material.dart';
import 'package:voyant_ads_sdk/voyant_ads_sdk.dart';
import 'sample_list_widget.dart';

class NativeAdPreview extends StatefulWidget {
  const NativeAdPreview({super.key});

  @override
  State<NativeAdPreview> createState() => _NativeAdPreviewState();
}

class _NativeAdPreviewState extends State<NativeAdPreview> {
  Widget get _adWidget {
    return VoyantAds.instance.getNativeAdWidget(
      testMode: true,
      heightConstraint: FixedHeightConstraint(400),
      placeholderWidget: const SizedBox.shrink(),
      styling: NativeAdStylingModel(
        logoSize: 30,
        logoBackgroundColor: Theme.of(context).primaryColor,
        descriptionStyle: const TextStyle(color: Colors.black, fontSize: 12),
        actionStyle: const TextStyle(color: Colors.white, fontSize: 10),
        headerTileStyle: AdListTileStyle(
          tileHeight: 45,
          tileTitleAlignment: MainAxisAlignment.start,
          tileElementsAlignment: CrossAxisAlignment.center,
          tileColor: Colors.white,
          titleTextStyle: const TextStyle(color: Colors.black, fontSize: 11),
          subtitleTextStyle: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
        footerTileStyle: AdListTileStyle(
          tileHeight: 45,
          tileTitleAlignment: MainAxisAlignment.spaceEvenly,
          tileElementsAlignment: CrossAxisAlignment.center,
          tileColor: Colors.indigo,
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 11),
          subtitleTextStyle: const TextStyle(color: Colors.white, fontSize: 10),
        ),
      ),
    );
  }

  Widget get mainWidget {
    return ListView.separated(
      separatorBuilder: (ctx, index) {
        return Container(height: 5, color: Colors.grey.shade200);
      },
      itemCount: 50,
      itemBuilder: (ctx, index) {
        if (index % 5 == 0) {
          return _adWidget;
        }
        return SampleListWidget();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        toolbarHeight: 40,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Native Ad example',
          style: TextStyle(fontSize: 12, color: Colors.white),
        ),
      ),
      body: mainWidget,
    );
  }
}
