class HistoryModel {
  int count;
  String next;

  List<HistoryResults> results;

  HistoryModel({
    required this.count,
    required this.next,
    required this.results,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      count: json['count'] ?? 0,
      next: json['next'] ?? "",
      results: json["results"] == null
          ? <HistoryResults>[]
          : List<HistoryResults>.from(
              json["results"].map(
                (x) => HistoryResults.fromJson(x),
              ),
            ),
    );
  }
}

class HistoryResults {
  int id;
  int bonus;
  String address;
  Location location;
  DateTime endShiptime;
  double deliveryTotal;
  PaymentType paymentType;
  Store store;
  Delivery delivery;
  String createdAt;
  double total;
  double cash;
  double realTotal;
  String status;
  String type;
  String fullName;
  String phone;
  String expireSelfOrder;
  String bookingLabel;
  List<Items> items;

  HistoryResults({
    required this.id,
    required this.address,
    required this.bonus,
    required this.location,
    required this.endShiptime,
    required this.deliveryTotal,
    required this.paymentType,
    required this.store,
    required this.delivery,
    required this.cash,
    required this.createdAt,
    required this.total,
    required this.realTotal,
    required this.status,
    required this.type,
    required this.fullName,
    required this.phone,
    required this.expireSelfOrder,
    required this.bookingLabel,
    required this.items,
  });

  factory HistoryResults.fromJson(Map<String, dynamic> json) {
    return HistoryResults(
      id: json['id'],
      bonus: json['bonus'] ?? 0,
      bookingLabel: json['booking_label'] ?? "",
      address: json['address'] == null ? "" : json['address'],
      location: json['location'] != null
          ? new Location.fromJson(json['location'])
          : Location(type: "", coordinates: [0.0, 0.0]),
      endShiptime: json["end_shiptime"] == null
          ? DateTime.now()
          : DateTime.parse(json["end_shiptime"]),
      deliveryTotal: json['delivery_total'] == null
          ? 0.0
          : json['delivery_total'].toDouble(),
      paymentType: json['payment_type'] != null
          ? new PaymentType.fromJson(json['payment_type'])
          : PaymentType(id: 0, name: "", type: ""),
      store: json['store'] != null
          ? Store.fromJson(json['store'])
          : Store.fromJson({}),
      delivery: json['delivery'] != null
          ? Delivery.fromJson(json['delivery'])
          : Delivery(login: "", firstName: "", lastName: ""),
      createdAt: json['created_at'],
      total: json['total'] == null ? 0.0 : json['total'],
      cash: json['cash'] ?? 0.0,
      realTotal: json['real_total'] == null ? 0.0 : json['real_total'],
      status: json['status'],
      type: json['type'] == null ? "" : json['type'],
      expireSelfOrder:
          json['expire_self_order'] == null ? "" : json['expire_self_order'],
      fullName: json['full_name'] == null ? "" : json['full_name'],
      phone: json['phone'] == null ? "" : json['phone'],
      items: json["items"] == null
          ? <Items>[]
          : List<Items>.from(
              json["items"].map(
                (x) => Items.fromJson(x),
              ),
            ),
    );
  }
}

class Location {
  String type;
  List<double> coordinates;

  Location({required this.type, required this.coordinates});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'] ?? "",
      coordinates: json['coordinates'] == null
          ? <double>[]
          : json['coordinates'].cast<double>(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['coordinates'] = this.coordinates;
    return data;
  }
}

class PaymentType {
  int id;
  String name;
  String type;

  PaymentType({
    required this.id,
    required this.name,
    required this.type,
  });

  factory PaymentType.fromJson(Map<String, dynamic> json) {
    return PaymentType(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      type: json['type'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['type'] = this.type;
    return data;
  }
}

class Store {
  int id;
  String name;
  String address;
  String phone;
  String mode;
  Location location;

  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.mode,
    required this.location,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      mode: json['mode'],
      location: json['location'] != null
          ? Location.fromJson(json['location'])
          : Location.fromJson({}),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['address'] = this.address;
    data['phone'] = this.phone;
    data['mode'] = this.mode;
    data['location'] = this.location.toJson();
    return data;
  }
}

class Delivery {
  String login;
  String firstName;
  String lastName;

  Delivery({
    required this.login,
    required this.firstName,
    required this.lastName,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      login: json['login'] ?? "",
      firstName: json['first_name'] ?? "",
      lastName: json['last_name'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['login'] = this.login;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    return data;
  }
}

class Items {
  int id;
  Drug drug;
  int qty;
  double price;
  double subtotal;
  bool status;

  Items({
    required this.id,
    required this.drug,
    required this.qty,
    required this.price,
    required this.subtotal,
    required this.status,
  });

  factory Items.fromJson(Map<String, dynamic> json) {
    return Items(
      id: json['id'],
      drug: json['drug'] != null
          ? Drug.fromJson(json['drug'])
          : Drug.fromJson({}),
      qty: json['qty'],
      price: json['price'],
      subtotal: json['subtotal'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['drug'] = this.drug.toJson();
    data['qty'] = this.qty;
    data['price'] = this.price;
    data['subtotal'] = this.subtotal;
    data['status'] = this.status;
    return data;
  }
}

class Drug {
  int id;
  String name;
  String barcode;
  String image;
  String imageThumbnail;

  Drug({
    required this.id,
    required this.name,
    required this.barcode,
    required this.image,
    required this.imageThumbnail,
  });

  factory Drug.fromJson(Map<String, dynamic> json) {
    return Drug(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      barcode: json['barcode'] ?? "",
      image: json['image'] ?? "",
      imageThumbnail: json['image_thumbnail'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['barcode'] = this.barcode;
    data['image'] = this.image;
    data['image_thumbnail'] = this.imageThumbnail;
    return data;
  }
}
