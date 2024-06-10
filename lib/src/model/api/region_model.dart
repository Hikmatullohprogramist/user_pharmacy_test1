import 'dart:convert';

List<RegionModel> regionModelFromJson(String str) => List<RegionModel>.from(
    json.decode(str).map((x) => RegionModel.fromJson(x)));

class RegionModel {
  RegionModel({
    required this.id,
    this.name = "",
    this.parentName = "",
    this.childs = const <RegionModel>[],
    this.coords = const <double>[],
    this.isChoose = false,
    this.isOpen = false,
  });

  int id;
  String name;
  String parentName;
  List<RegionModel> childs;
  bool isOpen;

  bool isChoose;
  List<double> coords;

  factory RegionModel.fromJson(Map<String, dynamic> json) => RegionModel(
        id: json["id"] ?? 0,
        name: json["name"] ?? "",
        parentName: json["parent_name"] ?? "",
        childs: json["childs"] == null
            ? <RegionModel>[]
            : List<RegionModel>.from(
                json["childs"].map((x) => RegionModel.fromJson(x))),
        coords: json["coords"] == null
            ? <double>[]
            : List<double>.from(json["coords"].map((x) => x.toDouble())),
      );
}
