class CheckOrderResponseModel {
  int status;
  String msg;
  Data data;

  CheckOrderResponseModel({
    required this.status,
    required this.msg,
    required this.data,
  });

  factory CheckOrderResponseModel.fromJson(Map<String, dynamic> json) {
    return CheckOrderResponseModel(
      status: json['status'] ?? 0,
      msg: json['error'] ?? "",
      data: json['data'] != null
          ? Data.fromJson(json['data'])
          : Data.fromJson({}),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['error'] = this.msg;
    data['data'] = this.data.toJson();
    return data;
  }
}

class Data {
  double distance;
  double deliverySum;
  String address;
  bool isUserPay;
  double total;
  double cash;

  Data({
    required this.distance,
    required this.deliverySum,
    required this.address,
    required this.isUserPay,
    required this.cash,
    required this.total,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      distance: json['distance'] ?? 0.0,
      deliverySum: json['delivery_sum'] ?? 0.0,
      address: json['address'] ?? "",
      isUserPay: json['is_user_pay'] ?? false,
      cash: json['cash'] ?? 0.0,
      total: json['total'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['distance'] = this.distance;
    data['delivery_sum'] = this.deliverySum;
    data['address'] = this.address;
    data['is_user_pay'] = this.isUserPay;
    data['cash'] = this.cash;
    data['total'] = this.total;
    return data;
  }
}
