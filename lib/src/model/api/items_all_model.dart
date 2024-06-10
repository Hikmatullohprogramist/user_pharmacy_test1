import 'item_model.dart';

class ItemsAllModel {
  int id;
  String name;
  String barcode;
  String description;
  String image;
  String imageThumbnail;
  double price;
  double basePrice;
  Category unit;
  InternationalName internationalName;
  Category manufacturer;
  Category category;
  List<ItemResult> analog;
  int maxCount;
  double rating;
  bool isComing;
  bool favourite = false;
  int cardCount = 0;

  ItemsAllModel({
    required this.id,
    required this.name,
    required this.barcode,
    required this.description,
    required this.image,
    required this.imageThumbnail,
    required this.price,
    required this.basePrice,
    required this.unit,
    required this.internationalName,
    required this.manufacturer,
    required this.category,
    required this.analog,
    required this.rating,
    required this.isComing,
    required this.maxCount,
    this.favourite = false,
    this.cardCount = 0,
  });

  factory ItemsAllModel.fromJson(Map<String, dynamic> json) {
    return ItemsAllModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      barcode: json['barcode'] ?? "",
      description: json['description'] ?? "",
      image: json['image'] ?? "",
      imageThumbnail: json['image_thumbnail'] ?? "",
      basePrice: json['base_price'] ?? 0.0,
      maxCount: json["max_count"] ?? 0,
      isComing: json["is_coming"] ?? false,
      price: json['price'] ?? 0.0,
      rating: json['rating'] ?? 0.0,
      unit: json['unit'] != null
          ? new Category.fromJson(json['unit'])
          : Category(id: 0, name: ""),
      internationalName: json['international_name'] != null
          ? new InternationalName.fromJson(json['international_name'])
          : InternationalName(id: 0, name: "", nameRu: ""),
      manufacturer: json['manufacturer'] != null
          ? new Category.fromJson(json['manufacturer'])
          : Category(id: 0, name: ""),
      category: json['category'] != null
          ? new Category.fromJson(json['category'])
          : Category(id: 0, name: ""),
      analog: json['analog'] == null
          ? <ItemResult>[]
          : List<ItemResult>.from(
              json["analog"].map(
                (x) => ItemResult.fromJson(x),
              ),
            ),
    );
  }
}

class Category {
  int id;
  String name;

  Category({
    required this.id,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
    );
  }
}

class InternationalName {
  int id;
  String name;
  String nameRu;

  InternationalName({
    required this.id,
    required this.name,
    required this.nameRu,
  });

  factory InternationalName.fromJson(Map<String, dynamic> json) {
    return InternationalName(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      nameRu: json['name_ru'] ?? "",
    );
  }
}
