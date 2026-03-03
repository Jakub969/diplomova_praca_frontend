class Tree {
  String name;
  String path;
  String uuid;
  String url;
  String type;
  String taskId;

  Tree({
    required this.name,
    required this.path,
    required this.uuid,
    required this.url,
    required this.type,
    required this.taskId,
  });

  factory Tree.fromJson(Map<String, dynamic> json) {
    return Tree(
      name: json['name'],
      path: json['path'],
      uuid: json['uuid'],
      url: json['url'],
      type: json['type'],
      taskId: json['taskId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'uuid': uuid,
      'url': url,
      'type': type,
      'taskId': taskId,
    };
  }
}
