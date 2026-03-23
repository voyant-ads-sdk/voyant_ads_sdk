// import 'package:flutter/material.dart';
// import 'package:voyant_ads_sdk/flutter_ads_sdk.dart';

// import '../../../frames/mobile_frame.dart';
// import '../widgets/sample_list_widget.dart';

// class MiniBannerAdPreview extends StatefulWidget {
//   final ImageMediaModel logoModel;
//   final String bannerTitle;
//   final String bannerSubtitle;
//   final String destinationUrl;

//   const MiniBannerAdPreview({
//     super.key,
//     required this.logoModel,
//     required this.bannerTitle,
//     required this.bannerSubtitle,
//     required this.destinationUrl,
//   });

//   @override
//   State<MiniBannerAdPreview> createState() => _MiniBannerAdPreviewState();
// }

// class _MiniBannerAdPreviewState extends State<MiniBannerAdPreview> {
//   @override
//   void dispose() {
//     VoyantAds.instance.miniBannerTestAds.clear();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     for (int i = 0; i <= 5; i++) {
//       DummyDataHelper.addTestMiniBannerAd(
//         logoModel: widget.logoModel,
//         bannerTitle: widget.bannerTitle,
//         bannerSubtitle: widget.bannerSubtitle,
//         destinationUrl: widget.destinationUrl,
//       );
//     }
//   }

//   Widget get mainWidget {
//     return ListView.separated(
//       separatorBuilder: (ctx, index) {
//         return Container(
//           height: 5,
//           color: Colors.grey.shade100,
//         );
//       },
//       itemCount: 50,
//       itemBuilder: (ctx, index) {
//         // return const ListTile(
//         //   title: Text('Dummy Title'),
//         //   subtitle: Text('Dummy substitle'),
//         //   );
//         return SampleListWidget();
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         toolbarHeight: 40,
//         backgroundColor: Theme.of(context).primaryColor,
//         title: Text(
//           'Mini Banner Ad example',
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.white,
//           ),
//         ),
//       ),
//       backgroundColor: Colors.white,
//       body: mainWidget,
//       bottomSheet: VoyantAds.instance.getMiniBannerAdWidget(
//         testMode: true,
//         styling: MiniBannerAdStylingModel(
//           logoSize: 30,
//           elevation: 20,
//           tileStyle: AdListTileStyle(
//             tileHeight: 45,
//             tileTitleAlignment: MainAxisAlignment.center,
//             tileElementsAlignment: CrossAxisAlignment.center,
//             tileColor: Colors.white,
//             titleTextStyle: const TextStyle(
//               color: Colors.black,
//               fontSize: 11,
//             ),
//             subtitleTextStyle: const TextStyle(
//               color: Colors.grey,
//               fontSize: 10,
//             ),
//           ),
//           actionButtonColor: Theme.of(context).primaryColor,
//         ),
//       ),
//     );
//   }
// }
