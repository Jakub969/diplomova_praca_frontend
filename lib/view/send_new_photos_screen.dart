import 'package:flutter/cupertino.dart';

class DatasetScreen extends StatelessWidget {
  const DatasetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar:
      const CupertinoNavigationBar(middle: Text("Podpora datasetu")),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                  style: const TextStyle(fontSize: 12, color: CupertinoColors.black),
                  decoration: BoxDecoration(border: Border.all(color: CupertinoColors.systemGrey), borderRadius: BorderRadius.circular(8)),
                  placeholder: "Názov stromu",
                  placeholderStyle: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey),
                ),],
              ),
              const SizedBox(height: 20),
              CupertinoButton.filled(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                borderRadius: BorderRadius.circular(14),
                onPressed: () {},
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.video_camera_solid),
                    SizedBox(width: 8),
                    Text("Video pred rezeom"),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              CupertinoButton.filled(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  borderRadius: BorderRadius.circular(14),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.video_camera),
                      SizedBox(width: 8),
                      Text("Video po reze"),
                    ],
                  ),
                  onPressed: () {})
            ],
          ),
        ),
      ),
    );
  }
}