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
                "Odošli fotografie stromov pred a po reze pre zlepšenie modelu.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              CupertinoButton.filled(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                borderRadius: BorderRadius.circular(14),
                onPressed: () {},
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.photo_on_rectangle),
                    SizedBox(width: 8),
                    Text("Nahrať fotografie"),
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