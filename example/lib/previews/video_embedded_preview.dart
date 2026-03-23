import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:voyant_ads_sdk/voyant_ads_sdk.dart';

class VideoEmbeddedAdPreview extends StatefulWidget {
  const VideoEmbeddedAdPreview({super.key});

  @override
  State<VideoEmbeddedAdPreview> createState() => _VideoEmbeddedAdPreviewState();
}

class _VideoEmbeddedAdPreviewState extends State<VideoEmbeddedAdPreview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        toolbarHeight: 40,
        backgroundColor: Colors.transparent,
        title: Text(
          'Embedded Ad Preview',
          style: TextStyle(fontSize: 12, color: Colors.white),
        ),
      ),
      body: Center(
        child: SizedBox(
          child: VoyantAds.instance.getVideoPlayerWithEmbeddedAdsWidget(
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
            showAdAfterEverySeconds: 5,
            testMode: true,
            heightConstraint: MaxHeightConstraint(700),
            onFullscreenToggle: (bool isFullScreen) {
              if (isFullScreen == false) {
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                  DeviceOrientation.portraitDown,
                ]);
              }
            },
            styling: VideoEmbeddedAdStylingModel(
              logoSize: 30,
              actionStyle: TextStyle(color: Colors.white, fontSize: 10),
              footerTileStyle: AdListTileStyle(
                tileHeight: 45,
                tileTitleAlignment: MainAxisAlignment.spaceEvenly,
                tileElementsAlignment: CrossAxisAlignment.center,
                tileColor: Colors.black.withValues(alpha: 0.1),
                titleTextStyle: TextStyle(color: Colors.white, fontSize: 11),
                subtitleTextStyle: TextStyle(color: Colors.white, fontSize: 10),
              ),
              overlayColor: Colors.black.withValues(alpha: 0.1),
              onOverlayColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
