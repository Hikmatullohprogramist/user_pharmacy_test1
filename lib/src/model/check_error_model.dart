class CheckErrorModel {
  CheckErrorModel({
    required this.error,
    required this.msg,
    required this.errors,
    required this.data,
  });

  int error;
  String msg;
  List<CheckErrorData> errors;
  CashBackData data;

  factory CheckErrorModel.fromJson(Map<String, dynamic> json) =>
      CheckErrorModel(
        error: json["error"] ?? 0,
        msg: json["msg"] ?? "",
        data: json["data"] == null
            ? CashBackData.fromJson({})
            : CashBackData.fromJson(json["data"]),
        errors: json["errors"] == null
            ? <CheckErrorData>[]
            : List<CheckErrorData>.from(
            json["errors"].map((x) => CheckErrorData.fromJson(x))),
      );
}

class CheckErrorData {
  CheckErrorData({
    required this.drugId,
    required this.msg,
  });

  int drugId;
  String msg;

  factory CheckErrorData.fromJson(Map<String, dynamic> json) =>
      CheckErrorData(
        drugId: json["drug_id"] ?? 0,
        msg: json["msg"] ?? "",
      );
}

class CashBackData {
  CashBackData({
    required this.total,
    required this.cash,
  });

  double total;
  double cash;

  factory CashBackData.fromJson(Map<String, dynamic> json) {
    double total;
    try {
      total = json["total"] ?? 0.0;
    } catch (_) {
      var k = (json["total"] ?? "").toString();
      total = double.parse(k);
    }
    double cash;
    try {
      cash = json["cash"] ?? 0.0;
    } catch (_) {
      var k = (json["cash"] ?? "").toString();
      cash = double.parse(k);
    }
    return CashBackData(
      total: total,
      cash: cash,
    );
  }
}
