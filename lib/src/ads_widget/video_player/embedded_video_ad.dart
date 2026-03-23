import 'dart:async';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../../voyant_ads_sdk.dart';
import '../../widgets/helper.dart';
import '../../widgets/video_ad_widget.dart';

class EmbeddedVideoAd extends StatefulWidget {
  final MediaModel videoModel;
  final VideoEmbeddedAdStylingModel styling;
  final Function(bool registerImpression) onCompletion;
  final Widget bottomTileWidget;
  final double? intitialVolume;

  const EmbeddedVideoAd({
    super.key,
    required this.videoModel,
    required this.onCompletion,
    required this.styling,
    required this.bottomTileWidget,
    required this.intitialVolume,
  });

  @override
  State<EmbeddedVideoAd> createState() => _VideoAdState();
}

class _VideoAdState extends State<EmbeddedVideoAd> {
  bool showOverlay = false;
  final ValueNotifier<DurationState> durationState =
      ValueNotifier<DurationState>(
        const DurationState(
          buffered: Duration.zero,
          progress: Duration.zero,
          total: Duration.zero,
        ),
      );
  Timer? hideTimer;
  Timer? playTimer;
  bool isVideoReady = false;
  final int _adSkipDuration = 10;
  late final Color _overlayColor;
  StreamSubscription<bool>? _completedSub;
  StreamSubscription<Duration>? _positionSub;
  Player adPlayer = Player();
  late VideoController controller;
  Timer? loadFailSafeTimer;
  bool hasImpression = false;

  @override
  void initState() {
    super.initState();
    _overlayColor = widget.styling.overlayColor.withValues(alpha: 0.5);
    controller = VideoController(adPlayer);
    _initialize();
  }

  @override
  void dispose() {
    loadFailSafeTimer?.cancel();
    _completedSub?.cancel();
    _positionSub?.cancel();
    adPlayer.dispose();
    hideTimer?.cancel();
    playTimer?.cancel();
    durationState.dispose();
    super.dispose();
  }

  _initialize() async {
    if (widget.intitialVolume != null) {
      await adPlayer.setVolume(widget.intitialVolume!);
    } else {
      await adPlayer.setVolume(0);
    }
    if (widget.videoModel is URLVideoMediaModel) {
      URLVideoMediaModel vmm = widget.videoModel as URLVideoMediaModel;
      await adPlayer.open(Media(vmm.url), play: true);
    }
    loadFailSafeTimer = Timer(const Duration(seconds: 6), () {
      if (mounted) {
        widget.onCompletion.call(hasImpression);
      }
    });
    _completedSub ??= adPlayer.stream.completed.listen((bool isCompleted) {
      if (isCompleted && mounted) {
        widget.onCompletion.call(hasImpression);
      }
    });
    _positionSub ??= adPlayer.stream.position.listen((Duration duration) {
      if (mounted) {
        if (duration > Duration.zero) {
          loadFailSafeTimer?.cancel();
        }
        int temp = _adSkipDuration - duration.inSeconds;
        if (temp < 0 && hasImpression == false) {
          hasImpression = true;
        }
        durationState.value = DurationState(
          buffered: adPlayer.state.buffer,
          progress: duration,
          total: adPlayer.state.duration,
        );
      }
    });
    isVideoReady = true;
    if (mounted) {
      setState(() {});
    }
  }

  void _scheduleHideOverlay() {
    hideTimer?.cancel();
    hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => showOverlay = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isVideoReady == false) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: SizedBox(
            height: 50,
            width: 50,
            child: CircularProgressIndicator(
              color: widget.styling.loadingColor,
            ),
          ),
        ),
      );
    }
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
                showOverlay = !showOverlay;
                if (adPlayer.state.playing == true) {
                  _scheduleHideOverlay();
                }
                reload(() {});
              },
              child: Stack(
                children: [
                  if (showOverlay == true)
                    Center(
                      child: adPlayer.state.playing
                          ? IconButton.filled(
                              iconSize: 35,
                              style: IconButton.styleFrom(
                                backgroundColor: _overlayColor,
                              ),
                              icon: const Icon(Icons.pause),
                              color: widget.styling.onOverlayColor,
                              onPressed: () async {
                                await adPlayer.pause();
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
                                await adPlayer.play();
                                _scheduleHideOverlay();
                                reload(() {});
                              },
                            ),
                    ),
                  if (showOverlay == false)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(child: widget.bottomTileWidget),
                    ),
                  if (showOverlay == true)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        color: _overlayColor,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                adPlayer.state.volume == 0
                                    ? MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          child: const Icon(
                                            Icons.volume_off,
                                            size: 18,
                                            color: Colors.red,
                                          ),
                                          onTap: () async {
                                            await adPlayer.setVolume(100);
                                            hideTimer?.cancel();
                                            if (adPlayer.state.playing ==
                                                true) {
                                              _scheduleHideOverlay();
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
                                            color:
                                                widget.styling.onOverlayColor,
                                          ),
                                          onTap: () async {
                                            await adPlayer.setVolume(0);
                                            hideTimer?.cancel();
                                            if (adPlayer.state.playing ==
                                                true) {
                                              _scheduleHideOverlay();
                                            }
                                            reload(() {});
                                          },
                                        ),
                                      ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: ValueListenableBuilder(
                                    valueListenable: durationState,
                                    builder: (ctx4, DurationState duration, _) {
                                      return ProgressBar(
                                        progress: duration.progress,
                                        buffered: duration.buffered,
                                        total: duration.total,
                                        timeLabelLocation:
                                            TimeLabelLocation.sides,
                                        timeLabelTextStyle: TextStyle(
                                          color: widget.styling.onOverlayColor,
                                        ),
                                        bufferedBarColor: Colors.red.withValues(
                                          alpha: 0.24,
                                        ),
                                        thumbColor:
                                            widget.styling.onOverlayColor,
                                        barHeight: 3.0,
                                        thumbRadius: 5.0,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: AdsHelper.getAdSkipByDurationWidget(
                      durationState,
                      adSkipDuration: _adSkipDuration,
                      overlayColor: _overlayColor,
                      onOverlayColor: widget.styling.onOverlayColor,
                      onSkip: () {
                        if (!mounted) return;
                        hasImpression = true;
                        widget.onCompletion.call(hasImpression);
                      },
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
}
