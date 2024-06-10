import 'dart:convert';

CancelOrder cancelDrugFromJson(String str) =>
    CancelOrder.fromJson(json.decode(str));

String cancelDrugToJson(CancelOrder data) => json.encode(data.toJson());

class CancelOrder {
  CancelOrder({
    required this.status,
    required this.payment,
    required this.message,
  });

  int status;
  String payment;
  String message;

  factory CancelOrder.fromJson(Map<String, dynamic> json) => CancelOrder(
        status: json["status"] ?? 0,
        payment: json["payment"] ?? "",
        message: json["message"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "payment": payment,
        "message": message,
      };
}
