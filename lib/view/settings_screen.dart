import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
              header: const Text("Všeobecné"),
              children: [
                CupertinoListTile(
                  title: const Text("Jazyk aplikácie"),
                  additionalInfo: const Text("Slovenčina"),
                  onTap: () => _showLanguageDialog(context),
                ),
                CupertinoListTile(
                  title: const Text("O aplikácii"),
                  leading: const Icon(CupertinoIcons.info),
                  subtitle: const Text("Verzia 1.0.0"),
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Zmena jazyka"),
        content: const Text("Dostupné jazyky"),
        actions: [
          CupertinoDialogAction(
            child: const Text("Slovenčina"),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('language', 'sk');
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            child: const Text("Angličtina"),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('language', 'uk');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => const CupertinoAlertDialog(
        title: Text("O aplikácii"),
        content: SingleChildScrollView(
          child: Text(
            "Táto aplikácia bola vyvinutá pre podporu rozhodovania pri reze ovocných stromov. "
                "Umožňuje užívateľom ukladať informácie o strome, ako je názov, typ a ďalšie detaily. "
                "Aplikácia poskytuje funkcie pre zobrazenie uložených stromov, ich detailov "
                "a 3D modelu, v ktorom je znázornené, ktoré vetvy sú vhodné na rez.\n\n"
                "Dataset poskytla Fakulta elektrotechniky, informatiky a informačných technológií "
                "Osijek, Chorvátsko.",
          ),
        ),
      ),
    );
  }
}