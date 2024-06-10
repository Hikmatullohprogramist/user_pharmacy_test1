import 'dart:convert';

List<FaqModel> faqModelFromJson(String str) =>
    List<FaqModel>.from(json.decode(str).map((x) => FaqModel.fromJson(x)));

String faqModelToJson(List<FaqModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FaqModel {
  FaqModel({
    required this.id,
    required this.question,
    required this.answer,
  });

  int id;
  String question;
  String answer;

  factory FaqModel.fromJson(Map<String, dynamic> json) => FaqModel(
        id: json["id"] ?? 0,
        question: json["question"] ?? "",
        answer: json["answer"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "question": question,
        "answer": answer,
      };
}
