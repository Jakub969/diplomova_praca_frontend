import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class CaptureScreen extends StatelessWidget {
  CaptureScreen({super.key});
  final ImagePicker _picker = ImagePicker();

  Future<void> _recordVideo() async {
    final XFile? video = await _picker.pickVideo(
      source: ImageSource.camera,
    );

    if (video != null) {
      print(video.path);
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? video = await _picker.pickVideo(
      source: ImageSource.gallery,
    );

    if (video != null) {
      print(video.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Zachytenie stromu"),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              CupertinoButton.filled(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                borderRadius: BorderRadius.circular(14),
                onPressed: _recordVideo,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.photo_camera_solid),
                    SizedBox(width: 8),
                    Text("Urobiť video stromu"),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              CupertinoButton(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                borderRadius: BorderRadius.circular(14),
                color: CupertinoColors.systemGrey5,
                onPressed: _pickFromGallery,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.cloud_upload),
                    SizedBox(width: 8),
                    Text("Odoslať predpripravené video"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}