import '../model/tree.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SaveTree {

  Future<void> saveInLocalStorage(String name, String path, String uuid, String url, String type, String taskId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> trees = prefs.getStringList('trees') ?? [];
  Tree tree = Tree(
    name: name,
    path: path,
    uuid: uuid,
    url: url,
    type: type,
    taskId: taskId,
  );
  trees.add(jsonEncode(tree.toJson()));

  await prefs.setStringList('trees', trees);
  }

  Future<void> deleteFromLocalStorage(String uuid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> trees = prefs.getStringList('trees') ?? [];

    trees.removeWhere((treeString) {
      Map<String, dynamic> treeMap = jsonDecode(treeString);
      Tree tree = Tree.fromJson(treeMap);
      return tree.uuid == uuid;
    });

    await prefs.setStringList('trees', trees);
  }

  Future<void> updateInLocalStorage(Tree updatedTree) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> trees = prefs.getStringList('trees') ?? [];

    for (int i = 0; i < trees.length; i++) {
      Map<String, dynamic> treeMap = jsonDecode(trees[i]);
      Tree tree = Tree.fromJson(treeMap);

      if (tree.uuid == updatedTree.uuid) {
        trees[i] = jsonEncode(updatedTree.toJson());
        break;
      }
    }

    await prefs.setStringList('trees', trees);
  }
}