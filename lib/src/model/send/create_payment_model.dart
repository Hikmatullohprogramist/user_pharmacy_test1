class PaymentOrderModel {
  int paymentType;
  int orderId;
  int cashPay;
  bool paymentRedirect;

  PaymentOrderModel({
    required this.orderId,
    required this.paymentType,
    required this.cashPay,
    required this.paymentRedirect,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_id'] = this.orderId;
    data['cash_pay'] = this.cashPay;
    data['payment_type'] = this.paymentType;
    data['payment_redirect'] = this.paymentRedirect;
    return data;
  }
}
