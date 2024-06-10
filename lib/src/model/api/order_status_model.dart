class OrderStatusModel {
  int status;
  String msg;
  String paymentRedirectUrl;
  int region;

  OrderStatusModel({
    required this.status,
    required this.msg,
    required this.region,
    required this.paymentRedirectUrl,
  });

  factory OrderStatusModel.fromJson(Map<String, dynamic> json) {
    return OrderStatusModel(
      status: json['status'] ?? 0,
      region: json['region'] ?? 0,
      msg: json['msg'] ?? "",
      paymentRedirectUrl: json['payment_redirect_url'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['region'] = this.region;
    data['msg'] = this.msg;
    data['payment_redirect_url'] = this.paymentRedirectUrl;
    return data;
  }
}
