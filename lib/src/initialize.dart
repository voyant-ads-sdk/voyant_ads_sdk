/// Voyant Ads SDK
///
/// Developer-controlled advertising infrastructure for Flutter applications.
///
/// This class provides:
/// - Explicit ad fetching
/// - Controlled rendering APIs
/// - Transparent impression & click reporting
/// - Fully themeable ad widgets
///
/// No automatic insertion, no background refresh cycles,
/// and no hidden monetization logic.
///
/// Use [VoyantAds.instance] to access the singleton.
///
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:safe_device/safe_device.dart';
import 'package:safe_device/safe_device_config.dart';
import 'package:toastification/toastification.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:voyant_ads_sdk/voyant_ads_sdk.dart';
import 'ads_widget/embedded_video/embedded_video.dart';
import 'ads_widget/mini_native_ad_widget.dart';
import 'ads_widget/native_ad_widget.dart';
import 'ads_widget/native_fullscreen_ad_widget.dart';
import 'ads_widget/rewarding_ad_widget.dart';
import 'models/data_models/ad_data_model.dart';
import 'models/data_models/mini_native_ad_data_model.dart';
import 'models/data_models/native_ad_data_model.dart';
import 'models/data_models/native_fullscreen_ad_data_model.dart';
import 'models/data_models/rewarding_ad_data_model.dart';
import 'models/data_models/video_embedded_ad_data_model.dart';
import 'non_web_headless.dart' if (dart.library.js_interop) 'web_headless.dart';
import 'package:collection/collection.dart';

import 'widgets/ad_tap_widget.dart';

sealed class VoyantAdsWrapperBase {}

/// Main entry point for the Voyant Ads SDK.
///
/// This is a singleton class. Access using:
///
/// ```dart
/// VoyantAds.instance
/// ```
///
/// Responsible for:
/// - SDK initialization
/// - Ad inventory management
/// - Fetching campaigns
/// - Rendering ad widgets
/// - Impression & click reporting
final class VoyantAds extends VoyantAdsWrapperBase {
  static final VoyantAds _singleton = VoyantAds._internal();
  factory VoyantAds() => _singleton;
  //
  VoyantAds._internal();
  static VoyantAds get instance => _singleton;
  //
  static final String adNetworkName = "Voyant Ads";
  final String _apiBaseUrl = isDev
      ? "http://127.0.0.1:4000"
      : "https://api.voyantnetworks.com";
  //"https://api.voyantnetworks.com"; //"http://127.0.0.1:4000";
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );
  static final bool isDev = !kReleaseMode;
  final int _adThresholdCount = 2;
  bool _initialized = false;
  bool audioMuted = false;
  final Map<AdType, int> _lastRequested = {};
  final Map<String, dynamic> _campaignReports = {};
  //
  AgeGroup? ageGroup;
  UserGender? gender;
  late final String _appId;
  late final String _apiKey;
  late final String _sdkSecret;
  late final String _deviceId;
  DeviceType? _deviceType;
  late final String _platform;
  late final String _packageName;
  late Box<dynamic> appSettingsBox;
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  late final bool _isSafeDevice;
  //
  final double _defaultTitleFontSize = 13;
  final double _defaultSubtitleFontSize = 12;
  final double _defaultActionFontSize = 14;
  // PROD ADS
  final List<MiniNativeAdDataModel> _miniNativeAds = [];
  final List<NativeAdDataModel> _nativeAds = [];
  final List<NativeFullScreenAdDataModel> _nativeFullScreenAds = [];
  final List<RewardingAdDataModel> _rewardingAds = [];
  final List<VideoEmbeddedAdDataModel> _videoEmbeddedAds = [];
  // TEST ADS
  final List<MiniNativeAdDataModel> miniNativeTestAds = [];
  final List<NativeAdDataModel> nativeTestAds = [];
  final List<NativeFullScreenAdDataModel> nativeFullScreenTestAds = [];
  final List<RewardingAdDataModel> rewardingTestAds = [];
  final List<VideoEmbeddedAdDataModel> videoEmbeddedTestAds = [];

  /// Populates all ad formats with built-in demo data.
  ///
  /// Used for development and UI testing.
  /// No network calls are made when using demo data.
  void addDummyData() {
    VoyantAdsDummyDataHelper.fillDemoAds();
  }

  //
  bool _autoFetch = false;

  /// Initializes the Voyant Ads SDK.
  ///
  /// Must be called before rendering or fetching ads.
  ///
  /// Typically called inside `main()` before `runApp()`.
  ///
  /// Requires:
  /// - [appId]
  /// - [apiKey]
  /// - [sdkSecret]
  ///
  /// This method:
  /// - Generates/stores anonymous device ID
  /// - Detects platform & device type
  /// - Performs device safety checks
  /// - Prepares internal networking layer
  Future<void> ensureInitialized({
    required String appId,
    required String apiKey,
    required String sdkSecret,
  }) async {
    if (_initialized) return;
    MediaKit.ensureInitialized();
    WidgetsFlutterBinding.ensureInitialized();
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      SafeDevice.init(
        SafeDeviceConfig(
          mockLocationCheckEnabled: false,
        ), // disables mock location check on Android
      );
    }
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _appId = appId;
    _apiKey = apiKey;
    _sdkSecret = sdkSecret;
    _packageName = packageInfo.packageName;
    await _setDeviceId();
    _setPlatform();
    _isSafeDevice = await _isSafe();
    _initialized = true;
    if (kDebugMode) print(_packageName);
    if (kDebugMode) print(_isSafeDevice);
    if (kDebugMode) print(_deviceId);
    if (kDebugMode) print(_platform);
  }

  /// Enables automatic background ad refetching.
  ///
  /// When enabled:
  /// - Device context is cached
  /// - Ads are automatically requested when inventory runs low
  /// - Future calls to [ensureAdsAvailable] do not require BuildContext
  enableAutoFetch(BuildContext context) {
    _deviceType = _getDeviceType(context);
    _autoFetch = true;
  }

  /// Disables automatic background ad refetching.
  ///
  /// Future fetch calls will require BuildContext again.
  disableAutoFetch(BuildContext context) {
    _deviceType = _getDeviceType(context);
    _autoFetch = false;
  }

  _setDeviceId() async {
    if (!Hive.isBoxOpen("voyant_sdk_settings")) {
      await Hive.initFlutter();
    }
    appSettingsBox = await Hive.openBox<dynamic>("voyant_sdk_settings");
    dynamic tempDeviceId = appSettingsBox.get("deviceId");
    String deviceId = Uuid().v4();
    if (tempDeviceId == null) {
      await appSettingsBox.put(
        "deviceId",
        Uint8List.fromList(utf8.encode(deviceId)),
      );
    } else {
      deviceId = utf8.decode(tempDeviceId);
    }
    _deviceId = deviceId;
  }

  void _setPlatform() {
    if (kIsWeb == false) {
      if (Platform.isAndroid) {
        _platform = "android";
      } else if (Platform.isIOS) {
        _platform = "ios";
      } else if (Platform.isLinux) {
        _platform = "linux";
      } else if (Platform.isWindows) {
        _platform = "windows";
      } else if (Platform.isMacOS) {
        _platform = "macos";
      }
    } else {
      _platform = "web";
    }
  }

  static DeviceType _getDeviceType(BuildContext context) {
    final media = MediaQuery.of(context);
    final shortestSide = media.size.shortestSide;
    // WEB
    if (kIsWeb) {
      //final ua = media.platformBrightness.toString().toLowerCase();
      if (shortestSide >= 900) return DeviceType.desktop;
      if (shortestSide >= 600) return DeviceType.tablet;
      return DeviceType.mobile;
    }
    // ANDROID / iOS
    if (Platform.isAndroid || Platform.isIOS) {
      if (shortestSide >= 600) return DeviceType.tablet;
      return DeviceType.mobile;
    }
    // WINDOWS / MACOS / LINUX
    return DeviceType.desktop;
  }

  Future<bool> _isSafe() async {
    // Release mode is required
    if (!kReleaseMode) return false;
    // 🌐 WEB
    if (kIsWeb) {
      // Headless / automation → unsafe
      if (isHeadlessWeb()) return false;
      return true;
    }
    // 🖥️ DESKTOP (no reliable signals)
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return true;
    }
    // 🤖 ANDROID
    if (Platform.isAndroid) {
      final isJailBroken = await SafeDevice.isJailBroken;
      final isRealDevice = await SafeDevice.isRealDevice;
      final isSafeDevice = await SafeDevice.isSafeDevice;
      if (!isRealDevice || isJailBroken || !isSafeDevice) {
        return false;
      }
    }
    // 🍎 IOS
    if (Platform.isIOS) {
      final isJailBroken = await SafeDevice.isJailBrokenCustom;
      final isRealDevice = await SafeDevice.isRealDevice;
      final isSafeDevice = await SafeDevice.isSafeDevice;
      if (!isRealDevice || isJailBroken || !isSafeDevice) {
        return false;
      }
    }
    return true;
  }

  //############### BLOC
  String _stableStringify(Map<String, dynamic> map) {
    final sortedKeys = map.keys.toList()..sort();
    final orderedMap = <String, dynamic>{};
    for (final key in sortedKeys) {
      orderedMap[key] = map[key];
    }
    return jsonEncode(orderedMap);
  }

  String _signPayload({
    required Map<String, dynamic> payload,
    required String sdkSecret,
  }) {
    final data = utf8.encode(_stableStringify(payload));
    final key = utf8.encode(sdkSecret);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(data);
    return digest.toString(); // hex string
  }

  String _generateNonce({int minLength = 16, int maxLength = 32}) {
    final rand = Random.secure();
    final length = minLength + rand.nextInt(maxLength - minLength + 1);
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
      length,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
  }

  Map<String, dynamic> _getPayloadBody({
    required AdType adType,
    EventType? eventType,
    String? token,
    String? campaignId,
  }) {
    Map<String, dynamic> payload = {
      'deviceId': _deviceId,
      'platform': _platform,
      'device': _deviceType?.apiValue,
      'packageName': _packageName,
      'appId': _appId,
      'apiKey': _apiKey,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'nonce': _generateNonce(),
      'adType': adType.apiValue,
    };
    if (ageGroup != null) {
      payload['ageGroup'] = ageGroup?.apiValue;
    }
    if (gender != null) {
      payload['gender'] = gender?.apiValue;
    }
    if (eventType != null) {
      payload['eventType'] = eventType.apiValue;
    }
    if (token != null) {
      payload['token'] = token;
    }
    if (campaignId != null) {
      payload['campaignId'] = campaignId;
    }
    String signature = _signPayload(payload: payload, sdkSecret: _sdkSecret);
    payload['signature'] = signature;
    return payload;
  }

  List<AdDataModel> _dataFromAdModel(AdType adType) {
    switch (adType) {
      case AdType.miniNative:
        return _miniNativeAds;
      case AdType.native:
        return _nativeAds;
      case AdType.nativeFullscreen:
        return _nativeFullScreenAds;
      case AdType.rewarding:
        return _rewardingAds;
      case AdType.videoEmbedded:
        return _videoEmbeddedAds;
    }
  }

  bool _hasEnoughAds({required AdType adType}) {
    final data = _dataFromAdModel(adType);
    final tokenCount = data.length;
    return tokenCount > _adThresholdCount;
  }

  Future<void> _registerImpression({
    required AdDataModel adModel,
    required AdType adType,
    required EventType eventType,
  }) async {
    if (_initialized && _isSafeDevice || _initialized && isDev) {
      try {
        String? token;
        if (eventType == EventType.impression) {
          token = adModel.token;
          if (token.isEmpty) {
            return;
          }
        }
        Map<String, dynamic> payload = _getPayloadBody(
          adType: adType,
          eventType: eventType,
          token: token,
          campaignId: adModel.adId,
        );
        if (eventType == EventType.click) {
          payload["category"] = adModel.category;
        }
        if (kDebugMode) print('dio body: $payload');
        var resp = await _dio.post(
          "$_apiBaseUrl/add_campaign_impression",
          data: payload,
          options: Options(
            validateStatus: (status) {
              return status != null && status < 500;
            },
          ),
        );
        final data = resp.data;
        if (kDebugMode) {
          print('_registerImpression: $eventType repsonse => $data');
        }
        if (resp.statusCode == HttpStatus.ok) {
          if (eventType == EventType.impression && token != null) {
            final data = _dataFromAdModel(adType);
            data.remove(adModel);
          }
        }
      } catch (e) {
        if (kDebugMode) print("registerImpression ads error: $e");
      }
    }
  }

  /// Requests ads from the server for the given [adType].
  ///
  /// This method:
  /// - Throttles excessive requests
  /// - Avoids refetching when inventory is sufficient
  /// - Automatically signs all requests
  ///
  /// If auto fetch is NOT enabled,
  /// a [BuildContext] must be provided to determine device type.
  ///
  /// Safe to call from:
  /// - initState
  /// - Scroll listeners
  /// - Lifecycle callbacks
  /// - Before rendering a placement
  Future<void> ensureAdsAvailable({
    required AdType adType,
    BuildContext? context,
    AgeGroup? ageGroup,
    UserGender? gender,
  }) async {
    if (this.ageGroup != null) {
      this.ageGroup = ageGroup;
    }
    if (this.gender != null) {
      this.gender = gender;
    }
    if (_initialized && _isSafeDevice || _initialized && isDev) {
      try {
        int now = DateTime.now().millisecondsSinceEpoch;
        bool hasEnoughAds = _hasEnoughAds(adType: adType);
        if (kDebugMode) print("=====hasEnoughAds > ${_miniNativeAds.length}");
        if (hasEnoughAds && !isDev) return;
        //
        final last = _lastRequested[adType];
        if (last != null && last + 8000 > now) return;
        _lastRequested[adType] = now;
        //
        if (_deviceType == null && context == null) {
          return;
        }
        if (_deviceType == null && context != null) {
          _deviceType = _getDeviceType(context);
        }
        Map<String, dynamic> payload = _getPayloadBody(adType: adType);
        //
        if (kDebugMode) print('dio body: $payload');
        _lastRequested[adType] = now;
        var resp = await _dio.post(
          "$_apiBaseUrl/get_campaigns",
          data: payload,
          options: Options(
            // validateStatus: (status) {
            //   return status != null && status < 500;
            // },
          ),
        );
        final data = resp.data;
        if (kDebugMode) print('resp data: $data');
        if (resp.statusCode == HttpStatus.ok) {
          if (data is List) {
            _processModels(adType, data);
          }
        }
      } catch (e) {
        if (kDebugMode) print("fetch ads error: $e");
      }
    } else {
      if (kDebugMode) print("non safe device");
    }
  }

  _processModels(AdType adType, List data) {
    switch (adType) {
      case AdType.miniNative:
        List<MiniNativeAdDataModel> models = MiniNativeAdDataModel.fromJson(
          data,
        );
        _miniNativeAds.addAll(models);
        break;
      case AdType.native:
        List<NativeAdDataModel> models = NativeAdDataModel.fromJson(data);
        _nativeAds.addAll(models);
        break;
      case AdType.nativeFullscreen:
        List<NativeFullScreenAdDataModel> models =
            NativeFullScreenAdDataModel.fromJson(data);
        _nativeFullScreenAds.addAll(models);
        break;
      case AdType.rewarding:
        List<RewardingAdDataModel> models = RewardingAdDataModel.fromJson(data);
        _rewardingAds.addAll(models);
        break;
      case AdType.videoEmbedded:
        List<VideoEmbeddedAdDataModel> models =
            VideoEmbeddedAdDataModel.fromJson(data);
        _videoEmbeddedAds.addAll(models);
        break;
    }
  }

  //############################## WIDGETS ##################################
  //###################### VIDEO EMBEDDED #########################
  /// Returns a cross-platform video player with embedded ad support.
  ///
  /// Ads are automatically inserted at fixed time intervals
  /// during playback.
  ///
  /// Set [testMode] to true for demo ads.
  Widget getVideoPlayerWithEmbeddedAdsWidget(
    String path, {
    Widget? placeholder,
    bool testMode = false,
    Function(bool isFullScreen)? onFullscreenToggle,
    int showAdAfterEverySeconds = 60,
    VideoEmbeddedAdStylingModel? styling,
    HeightConstraint? heightConstraint,
    bool playInitially = false,
  }) {
    if (showAdAfterEverySeconds < 60) {
      showAdAfterEverySeconds = 60;
    }
    if (testMode) {
      showAdAfterEverySeconds = 10;
    }
    if (kDebugMode) print("showAdAfterEverySeconds: $showAdAfterEverySeconds");
    return EmbeddedVideoPlayer(
      videoPath: path,
      playInitially: playInitially,
      onFullscreenToggle: onFullscreenToggle,
      heightConstraint: heightConstraint ?? ExpandedHeightConstraint(),
      styling:
          styling ??
          VideoEmbeddedAdStylingModel.defaultVideoEmbeddedAdStyling(
            defaultTitleFontSize: _defaultTitleFontSize,
            defaultSubtitleFontSize: _defaultSubtitleFontSize,
            defaultActionFontSize: _defaultActionFontSize,
          ),
      placeholderWidget: placeholder,
      fetchAd: () {
        VideoEmbeddedAdDataModel? initialData;
        if (testMode) {
          initialData = videoEmbeddedTestAds.firstOrNull;
        } else {
          if (_isSafeDevice || isDev) {
            initialData = _videoEmbeddedAds.firstOrNull;
            if (initialData == null) {
              if (_deviceType != null &&
                  _autoFetch &&
                  _hasEnoughAds(adType: AdType.videoEmbedded) == false) {
                ensureAdsAvailable(adType: AdType.videoEmbedded);
              }
            }
          }
        }
        return initialData;
      },
      registerImpression:
          (VideoEmbeddedAdDataModel adModel, EventType eventType) {
            if (testMode == false || isDev) {
              _registerImpression(
                adModel: adModel,
                adType: AdType.videoEmbedded,
                eventType: eventType,
              );
            }
          },
    );
  }

  //###################### NATIVE FULLSCREEN #########################
  /// Returns a Native Fullscreen ad widget only if available.
  /// Returns null if inventory is empty.
  Widget? maybeGetNativeFullScreenAdWidget({
    NativeFullScreenAdStylingModel? styling,
    Widget? placeholderWidget,
    bool testMode = false,
  }) {
    NativeFullScreenAdDataModel? initialData = _getNativeFullScreenAdDataModel(
      testMode,
    );
    if (initialData != null) {
      return _getNativeFullScreenAdWidget(
        styling: styling,
        placeholderWidget: placeholderWidget,
        testMode: testMode,
        initialData: initialData,
      );
    } else {
      return null;
    }
  }

  NativeFullScreenAdDataModel? _getNativeFullScreenAdDataModel(bool testMode) {
    NativeFullScreenAdDataModel? initialData;
    if (testMode) {
      initialData = nativeFullScreenTestAds.firstOrNull;
    } else {
      if (_isSafeDevice || isDev) {
        initialData = _nativeFullScreenAds.firstOrNull;
        if (initialData == null) {
          if (_deviceType != null &&
              _autoFetch &&
              _hasEnoughAds(adType: AdType.nativeFullscreen) == false) {
            ensureAdsAvailable(adType: AdType.nativeFullscreen);
          }
        }
      }
    }
    return initialData;
  }

  /// Returns a Native Fullscreen ad widget.
  /// Always renders placeholder if no ad is available.
  Widget getNativeFullScreenAdWidget({
    NativeFullScreenAdStylingModel? styling,
    required Widget placeholderWidget,
    bool testMode = false,
  }) {
    return _getNativeFullScreenAdWidget(
      styling: styling,
      placeholderWidget: placeholderWidget,
      testMode: testMode,
      initialData: _getNativeFullScreenAdDataModel(testMode),
    );
  }

  Widget _getNativeFullScreenAdWidget({
    NativeFullScreenAdStylingModel? styling,
    bool testMode = false,
    Widget? placeholderWidget,
    NativeFullScreenAdDataModel? initialData,
  }) {
    return NativeFullScreenAdWidget(
      initialData: initialData,
      styling:
          styling ??
          NativeFullScreenAdStylingModel.defaultNativeFullScreenAdStyling(
            defaultTitleFontSize: _defaultTitleFontSize,
            defaultSubtitleFontSize: _defaultSubtitleFontSize,
            defaultActionFontSize: _defaultActionFontSize,
          ),
      placeholderWidget: placeholderWidget,
      fetchAd: () {
        return _getNativeFullScreenAdDataModel(testMode);
      },
      registerImpression:
          (NativeFullScreenAdDataModel adModel, EventType eventType) {
            if (testMode == false || isDev) {
              _registerImpression(
                adModel: adModel,
                adType: AdType.nativeFullscreen,
                eventType: eventType,
              );
            }
          },
    );
  }

  //###################### NATIVE #########################
  /// Returns a Native ad widget only if inventory exists.
  /// Returns null otherwise.
  Widget? maybeGetNativeAdWidget({
    NativeAdStylingModel? styling,
    HeightConstraint? heightConstraint,
    double width = double.infinity,
    bool testMode = false,
    Widget? placeholderWidget,
  }) {
    NativeAdDataModel? initialData = _getNativeAdDataModel(testMode);
    if (initialData != null) {
      return _getNativeAdWidget(
        initialData: initialData,
        styling: styling,
        heightConstraint: heightConstraint,
        width: width,
        testMode: testMode,
        placeholderWidget: placeholderWidget,
      );
    } else {
      return null;
    }
  }

  NativeAdDataModel? _getNativeAdDataModel(bool testMode) {
    NativeAdDataModel? initialData;
    if (testMode) {
      initialData = nativeTestAds.firstOrNull;
    } else {
      if (_isSafeDevice || isDev) {
        initialData = _nativeAds.firstOrNull;
      }
      if (initialData == null) {
        if (_deviceType != null &&
            _autoFetch &&
            _hasEnoughAds(adType: AdType.native) == false) {
          ensureAdsAvailable(adType: AdType.native);
        }
      }
    }
    return initialData;
  }

  /// Returns a Native ad widget.
  /// Always renders placeholder if no ad is available.
  Widget getNativeAdWidget({
    required Widget placeholderWidget,
    NativeAdStylingModel? styling,
    HeightConstraint? heightConstraint,
    double width = double.infinity,
    bool testMode = false,
  }) {
    return _getNativeAdWidget(
      styling: styling,
      heightConstraint: heightConstraint,
      width: width,
      testMode: testMode,
      placeholderWidget: placeholderWidget,
      initialData: _getNativeAdDataModel(testMode),
    );
  }

  Widget _getNativeAdWidget({
    NativeAdStylingModel? styling,
    bool testMode = false,
    Widget? placeholderWidget,
    HeightConstraint? heightConstraint,
    double width = double.infinity,
    NativeAdDataModel? initialData,
  }) {
    return NativeAdWidget(
      width: width,
      initialData: initialData,
      heightConstraint: heightConstraint ?? ExpandedHeightConstraint(),
      styling:
          styling ??
          NativeAdStylingModel.defaultNativeAdStyling(
            defaultTitleFontSize: _defaultTitleFontSize,
            defaultSubtitleFontSize: _defaultSubtitleFontSize,
            defaultActionFontSize: _defaultActionFontSize,
          ),
      placeholderWidget: placeholderWidget,
      fetchAd: () {
        return _getNativeAdDataModel(testMode);
      },
      registerImpression: (NativeAdDataModel adModel, EventType eventType) {
        if (testMode == false || isDev) {
          _registerImpression(
            adModel: adModel,
            adType: AdType.native,
            eventType: eventType,
          );
        }
      },
    );
  }

  //###################### MINI NATIVE #########################
  /// Returns a Mini Native ad widget.
  ///
  /// If an ad is available, it is rendered.
  /// Otherwise, [placeholderWidget] is displayed.
  ///
  /// Set [testMode] to true to render demo ads.
  Widget getMiniNativeAdWidget({
    MiniNativeAdStylingModel? styling,
    required Widget placeholderWidget,
    bool testMode = false,
  }) {
    return _getMiniNativeAdWidget(
      styling: styling,
      placeholderWidget: placeholderWidget,
      testMode: testMode,
      initialData: _getMiniNativeAdDataModel(testMode),
    );
  }

  MiniNativeAdDataModel? _getMiniNativeAdDataModel(bool testMode) {
    MiniNativeAdDataModel? initialData;
    if (testMode) {
      initialData = miniNativeTestAds.firstOrNull;
    } else {
      if (_isSafeDevice || isDev) {
        initialData = _miniNativeAds.firstOrNull;
        if (initialData == null) {
          if (_deviceType != null &&
              _autoFetch &&
              _hasEnoughAds(adType: AdType.miniNative) == false) {
            ensureAdsAvailable(adType: AdType.miniNative);
          }
        }
      }
    }
    return initialData;
  }

  /// Returns a Mini Native ad widget only if inventory is available.
  ///
  /// Returns null if no ad is ready,
  /// allowing conditional placement logic.
  Widget? maybeGetMiniNativeAdWidget({
    MiniNativeAdStylingModel? styling,
    bool testMode = false,
    Widget? placeholderWidget,
  }) {
    MiniNativeAdDataModel? initialData = _getMiniNativeAdDataModel(testMode);
    if (initialData != null) {
      return _getMiniNativeAdWidget(
        styling: styling,
        testMode: testMode,
        placeholderWidget: placeholderWidget,
        initialData: initialData,
      );
    } else {
      return null;
    }
  }

  Widget _getMiniNativeAdWidget({
    bool testMode = false,
    MiniNativeAdStylingModel? styling,
    Widget? placeholderWidget,
    MiniNativeAdDataModel? initialData,
  }) {
    return MiniNativeAdWidget(
      initialData: initialData,
      styling:
          styling ??
          MiniNativeAdStylingModel.defaultMiniNativeAdStyling(
            defaultTitleFontSize: _defaultTitleFontSize,
            defaultSubtitleFontSize: _defaultSubtitleFontSize,
            defaultActionFontSize: _defaultActionFontSize,
          ),
      placeholderWidget: placeholderWidget,
      fetchAd: () {
        return _getMiniNativeAdDataModel(testMode);
      },
      registerImpression: (MiniNativeAdDataModel adModel, EventType eventType) {
        if (testMode == false || isDev) {
          _registerImpression(
            adModel: adModel,
            adType: AdType.miniNative,
            eventType: eventType,
          );
        }
      },
    );
  }

  //###################### REWARDING #########################
  RewardingAdDataModel? _getRewardingAdDataModel(bool testMode) {
    RewardingAdDataModel? initialData;
    if (testMode) {
      initialData = rewardingTestAds.firstOrNull;
    } else {
      if (_isSafeDevice || isDev) {
        initialData = _rewardingAds.firstOrNull;
        if (initialData == null) {
          if (_deviceType != null &&
              _autoFetch &&
              _hasEnoughAds(adType: AdType.rewarding) == false) {
            ensureAdsAvailable(adType: AdType.rewarding);
          }
        }
      }
    }
    return initialData;
  }

  /// Displays a full-screen Rewarding ad.
  ///
  /// This method pushes a fullscreen route.
  /// On successful completion, [onSuccess] is triggered.
  /// If dismissed or failed, [onFailure] is triggered.
  ///
  /// If no ad inventory exists, [onAdRepoEmpty] is called.
  Future<void> showRewardingAd({
    RewardingAdStylingModel? styling,
    required BuildContext context,
    required VoidCallback onSuccess,
    VoidCallback? onFailure,
    VoidCallback? onAdRepoEmpty,
    bool testMode = false,
  }) async {
    final RewardingAdDataModel? adModel = _getRewardingAdDataModel(testMode);
    if (adModel == null) {
      onAdRepoEmpty?.call();
      return;
    }
    final Orientation initialOrientation = MediaQuery.of(context).orientation;
    bool? result;
    try {
      result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => RewardingAdWidget(
            styling:
                styling ??
                RewardingAdStylingModel.defaultRewardingStyling(
                  defaultTitleFontSize: _defaultTitleFontSize,
                  defaultSubtitleFontSize: _defaultSubtitleFontSize,
                  defaultActionFontSize: _defaultActionFontSize,
                ),
            currentModel: adModel,
            registerImpression: (VisibilityInfo info, EventType eventType) {
              if (info.size.height > 200 && info.size.width > 200) {
                if (testMode == false || isDev) {
                  _registerImpression(
                    adModel: adModel,
                    adType: AdType.rewarding,
                    eventType: eventType,
                  );
                }
              }
            },
          ),
        ),
      );
    } finally {
      // ALWAYS restore orientation, even on crash / back swipe
      _restoreOrientation(initialOrientation);
    }
    if (result == true) {
      onSuccess();
    } else {
      onFailure?.call();
    }
  }

  void _restoreOrientation(Orientation orientation) {
    if (orientation == Orientation.landscape) {
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  Future<void> showAdTapWidget({
    required AdDataModel adModel,
    required BuildContext context,
    required Function onContinue,
  }) async {
    await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      constraints: const BoxConstraints(maxWidth: 600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      builder: (BuildContext ctx) {
        return AdTapWidget(
          adModel: adModel,
          onReport: _sendReport,
          onContinue: onContinue,
        );
      },
    );
  }

  _sendReport(
    AdDataModel adModel,
    String reportType,
    BuildContext context,
  ) async {
    if (kDebugMode) {
      print(
        'already reported ${_campaignReports[adModel.adId]}, $_campaignReports',
      );
    }
    if (_campaignReports[adModel.adId] == reportType) {
      _showToast(
        icon: Icons.report_problem_rounded,
        context: context,
        mainColor: Colors.red,
        title: 'Already reported',
        subtitle: 'You have already reported this ad recently.',
      );
      return;
    }
    Map<String, dynamic> payload = {
      'deviceId': _deviceId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'campaignId': adModel.adId,
      'reportType': reportType,
      'packageName': _packageName,
      'appId': _appId,
      'apiKey': _apiKey,
      'nonce': _generateNonce(),
      'recordType': 'campaign',
      'platform': _platform,
    };
    String signature = _signPayload(payload: payload, sdkSecret: _sdkSecret);
    payload['signature'] = signature;
    //
    if (_initialized && _isSafeDevice || _initialized && isDev) {
      try {
        var resp = await _dio.post("$_apiBaseUrl/report", data: payload);
        final data = resp.data;
        if (data is bool) {
          _campaignReports[adModel.adId] = reportType;
          _showToast(
            icon: Icons.report_problem_rounded,
            context: context,
            mainColor: Colors.green,
            title: 'Reporting Done',
            subtitle: 'It may take some time to take effect',
          );
        }
        if (kDebugMode) print('resp data: $data');
      } catch (e) {
        if (kDebugMode) print("fetch ads error: $e");
      }
    } else {
      if (kDebugMode) print("non safe device");
    }
  }

  _showToast({
    required BuildContext context,
    Color mainColor = Colors.red,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      title: Text(
        title,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      description: Text(
        subtitle,
        style: TextStyle(color: Colors.white70, fontSize: 12),
      ),
      icon: Icon(icon, color: Colors.white),
      primaryColor: mainColor,
      backgroundColor: mainColor,
      foregroundColor: Colors.white,
      autoCloseDuration: const Duration(seconds: 2),
      borderRadius: BorderRadius.circular(8),
    );
  }
}

/// Supported ad formats in Voyant Ads SDK.
enum AdType { miniNative, native, nativeFullscreen, rewarding, videoEmbedded }

/// Represents detected device category.
enum DeviceType { desktop, tablet, mobile }

/// Represents ad interaction events.
enum EventType { impression, click }

/// Optional gender signal provided by developer.
enum UserGender { male, female }

/// Optional demographic signal provided by developer.
enum AgeGroup { under18, age18to24, age25to34, age35to54, age55Plus }

extension _DeviceTypeX on DeviceType {
  String get apiValue {
    switch (this) {
      case DeviceType.desktop:
        return 'desktop';
      case DeviceType.tablet:
        return 'tablet';
      case DeviceType.mobile:
        return 'mobile';
    }
  }
}

extension _AdTypeX on AdType {
  String get apiValue {
    switch (this) {
      case AdType.miniNative:
        return 'miniNative';
      case AdType.native:
        return 'native';
      case AdType.nativeFullscreen:
        return 'nativeFullscreen';
      case AdType.rewarding:
        return 'rewarding';
      case AdType.videoEmbedded:
        return 'videoEmbedded';
    }
  }
}

extension _AgeGroupX on AgeGroup {
  String get apiValue {
    switch (this) {
      case AgeGroup.under18:
        return '0-17';
      case AgeGroup.age18to24:
        return '18-24';
      case AgeGroup.age25to34:
        return '25-34';
      case AgeGroup.age35to54:
        return '35-54';
      case AgeGroup.age55Plus:
        return '55+';
    }
  }
}

extension _UserGender on UserGender {
  String get apiValue {
    switch (this) {
      case UserGender.male:
        return 'male';
      case UserGender.female:
        return 'female';
    }
  }
}

extension _EventType on EventType {
  String get apiValue {
    switch (this) {
      case EventType.impression:
        return 'impression';
      case EventType.click:
        return 'click';
    }
  }
}
