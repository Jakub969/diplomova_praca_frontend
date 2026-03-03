import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../controller/load_tree.dart';
import '../model/tree.dart';

class TreeDetail extends StatefulWidget {
  final String uuid;

  const TreeDetail({super.key, required this.uuid});

  @override
  State<TreeDetail> createState() => _TreeDetailState();
}

class _TreeDetailState extends State<TreeDetail> {

  Tree? tree;
  bool isLoading = true;
  bool isProcessing = false;
  int progress = 0;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadTree();
  }

  Future<void> _loadTree() async {
    final loadedTree = await LoadTree().loadOneTree(widget.uuid);

    setState(() {
      tree = loadedTree;
    });

    _checkStatus();
  }

  void _checkStatus() async {
    final response = await http.get(
        Uri.parse("http://192.168.0.113:8000/status/${tree!.taskId}")
    );

    final data = jsonDecode(response.body);
    final state = data["state"];

    if (state == "SUCCESS") {
      setState(() {
        isProcessing = false;
        isLoading = false;
        progress = 100;
      });
      return;
    }

    setState(() {
      isProcessing = true;
      isLoading = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      final progressResponse = await http.get(
          Uri.parse("http://192.168.0.113:8000/progress/${tree!.taskId}")
      );

      final progressData = jsonDecode(progressResponse.body);

      if (progressData["state"] == "SUCCESS") {
        timer.cancel();
        setState(() {
          isProcessing = false;
          progress = 100;
        });
      } else if (progressData["state"] == "PROGRESS") {
        setState(() {
          progress = progressData["progress"] ?? 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Detail stromu"),
      ),
      child: SafeArea(
        child: isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : isProcessing
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CupertinoActivityIndicator(radius: 20),
              const SizedBox(height: 20),
              Text("Spracovanie: $progress %"),
            ],
          ),
        )
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return CupertinoListSection.insetGrouped(
      children: [
        CupertinoListTile(
          title: const Text("Názov"),
          additionalInfo: Text(tree!.name),
        ),
        CupertinoListTile(
          title: const Text("Typ"),
          additionalInfo: Text(tree!.type),
        ),
        CupertinoListTile(
          title: const Text("UUID"),
          additionalInfo: Text(tree!.uuid),
        ),
      ],
    );
  }
}