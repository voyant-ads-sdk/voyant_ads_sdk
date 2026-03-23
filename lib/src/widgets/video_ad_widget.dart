import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import '../../voyant_ads_sdk.dart';
import 'helper.dart';

class VideoAdWidget extends StatefulWidget {
  final VideoMediaModel model;
  final Color mediaBackgroundColor;
  final Widget? footerWidget;
  final Color loadingColor;
  final bool fullScreenMode;
  final Color overlayColor;
  final Color onOverlayColor;
  final double reservedHeight;
  final BoxConstraints? constraints;
  final HeightConstraint? heightConstraint;

  const VideoAdWidget({
    super.key,
    required this.model,
    this.footerWidget,
    this.loadingColor = Colors.blue,
    this.fullScreenMode = false,
    this.overlayColor = Colors.black,
    this.onOverlayColor = Colors.white,
    this.mediaBackgroundColor = Colors.black,
    this.heightConstraint,
    this.reservedHeight = 0,
    this.constraints,
  });

  @override
  State<VideoAdWidget> createState() => _VideoAdWidgetState();
}

class _VideoAdWidgetState extends State<VideoAdWidget> {
  final Player player = Player();
  late VideoController controller;
  final GlobalKey widgetKey = GlobalKey();
  final ValueNotifier<DurationState> durationState =
      ValueNotifier<DurationState>(
        const DurationState(
          buffered: Duration.zero,
          progress: Duration.zero,
          total: Duration.zero,
        ),
      );
  bool userPausedVideo = false;
  bool showOverlay = false;
  Timer? hideTimer;
  bool videoReady = false;
  final double _iconSize = 22;
  double? videoHeight;
  double? videoWidth;
  String? videoPath;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<int?>? _heightSub;
  StreamSubscription<int?>? _widthSub;

  @override
  void initState() {
    super.initState();
    controller = VideoController(player);
    loadVideo();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    player.pause();
    player.dispose();
    hideTimer?.cancel();
    durationState.dispose();
    super.dispose();
  }

  void _scheduleHide(StateSetter reload) {
    hideTimer?.cancel();
    hideTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      reload(() => showOverlay = false);
    });
  }

  Future<void> loadVideo() async {
    if (widget.model is URLVideoMediaModel) {
      URLVideoMediaModel mm = widget.model as URLVideoMediaModel;
      videoPath = mm.url;
      await player.open(Media(mm.url), play: false);
    } else {
      MemoryVideoMediaModel mm = widget.model as MemoryVideoMediaModel;
      videoPath = mm.path;
      await player.open(Media(mm.path), play: false);
    }
    _heightSub ??= player.stream.height.listen((int? height) {
      if (height != null && height.toDouble() != videoHeight && mounted) {
        videoHeight = height.toDouble();
        setState(() {});
      }
    });
    _widthSub ??= player.stream.width.listen((int? width) {
      if (width != null && width.toDouble() != videoWidth && mounted) {
        videoWidth = width.toDouble();
        setState(() {});
      }
    });
    _positionSub ??= player.stream.position.listen((Duration duration) {
      if (mounted) {
        durationState.value = DurationState(
          buffered: player.state.buffer,
          progress: duration,
          total: player.state.duration,
        );
      }
    });
    if (VoyantAds.instance.audioMuted) {
      await player.setVolume(0);
    }
    if (!videoReady && mounted) {
      setState(() => videoReady = true);
    }
    // setState(() {
    //   videoReady = true;
    // });
  }

  Widget get _videoWidget {
    return VisibilityDetector(
      key: widgetKey,
      child: Video(
        fill: widget.mediaBackgroundColor,
        controller: controller,
        controls: (VideoState state) {
          return StatefulBuilder(
            builder: (ctx3, reload) {
              if (showOverlay == false) {
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  child: widget.footerWidget != null
                      ? Stack(
                          children: [
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: widget.footerWidget!,
                            ),
                          ],
                        )
                      : null,
                  onTap: () {
                    reload(() {
                      showOverlay = true;
                      hideTimer?.cancel();
                      if (player.state.playing) {
                        _scheduleHide(reload);
                      }
                    });
                  },
                );
              }
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  hideTimer?.cancel();
                  reload(() {
                    showOverlay = false;
                  });
                },
                child: AnimatedOpacity(
                  opacity: showOverlay ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Stack(
                    children: [
                      Center(
                        child: player.state.playing
                            ? IconButton.filled(
                                iconSize: 35,
                                icon: const Icon(Icons.pause),
                                style: IconButton.styleFrom(
                                  backgroundColor: widget.overlayColor,
                                ),
                                color: widget.onOverlayColor,
                                onPressed: () async {
                                  await player.pause();
                                  hideTimer?.cancel();
                                  userPausedVideo = true;
                                  reload(() {});
                                },
                              )
                            : IconButton.filled(
                                iconSize: 35,
                                icon: const Icon(Icons.play_arrow),
                                style: IconButton.styleFrom(
                                  backgroundColor: widget.overlayColor,
                                ),
                                color: widget.onOverlayColor,
                                onPressed: () async {
                                  await player.play();
                                  hideTimer?.cancel();
                                  _scheduleHide(reload);
                                  userPausedVideo = false;
                                  reload(() {});
                                },
                              ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.footerWidget != null)
                              widget.footerWidget!,
                            Container(
                              padding: const EdgeInsets.all(10),
                              color: widget.overlayColor,
                              child: Row(
                                children: [
                                  player.state.volume == 0
                                      ? MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            child: Icon(
                                              Icons.volume_off,
                                              size: _iconSize,
                                              color: Colors.red,
                                            ),
                                            onTap: () async {
                                              await player.setVolume(100);
                                              VoyantAds.instance.audioMuted =
                                                  false;
                                              if (player.state.playing) {
                                                _scheduleHide(reload);
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
                                              size: _iconSize,
                                              color: widget.onOverlayColor,
                                            ),
                                            onTap: () async {
                                              await player.setVolume(0);
                                              VoyantAds.instance.audioMuted =
                                                  true;
                                              //hideTimer?.cancel();
                                              if (player.state.playing) {
                                                _scheduleHide(reload);
                                              }
                                              reload(() {});
                                            },
                                          ),
                                        ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: ValueListenableBuilder(
                                      valueListenable: durationState,
                                      builder:
                                          (ctx4, DurationState duration, _) {
                                            return ProgressBar(
                                              progress: duration.progress,
                                              buffered: duration.buffered,
                                              total: duration.total,
                                              timeLabelLocation:
                                                  TimeLabelLocation.sides,
                                              timeLabelTextStyle: TextStyle(
                                                color: widget.onOverlayColor,
                                              ),
                                              bufferedBarColor: Colors.red
                                                  .withValues(alpha: 0.25),
                                              thumbColor: widget.onOverlayColor,
                                              barHeight: 3.0,
                                              thumbRadius: 5.0,
                                              onSeek: (Duration seekDuration) {
                                                player.seek(seekDuration);
                                              },
                                              onDragStart: (details) {
                                                hideTimer?.cancel();
                                              },
                                              onDragEnd: () {
                                                _scheduleHide(reload);
                                              },
                                            );
                                          },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      onVisibilityChanged: (VisibilityInfo info) {
        if (info.visibleFraction >= 0.75) {
          if (userPausedVideo == false) {
            if (player.state.playing == false) {
              player.play();
            }
          }
        } else {
          if (player.state.playing) {
            player.pause();
          }
        }
      },
    );
  }

  Widget get _mainWidget {
    if (widget.fullScreenMode) {
      if (videoReady) {
        return _videoWidget;
      } else {
        return _getProgressWidget;
      }
    }
    bool showPlaceholder = false;
    if ((videoHeight == null) ||
        (videoWidth == null) ||
        (videoReady == false)) {
      showPlaceholder = true;
    }
    return AdsHelper.getScaledMediaDimensions(
      constraints: widget.constraints,
      mediaHeight: showPlaceholder ? widget.model.videoHeight : videoHeight,
      mediaWidth: showPlaceholder ? widget.model.videoWidth : videoWidth,
      heightConstraint: widget.heightConstraint,
      reservedHeight: widget.reservedHeight,
      builder: (double? height, double? width) {
        return SizedBox(
          width: showPlaceholder
              ? width
              : null, //so that video controls get shown in full width
          height: height,
          child: showPlaceholder ? _getProgressWidget : _videoWidget,
        );
      },
    );
  }

  Widget get _getProgressWidget {
    return Center(
      child: SpinKitSquareCircle(size: 25, color: widget.loadingColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: _mainWidget);
  }
}

class DurationState {
  const DurationState({
    required this.progress,
    required this.buffered,
    required this.total,
  });
  final Duration progress;
  final Duration buffered;
  final Duration total;
}
