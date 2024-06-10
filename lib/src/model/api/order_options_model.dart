class OrderOptionsModel {
  List<ShippingTimes> shippingTimes;
  List<PaymentTypes> paymentTypes;

  OrderOptionsModel({required this.shippingTimes, required this.paymentTypes});

  factory OrderOptionsModel.fromJson(Map<String, dynamic> json) {
    return OrderOptionsModel(
      shippingTimes: json["shipping_times"] == null
          ? <ShippingTimes>[]
          : List<ShippingTimes>.from(
              json["shipping_times"].map(
                (x) => ShippingTimes.fromJson(x),
              ),
            ),
      paymentTypes: json["payment_types"] == null
          ? <PaymentTypes>[]
          : List<PaymentTypes>.from(
              json["payment_types"].map(
                (x) => PaymentTypes.fromJson(x),
              ),
            ),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['shipping_times'] = this.shippingTimes.map((v) => v.toJson()).toList();
    data['payment_types'] = this.paymentTypes.map((v) => v.toJson()).toList();
    return data;
  }
}

class ShippingTimes {
  int id;
  String name;
  double price;
  int time;
  bool isUserPay;
  List<String> descriptions;

  ShippingTimes({
    required this.id,
    required this.name,
    required this.price,
    required this.time,
    required this.isUserPay,
    required this.descriptions,
  });

  factory ShippingTimes.fromJson(Map<String, dynamic> json) {
    return ShippingTimes(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      price: json['price'] ?? 0.0,
      time: json['time'] ?? 0,
      isUserPay: json['is_user_pay'] ?? false,
      descriptions: json['descriptions'] == null
          ? <String>[]
          : List<String>.from(json["descriptions"].map((x) => x)),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['price'] = this.price;
    data['time'] = this.time;
    data['is_user_pay'] = this.isUserPay;
    data['descriptions'] = List<dynamic>.from(descriptions.map((x) => x));
    return data;
  }
}

class PaymentTypes {
  int id;
  int cardId;
  String name;
  String cardToken;
  String pan;
  String type;

  PaymentTypes({
    required this.id,
    required this.cardId,
    required this.cardToken,
    required this.name,
    required this.pan,
    required this.type,
  });

  factory PaymentTypes.fromJson(Map<String, dynamic> json) {
    return PaymentTypes(
      id: json['id'] ?? 0,
      cardId: json['card_id'] ?? 0,
      cardToken: json['card_token'] ?? "",
      name: json['name'] ?? "",
      pan: json['pan'] ?? "",
      type: json['type'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['card_id'] = this.cardId;
    data['card_token'] = this.cardToken;
    data['name'] = this.name;
    data['pan'] = this.pan;
    data['type'] = this.type;
    return data;
  }
}
