class CheckOrderModelNew {
  int status;
  String msg;
  Data data;

  CheckOrderModelNew({
    required this.status,
    required this.msg,
    required this.data,
  });

  factory CheckOrderModelNew.fromJson(Map<String, dynamic> json) {
    return CheckOrderModelNew(
      status: json['status'] ?? 1,
      msg: json['msg'] ?? "",
      data: json['data'] != null
          ? Data.fromJson(json['data'])
          : Data.fromJson({}),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['msg'] = this.msg;
    data['data'] = this.data.toJson();
    return data;
  }
}

class Data {
  List<Stores> stores;

  Data({
    required this.stores,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      stores: json["stores"] == null
          ? <Stores>[]
          : List<Stores>.from(
              json["stores"].map(
                (x) => Stores.fromJson(x),
              ),
            ),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stores'] = this.stores.map((v) => v.toJson()).toList();
    return data;
  }
}

class Stores {
  int id;
  String name;
  String address;
  double distance;
  double deliverySum;
  double total;
  String text;

  Stores({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.deliverySum,
    required this.total,
    required this.text,
  });

  factory Stores.fromJson(Map<String, dynamic> json) {
    return Stores(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      address: json['address'] ?? "",
      distance: json['distance'] ?? 0.0,
      deliverySum: json['delivery_sum'] ?? 0.0,
      total: json['total'] ?? 0.0,
      text: json['text'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['address'] = this.address;
    data['distance'] = this.distance;
    data['delivery_sum'] = this.deliverySum;
    data['total'] = this.total;
    data['text'] = this.text;
    return data;
  }
}
