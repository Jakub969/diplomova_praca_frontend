import 'package:diplomova_praca/model/tree.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LoadTree {

  Future<Tree> loadOneTree(String uuid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> trees = prefs.getStringList('trees') ?? [];

    for (String treeString in trees) {
      Map<String, dynamic> treeMap = jsonDecode(treeString);
      Tree tree = Tree.fromJson(treeMap);

      if (tree.uuid == uuid) {
        return tree;
      }
    }

    throw Exception("Tree with UUID $uuid not found");
  }

  Future<List<Tree>> loadAllTrees() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> trees = prefs.getStringList('trees') ?? [];

    return trees
        .map((treeString) =>
        Tree.fromJson(jsonDecode(treeString)))
        .toList();
  }
}