import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class DatasetScreen extends StatefulWidget {
  const DatasetScreen({super.key});

  @override
  State<DatasetScreen> createState() => _DatasetScreenState();
}

class _DatasetScreenState extends State<DatasetScreen> {
  XFile? _beforeVideo;
  XFile? _afterVideo;
  final ImagePicker _picker = ImagePicker();
  VideoPlayerController? _beforeController;
  VideoPlayerController? _afterController;
  Future<void>? _initBefore;
  Future<void>? _initAfter;
  final TextEditingController _nameController = TextEditingController();

  Future<void> sendDataset(
      File beforeVideo,
      File afterVideo,
      String name,
      BuildContext context
      ) async {

    var uri = Uri.parse("http://192.168.0.115:8000/dataset");

    var request = http.MultipartRequest('POST', uri)
      ..fields['name'] = name
      ..files.add(await http.MultipartFile.fromPath(
        'before_video',
        beforeVideo.path,
      ))
      ..files.add(await http.MultipartFile.fromPath(
        'after_video',
        afterVideo.path,
      ));

    var response = await request.send();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print("Dataset uploaded");
    } else {
      print("Upload failed: ${response.statusCode}");
    }
  }

  Future<void> _setBeforeVideo(XFile video) async {
    _beforeVideo = video;
    _beforeController?.dispose();

    _beforeController = VideoPlayerController.file(File(video.path));
    _initBefore = _beforeController!.initialize().then((_) {
      _beforeController!..setLooping(true)..play();
      setState(() {});
    });

    setState(() {});
  }

  Future<void> _setAfterVideo(XFile video) async {
    _afterVideo = video;
    _afterController?.dispose();

    _afterController = VideoPlayerController.file(File(video.path));
    _initAfter = _afterController!.initialize().then((_) {
      _afterController!..setLooping(true)..play();
      setState(() {});
    });

    setState(() {});
  }

  Future<void> _pickBeforeVideo() async {
    final video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) await _setBeforeVideo(video);
  }

  Future<void> _pickAfterVideo() async {
    final video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) await _setAfterVideo(video);
  }

  void _discardBeforeVideo() {
    _beforeController?.pause();
    _beforeController?.dispose();
    _beforeController = null;
    _initBefore = null;
    _beforeVideo = null;
    setState(() {});
  }

  void _discardAfterVideo() {
    _afterController?.pause();
    _afterController?.dispose();
    _afterController = null;
    _initAfter = null;
    _afterVideo = null;
    setState(() {});
  }

  @override
  void dispose() {
    _beforeController?.dispose();
    _afterController?.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasBefore = _beforeVideo != null && _beforeController != null;
    final bool hasAfter = _afterVideo != null && _afterController != null;
    final bool canSend = hasBefore && hasAfter && _nameController.text.trim().isNotEmpty;

    return CupertinoPageScaffold(
      navigationBar:
      const CupertinoNavigationBar(middle: Text("Podpora datasetu")),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Odošlite videá stromov pred a po reze pre zlepšenie modelu.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                CupertinoFormSection.insetGrouped(
                  children: [CupertinoTextFormFieldRow(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 12, color: CupertinoColors.black),
                    decoration: BoxDecoration(border: Border.all(color: CupertinoColors.systemGrey), borderRadius: BorderRadius.circular(8)),
                    placeholder: "Názov stromu",
                    placeholderStyle: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey),
                  ),],
                ),
                const SizedBox(height: 20),
                if (hasBefore)
                  Stack(
                    children: [
                      Center(
                        child: FutureBuilder(
                          future: _initBefore,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done && _beforeController != null) {
                              final aspect = _beforeController!.value.aspectRatio;
                              return AspectRatio(
                                aspectRatio: aspect > 0 ? aspect : 16 / 9,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: VideoPlayer(_beforeController!),
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
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _discardBeforeVideo,
                          child: Container(
                            decoration: BoxDecoration(color: CupertinoColors.systemRed, shape: BoxShape.circle),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(CupertinoIcons.delete, color: CupertinoColors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey5,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                const SizedBox(height: 12),
                CupertinoButton.filled(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  borderRadius: BorderRadius.circular(14),
                  onPressed: hasBefore ? null : _pickBeforeVideo,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(CupertinoIcons.video_camera_solid),
                      SizedBox(width: 8),
                      Text("Video pred rezeom"),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (hasAfter)
                  Stack(
                    children: [
                      Center(
                        child: FutureBuilder(
                          future: _initAfter,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done && _afterController != null) {
                              final aspect = _afterController!.value.aspectRatio;
                              return AspectRatio(
                                aspectRatio: aspect > 0 ? aspect : 16 / 9,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: VideoPlayer(_afterController!),
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
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _discardAfterVideo,
                          child: Container(
                            decoration: BoxDecoration(color: CupertinoColors.systemRed, shape: BoxShape.circle),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(CupertinoIcons.delete, color: CupertinoColors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey5,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                const SizedBox(height: 12),
                CupertinoButton.filled(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    borderRadius: BorderRadius.circular(14),
                    onPressed: hasAfter ? null : _pickAfterVideo,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(CupertinoIcons.video_camera),
                        SizedBox(width: 8),
                        Text("Video po reze"),
                      ],
                    )),
            
                const SizedBox(height: 20),
                CupertinoButton.filled(
                  onPressed: canSend
                      ? () {
                          sendDataset(
                            File(_beforeVideo!.path),
                            File(_afterVideo!.path),
                            _nameController.text.trim(),
                            context,
                          );
                        }
                      : null,
                  child: const Text("Odoslať dataset"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


