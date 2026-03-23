import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late final Player _player;
  late final VideoController _videoController;

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<bool>? _playingSub;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _player = Player();
    _videoController = VideoController(_player);

    await _player.open(Media('asset:///assets/video.mp4'), play: true);

    /// ✅ POSITION STREAM (this NEVER breaks)
    _positionSub = _player.stream.position.listen((pos) {
      if (kDebugMode) debugPrint('position => ${pos.inMilliseconds}');
    });

    /// Optional: observe play/pause state
    _playingSub = _player.stream.playing.listen((playing) {
      if (kDebugMode) debugPrint('playing => $playing');
    });
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _playingSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _seekBy(Duration offset) async {
    final current = _player.state.position;
    await _player.seek(current + offset);

    /// 🔥 CRITICAL: resume playback after seek
    await _player.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Video(controller: _videoController, fit: BoxFit.contain),
          ),

          /// Overlay controls
          Positioned.fill(
            child: IgnorePointer(
              ignoring: false,
              child: Container(
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 40,
                      color: Colors.white,
                      icon: const Icon(Icons.replay_10),
                      onPressed: () => _seekBy(const Duration(seconds: -10)),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      iconSize: 50,
                      color: Colors.white,
                      icon: StreamBuilder<bool>(
                        stream: _player.stream.playing,
                        initialData: true,
                        builder: (_, snap) {
                          return Icon(
                            snap.data == true
                                ? Icons.pause_circle
                                : Icons.play_circle,
                          );
                        },
                      ),
                      onPressed: () {
                        if (_player.state.playing) {
                          _player.pause();
                        } else {
                          _player.play();
                        }
                      },
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      iconSize: 40,
                      color: Colors.white,
                      icon: const Icon(Icons.forward_10),
                      onPressed: () => _seekBy(const Duration(seconds: 10)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
