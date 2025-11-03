import 'package:diplomova_praca/view/main_screen.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(const FruitTreeApp());
}

class FruitTreeApp extends StatelessWidget {
  const FruitTreeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'Rezy Ovocných Stromov',
      theme: CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: CupertinoColors.activeGreen,
        barBackgroundColor: CupertinoColors.systemGrey6,
        scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
      ),
      home: MainScreen(),
    );
  }
}

