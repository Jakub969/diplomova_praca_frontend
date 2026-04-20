import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:diplomova_praca/controller/save_tree.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../controller/load_tree.dart';
import '../model/tree.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class TreeDetail extends StatefulWidget {
  final String uuid;

  const TreeDetail({super.key, required this.uuid});

  @override
  State<TreeDetail> createState() => _TreeDetailState();
}

class _TreeDetailState extends State<TreeDetail> {

  late Tree tree;
  bool isLoading = true;
  bool isProcessing = false;
  bool internetAvailable = true;
  int progress = 0;
  final Flutter3DController _3dController = Flutter3DController();

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
    if (tree.url != "") {
      setState(() {
        isLoading = false;
        debugPrint("URL: ${tree.url}");
      });
    } else {
      debugPrint("Bez url");
      _checkStatus();
    }
  }

  void _checkStatus() async {
    final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      setState(() {
        isLoading = false;
        isProcessing = false;
        internetAvailable = false;
      });
      debugPrint("Žiadne internetové pripojenie");
      return;
    }
    try {
      final response = await http.get(
          Uri.parse("http://192.168.0.115:8000/status/${tree.taskId}")
      );

      if (response.statusCode != 200) {
        setState(() {
          isLoading = false;
          isProcessing = false;
        });
        debugPrint("Chyba pri načítaní stavu: ${response.statusCode}");
        return;
      }
      final data = jsonDecode(response.body);
      final state = data["state"];

      if (state == "SUCCESS") {
        if (tree.url.isEmpty) {
          final uri = Uri.parse(
            "http://192.168.0.115:8000/result/${tree.uuid}/sparse",
          );

          final response = await http.get(uri);

          if (response.statusCode != 200) {
            debugPrint("Download failed: ${response.statusCode}");
            return;
          }

          final dir = await getApplicationDocumentsDirectory();

          final filePath = "${dir.path}/${tree.uuid}.glb";

          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          setState(() {
            tree.url = filePath;
            isProcessing = false;
            isLoading = false;
            progress = 100;
          });
          SaveTree updateController = SaveTree();
          await updateController.updateInLocalStorage(tree);
          return;
        }
      }

      setState(() {
        isProcessing = true;
        isLoading = false;
      });

      _timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
        final progressResponse = await http.get(
            Uri.parse("http://192.168.0.115:8000/progress/${tree.taskId}")
        );

        if (progressResponse.statusCode != 200) {
          debugPrint("Chyba pri načítání progressu: ${progressResponse.statusCode}");
          return;
        }
        final progressData = jsonDecode(progressResponse.body);

        if (progressData["state"] == "SUCCESS") {
          timer.cancel();
          final uri = Uri.parse(
            "http://192.168.0.115:8000/result/${tree.uuid}/sparse",
          );

          final response = await http.get(uri);

          if (response.statusCode != 200) {
            debugPrint("Download failed: ${response.statusCode}");
            return;
          }

          final dir = await getApplicationDocumentsDirectory();

          final filePath = "${dir.path}/${tree.uuid}.glb";

          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          setState(() {
            tree.url = filePath;
            isProcessing = false;
            progress = 100;
          });
          SaveTree updateController = SaveTree();
          await updateController.updateInLocalStorage(tree);
        } else if (progressData["state"] == "PROGRESS") {
          setState(() {
            progress = progressData["progress"] ?? 0;
          });
        }
      });
    } on SocketException {
      setState(() {
        isLoading = false;
        isProcessing = false;
      });
      debugPrint("Chyba na strane serveru: SocketException");
    } catch (e) {
      setState(() {
        isLoading = false;
        isProcessing = false;
      });
      debugPrint("Chyba pri načítaní stavu: $e");
    }
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
        child:
            isLoading
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
            : internetAvailable
            ? _buildContent()
            : const Center(child: Text("Žiadne internetove pripojenie"))
      ),
    );
  }

  Widget _buildContent() {
    return CupertinoListSection.insetGrouped(
      children: [
        CupertinoListTile(
          title: const Text("Názov"),
          additionalInfo: Text(tree.name),
        ),
        CupertinoListTile(
          title: const Text("Typ"),
          additionalInfo: Text("SfM-MVS"),
        ),
        CupertinoListTile(
          title: const Text("UUID"),
          additionalInfo: Expanded(child: Text(tree.uuid, overflow: TextOverflow.ellipsis,)),
        ),
        if (tree.url.isNotEmpty)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Flutter3DViewer(
                    controller: _3dController,
                    src: Uri.file(tree.url).toString(),
                  ),
                ),
              ],
            ),
          )
      ],
    );
  }
}