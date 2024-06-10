class CreateOrderStatusModel {
  CreateOrderStatusModel({
    required this.status,
    required this.msg,
    required this.data,
  });

  int status;
  String msg;
  Data data;

  factory CreateOrderStatusModel.fromJson(Map<String, dynamic> json) =>
      CreateOrderStatusModel(
        status: json["status"] ?? 0,
        msg: json["msg"] ?? "",
        data: json["data"] == null
            ? Data.fromJson({})
            : Data.fromJson(
                json["data"],
              ),
      );
}

class Data {
  Data({
    required this.orderId,
    required this.total,
    required this.deliverySum,
    required this.cash,
    required this.expireSelfOrder,
    required this.isUserPay,
    required this.isTotalCash,
  });

  int orderId;
  double total;
  String expireSelfOrder;
  double deliverySum;
  double cash;
  bool isUserPay;
  bool isTotalCash;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        orderId: json["order_id"] ?? 0,
        total: json["total"] ?? 0.0,
        expireSelfOrder: json["expire_self_order"] ?? "",
        deliverySum: json["delivery_sum"] ?? 0.0,
        cash: json["cash"] ?? 0.0,
        isUserPay: json["is_user_pay"] ?? false,
        isTotalCash: json["is_total_cash"] ?? false,
      );
}
