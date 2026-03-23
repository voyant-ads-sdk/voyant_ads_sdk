import 'dart:async';
import 'package:blur/blur.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:simple_alert_dialog/simple_alert_dialog.dart';
import 'package:uuid/uuid.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../voyant_ads_sdk.dart';
import '../models/data_models/rewarding_ad_data_model.dart';
import '../widgets/brand_logo_widget.dart';
import '../widgets/carousel_ad_widget.dart';
import '../widgets/helper.dart';
import '../widgets/image_ad_widget.dart';
import '../widgets/video_ad_widget.dart';

class RewardingAdWidget extends StatefulWidget {
  final RewardingAdStylingModel styling;
  final RewardingAdDataModel currentModel;
  final Function(VisibilityInfo visibilityInfo, EventType eventType)
  registerImpression;

  const RewardingAdWidget({
    super.key,
    required this.styling,
    required this.currentModel,
    required this.registerImpression,
  });

  @override
  State<RewardingAdWidget> createState() => _RewardingAdWidgetState();
}

class _RewardingAdWidgetState extends State<RewardingAdWidget> {
  final Player player = Player();
  late VideoController controller;
  bool impressionSuccessful = false;
  bool adReady = false;
  final String uniqueId = Uuid().v4();
  final int _adSkipDuration = 8;
  Timer? hideTimer;
  VisibilityInfo? visibilityInfo;

  final ValueNotifier<DurationState> durationState =
      ValueNotifier<DurationState>(
        const DurationState(
          buffered: Duration.zero,
          progress: Duration.zero,
          total: Duration.zero,
        ),
      );

  final ValueNotifier<int> timeElapsed = ValueNotifier<int>(0);
  Timer? timeElapsedTimer;
  late final Color _overlayColor;
  //
  StreamSubscription<bool>? _completedSub;
  StreamSubscription<Duration>? _positionSub;
  DeviceOrientation? _lastOrientation;

  @override
  void initState() {
    super.initState();
    _overlayColor = widget.styling.overlayColor.withValues(alpha: 0.5);
    _loadFuture();
  }

  @override
  void dispose() {
    timeElapsed.dispose();
    hideTimer?.cancel();
    timeElapsedTimer?.cancel();
    durationState.dispose();
    player.dispose();
    _completedSub?.cancel();
    _positionSub?.cancel();
    super.dispose();
  }

  Future<void>? _loadVideoFuture(VideoMediaModel vm) async {
    controller = VideoController(player);
    if (vm is URLVideoMediaModel) {
      await player.open(Media(vm.url), play: true);
    } else {
      MemoryVideoMediaModel mm = vm as MemoryVideoMediaModel;
      await player.open(Media(mm.path), play: true);
    }
    if (VoyantAds.instance.audioMuted) {
      await player.setVolume(0);
    }
    _completedSub?.cancel();
    _positionSub?.cancel();
    _completedSub = player.stream.completed.listen((isCompleted) {
      if (isCompleted) _handleVideoImpression();
    });
    _positionSub = player.stream.position.listen((duration) {
      durationState.value = DurationState(
        buffered: player.state.buffer,
        progress: duration,
        total: player.state.duration,
      );
    });
  }

  void manageOrientation(double? h, double? w) {
    if (h == null || w == null) return;
    final next = h <= w
        ? DeviceOrientation.landscapeLeft
        : DeviceOrientation.portraitUp;
    if (_lastOrientation == next) return;
    _lastOrientation = next;
    SystemChrome.setPreferredOrientations(
      h <= w
          ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
          : [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
    );
  }

  void _completeImpression(EventType type) {
    if (impressionSuccessful) return;
    impressionSuccessful = true;
    if (visibilityInfo != null) {
      widget.registerImpression(visibilityInfo!, type);
    }
    if (mounted) setState(() {});
  }

  Future<void> _loadFuture() async {
    if (widget.currentModel.mediaModel is VideoMediaModel) {
      VideoMediaModel vm = widget.currentModel.mediaModel as VideoMediaModel;
      manageOrientation(vm.videoHeight, vm.videoWidth);
      await _loadVideoFuture(vm);
    } else if (widget.currentModel.mediaModel is ImageMediaModel) {
      ImageMediaModel im = widget.currentModel.mediaModel as ImageMediaModel;
      manageOrientation(im.height, im.width);
      timeElapsedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        timeElapsed.value = timeElapsed.value + 1;
        if (timeElapsed.value >= _adSkipDuration) {
          timeElapsedTimer?.cancel();
          _completeImpression(EventType.impression);
        }
      });
    } else if (widget.currentModel.mediaModel is CarouselMediaModel) {
      timeElapsedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        timeElapsed.value = timeElapsed.value + 1;
        if (timeElapsed.value >= _adSkipDuration * 2) {
          //impressionSuccessful = true;
          timeElapsedTimer?.cancel();
          _completeImpression(EventType.impression);
        }
      });
    }
    adReady = true;
    if (mounted) setState(() {});
  }

  _handleVideoImpression() async {
    hideTimer?.cancel();
    if (player.state.playing) {
      await player.pause();
    }
    impressionSuccessful = true;
    if (visibilityInfo != null) {
      widget.registerImpression(visibilityInfo!, EventType.impression);
    }
    if (mounted) setState(() {});
  }

  Widget bottomTile(RewardingAdDataModel adModel) {
    Uri url = Uri.parse(adModel.destinationUrl);
    String tempUrl = adModel.destinationUrl;
    if (url.scheme != '') {
      tempUrl = url.origin;
    }
    return AdListTile(
      title: adModel.footerTitle ?? adModel.headerTitle,
      style: widget.styling.footerTileStyle,
      subtitle: adModel.footerSubtitle != null
          ? adModel.footerSubtitle!
          : tempUrl,
      trailing: SizedBox(
        height: 35,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            side: BorderSide(width: 1, color: widget.styling.onOverlayColor),
            textStyle: TextStyle(color: widget.styling.onOverlayColor),
          ),
          child: Text(
            adModel.actionText ?? 'VISIT',
            style: widget.styling.actionStyle,
          ),
          onPressed: () {
            VoyantAds.instance.showAdTapWidget(
              adModel: widget.currentModel,
              context: context,
              onContinue: () {
                widget.registerImpression(visibilityInfo!, EventType.click);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _getPostImpressionWidget(
    RewardingAdDataModel adModel,
    Widget blurredWidget,
  ) {
    return Stack(
      children: [
        blurredWidget,
        Column(
          children: [
            const Spacer(),
            BrandLogoWidget(
              model: adModel.logoModel,
              height: widget.styling.logoSize,
              width: widget.styling.logoSize,
            ),
            const SizedBox(height: 10),
            Text(
              adModel.headerTitle,
              style: widget.styling.headerTitleStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              adModel.headerSubtitle,
              style: widget.styling.headerSubtitleStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            if (adModel.adDescription != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 15, right: 15),
                child: Text(
                  adModel.adDescription!,
                  style: widget.styling.descriptionStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            const Spacer(),
            bottomTile(adModel),
          ],
        ),
        Positioned(
          top: 15,
          left: 15,
          child: IconButton.filled(
            style: IconButton.styleFrom(backgroundColor: _overlayColor),
            icon: Icon(Icons.clear, color: widget.styling.onOverlayColor),
            onPressed: () {
              Navigator.of(context).pop(impressionSuccessful);
            },
          ),
        ),
      ],
    );
  }

  void _cancelOverlayHide() {
    hideTimer?.cancel();
    hideTimer = null;
  }

  void _scheduleOverlayHide(VoidCallback hide) {
    _cancelOverlayHide();
    hideTimer = Timer(const Duration(seconds: 4), hide);
  }

  Widget _getVideoWidget(RewardingAdDataModel adModel) {
    bool showOverlay = false;
    return Video(
      fill: widget.styling.mediaBackgroundColor,
      controller: controller,
      controls: (VideoState state) {
        return StatefulBuilder(
          builder: (ctx, reload) {
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                hideTimer?.cancel();
                reload(() {
                  showOverlay = !showOverlay;
                  if (player.state.playing == true) {
                    _scheduleOverlayHide(() {
                      reload(() => showOverlay = false);
                    });
                  }
                });
              },
              child: Stack(
                children: [
                  if (showOverlay == true)
                    Center(
                      child: player.state.playing
                          ? IconButton.filled(
                              iconSize: 35,
                              style: IconButton.styleFrom(
                                backgroundColor: _overlayColor,
                              ),
                              icon: const Icon(Icons.pause),
                              color: widget.styling.onOverlayColor,
                              onPressed: () async {
                                await player.pause();
                                hideTimer?.cancel();
                                reload(() {});
                              },
                            )
                          : IconButton.filled(
                              iconSize: 35,
                              style: IconButton.styleFrom(
                                backgroundColor: _overlayColor,
                              ),
                              icon: const Icon(Icons.play_arrow),
                              color: widget.styling.onOverlayColor,
                              onPressed: () async {
                                await player.play();
                                _scheduleOverlayHide(() {
                                  reload(() => showOverlay = false);
                                });
                                reload(() {});
                              },
                            ),
                    ),
                  _closeAdWidget(adModel),
                  if (showOverlay == true)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        color: _overlayColor,
                        child: Row(
                          children: [
                            player.state.volume == 0
                                ? MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      child: const Icon(
                                        Icons.volume_off,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                      onTap: () async {
                                        await player.setVolume(100);
                                        hideTimer?.cancel();
                                        if (player.state.playing == true) {
                                          _scheduleOverlayHide(() {
                                            reload(() => showOverlay = false);
                                          });
                                        }
                                        reload(() {});
                                      },
                                    ),
                                  )
                                : MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      child: Icon(
                                        Icons.volume_up,
                                        size: 18,
                                        color: widget.styling.onOverlayColor,
                                      ),
                                      onTap: () async {
                                        await player.setVolume(0);
                                        hideTimer?.cancel();
                                        if (player.state.playing == true) {
                                          _scheduleOverlayHide(() {
                                            reload(() => showOverlay = false);
                                          });
                                        }
                                        reload(() {});
                                      },
                                    ),
                                  ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: ValueListenableBuilder(
                                valueListenable: durationState,
                                builder: (ctx3, DurationState duration, _) {
                                  return ProgressBar(
                                    progress: duration.progress,
                                    buffered: duration.buffered,
                                    total: duration.total,
                                    timeLabelLocation: TimeLabelLocation.sides,
                                    timeLabelTextStyle: TextStyle(
                                      color: widget.styling.onOverlayColor,
                                    ),
                                    bufferedBarColor: Colors.red.withValues(
                                      alpha: 0.24,
                                    ),
                                    thumbColor: widget.styling.onOverlayColor,
                                    barHeight: 3.0,
                                    thumbRadius: 5.0,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    top: 15,
                    right: 5,
                    child: AdsHelper.getAdSkipByDurationWidget(
                      durationState,
                      adSkipDuration: _adSkipDuration,
                      overlayColor: _overlayColor,
                      onOverlayColor: widget.styling.onOverlayColor,
                      onSkip: _handleVideoImpression,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _closeAdWidget(RewardingAdDataModel adModel) {
    return Positioned(
      left: 5,
      top: 15,
      child: FilledButton(
        style: FilledButton.styleFrom(backgroundColor: _overlayColor),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.clear, color: widget.styling.onOverlayColor),
            const SizedBox(width: 5),
            Text(
              VoyantAds.adNetworkName,
              style: TextStyle(
                color: widget.styling.onOverlayColor,
                fontSize: 13,
              ),
            ),
          ],
        ),
        onPressed: () {
          if (impressionSuccessful == false) {
            SimpleAlertDialog.show(
              context,
              assetImagepath: AnimatedImage.error,
              buttonsColor: Colors.red,
              title: AlertTitleText("Deny rewards ?"),
              content: AlertContentText(
                "Are you sure to deny reward ? You will not be able to undo this action.",
              ),
              cancelBtnText: 'NO',
              barrierDismissible: true,
              confirmBtnText: 'YES',
              onConfirmButtonPressed: (ctx) async {
                Navigator.pop(ctx);
                Navigator.of(context).pop(impressionSuccessful);
              },
            );
          } else {
            Navigator.of(context).pop(impressionSuccessful);
          }
        },
      ),
    );
  }

  Widget _getImageWidget(RewardingAdDataModel adModel) {
    return Stack(
      children: [
        ImageAdWidget(
          model: adModel.mediaModel as ImageMediaModel,
          fullScreenMode: true,
          loadingColor: widget.styling.loadingColor,
        ),
        Positioned(
          top: 15,
          right: 5,
          child: ValueListenableBuilder(
            valueListenable: timeElapsed,
            builder: (ctx, int duration, _) {
              return AdsHelper.getOverlayTextButtonWidget(
                'Auto skip in ${_adSkipDuration - duration}',
                overlayColor: _overlayColor,
                onOverlayColor: widget.styling.onOverlayColor,
              );
            },
          ),
        ),
        _closeAdWidget(adModel),
      ],
    );
  }

  Widget _getCarousalWidget(RewardingAdDataModel adModel) {
    return Stack(
      children: [
        CarouselAdWidget(
          model: adModel.mediaModel as CarouselMediaModel,
          fullScreenMode: true,
          loadingColor: widget.styling.loadingColor,
        ),
        Positioned(
          top: 15,
          right: 5,
          child: ValueListenableBuilder(
            valueListenable: timeElapsed,
            builder: (ctx, int duration, _) {
              return AdsHelper.getOverlayTextButtonWidget(
                duration > _adSkipDuration
                    ? 'Auto Skip in ${_adSkipDuration * 2 - duration}'
                    : 'Skip in ${_adSkipDuration - duration}',
                overlayColor: _overlayColor,
                onOverlayColor: widget.styling.onOverlayColor,
                onTap: () {
                  if (duration >= _adSkipDuration) {
                    impressionSuccessful = true;
                    timeElapsedTimer?.cancel();
                    if (visibilityInfo != null) {
                      widget.registerImpression(
                        visibilityInfo!,
                        EventType.click,
                      );
                    }
                    if (mounted) setState(() {});
                  }
                },
              );
            },
          ),
        ),
        _closeAdWidget(adModel),
      ],
    );
  }

  Widget get _getMainWidget {
    if (adReady) {
      if (impressionSuccessful) {
        if (widget.currentModel.mediaModel is VideoMediaModel) {
          return _getPostImpressionWidget(
            widget.currentModel,
            Blur(
              blur: 5,
              blurColor: Theme.of(context).primaryColor,
              child: Video(
                controller: controller,
                controls: (VideoState state) {
                  return const SizedBox.shrink();
                },
              ),
            ),
          );
        } else if (widget.currentModel.mediaModel is CarouselMediaModel) {
          return _getPostImpressionWidget(
            widget.currentModel,
            Blur(
              blur: 5,
              blurColor: Theme.of(context).primaryColor,
              child: CarouselAdWidget(
                model: widget.currentModel.mediaModel as CarouselMediaModel,
                fullScreenMode: true,
                loadingColor: widget.styling.loadingColor,
              ),
            ),
          );
        } else if (widget.currentModel.mediaModel is ImageMediaModel) {
          return _getPostImpressionWidget(
            widget.currentModel,
            Blur(
              blur: 5,
              blurColor: Theme.of(context).primaryColor,
              child: ImageAdWidget(
                model: widget.currentModel.mediaModel as ImageMediaModel,
                fullScreenMode: true,
                loadingColor: widget.styling.loadingColor,
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      } else {
        if (widget.currentModel.mediaModel is VideoMediaModel) {
          return _getVideoWidget(widget.currentModel);
        } else if (widget.currentModel.mediaModel is ImageMediaModel) {
          return _getImageWidget(widget.currentModel);
        } else if (widget.currentModel.mediaModel is CarouselMediaModel) {
          return _getCarousalWidget(widget.currentModel);
        } else {
          return const SizedBox.shrink();
        }
      }
    } else {
      return Center(
        child: SpinKitSquareCircle(
          size: 25,
          color: widget.styling.loadingColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: widget.styling.mediaBackgroundColor,
        body: VisibilityDetector(
          key: ValueKey('${widget.currentModel.adId}_$uniqueId'),
          onVisibilityChanged: (VisibilityInfo info) {
            visibilityInfo = info.visibleFraction > 0 ? info : null;
          },
          child: _getMainWidget,
        ),
      ),
    );
  }
}
