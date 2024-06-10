class SearchModel {
  SearchModel({
    required this.count,
    required this.next,
    required this.results,
  });

  int count;
  String next;

  List<SearchResult> results;

  factory SearchModel.fromJson(Map<String, dynamic> json) => SearchModel(
        count: json["count"] ?? 0,
        next: json["next"] ?? "",
        results: json["results"] == null
            ? <SearchResult>[]
            : List<SearchResult>.from(
                json["results"].map((x) => SearchResult.fromJson(x)),
              ),
      );
}

class SearchResult {
  int id;
  String name;
  Unit manufacturer;

  SearchResult({
    required this.id,
    required this.name,
    required this.manufacturer,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'],
      name: json['name'],
      manufacturer: json['manufacturer'] != null
          ? Unit.fromJson(json['manufacturer'])
          : Unit.fromJson({}),
    );
  }
}

class Unit {
  int id;
  String name;

  Unit({
    required this.id,
    required this.name,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
    );
  }
}
