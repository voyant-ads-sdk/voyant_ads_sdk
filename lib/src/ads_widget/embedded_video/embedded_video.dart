import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:uuid/uuid.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../voyant_ads_sdk.dart';
import '../../models/data_models/video_embedded_ad_data_model.dart';
import '../../widgets/helper.dart';
import '../../widgets/video_ad_widget.dart';
import 'embedded_video_controller.dart';

class EmbeddedVideoPlayer extends StatefulWidget {
  final String videoPath;
  final VideoEmbeddedAdStylingModel styling;
  final Widget? placeholderWidget;
  final HeightConstraint heightConstraint;
  final VideoEmbeddedAdDataModel? Function() fetchAd;
  final Function(bool isFullScreen)? onFullscreenToggle;
  final int showAdAfterEverySeconds;
  final bool playInitially;
  final Function(VideoEmbeddedAdDataModel adModel, EventType eventType)
  registerImpression;

  const EmbeddedVideoPlayer({
    super.key,
    required this.videoPath,
    required this.heightConstraint,
    this.showAdAfterEverySeconds = 10,
    required this.styling,
    this.placeholderWidget,
    this.onFullscreenToggle,
    required this.fetchAd,
    required this.registerImpression,
    required this.playInitially,
  });

  @override
  State<EmbeddedVideoPlayer> createState() => _EmbeddedVideoPlayerState();
}

class _EmbeddedVideoPlayerState extends State<EmbeddedVideoPlayer> {
  late final EmbeddedVideoController controller;
  final String uniqueId = Uuid().v4();
  final double _iconSize = 22;

  @override
  void initState() {
    super.initState();
    controller = EmbeddedVideoController(
      fetchAd: widget.fetchAd,
      showAdAfterEverySeconds: widget.showAdAfterEverySeconds,
      videoPath: widget.videoPath,
      onFullscreenToggle: widget.onFullscreenToggle,
      styling: widget.styling,
      registerImpression: widget.registerImpression,
      playInitially: widget.playInitially,
    );
    controller.initialize();
  }

  @override
  void dispose() {
    controller.clearData();
    super.dispose();
  }

  Widget get _videoWidget {
    final overlayColor = widget.styling.overlayColor.withValues(alpha: 0.5);
    if (controller.videoController == null) {
      return const SizedBox.shrink();
    }
    return Video(
      controller: controller.videoController!,
      controls: (VideoState state) {
        return ValueListenableBuilder(
          valueListenable: controller.showOverlay,
          builder: (BuildContext context, bool showOverlay, _) {
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (!mounted) return;
                controller.showOverlay.value = !controller.showOverlay.value;
                controller.hideTimer?.cancel();
                if (showOverlay && controller.videoPlayer.state.playing) {
                  controller.scheduleHide();
                }
              },
              child: Stack(
                children: [
                  AnimatedOpacity(
                    opacity: showOverlay ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Stack(
                      children: [
                        Center(
                          child: controller.videoPlayer.state.playing
                              ? IconButton.filled(
                                  iconSize: 35,
                                  icon: const Icon(Icons.pause),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.black.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  color: Colors.white,
                                  onPressed: () async {
                                    await controller.videoPlayer.pause();
                                    if (!mounted) return;
                                    controller.hideTimer?.cancel();
                                    controller.scheduleHide();
                                    controller.userPausedVideo = true;
                                    setState(() {});
                                  },
                                )
                              : IconButton.filled(
                                  iconSize: 35,
                                  icon: const Icon(Icons.play_arrow),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.black.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  color: Colors.white,
                                  onPressed: () async {
                                    await controller.videoPlayer.play();
                                    if (!mounted) return;
                                    controller.hideTimer?.cancel();
                                    controller.scheduleHide();
                                    controller.userPausedVideo = false;
                                    setState(() {});
                                  },
                                ),
                        ),

                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            color: Colors.black.withValues(alpha: 0.5),
                            child: Row(
                              children: [
                                controller.videoPlayer.state.volume == 0
                                    ? MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          child: Icon(
                                            Icons.volume_off,
                                            size: _iconSize,
                                            color: Colors.red,
                                          ),
                                          onTap: () async {
                                            await controller.videoPlayer
                                                .setVolume(100);
                                            VoyantAds.instance.audioMuted =
                                                false;
                                            if (controller
                                                .videoPlayer
                                                .state
                                                .playing) {
                                              controller.scheduleHide();
                                            }
                                            if (!mounted) return;
                                            setState(() {});
                                          },
                                        ),
                                      )
                                    : MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          child: Icon(
                                            Icons.volume_up,
                                            size: _iconSize,
                                            color: Colors.white,
                                          ),
                                          onTap: () async {
                                            await controller.videoPlayer
                                                .setVolume(0);
                                            VoyantAds.instance.audioMuted =
                                                true;
                                            //hideTimer?.cancel();
                                            if (controller
                                                .videoPlayer
                                                .state
                                                .playing) {
                                              controller.scheduleHide();
                                            }
                                            if (!mounted) return;
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: ValueListenableBuilder(
                                    valueListenable: controller.durationState,
                                    builder: (ctx4, DurationState duration, _) {
                                      return ProgressBar(
                                        progress: duration.progress,
                                        buffered: duration.buffered,
                                        total: duration.total,
                                        timeLabelLocation:
                                            TimeLabelLocation.sides,
                                        timeLabelTextStyle: TextStyle(
                                          color: Colors.white,
                                        ),
                                        bufferedBarColor: Colors.green,
                                        thumbColor: Colors.red,
                                        baseBarColor: Colors.white,
                                        progressBarColor: Colors.yellow,
                                        barHeight: 3.0,
                                        thumbRadius: 5.0,
                                        onSeek: (Duration seekDuration) {
                                          controller.videoPlayer.seek(
                                            seekDuration,
                                          );
                                        },
                                        onDragStart: (details) {
                                          controller.hideTimer?.cancel();
                                        },
                                        onDragEnd: () {
                                          controller.scheduleHide();
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: ValueListenableBuilder(
                      valueListenable: controller.adBufferTimer,
                      builder: (BuildContext ctx3, int value, _) {
                        if (value <= 0) {
                          return const SizedBox.shrink();
                        }
                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: overlayColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            'Ad in ${controller.showAdTimerInAdvance - value}',
                            style: TextStyle(
                              color: widget.styling.onOverlayColor,
                            ),
                          ),
                        );
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

  Widget get _mainWidget {
    if (controller.videoReady) {
      return ValueListenableBuilder(
        valueListenable: controller.showAd,
        builder: (ctx, value, _) {
          if (value != null) {
            return value;
          }
          return _videoWidget;
        },
      );
    }
    return _progressWidget;
  }

  Widget get _progressWidget {
    if (widget.placeholderWidget != null) {
      return widget.placeholderWidget!;
    }
    return Center(
      child: SpinKitSquareCircle(size: 30, color: widget.styling.loadingColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey(uniqueId),
      onVisibilityChanged: (VisibilityInfo info) {
        controller.visibilityInfo = info;
      },
      child: ValueListenableBuilder(
        valueListenable: controller.refreshVideoWidget,
        builder: (BuildContext context, _, __) {
          return LayoutBuilder(
            builder: (BuildContext ctx, BoxConstraints constraints) {
              return AdsHelper.getScaledMediaDimensions(
                constraints: constraints,
                mediaHeight: controller.videoHeight,
                mediaWidth: controller.videoWidth,
                heightConstraint: widget.heightConstraint,
                reservedHeight: 0,
                builder: (double? height, double? width) {
                  return SizedBox(height: height, child: _mainWidget);
                },
              );
            },
          );
        },
      ),
    );
  }
}
