import 'package:flutter/material.dart';
import 'package:voyant_ads_sdk/voyant_ads_sdk.dart';

class NativeFullScreenAdPreview extends StatefulWidget {
  const NativeFullScreenAdPreview({super.key});

  @override
  State<NativeFullScreenAdPreview> createState() =>
      _NativeFullScreenAdPreviewState();
}

class _NativeFullScreenAdPreviewState extends State<NativeFullScreenAdPreview> {
  Widget get mainWidget {
    return PageView.builder(
      itemCount: 50,
      scrollDirection: Axis.vertical,
      itemBuilder: (ctx, index) {
        if (index % 5 == 0) {
          return VoyantAds.instance.getNativeFullScreenAdWidget(
            testMode: true,
            placeholderWidget: const SizedBox.shrink(),
            styling: NativeFullScreenAdStylingModel(
              logoSize: 30,
              headerTileStyle: AdListTileStyle(
                tileHeight: 45,
                tileTitleAlignment: MainAxisAlignment.start,
                tileElementsAlignment: CrossAxisAlignment.center,
                tileColor: Colors.transparent,
                titleTextStyle: TextStyle(color: Colors.white, fontSize: 11),
                subtitleTextStyle: TextStyle(color: Colors.white, fontSize: 10),
              ),
              footerTileStyle: AdListTileStyle(
                tileHeight: 45,
                tileTitleAlignment: MainAxisAlignment.spaceEvenly,
                tileElementsAlignment: CrossAxisAlignment.center,
                tileColor: Colors.transparent,
                titleTextStyle: TextStyle(color: Colors.white, fontSize: 11),
                subtitleTextStyle: TextStyle(color: Colors.white, fontSize: 10),
              ),
              descriptionStyle: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.normal,
              ),
              actionStyle: TextStyle(color: Colors.white, fontSize: 10),
            ),
          );
        }
        return const Center(
          child: Text(
            'Sample fullscreen widget',
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: mainWidget,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        toolbarHeight: 40,
        backgroundColor: Colors.transparent,
        title: Text(
          'Native Fullscreen Ad example',
          style: TextStyle(fontSize: 12, color: Colors.white),
        ),
      ),
    );
  }
}
