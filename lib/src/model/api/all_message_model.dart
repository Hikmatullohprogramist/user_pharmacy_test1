class AllMessageModel {
  String next;
  List<ChatResults> results;

  AllMessageModel({
    required this.next,
    required this.results,
  });

  factory AllMessageModel.fromJson(Map<String, dynamic> json) {
    return AllMessageModel(
      next: json["next"] ?? "",
      results: json["results"] == null
          ? <ChatResults>[]
          : List<ChatResults>.from(
              json["results"].map(
                (x) => ChatResults.fromJson(x),
              ),
            ),
    );
  }
}

class ChatResults {
  int id;
  int userId;
  String body;
  DateTime createdAt;
  String year;

  ChatResults({
    required this.id,
    required this.userId,
    required this.body,
    required this.createdAt,
    required this.year,
  });

  factory ChatResults.fromJson(Map<String, dynamic> json) {
    return ChatResults(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      body: json['body'] ?? "",
      createdAt: json['created_at'] == null
          ? DateTime.now()
          : DateTime.parse(json['created_at']),
      year: json['created_at'] != null
          ? DateTime.parse(json["created_at"]).year.toString() +
              "." +
              DateTime.parse(json["created_at"]).month.toString() +
              "." +
              DateTime.parse(json["created_at"]).day.toString()
          : DateTime.now().year.toString() +
              "." +
              DateTime.now().month.toString() +
              "." +
              DateTime.now().day.toString(),
    );
  }
}
