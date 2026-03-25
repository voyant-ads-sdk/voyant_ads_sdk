import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../voyant_ads_sdk.dart';
import '../../models/data_models/video_embedded_ad_data_model.dart';
import '../../widgets/video_ad_widget.dart';
import '../video_player/embedded_carousel_ad.dart';
import '../video_player/embedded_image_ad.dart';
import '../video_player/embedded_video_ad.dart';
import 'bottom_tile_widget.dart';

class EmbeddedVideoController {
  final int showAdAfterEverySeconds;
  final Function(bool isFullScreen)? onFullscreenToggle;
  final VideoEmbeddedAdDataModel? Function() fetchAd;
  final VideoEmbeddedAdStylingModel styling;
  final Function(VideoEmbeddedAdDataModel adModel, EventType eventType)
  registerImpression;
  final bool playInitially;

  EmbeddedVideoController({
    required this.videoPath,
    this.onFullscreenToggle,
    required this.showAdAfterEverySeconds,
    required this.fetchAd,
    required this.styling,
    required this.registerImpression,
    required this.playInitially,
  });
  bool _disposed = false;
  final Player videoPlayer = Player();
  final String videoPath;

  VideoController? videoController;
  bool videoReady = false;
  final ValueNotifier<bool> refreshVideoWidget = ValueNotifier<bool>(true);
  final ValueNotifier<Widget?> showAd = ValueNotifier<Widget?>(null);
  final ValueNotifier<int> adBufferTimer = ValueNotifier<int>(0);

  double? videoHeight;
  double? videoWidth;
  final double minHeight = 200;
  final double minWidth = 200;
  VisibilityInfo? visibilityInfo;
  AdLoadingState loadingState = AdLoadingState.notNeeded;

  Timer? playTimer;
  Timer? adBufferTimerFunc;
  int videoPlayedTime = 0;
  final int showAdTimerInAdvance = 8;
  Widget? adWidget;

  ValueNotifier<bool> showOverlay = ValueNotifier<bool>(false);
  Timer? hideTimer;
  bool userPausedVideo = false;
  bool isDisposed = false;

  StreamSubscription<bool>? playingSub;
  StreamSubscription<int?>? heightSub;
  StreamSubscription<int?>? widthSub;
  StreamSubscription<Duration>? _positionSub;

  final ValueNotifier<DurationState> durationState =
      ValueNotifier<DurationState>(
        const DurationState(
          buffered: Duration.zero,
          progress: Duration.zero,
          total: Duration.zero,
        ),
      );

  void clearData() {
    isDisposed = true;
    showOverlay.dispose();
    _disposed = true;
    adBufferTimerFunc?.cancel();
    adBufferTimer.dispose();
    playTimer?.cancel();
    showAd.dispose();
    _positionSub?.cancel();
    durationState.dispose();
    refreshVideoWidget.dispose();
    playingSub?.cancel();
    heightSub?.cancel();
    widthSub?.cancel();
    videoPlayer.dispose();
  }

  void refreshVideo() {
    if (isDisposed == false) {
      refreshVideoWidget.value = !refreshVideoWidget.value;
    }
  }

  Future<void> initialize() async {
    videoController = VideoController(videoPlayer);
    await videoPlayer.open(Media(videoPath), play: playInitially);
    if (_disposed) return;
    heightSub ??= videoPlayer.stream.height.listen((int? height) {
      if (videoHeight != height?.toDouble()) {
        videoHeight = height?.toDouble();
        refreshVideo();
      }
    });
    widthSub ??= videoPlayer.stream.width.listen((int? width) {
      if (videoWidth != width?.toDouble()) {
        videoWidth = width?.toDouble();
        refreshVideo();
      }
    });
    _positionSub ??= videoPlayer.stream.position.listen((Duration duration) {
      //if (mounted) {
      durationState.value = DurationState(
        buffered: videoPlayer.state.buffer,
        progress: duration,
        total: videoPlayer.state.duration,
      );
      //}
    });
    playingSub ??= videoPlayer.stream.playing.listen((bool isPlaying) {
      // if (isDisposed == false) {
      //   showOverlay.value = true;
      // }
      // scheduleHide();
      //if (isPlaying) {} else {}
      if (!isPlaying) return;
      playTimer ??= Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (!videoReady) return;
        if (loadingState == AdLoadingState.loading ||
            loadingState == AdLoadingState.playing) {
          videoPlayedTime = 0;
          return;
        }
        if (loadingState == AdLoadingState.loaded && adWidget != null) {
          if (videoPlayer.state.playing) {
            adBufferTimer.value = adBufferTimer.value + 1;
            if (adBufferTimer.value >= showAdTimerInAdvance) {
              loadingState = AdLoadingState.playing;
              videoPlayedTime = 0;
              await videoPlayer.pause();
              showAd.value = adWidget;
              adBufferTimer.value = 0;
            }
          }
        }
        if (loadingState == AdLoadingState.notNeeded) {
          videoPlayedTime = videoPlayedTime + 1;
          if (videoPlayedTime >= showAdAfterEverySeconds) {
            loadingState = AdLoadingState.loading;
            videoPlayedTime = 0;
            adWidget ??= await _getAdWidget(fetchAd());
            if (adWidget != null) {
              loadingState = AdLoadingState.loaded;
            } else {
              loadingState = AdLoadingState.notNeeded;
            }
          }
        }
      });
    });
    videoReady = true;
    refreshVideo();
  }

  void scheduleHide() {
    hideTimer?.cancel();
    hideTimer = Timer(const Duration(seconds: 4), () {
      if (isDisposed == false) {
        showOverlay.value = false;
      }
    });
  }

  onCompletion(VideoEmbeddedAdDataModel adModel, bool hasImpression) async {
    showAd.value = null;
    adWidget = null;
    loadingState = AdLoadingState.notNeeded;
    if (isVisibleEnough && hasImpression) {
      registerImpression(adModel, EventType.impression);
    }
    await videoPlayer.play();
  }

  Future<Widget?> _getAdWidget(VideoEmbeddedAdDataModel? adModel) async {
    try {
      if (adModel != null) {
        if (adModel.mediaModel is VideoMediaModel) {
          return EmbeddedVideoAd(
            intitialVolume: videoController?.player.state.volume,
            styling: styling,
            videoModel: adModel.mediaModel,
            bottomTileWidget: BottomTileWidget(
              adModel: adModel,
              styling: styling,
              registerImpression: registerImpression,
            ),
            onCompletion: (hasImpression) =>
                onCompletion(adModel, hasImpression),
          );
        } else if (adModel.mediaModel is CarouselMediaModel) {
          return EmbeddedCarouselAd(
            adModel: adModel,
            styling: styling,
            bottomTileWidget: BottomTileWidget(
              adModel: adModel,
              styling: styling,
              registerImpression: registerImpression,
            ),
            onCompletion: () => onCompletion(adModel, true),
          );
        } else if (adModel.mediaModel is ImageMediaModel) {
          return EmbeddedImageAd(
            adModel: adModel,
            styling: styling,
            bottomTileWidget: BottomTileWidget(
              adModel: adModel,
              styling: styling,
              registerImpression: registerImpression,
            ),
            onCompletion: () => onCompletion(adModel, true),
          );
        }
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  bool get isVisibleEnough =>
      visibilityInfo != null &&
      visibilityInfo!.size.height > minHeight &&
      visibilityInfo!.size.width > minWidth;
}

enum AdLoadingState { notNeeded, loading, loaded, playing }
