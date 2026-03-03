import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CaptureScreen extends StatefulWidget {
  CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _videoFile;
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoFuture;

  Future<void> sendVideo(File videoFile) async {
    var uri = Uri.parse("http://192.168.0.113:8000/upload");

    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', videoFile.path));

    var response = await request.send();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> body = json.decode(await response.stream.bytesToString());
      final jobId = body['job_id'];
      if (jobId == null) {
        print("Warning: No job ID found in response");
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('job_id', jobId.toString());

      print("Video uploaded successfully, job ID: $jobId");
    } else {
      // handle non-2xx
      print("Failed to upload video, status code: ${response.statusCode}");
    }
  }

  Future<void> _setVideo(XFile video) async {
    _videoFile = video;
    _controller?.dispose();
    _controller = VideoPlayerController.file(File(video.path));
    _initializeVideoFuture = _controller!.initialize().then((_) {
      _controller!..setLooping(true)..play();
      setState(() {});
    });
    setState(() {});
  }

  Future<void> _recordVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
    if (video != null) await _setVideo(video);
  }

  Future<void> _pickFromGallery() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) await _setVideo(video);
  }

  void _discardVideo() {
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
    _initializeVideoFuture = null;
    _videoFile = null;
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasVideo = _videoFile != null && _controller != null;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Zachytenie stromu')),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              // Preview area
              if (hasVideo)
                Expanded(
                  child: Stack(
                    children: [
                      Center(
                        child: FutureBuilder<void>(
                          future: _initializeVideoFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done && _controller != null) {
                              final aspect = _controller!.value.aspectRatio;
                              return AspectRatio(
                                aspectRatio: aspect > 0 ? aspect : 16 / 9,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: VideoPlayer(_controller!),
                                ),
                              );
                            }
                            return Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemGrey5,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(child: CupertinoActivityIndicator()),
                            );
                          },
                        ),
                      ),

                      // Green check top-right
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () {
                            if (_videoFile != null) {
                              sendVideo(File(_videoFile!.path));
                              Navigator.pop(context);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(color: CupertinoColors.activeGreen, shape: BoxShape.circle),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(CupertinoIcons.check_mark, color: CupertinoColors.white, size: 20),
                          ),
                        ),
                      ),

                      // Red trash bottom-right
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: _discardVideo,
                          child: Container(
                            decoration: BoxDecoration(color: CupertinoColors.systemRed, shape: BoxShape.circle),
                            padding: const EdgeInsets.all(10),
                            child: const Icon(CupertinoIcons.delete, color: CupertinoColors.white, size: 22),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox(height: 200),

              const SizedBox(height: 20),

              // Buttons
              CupertinoButton.filled(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                borderRadius: BorderRadius.circular(14),
                onPressed: hasVideo ? null : _recordVideo,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.photo_camera_solid),
                    SizedBox(width: 8),
                    Text('Urobiť video stromu'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                borderRadius: BorderRadius.circular(14),
                color: CupertinoColors.systemGrey5,
                onPressed: hasVideo ? null : _pickFromGallery,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.cloud_upload),
                    SizedBox(width: 8),
                    Text('Odoslať predpripravené video'),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}