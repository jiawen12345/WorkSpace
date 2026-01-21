import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final File videoFile;

  const VideoPlayerScreen({Key? key, required this.videoFile}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _showControls = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    print('初始化视频播放器: ${widget.videoFile.path}');
    print('视频文件是否存在: ${widget.videoFile.existsSync()}');

    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        print('视频初始化成功');
        setState(() {});
      }).catchError((error) {
        print('视频初始化失败: $error');
        setState(() {
          _hasError = true;
          _errorMessage = '视频加载失败: $error';
        });
      });

    _controller.addListener(() {
      if (_controller.value.isPlaying != _isPlaying) {
        setState(() {
          _isPlaying = _controller.value.isPlaying;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('视频播放', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: _hasError
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('返回'),
                  ),
                ],
              )
            : _controller.value.isInitialized
                ? GestureDetector(
                    onTap: _toggleControls,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                    if (_showControls)
                      Container(
                        color: Colors.black.withOpacity(0.3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: _togglePlayPause,
                              icon: Icon(
                                _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                                size: 80,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  Text(
                                    _formatDuration(_controller.value.position),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  Expanded(
                                    child: Slider(
                                      value: _controller.value.position.inSeconds.toDouble(),
                                      max: _controller.value.duration.inSeconds.toDouble(),
                                      onChanged: (value) {
                                        _controller.seekTo(Duration(seconds: value.toInt()));
                                      },
                                      activeColor: Colors.white,
                                      inactiveColor: Colors.white.withOpacity(0.3),
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(_controller.value.duration),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      ],
                    ),
                  )
                : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}