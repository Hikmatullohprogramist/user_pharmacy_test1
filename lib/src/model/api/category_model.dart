class CategoryModel {
  int count;
  String next;
  List<CategoryResults> results;

  CategoryModel({
    required this.count,
    required this.next,
    required this.results,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      count: json["count"] ?? 0,
      next: json["next"] ?? "",
      results: json["results"] == null
          ? <CategoryResults>[]
          : List<CategoryResults>.from(
              json["results"].map(
                (x) => CategoryResults.fromJson(x),
              ),
            ),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    data['next'] = this.next;
    data['results'] = this.results.map((v) => v.toJson()).toList();
    return data;
  }
}

class CategoryResults {
  int id;
  String name;
  String image;
  List<Childs> childs;

  CategoryResults({
    required this.id,
    required this.name,
    required this.image,
    required this.childs,
  });

  factory CategoryResults.fromJson(Map<String, dynamic> json) {
    return CategoryResults(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      image: json["image"] ?? "",
      childs: json["childs"] == null
          ? <Childs>[]
          : List<Childs>.from(
              json["childs"].map(
                (x) => Childs.fromJson(x),
              ),
            ),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['image'] = this.image;
    data['childs'] = this.childs.map((v) => v.toJson()).toList();
    return data;
  }
}

class Childs {
  int id;
  String name;
  List<Childs> childs;

  Childs({
    required this.id,
    required this.name,
    required this.childs,
  });

  factory Childs.fromJson(Map<String, dynamic> json) {
    return Childs(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      childs: json["childs"] == null
          ? <Childs>[]
          : List<Childs>.from(
              json["childs"].map(
                (x) => Childs.fromJson(x),
              ),
            ),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['childs'] = this.childs.map((v) => v.toJson()).toList();
    return data;
  }
}
