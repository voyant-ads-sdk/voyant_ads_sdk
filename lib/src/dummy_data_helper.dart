import '../voyant_ads_sdk.dart';
import 'models/data_models/mini_native_ad_data_model.dart';
import 'models/data_models/native_ad_data_model.dart';
import 'models/data_models/native_fullscreen_ad_data_model.dart';
import 'models/data_models/rewarding_ad_data_model.dart';
import 'models/data_models/video_embedded_ad_data_model.dart';

class VoyantAdsDummyDataHelper {
  static final UrlImageMediaModel logoModel = UrlImageMediaModel(
    // logo.jpg
    url: 'https://picsum.photos/seed/logo123/200/200',
    imageHeight: 640,
    imageWidth: 640,
  );
  static final URLVideoMediaModel videoModel = URLVideoMediaModel(
    // video_ad.mp4
    url:
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    videoHeight: 360,
    videoWidth: 640,
  );
  static final List<UrlImageMediaModel> imagesModel = [
    UrlImageMediaModel(
      // team.jpg
      url: 'https://picsum.photos/seed/carousel2/1200/800',
      imageHeight: 360,
      imageWidth: 640,
    ),
    UrlImageMediaModel(
      // meeting.jpg
      url: 'https://picsum.photos/seed/native1/1200/800',
      imageHeight: 427,
      imageWidth: 640,
    ),
  ];
  static void fillDemoAds() {
    //miniNativeTestAds
    VoyantAds.instance.miniNativeTestAds.clear();
    VoyantAds.instance.miniNativeTestAds.add(
      MiniNativeAdDataModel(
        adId: 'test',
        logoModel: logoModel,
        title: 'Demo CRM Platform',
        subtitle: 'Manage leads smarter',
        destinationUrl: 'www.google.com',
        token: "",
        destinationUrlStatus: 'safe',
        reportsData: {},
        impressionsCount: 10560,
        clicksCount: 105,
        category: "Business > Software > CRM & Sales",
      ),
    );
    //nativeTestAds
    VoyantAds.instance.nativeTestAds.clear();
    // VoyantAds.instance.nativeTestAds.add(
    //   NativeAdDataModel(
    //     adId: 'demo_native_1',
    //     logoModel: logoModel,
    //     headerTitle: 'AI CRM for Growing Businesses',
    //     headerSubtitle: 'Close deals 3x faster with smart automation',
    //     destinationUrl: 'www.google.com',
    //     adDescription:
    //         'Automate follow-ups, track customer journeys, and boost conversions with an all-in-one CRM platform built for modern teams.',
    //     footerTitle: 'Start Your Free Trial',
    //     footerSubtitle: 'No credit card required',
    //     actionText: 'GET STARTED',
    //     token: "",
    //     mediaModel: imagesModel.first,
    //     destinationUrlStatus: 'safe',
    //     reportsData: {'misleading': 1},
    //     impressionsCount: 25630,
    //     clicksCount: 1842,
    //     category: "Business > Software > CRM & Sales",
    //   ),
    // );
    VoyantAds.instance.nativeTestAds.add(
      NativeAdDataModel(
        adId: 'demo_native_1',
        logoModel: logoModel,
        headerTitle: 'AI CRM for Growing Businesses',
        headerSubtitle: 'Close deals 3x faster with smart automation',
        destinationUrl: 'www.google.com',
        adDescription:
            'Automate follow-ups, track customer journeys, and boost conversions with an all-in-one CRM platform built for modern teams.',
        footerTitle: 'Start Your Free Trial',
        footerSubtitle: 'No credit card required',
        actionText: 'GET STARTED',
        token: "",
        mediaModel: videoModel,
        destinationUrlStatus: 'safe',
        reportsData: {'misleading': 1},
        impressionsCount: 25630,
        clicksCount: 1842,
        category: "Business > Software > CRM & Sales",
      ),
    );
    //nativeFullScreenTestAds
    VoyantAds.instance.nativeFullScreenTestAds.clear();
    // VoyantAds.instance.nativeFullScreenTestAds.add(
    //   NativeFullScreenAdDataModel(
    //     adId: 'demo_fullscreen_1',
    //     logoModel: logoModel,
    //     headerTitle: "AI-Powered CRM Platform",
    //     headerSubtitle: "Turn conversations into customers",
    //     destinationUrl: "www.google.com",
    //     adDescription:
    //         "Automate lead tracking, personalize follow-ups, and close deals faster with intelligent sales automation built for modern teams.",
    //     footerTitle: "Start Free Trial",
    //     footerSubtitle: "14-day access • No credit card",
    //     actionText: "GET STARTED",
    //     token: "",
    //     mediaModel: imagesModel.first,
    //     destinationUrlStatus: 'safe',
    //     reportsData: {'misleading': 1},
    //     impressionsCount: 48230,
    //     clicksCount: 3921,
    //     category: "Business > Software > CRM & Sales",
    //   ),
    // );
    VoyantAds.instance.nativeFullScreenTestAds.add(
      NativeFullScreenAdDataModel(
        adId: 'demo_fullscreen_2',
        logoModel: logoModel,
        headerTitle: "Scale Your Business Faster",
        headerSubtitle: "All-in-one growth platform",
        destinationUrl: "www.google.com",
        adDescription:
            "From marketing automation to analytics dashboards, manage everything in one powerful platform designed for startups and enterprises.",
        footerTitle: "Explore Features",
        footerSubtitle: "Marketing • Sales • Analytics",
        actionText: "LEARN MORE",
        token: "",
        mediaModel: UrlCarouselMediaModel(imagesList: imagesModel),
        destinationUrlStatus: 'safe',
        reportsData: {'spam': 0},
        impressionsCount: 76450,
        clicksCount: 5840,
        category: "Business > Software > Marketing Automation",
      ),
    );
    //rewardingTestAds
    VoyantAds.instance.rewardingTestAds.clear();
    VoyantAds.instance.rewardingTestAds.add(
      RewardingAdDataModel(
        adId: 'demo_reward_1',
        logoModel: logoModel,
        headerTitle: 'Unlock Premium CRM Tools',
        headerSubtitle: 'Watch to access advanced features',
        destinationUrl: 'www.google.com',
        adDescription:
            'Discover AI-powered automation, smart lead scoring, and real-time analytics designed to help your business grow faster.',
        footerTitle: 'Access Premium Features',
        footerSubtitle: 'Available for a limited time',
        actionText: 'UNLOCK NOW',
        token: "",
        mediaModel: videoModel,
        destinationUrlStatus: 'safe',
        reportsData: {'misleading': 0},
        impressionsCount: 38210,
        clicksCount: 4512,
        category: "Business > Software > CRM & Sales",
      ),
    );
    //videoEmbeddedTestAds
    VoyantAds.instance.videoEmbeddedTestAds.clear();
    VoyantAds.instance.videoEmbeddedTestAds.add(
      VideoEmbeddedAdDataModel(
        adId: 'demo_embedded_1',
        logoModel: logoModel,
        footerTitle: 'AI CRM Built for Modern Teams',
        footerSubtitle: 'Automate sales. Increase conversions.',
        destinationUrl: 'www.example.com',
        actionText: 'LEARN MORE',
        token: "",
        mediaModel: imagesModel.first,
        // mediaModel: videoModel,
        destinationUrlStatus: 'safe',
        reportsData: {'misleading': 0},
        impressionsCount: 64210,
        clicksCount: 5384,
        category: "Business > Software > CRM & Sales",
      ),
    );
  }

  static addTestMiniNativeAd({
    required ImageMediaModel logoModel,
    required String title,
    required String subtitle,
    required String destinationUrl,
    required String category,
  }) {
    VoyantAds.instance.miniNativeTestAds.add(
      MiniNativeAdDataModel(
        adId: 'test',
        logoModel: logoModel,
        title: title,
        subtitle: subtitle,
        destinationUrl: destinationUrl,
        token: "",
        destinationUrlStatus: 'safe',
        reportsData: {},
        impressionsCount: 10560,
        clicksCount: 105,
        category: category,
      ),
    );
  }

  static addTestNativeAd({
    required ImageMediaModel logoModel,
    required String primaryTitle,
    required String primarySubtitle,
    String? description,
    String? secondaryTitle,
    String? secondarySubtitle,
    MemoryImageMediaModel? imageModel,
    VideoMediaModel? videoModel,
    required MemoryCarouselMediaModel? carouselModel,
    required String destinationUrl,
    String? actionText,
    required String category,
  }) {
    MediaModel? mediaModel = imageModel ?? carouselModel ?? videoModel;
    if (mediaModel == null) return;
    VoyantAds.instance.nativeTestAds.add(
      NativeAdDataModel(
        adId: 'demo_native_1',
        logoModel: logoModel,
        headerTitle: primaryTitle,
        headerSubtitle: primarySubtitle,
        destinationUrl: destinationUrl,
        adDescription: description,
        footerTitle: secondaryTitle,
        footerSubtitle: secondarySubtitle,
        actionText: actionText ?? 'VISIT',
        token: "",
        mediaModel: mediaModel,
        destinationUrlStatus: 'safe',
        reportsData: {'misleading': 1},
        impressionsCount: 25630,
        clicksCount: 1842,
        category: category,
      ),
    );
  }

  static addTestNativeFullScreenAd({
    required ImageMediaModel logoModel,
    required String primaryTitle,
    required String primarySubtitle,
    String? description,
    String? secondaryTitle,
    String? secondarySubtitle,
    MemoryImageMediaModel? imageModel,
    VideoMediaModel? videoModel,
    required MemoryCarouselMediaModel? carouselModel,
    required String destinationUrl,
    String? actionText,
    required String category,
  }) {
    MediaModel? mediaModel = imageModel ?? carouselModel ?? videoModel;
    if (mediaModel == null) return;
    VoyantAds.instance.nativeFullScreenTestAds.add(
      NativeFullScreenAdDataModel(
        adId: 'demo_native_1',
        logoModel: logoModel,
        headerTitle: primaryTitle,
        headerSubtitle: primarySubtitle,
        destinationUrl: destinationUrl,
        adDescription: description,
        footerTitle: secondaryTitle,
        footerSubtitle: secondarySubtitle,
        actionText: actionText ?? 'VISIT',
        token: "",
        mediaModel: mediaModel,
        destinationUrlStatus: 'safe',
        reportsData: {'misleading': 1},
        impressionsCount: 25630,
        clicksCount: 1842,
        category: category,
      ),
    );
  }

  static addTestRewardingAd({
    required ImageMediaModel logoModel,
    required String primaryTitle,
    required String primarySubtitle,
    String? description,
    String? secondaryTitle,
    String? secondarySubtitle,
    MemoryImageMediaModel? imageModel,
    VideoMediaModel? videoModel,
    required MemoryCarouselMediaModel? carouselModel,
    required String destinationUrl,
    String? actionText,
    required String category,
  }) {
    MediaModel? mediaModel = imageModel ?? carouselModel ?? videoModel;
    if (mediaModel == null) return;
    VoyantAds.instance.rewardingTestAds.add(
      RewardingAdDataModel(
        adId: 'demo_native_1',
        logoModel: logoModel,
        headerTitle: primaryTitle,
        headerSubtitle: primarySubtitle,
        destinationUrl: destinationUrl,
        adDescription: description,
        footerTitle: secondaryTitle,
        footerSubtitle: secondarySubtitle,
        actionText: actionText ?? 'VISIT',
        token: "",
        mediaModel: mediaModel,
        destinationUrlStatus: 'safe',
        reportsData: {'misleading': 1},
        impressionsCount: 25630,
        clicksCount: 1842,
        category: category,
      ),
    );
  }

  static addTestVideoEmbeddedAd({
    required ImageMediaModel logoModel,
    required String primaryTitle,
    required String primarySubtitle,
    MemoryImageMediaModel? imageModel,
    VideoMediaModel? videoModel,
    required MemoryCarouselMediaModel? carouselModel,
    required String destinationUrl,
    String? actionText,
    required String category,
  }) {
    MediaModel? mediaModel = imageModel ?? carouselModel ?? videoModel;
    if (mediaModel == null) return;
    VoyantAds.instance.videoEmbeddedTestAds.add(
      VideoEmbeddedAdDataModel(
        adId: 'demo_native_1',
        logoModel: logoModel,
        destinationUrl: destinationUrl,
        footerTitle: primaryTitle,
        footerSubtitle: primarySubtitle,
        actionText: actionText ?? 'VISIT',
        token: "",
        mediaModel: mediaModel,
        destinationUrlStatus: 'safe',
        reportsData: {'misleading': 1},
        impressionsCount: 25630,
        clicksCount: 1842,
        category: category,
      ),
    );
  }
}
