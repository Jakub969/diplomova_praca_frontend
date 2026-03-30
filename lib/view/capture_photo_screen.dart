import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:diplomova_praca/controller/save_tree.dart';

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
  TextEditingController _nameController = TextEditingController();
  SaveTree saveTreeController = SaveTree();

  Future<void> sendVideo(File videoFile, BuildContext context) async {
    final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult.isEmpty || connectivityResult.contains(ConnectivityResult.none)) {
        print("No internet connection, cannot upload video");
        showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: const Text("Žiadne pripojenie"),
            content: const Text("Nemôžeme odoslať video bez internetového pripojenia. Skontrolujte svoje pripojenie a skuste to znovu."),
            actions: [
              CupertinoDialogAction(
                child: const Text("OK"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
        return;
      }
    var uri = Uri.parse("http://192.168.0.115:8000/upload");

    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', videoFile.path));

    var response = await request.send();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> body = json.decode(await response.stream.bytesToString());
      final jobId = body['job_id'];
      final taskId = body['task_id'];
      if (jobId == null) {
        print("Warning: No job ID found in response");
      }
      //save tree using function from save_tree.dart
      await saveTreeController.saveInLocalStorage(_nameController.text, _videoFile!.path, jobId, "", "", taskId);
      print("Video uploaded successfully, job ID: $jobId");
      showCupertinoDialog(context: context, builder: (_) => CupertinoAlertDialog(
        title: const Text("Video úspešne odoslané"),
        content: const Text("Video bolo úspešne odoslané a bude spracované. Výsledky budú k dispozíci v sekci Moje stromy."),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text("OK"),
            onPressed: () => Navigator.popUntil(context, ( route) => route.isFirst),
          ),
        ],
      ));
    } else {
      // handle non-2xx
      print("Failed to upload video, status code: ${response.statusCode}");
      showCupertinoDialog(context: context, builder: (_) => CupertinoAlertDialog(
        title: const Text("Chyba pri odosielaní videa"),
        content: const Text("Nastala chyba pri odosielaní videa. Skuste to znovu neskôr."),
        actions: [
          CupertinoDialogAction(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ));
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
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () {
                            if (_videoFile != null && _nameController.text.trim().isNotEmpty) {
                              sendVideo(File(_videoFile!.path), context);
                            } else {
                              showCupertinoDialog(
                                context: context,
                                builder: (_) => CupertinoAlertDialog(
                                  title: const Text("Chýbajúci názov stromu"),
                                  content: const Text("Prosím zadajte názov stromu pred odoslaním videa."),
                                  actions: [
                                    CupertinoDialogAction(
                                      child: const Text("OK"),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                              );
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
              hasVideo ? CupertinoFormSection.insetGrouped( children: [CupertinoTextFormFieldRow(
                controller: _nameController,
                style: const TextStyle(fontSize: 12, color: CupertinoColors.black),
                decoration: BoxDecoration(border: Border.all(color: CupertinoColors.systemGrey), borderRadius: BorderRadius.circular(8)),
                placeholder: "Názov stromu",
                placeholderStyle: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Názov stromu nemôže být prázdný";
                  }
                  return null;
                },
              )]) : const SizedBox(),
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