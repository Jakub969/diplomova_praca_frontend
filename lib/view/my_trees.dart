import 'package:flutter/cupertino.dart';
import '../controller/load_tree.dart';
import '../model/tree.dart';
import 'tree_detail.dart';

class MyTrees extends StatefulWidget {
  const MyTrees({super.key});

  @override
  State<MyTrees> createState() => _MyTreesState();
}

class _MyTreesState extends State<MyTrees> {

  late Future<List<Tree>> _treesFuture;

  @override
  void initState() {
    super.initState();
    _treesFuture = LoadTree().loadAllTrees();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Moje stromy"),
      ),
      child: SafeArea(
        child: FutureBuilder<List<Tree>>(
          future: _treesFuture,
          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CupertinoActivityIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text("Žiadne uložené stromy"),
              );
            }

            final trees = snapshot.data!;
            for (Tree tree in trees) {
              print("${tree.name} ${tree.path} ${tree.uuid} ${tree.url} ${tree.type} ${tree.taskId}");
            }
            return CupertinoListSection.insetGrouped(
              children: trees.map((tree) {
                return CupertinoListTile(
                  title: Text(tree.name),
                  subtitle: Text(tree.type),
                  trailing: const Icon(CupertinoIcons.chevron_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => TreeDetail(uuid: tree.uuid),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}