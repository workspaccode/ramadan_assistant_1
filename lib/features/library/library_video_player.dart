import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:video_player/video_player.dart';

/// Direct media files and HLS streams can play in-app; page links such as
/// YouTube watch pages cannot and must open in the user's own app instead.
bool libraryIsDirectVideo(Uri uri) {
  final path = uri.path.toLowerCase();
  return const [
    '.mp4',
    '.m4v',
    '.webm',
    '.mov',
    '.mkv',
    '.m3u8',
    '.3gp',
  ].any(path.endsWith);
}

typedef VideoControllerFactory = VideoPlayerController Function(Uri url);

/// Inline player for a user-attached HTTPS video. Owns its controller, tolerates
/// slow or failing networks, and reports failure so the caller can fall back.
class LibraryVideoPlayer extends StatefulWidget {
  const LibraryVideoPlayer({
    super.key,
    required this.url,
    required this.onFailed,
    this.controllerFactory = _networkController,
  });
  final Uri url;
  final VoidCallback onFailed;
  final VideoControllerFactory controllerFactory;

  static VideoPlayerController _networkController(Uri url) =>
      VideoPlayerController.networkUrl(url);

  @override
  State<LibraryVideoPlayer> createState() => _LibraryVideoPlayerState();
}

class _LibraryVideoPlayerState extends State<LibraryVideoPlayer> {
  VideoPlayerController? _video;
  ChewieController? _chewie;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  Future<void> _start() async {
    final video = widget.controllerFactory(widget.url);
    _video = video;
    try {
      await video.initialize();
      if (!mounted || _video != video) return;
      setState(() {
        _chewie = ChewieController(
          videoPlayerController: video,
          autoPlay: true,
          aspectRatio: video.value.aspectRatio == 0
              ? 16 / 9
              : video.value.aspectRatio,
          errorBuilder: (_, _) => const _Failure(),
        );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = true);
      widget.onFailed();
    }
  }

  @override
  void dispose() {
    _chewie?.dispose();
    // ChewieController does not dispose a controller it did not create.
    unawaited(_video?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) return const _Failure();
    final chewie = _chewie;
    if (chewie == null) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: chewie.aspectRatio ?? 16 / 9,
        child: Chewie(controller: chewie),
      ),
    );
  }
}

class _Failure extends StatelessWidget {
  const _Failure();
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Text(
      context.loc.library_video_failed,
      style: TextStyle(color: context.errorColor),
    ),
  );
}
