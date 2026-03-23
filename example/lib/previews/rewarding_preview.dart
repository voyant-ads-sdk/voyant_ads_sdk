import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:voyant_ads_sdk/voyant_ads_sdk.dart';

class RewardingAdPreview extends StatefulWidget {
  const RewardingAdPreview({super.key});

  @override
  State<RewardingAdPreview> createState() => _RewardingAdPreviewState();
}

class _RewardingAdPreviewState extends State<RewardingAdPreview> {
  int points = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        toolbarHeight: 40,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Rewarding Ad Preview',
          style: TextStyle(fontSize: 12, color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "$points points",
              style: const TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              icon: const Icon(Icons.ad_units, color: Colors.blue, size: 15),
              label: const Text(
                'Show Ad for 100 points',
                style: TextStyle(color: Colors.blue, fontSize: 12),
              ),
              onPressed: () {
                VoyantAds.instance.showRewardingAd(
                  styling: RewardingAdStylingModel(
                    headerTitleStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    headerSubtitleStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    footerTileStyle: AdListTileStyle(
                      tileTitleAlignment: MainAxisAlignment.spaceEvenly,
                      tileElementsAlignment: CrossAxisAlignment.center,
                      tileColor: Colors.indigo,
                      titleTextStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      subtitleTextStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    descriptionStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                    actionStyle: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  testMode: true,
                  context: context,
                  onSuccess: () {
                    points = points + 100;
                    setState(() {});
                    if (kDebugMode) print('[rewarding ad] -> success');
                  },
                  onFailure: () {
                    if (kDebugMode) print('[rewarding ad] -> fail');
                  },
                  onAdRepoEmpty: () {
                    if (kDebugMode) print('[rewarding ad] -> no ads');
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
