import 'dart:convert';

List<LocationModel> locationModelFromJson(String str) =>
    List<LocationModel>.from(
        json.decode(str).map((x) => LocationModel.fromJson(x)));

class LocationModel {
  LocationModel({
    required this.id,
    required this.name,
    required this.image,
    required this.address,
    required this.phone,
    required this.mode,
    required this.location,
    required this.distance,
    required this.total,
  });

  int id;
  String name;
  String image;
  String address;
  String phone;
  String mode;
  Location location;
  double distance;
  double total;

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
        id: json["id"] ?? 0,
        name: json["name"] ?? "",
        image: json["image"] ?? "",
        address: json["address"] ?? "",
        phone: json["phone"] ?? "",
        mode: json["mode"] ?? "",
        location: json["location"] == null
            ? Location.fromJson({})
            : Location.fromJson(json["location"]),
        distance: json["distance"] ?? 0.0,
        total: json["total"] ?? 0.0,
      );
}

class Location {
  Location({
    required this.type,
    required this.coordinates,
  });

  String type;
  List<double> coordinates;

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        type: json["type"] ?? "",
        coordinates: json["coordinates"] == null
            ? <double>[]
            : List<double>.from(json["coordinates"].map((x) => x.toDouble())),
      );
}
