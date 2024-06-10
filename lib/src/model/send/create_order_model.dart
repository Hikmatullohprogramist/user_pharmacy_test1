class CreateOrderModel {
  String type;
  String location;
  List<Drugs> drugs;
  int shippingTime;
  int storeId;
  String address;
  String device;
  String fullName;
  String phone;

  CreateOrderModel({
    required this.address,
    required this.location,
    required this.type,
    required this.shippingTime,
    required this.device,
    required this.storeId,
    required this.drugs,
    required this.fullName,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['location'] = this.location;
    data['full_name'] = this.fullName;
    data['phone'] = this.phone;
    data['type'] = this.type;
    data['device'] = this.device;
    data['store_id'] = this.storeId;
    data['shipping_time'] = this.shippingTime;
    data['drugs'] = this.drugs.map((v) => v.toJson()).toList();

    return data;
  }
}

class Drugs {
  int drug;
  int qty;

  Drugs({
    required this.drug,
    required this.qty,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['drug'] = this.drug;
    data['qty'] = this.qty;
    return data;
  }
}
