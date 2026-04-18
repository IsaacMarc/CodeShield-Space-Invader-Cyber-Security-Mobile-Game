import 'package:codeshield/core/carousel_data.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class HowToPlayVideoItem extends StatefulWidget {
  final CarouselItemData data;
  final bool isActive;

  const HowToPlayVideoItem({
    super.key,
    required this.data,
    required this.isActive,
  });

  @override
  State<HowToPlayVideoItem> createState() => _HowToPlayVideoItemState();
}

class _HowToPlayVideoItemState extends State<HowToPlayVideoItem> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.data.videoPath == null) return;
    _controller = VideoPlayerController.asset(widget.data.videoPath!)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _isInitialized = true;
          _controller?.setLooping(true);
        });
      });
  }

  @override
  void didUpdateWidget(covariant HowToPlayVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isActive && (_controller?.value.isPlaying ?? false)) {
      _controller?.pause();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (!widget.isActive || !_isInitialized || _controller == null) return;

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
  }

  Widget getVideoLayer() {
    if (_isInitialized) {
      // Force the video to stay in its 16:9 aspect ratio
      return AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: VideoPlayer(_controller!),
      );
    } else if (widget.data.videoPath != null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      );
    } else {
      return const Center(
        child: Icon(Icons.video_file_rounded, color: Colors.white24, size: 60),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: widget.data.color,
          border: Border.all(color: Colors.white, width: 4.0),
        ),
        // Center ensures the video doesn't try to stretch to fill the card
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              getVideoLayer(),
              if (widget.isActive && _isInitialized && !(_controller!.value.isPlaying))
                Container(
                  color: Colors.black.withOpacity(0.4),
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      color: Colors.white70,
                      size: 64.0,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}