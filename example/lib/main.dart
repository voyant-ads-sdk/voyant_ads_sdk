import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:voyant_ads_sdk/voyant_ads_sdk.dart';
import 'package:media_kit/media_kit.dart';
import 'previews/mini_native_preview.dart';
import 'previews/native_fullscreen_preview.dart';
import 'previews/native_preview.dart';
import 'previews/rewarding_preview.dart';
import 'previews/video_embedded_preview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await VoyantAds.instance.ensureInitialized(
    appId: 'XXXXXXXXXXXXXXXX',
    apiKey: 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
    sdkSecret:
        'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
  );
  VoyantAds.instance.addDummyData();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Uint8List> loadAssetBytes(String assetKey) async {
    final ByteData data = await rootBundle.load(assetKey);
    return data.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        // ✅ IMPORTANT
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: const Text('Voyant Ads Example')),
            body: HomePageWidget(),
            //body: VideoPlayerPage(),
          );
        },
      ),
    );
  }
}

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  @override
  Widget build(BuildContext context) {
    VoyantAds.instance.enableAutoFetch(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            child: const Text('SHOW miniNative'),
            onPressed: () async {
              await VoyantAds.instance.ensureAdsAvailable(
                adType: AdType.miniNative,
              );
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MiniNativeAdPreview()),
              );
            },
          ),

          TextButton(
            child: const Text('SHOW native'),
            onPressed: () async {
              await VoyantAds.instance.ensureAdsAvailable(
                adType: AdType.native,
              );
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NativeAdPreview()),
              );
            },
          ),

          TextButton(
            child: const Text('SHOW nativeFullscreen'),
            onPressed: () async {
              await VoyantAds.instance.ensureAdsAvailable(
                adType: AdType.nativeFullscreen,
              );
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NativeFullScreenAdPreview()),
              );
            },
          ),

          TextButton(
            child: const Text('SHOW rewarding'),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RewardingAdPreview()),
              );
            },
          ),

          TextButton(
            child: const Text('SHOW videoEmbedded'),
            onPressed: () async {
              await VoyantAds.instance.ensureAdsAvailable(
                adType: AdType.videoEmbedded,
              );
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => VideoEmbeddedAdPreview()),
              );
            },
          ),
        ],
      ),
    );
  }
}
