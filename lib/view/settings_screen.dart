import 'package:flutter/cupertino.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar:
      const CupertinoNavigationBar(middle: Text("Nastavenia")),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoListSection.insetGrouped(
              header: Text("Všeobecné"),
              children: [
                CupertinoListTile(
                  title: Text("Jazyk aplikácie"),
                  additionalInfo: Text("Slovenčina"),
                ),
                CupertinoListTile(
                  title: Text("O aplikácii"),
                  leading: Icon(CupertinoIcons.info),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
