class ItemModel {
  ItemModel({
    required this.count,
    required this.next,
    required this.results,
    required this.drugs,
    required this.title,
  });

  int count;
  String next;
  String title;
  List<ItemResult> results;
  List<ItemResult> drugs;

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      count: json["count"] ?? 0,
      next: json["next"] ?? "",
      title: json["title"] ?? "",
      results: json["results"] == null
          ? []
          : List<ItemResult>.from(
              json["results"].map(
                (x) => ItemResult.fromJson(x),
              ),
            ),
      drugs: json["drugs"] == null
          ? []
          : List<ItemResult>.from(
              json["drugs"].map(
                (x) => ItemResult.fromJson(x),
              ),
            ),
    );
  }
}

class ItemResult {
  int id;
  String name;
  String barcode;
  String image;
  String imageThumbnail;
  double price;
  double basePrice;
  Manufacturer manufacturer;
  int maxCount;
  bool isComing;
  bool favourite;
  int cardCount;
  String msg;

  ItemResult({
    required this.id,
    required this.name,
    required this.barcode,
    required this.image,
    required this.imageThumbnail,
    required this.price,
    required this.manufacturer,
    required this.basePrice,
    required this.isComing,
    required this.maxCount,
    this.cardCount = 0,
    this.favourite = false,
    this.msg = "",
  });

  factory ItemResult.fromJson(Map<dynamic, dynamic> map) {
    return ItemResult(
      id: map["id"] ?? 0,
      name: map["name"] ?? "",
      barcode: map["barcode"] ?? "",
      image: map["image"] ?? "",
      imageThumbnail: map["image_thumbnail"] ?? "",
      maxCount: map["max_count"] ?? 100,
      isComing: map["is_coming"] ?? false,
      price: map["price"] == null ? 0.0 : map["price"].toDouble(),
      basePrice: map["base_price"] == null ? 0.0 : map["base_price"].toDouble(),
      manufacturer: map['manufacturer'] != null
          ? Manufacturer.fromMap(map['manufacturer'])
          : Manufacturer.fromMap({}),
      favourite: map["favourite"] == 1 ? true : false,
      cardCount: map["cardCount"] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["name"] = name;
    map["barcode"] = barcode;
    map["image"] = image;
    map["image_thumbnail"] = imageThumbnail;
    map["price"] = price;
    map["favourite"] = favourite ? 1 : 0;
    map["cardCount"] = cardCount;
    map["manufacturer"] = manufacturer.name;
    return map;
  }
}

class Manufacturer {
  Manufacturer({
    required this.name,
  });

  String name;

  factory Manufacturer.fromMap(Map<String, dynamic> map) {
    return Manufacturer(name: map["name"] ?? "");
  }

  Map<String, dynamic> toJson() => {
        "name": name,
      };
}
