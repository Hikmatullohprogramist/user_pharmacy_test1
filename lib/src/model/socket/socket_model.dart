class SocketModel {
  String type;
  String event;
  Message message;

  SocketModel({
    required this.type,
    required this.event,
    required this.message,
  });

  factory SocketModel.fromJson(Map<String, dynamic> json) {
    return SocketModel(
      type: json['type'] ?? "",
      event: json['event'] ?? "",
      message: json['message'] != null
          ? Message.fromJson(json['message'])
          : Message.fromJson({}),
    );
  }
}

class Message {
  int id;
  int userId;
  String body;
  String createdAt;
  String updatedAt;

  Message({
    required this.id,
    required this.userId,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      body: json['body'] ?? "",
      createdAt: json['created_at'] ?? "",
      updatedAt: json['updated_at'] ?? "",
    );
  }
}
