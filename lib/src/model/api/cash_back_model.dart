import 'dart:convert';

CashBackModel cashBackModelFromJson(String str) =>
    CashBackModel.fromJson(json.decode(str));

class CashBackModel {
  CashBackModel({
    required this.status,
    required this.cash,
    required this.bonus,
  });

  int status;
  double cash;
  double bonus;

  factory CashBackModel.fromJson(Map<String, dynamic> json) {
    double bonus;
    try {
      bonus = json["bonus"] ?? 0.0;
    } catch (_) {
      var k = (json["bonus"] ?? "").toString();
      bonus = double.parse(k);
    }
    double cash;
    try {
      cash = json["cash"] ?? 0.0;
    } catch (_) {
      var k = (json["cash"] ?? "").toString();
      cash = double.parse(k);
    }
    return CashBackModel(
      status: json["status"] ?? 0,
      cash: cash,
      bonus: bonus,
    );
  }
}
