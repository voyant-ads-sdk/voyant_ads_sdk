import 'package:flutter/material.dart';
import 'package:voyant_ads_sdk/voyant_ads_sdk.dart';

import 'sample_list_widget.dart';

class MiniNativeAdPreview extends StatefulWidget {
  const MiniNativeAdPreview({super.key});

  @override
  State<MiniNativeAdPreview> createState() => _MiniNativeAdPreviewState();
}

class _MiniNativeAdPreviewState extends State<MiniNativeAdPreview> {
  Widget get mainWidget {
    return ListView.separated(
      separatorBuilder: (ctx, index) {
        return Container(height: 5, color: Colors.grey.shade100);
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

  Widget get _adWidget {
    return VoyantAds.instance.getMiniNativeAdWidget(
      placeholderWidget: const SizedBox.shrink(),
      testMode: true,
      styling: MiniNativeAdStylingModel(
        logoSize: 30,
        elevation: 0,
        tileStyle: AdListTileStyle(
          tileHeight: 45,
          tileTitleAlignment: MainAxisAlignment.center,
          tileElementsAlignment: CrossAxisAlignment.center,
          tileColor: Colors.white,
          titleTextStyle: const TextStyle(color: Colors.black, fontSize: 11),
          subtitleTextStyle: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
        actionButtonColor: Theme.of(context).primaryColor,
      ),
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
          'Mini Native Ad example',
          style: TextStyle(fontSize: 12, color: Colors.white),
        ),
      ),
      backgroundColor: Colors.white,
      body: mainWidget,
    );
  }
}
