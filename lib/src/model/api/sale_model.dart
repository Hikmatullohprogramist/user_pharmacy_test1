class BannerModel {
  BannerModel({
    required this.count,
    required this.next,
    required this.results,
  });

  int count;
  String next;
  List<BannerResult> results;

  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
        count: json["count"] ?? 0,
        next: json["next"] ?? "",
        results: json["results"] == null
            ? <BannerResult>[]
            : List<BannerResult>.from(
                json["results"].map(
                  (x) => BannerResult.fromJson(x),
                ),
              ),
      );
}

class BannerResult {
  BannerResult({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.status,
    required this.drug,
    required this.category,
    required this.drugs,
    required this.url,
  });

  int id;
  String name;
  String image;
  String description;
  String url;
  bool status;
  int drug;
  int category;
  List<int> drugs;

  factory BannerResult.fromJson(Map<String, dynamic> json) => BannerResult(
        id: json["id"] ?? 0,
        name: json["name"] ?? "",
        image: json["image"] ?? "",
        description: json["description"] ?? "",
        status: json["status"] ?? false,
        url: json["url"] ?? "",
        drug: json["drug"] ?? 0,
        category: json["category"] ?? 0,
        drugs: json["drugs"] == null
            ? <int>[]
            : List<int>.from(json["drugs"].map((x) => x)),
      );
}
