// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:voyant_ads_sdk/flutter_ads_sdk.dart';
// import '../../../frames/mobile_frame.dart';
// import '../../new_campaign_screen/controller/new_campaign_controller.dart';
// import '../widgets/sample_list_widget.dart';

// class BannerAdPreview extends StatefulWidget {
//   //final double height;
//   //final double width;
//   final ImageMediaModel logoModel;
//   final String primaryTitle;
//   final String primarySubtitle;
//   final String? description;
//   final String? secondaryTitle;
//   final String? secondarySubtitle;
//   final MemoryImageMediaModel? imageModel;
//   final VideoMediaModel? videoModel;
//   final MemoryCarouselMediaModel? carouselModel;
//   final String destinationUrl;
//   final String? actionText;

//   const BannerAdPreview({
//     super.key,
//     this.imageModel,
//     this.videoModel,
//     this.carouselModel,
//     required this.logoModel,
//     required this.primaryTitle,
//     required this.primarySubtitle,
//     this.description,
//     this.secondaryTitle,
//     this.secondarySubtitle,
//     required this.destinationUrl,
//     this.actionText,
//     //required this.height,
//     //required this.width,
//   });

//   @override
//   State<BannerAdPreview> createState() => _BannerAdPreviewState();
// }

// class _BannerAdPreviewState extends State<BannerAdPreview> {
//   @override
//   void dispose() {
//     VoyantAds.instance.bannerTestAds.clear();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     for (int i = 0; i <= 5; i++) {
//       DummyDataHelper.addTestBannerAd(
//         actionText: widget.actionText,
//         logoModel: widget.logoModel,
//         primaryTitle: widget.primaryTitle,
//         primarySubtitle: widget.primarySubtitle,
//         description: widget.description,
//         secondaryTitle: widget.secondaryTitle,
//         secondarySubtitle: widget.secondarySubtitle,
//         imageModel: widget.imageModel,
//         videoModel: widget.videoModel,
//         carouselModel: widget.carouselModel,
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
//         // return const SizedBox(
//         //   height: 88,
//         //   child: ListTile(
//         //     title: Text('Dummy Title'),
//         //     subtitle: Text('Dummy substitle'),
//         //   ),
//         // );
//         return SampleListWidget();
//       },
//     );
//   }

//   Widget get _getAdWidget {
//     return VoyantAds.instance.getBannerAdWidget(
//       testMode: true,
//       width: 400,
//       heightConstraint: FixedHeightConstraint(300),
//       styling: BannerAdStylingModel(
//         logoSize: 30,
//         elevation: 30,
//         logoBackgroundColor: Theme.of(context).primaryColor,
//         descriptionStyle: const TextStyle(
//           color: Colors.black,
//           fontSize: 12,
//         ),
//         actionStyle: const TextStyle(
//           color: Colors.white,
//           fontSize: 10,
//         ),
//         headerTileStyle: AdListTileStyle(
//           tileHeight: 45,
//           tileTitleAlignment: MainAxisAlignment.start,
//           tileElementsAlignment: CrossAxisAlignment.center,
//           tileColor: Colors.white,
//           titleTextStyle: const TextStyle(
//             color: Colors.black,
//             fontSize: 11,
//           ),
//           subtitleTextStyle: const TextStyle(
//             color: Colors.grey,
//             fontSize: 10,
//           ),
//         ),
//         footerTileStyle: AdListTileStyle(
//           tileHeight: 45,
//           tileTitleAlignment: MainAxisAlignment.spaceEvenly,
//           tileElementsAlignment: CrossAxisAlignment.center,
//           tileColor: Colors.indigo,
//           titleTextStyle: const TextStyle(
//             color: Colors.white,
//             fontSize: 11,
//           ),
//           subtitleTextStyle: const TextStyle(
//             color: Colors.white,
//             fontSize: 10,
//           ),
//         ),
//       ),
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
//           'Banner Ad example',
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.white,
//           ),
//         ),
//       ),
//       backgroundColor: Colors.white,
//       body: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           Expanded(child: mainWidget),
//           Container(width: 400, child: _getAdWidget),
//         ],
//       ),
//     );
//   }
// }
