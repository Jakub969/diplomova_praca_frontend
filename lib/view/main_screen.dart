import 'package:diplomova_praca/view/send_new_photos_screen.dart';
import 'package:diplomova_praca/view/settings_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'capture_photo_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Future<bool> checkDepthSupport() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    // Replace this with a real depth capability check later
    return androidInfo.model.toLowerCase().contains("pro");
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Rezy Ovocných Stromov"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
          child: const Icon(CupertinoIcons.settings),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Mobilná aplikácia pre podporu rozhodovania pri reze ovocných stromov",
                textAlign: TextAlign.center,
                style: CupertinoTheme.of(context)
                    .textTheme
                    .navTitleTextStyle
                    .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              CupertinoButton.filled(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                borderRadius: BorderRadius.circular(14),
                onPressed: () async {
                  final supportDepth = await checkDepthSupport();
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) =>
                          CaptureScreen(depthSupported: supportDepth),
                    ),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.camera),
                    SizedBox(width: 8),
                    Text("Zachytiť strom"),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              CupertinoButton(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                borderRadius: BorderRadius.circular(14),
                color: CupertinoColors.systemGrey5,
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (_) => const DatasetScreen()),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.cloud_upload),
                    SizedBox(width: 8),
                    Text("Prispieť datasetom"),
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