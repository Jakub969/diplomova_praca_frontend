import 'package:flutter/cupertino.dart';

class CaptureScreen extends StatelessWidget {
  final bool depthSupported;
  const CaptureScreen({super.key, required this.depthSupported});

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
              Text(
                depthSupported
                    ? "Váš telefón podporuje fotenie s hĺbkou.\nStačia 1–2 snímky."
                    : "Váš telefón nepodporuje fotenie s hĺbkou.\nPotrebných bude 10–20 snímok.",
                textAlign: TextAlign.center,
                style: CupertinoTheme.of(context)
                    .textTheme
                    .textStyle
                    .copyWith(fontSize: 17),
              ),
              const SizedBox(height: 40),
              CupertinoButton.filled(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                borderRadius: BorderRadius.circular(14),
                onPressed: () {},
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.photo_camera_solid),
                    SizedBox(width: 8),
                    Text("Zachytiť snímky"),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              CupertinoButton(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                borderRadius: BorderRadius.circular(14),
                color: depthSupported
                    ? CupertinoColors.activeGreen
                    : CupertinoColors.systemGrey4,
                onPressed: depthSupported ? () {} : null,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.cloud_upload),
                    SizedBox(width: 8),
                    Text("Odoslať na analýzu"),
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